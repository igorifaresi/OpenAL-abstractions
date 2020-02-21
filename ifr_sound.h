/*
 * resume:
 *     OpenAL audio abstractions.
 * author: 
 *     Igor Fagundes [ifaresi]
 * date: 
 *     10/01/2020
 */

#ifndef IFR_SOUND_H
#define IFR_SOUND_H

#include <AL/al.h>
#include <AL/alc.h>
#include <AL/alut.h>

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "stb_vorbis.c"

//-----------------------------------------------------------------------------

#define ifr_SoundBuffer  ALuint
#define ifr_SoundSpeaker ALuint

#define IFR_AUDIO_GAIN_CONST 0.1f  
#define IFR_AUDIO_PAN_CONST  0.1

//-----------------------------------------------------------------------------

inline ALfloat IFR_AUDIO_GAIN_FUNC(float x, float y)
{
	return 1.0f / ((x*x + y*y) * IFR_AUDIO_GAIN_CONST + 1.0f);
}


inline ALfloat IFR_AUDIO_PAN_FUNCTION(float x)
{
	return ((x > 0.0) ? 1.0 : -1.0) * (pow(1.0 + 1.0/(x * IFR_AUDIO_PAN_CONST)
		, x * IFR_AUDIO_PAN_CONST) - 1) / 1.71828;
}

//-----------------------------------------------------------------------------

/*
 * Play the song linked to speaker. If the speaker was previous paused the 
 * execution will be started in the paused point. If was stoped the execution
 * will be started on begin.
 */
inline void ifr_playSpeaker  (ifr_SoundSpeaker speaker) 
{
	alSourcePlay(speaker);
}

/*
 * Pause speaker audio execution.
 */
inline void ifr_pauseSpeaker (ifr_SoundSpeaker speaker)
{
	alSourcePause(speaker);
}

/*
 * Stop speaker audio execution.
 */
inline void ifr_stopSpeaker  (ifr_SoundSpeaker speaker)
{
	alSourceStop(speaker);
}

/*
 * Play the song linked to speaker from begin.
 */
inline void ifr_rewindSpeaker(ifr_SoundSpeaker speaker)
{
	alSourceRewind(speaker);
}

//-----------------------------------------------------------------------------

/*
 * Check OpenAL error, and if an error has detected, print OpenAL error code in
 * STDERR with context details.
 * params: 
 *     details - details about context of error verification.
 */
void ifr_checkAlError(char* details)
{
	//check OpenAL error status
	ALenum error = alGetError();
	if (error != AL_NO_ERROR)
	{
		fprintf(stderr,"OpenAl error: %d on %s\n", (int)error, details);
		error = alGetError();
	}
}

/*
 * Init audio library.
 */
void ifr_initAudioLib()
{
	//open default device
	ALCdevice *device;
	device = alcOpenDevice(NULL);
	if (!device)
		fprintf(stderr,"Default device not found\n");
	ifr_checkAlError("device check");

	//creating the current context
	ALCcontext *context;
	context = alcCreateContext(device, NULL);
	if (!alcMakeContextCurrent(context))
		fprintf(stderr,"Failed to create the main context");
	ifr_checkAlError("context creation");

	//defing the listener
	alListener3f(AL_POSITION, 0.0f, 0.0f, 0.0f);
	ifr_checkAlError("listener creation");
}

/*
 * Returns a array of `char*` that represents the names of each audio device
 * detected by OpenAL in the moment of function call.
 * params:
 *     qnt - the adress of a integer. The procedure will pass for this variable
 *     the quantity of audio devices.
 */
char** ifr_listAudioDevices(int* qnt)
{
	char** list = NULL;
	ALboolean enumeration;
	enumeration = alcIsExtensionPresent(NULL, "ALC_ENUMERATION_EXT");
	if (enumeration == AL_TRUE)
	{
		char* devices = (char*)alcGetString(NULL, ALC_DEVICE_SPECIFIER);

		//get device qnt
		int device_qnt = 0;
		int i = 0;
		int j = 0;
		while (devices[i] != '\0')
		{
			while (devices[i] != '\0')
				i++;
			i++;
			device_qnt++;
		}

		//get device names sizes
		int sizes[device_qnt];
		i = 0;
		j = 0;
		while (devices[i] != '\0')
		{
			sizes[j] = strlen(&devices[i]);
			while (devices[i] != '\0')
				i++;
			i++;
			j++;
		}

		//get the device list
		list = (char**)malloc(sizeof(char*) * device_qnt);
		i = 0;
		j = 0;
		while (devices[i] != '\0')
		{
			list[j] = (char*)strdup(&devices[i]);
			while (devices[i] != '\0')
				i++;
			i++;
			j++;
		}

		*qnt = device_qnt;
	}	
	else
	{
		list = (char**)malloc(sizeof(char*) * 1);
		list[0] = (char*)strdup((char*)alcGetString(NULL, ALC_DEVICE_SPECIFIER));
		*qnt = (list[0] != NULL) ? 1 : 0;
	}
	return list;
}

/*
 * Change OpenAL current audio device.
 * params:
 *     device_name - the name of new current device.
 */
void ifr_changeAudioDevice(char* device_name)
{
	//open default device
	ALCdevice *device;
	device = alcOpenDevice(device_name);
	if (!device)
		fprintf(stderr,"Device not found\n");
	ifr_checkAlError("device check");

	//creating the current context
	ALCcontext *context;
	context = alcCreateContext(device, NULL);
	if (!alcMakeContextCurrent(context))
		fprintf(stderr,"Failed to create the main context");
	ifr_checkAlError("context creation");
}

/*
 * Load a array of OGG audio files, and pass the generated sound buffers.
 * params:
 *     names - the paths of audio files.
 *     qnt - quantity of files.
 *     buffers - the procedure pass will pass the generated buffers
 *     for this variable.
 */
void ifr_loadOGGAudioBuffers(char* names[], int qnt, ifr_SoundBuffer* buffers)
{
	for (int i = 0; i < qnt; i++)
	{
		//creating a song buffer
		alGenBuffers((ALuint)1, &buffers[i]);
		ifr_checkAlError("creation a new song buffer");
		ALsizei size, freq;
		ALenum  format, channels;
		ALvoid* data;
		size = stb_vorbis_decode_filename(names[i] , &channels
                                                           , &freq
                                                           , (short**)&data);
		if (channels == 1) 
		{
			format = AL_FORMAT_MONO16;
			size = size * 2;
		} 
		else
		{
			format = AL_FORMAT_STEREO16;
			size = size * 4;
		}
		alBufferData(buffers[i], format, data, size, freq);
		ifr_checkAlError("defining a new song buffer");

		free(data);
	}
}

/*
 * Load a array of WAVE audio files, and pass the generated sound buffers.
 * params:
 *     names - the paths of audio files.
 *     qnt - quantity of files.
 *     buffers - the procedure pass will pass the generated buffers
 *     for this variable.
 */
void ifr_loadWAVEAudioBuffers(char* names[], int qnt, ifr_SoundBuffer* buffers)
{
	for (int i = 0; i < qnt; i++)
	{
		//creating a song buffer
		alGenBuffers((ALuint)1, &buffers[i]);
		ifr_checkAlError("creation a new song buffer");
		ALsizei size, freq;
		ALboolean loop;
		ALenum format;
		ALvoid *data;
		ALbyte *tmp = (ALbyte*)names[i]; 
		alutLoadWAVFile(tmp, &format, &data, &size, &freq, &loop);
		alBufferData(buffers[i], format, data, size, freq);
		ifr_checkAlError("defining a new song buffer");

		free(data);
	}
}


/*
 * Delete a array of sound buffers.
 * params:
 *     init - initial index in array for deletion.
 *     qnt - quantity of elements for delete.
 *     buffers - the buffers for delete.
 */
void ifr_deleteAudioBuffers(int init, int qnt, ifr_SoundBuffer* buffers)
{
	for (int i = 0; i < qnt; i++)
	{
		alDeleteBuffers(1, &buffers[i + init]);
		ifr_checkAlError("deleting audio buffers");
	}
}

/*
 * Init a ifr_SoundSpeaker.
 * params:
 *     speaker - the speaker for initialize.
 *     loop - if `TRUE`, the speaker will loop the song when the song ends.
 */
void ifr_initSpeaker(ifr_SoundSpeaker* speaker, ALboolean loop)
{
	//init the speaker
	alGenSources((ALuint)1, (ALuint*)speaker);
	alSourcei((ALuint)*speaker, AL_LOOPING, loop);
	alSourcef((ALuint)*speaker, AL_ROLLOFF_FACTOR, 0.0f);
	alSourcei((ALuint)*speaker, AL_SOURCE_RELATIVE, AL_TRUE);
	ifr_checkAlError("source creation");
}

/*
 * Delete a ifr_SoundSpeaker.
 * params:
 *     speaker - speaker for delete.
 */
void ifr_deleteSpeaker(ifr_SoundSpeaker* speaker)
{
	alDeleteSources(1, speaker);
	ifr_checkAlError("deleting source");
}

/*
 * Update a ifr_SoundSpeaker 2d position.
 * params:
 *     speaker - speaker for update.
 *     pos - the vector of new 2d speaker position.
 *     volum - a gain modificator.
 */
void ifr_updateSpeaker(ifr_SoundSpeaker speaker, float pos_x, float pos_y, float volum)
{
	//calculate pan
	alSource3f(speaker, AL_POSITION
                          , IFR_AUDIO_PAN_FUNCTION(pos_x)
                          , IFR_AUDIO_PAN_FUNCTION(pos_y)
                          , 0.1f);
	
	//calculate gain
	alSourcef(speaker, AL_GAIN, IFR_AUDIO_GAIN_FUNC(pos_x, pos_y) * volum);
}

/*
 * Bind a ifr_SoundBuffer to ifr_SoundSpeaker.
 */
void ifr_loadSongToSpeaker(ifr_SoundSpeaker speaker, ifr_SoundBuffer buffer)
{
	//bind song into speaker
	alSourcei(speaker, AL_BUFFER, buffer);
	ifr_checkAlError("binding song to source");
}

#endif
