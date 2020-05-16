-- TODO: add nesting documents
Default = {
    Document = function(_width, _height)
        return {
            head = { 
                width = _width,
                height = _height,
                version = "1.1",
                xmlns = "http://www.w3.org/2000/svg",
            },
            body = {},
            patterns = {},
            add = function(self, _tag)
                -- table.insert(self.body, { tag = _tag })
                self.body[(#self.body + 1)] = { tag = _tag }
                return self.patterns[_tag].generateNew(self.body[#self.body])
            end,
            addPattern = function(self, name, pattern)
                self.patterns[name] = pattern
            end,
            generate = function(self)
                local str = "<svg "..
                    "width=\'"..self.head.width.."\' "..
                    "height=\'"..self.head.height.."\' "..
                    "version=\'"..self.head.version.."\' "..
                    "xmlns=\'"..self.head.xmlns.."\'>\n"
                for key,value in pairs(self.body) do
                    if self.patterns[value.tag] ~= nil then
                        str = str.."\t"..self.patterns[value.tag].toString(value).."\n"
                    end
                end
                return str.."</svg>"
            end,
        }
    end,
}

-- TODO:
--    remove fix style attributions, in other words: create a generic way to apply style changes
BasicShapes = {
    Circle = {
        toString = function(value)
            local str = "<circle cx=\'"..value.cx.."\' cy=\'"..value.cy.."\' r=\'"..value.r.."\'"
            if value.stroke ~= nil then
                str = str.." stroke=\'"..value.stroke.."\'"
            end
            if value.fill ~= nil then
                str = str.." fill=\'"..value.fill.."\'"
            end
            if value.stroke_width ~= nil then
                str = str.." stroke-width="..value.stroke_width
            end
            return str.." />"
        end,
        generateNew = function(value)
            value.cx = 0;
            value.cy = 0;
            value.r  = 0;
            return {
                ref = value,
                setRect = function(self, posX, posY, radious)
                    self.ref.cx = posX
                    self.ref.cy = posY
                    self.ref.r  = radious
                    return self
                end,
                setFill = function(self, v)
                    self.ref.fill = v
                    return self
                end,
                setStroke = function(self, v)
                    self.ref.stroke = v
                    return self
                end,
                setStrokeWidth = function(self, v)
                    self.ref.stroke_width = v
                    return self
                end,
            }
        end
    },
    Rectangle = {
        toString = function(value)
            local str = "<rect x=\'"..value.x.."\' y=\'"..value.y..
                        "\' width=\'"..value.width.."\' height=\'"..value.height.."\'"
            if value.rx ~= nil then
                str = str.." rx=\'"..value.rx.."\'"
            end
            if value.ry ~= nil then 
                str = str.." ry=\'"..value.ry.."\'"
            end
            if value.stroke ~= nil then
                str = str.." stroke=\'"..value.stroke.."\'"
            end
            if value.fill ~= nil then
                str = str.." fill=\'"..value.fill.."\'"
            end
            if value.stroke_width ~= nil then
                str = str.." stroke-width="..value.stroke_width
            end
            return str.." />"
        end,
        generateNew = function(value)
            value.x = 0;
            value.y = 0;
            value.width = 0;
            value.height = 0;
            return {
                ref = value,
                setRect = function(self, posX, posY, sizeX, sizeY)
                    self.ref.x = posX
                    self.ref.y = posY
                    self.ref.width = sizeX
                    self.ref.height = sizeY
                    return self
                end,
                setRoundedCorners = function(self, roundX, roundY)
                    self.ref.rx = roundX
                    self.ref.ry = roundY
                    return self
                end,
                setFill = function(self, v)
                    self.ref.fill = v
                    return self
                end,
                setStroke = function(self, v)
                    self.ref.stroke = v
                    return self
                end,
                setStrokeWidth = function(self, v)
                    self.ref.stroke_width = v
                    return self
                end,
            }
        end
    },
    Line = {
        toString = function(value)
            local str = "<line x1=\'"..value.x1.."\' y1=\'"..value.y1..
                        "\' x2=\'"..value.x2.."\' y2=\'"..value.y2.."\'"
            if value.stroke ~= nil then
                str = str.." stroke=\'"..value.stroke.."\'"
            end
            if value.fill ~= nil then
                str = str.." fill=\'"..value.fill.."\'"
            end
            if value.stroke_width ~= nil then
                str = str.." stroke-width="..value.stroke_width
            end
            return str.." />"
        end,
        generateNew = function(value)
            value.x1 = 0;
            value.y1 = 0;
            value.x2 = 0;
            value.y2 = 0;
            value.stroke = "black"
            return {
                ref = value,
                setPoints = function(self, posX1, posY1, posX2, posY2)
                    self.ref.x1 = posX1
                    self.ref.y1 = posY1
                    self.ref.x2 = posX2
                    self.ref.y2 = posY2
                    return self
                end,
                setRoundedCorners = function(self, roundX, roundY)
                    self.ref.rx = roundX
                    self.ref.ry = roundY
                    return self
                end,
                setFill = function(self, v)
                    self.ref.fill = v
                    return self
                end,
                setStroke = function(self, v)
                    self.ref.stroke = v
                    return self
                end,
                setStrokeWidth = function(self, v)
                    self.ref.stroke_width = v
                    return self
                end,
            }
        end
    },
    Polyline = {
        toString = function(value)
            local str = "<polyline points=\'"
            for key,point in pairs(value.points) do
                str = str..point[1]..", "..point[2].." "
            end
            str = str.."\'"
            if value.stroke ~= nil then
                str = str.." stroke=\'"..value.stroke.."\'"
            end
            if value.fill ~= nil then
                str = str.." fill=\'"..value.fill.."\'"
            end
            if value.stroke_width ~= nil then
                str = str.." stroke-width="..value.stroke_width
            end
            return str.." />"
        end,
        generateNew = function(value)
            value.points = {}
            value.fill = "none"
            value.stroke = "black"
            return {
                ref = value,
                addPoint = function(self, point)
                    self.ref.points[#self.ref.points + 1] = point
                    return self
                end,
                addPoints = function(self, points)
                    for key,point in pairs(points) do
                        self.ref.points[#self.ref.points + 1] = point
                    end
                    return self
                end,
                setFill = function(self, v)
                    self.ref.fill = v
                    return self
                end,
                setStroke = function(self, v)
                    self.ref.stroke = v
                    return self
                end,
                setStrokeWidth = function(self, v)
                    self.ref.stroke_width = v
                    return self
                end,
            }
        end
    },
    Polygon = {
        toString = function(value)
            local str = "<polygon points=\'"
            for key,point in pairs(value.points) do
                str = str..point[1]..", "..point[2].." "
            end
            str = str.."\'"
            if value.stroke ~= nil then
                str = str.." stroke=\'"..value.stroke.."\'"
            end
            if value.fill ~= nil then
                str = str.." fill=\'"..value.fill.."\'"
            end
            if value.stroke_width ~= nil then
                str = str.." stroke-width="..value.stroke_width
            end
            return str.." />"
        end,
        generateNew = function(value)
            value.points = {}
            value.fill = "none"
            value.stroke = "black"
            return {
                ref = value,
                addPoint = function(self, point)
                    self.ref.points[#self.ref.points + 1] = point
                    return self
                end,
                addPoints = function(self, points)
                    for key,point in pairs(points) do
                        self.ref.points[#self.ref.points + 1] = point
                    end
                    return self
                end,
                setFill = function(self, v)
                    self.ref.fill = v
                    return self
                end,
                setStroke = function(self, v)
                    self.ref.stroke = v
                    return self
                end,
                setStrokeWidth = function(self, v)
                    self.ref.stroke_width = v
                    return self
                end,
            }
        end
    },
    Path = {
        toString = function(value)
            local str = "<path d=\' M "..value.M[1].." "..value.M[2]
            if value.Q ~= nil then
                for key,it in pairs(value.Q) do
                    str = str.." Q "..it[1].." "..it[2].." "..it[3].." "..it[4]
                end
            end
            if value.L ~= nil then
                for key,it in pairs(value.L) do
                    str = str.." L "..it[1].." "..it[2]
                end
            end
            str = str.."\'"
            if value.stroke ~= nil then
                str = str.." stroke=\'"..value.stroke.."\'"
            end
            if value.fill ~= nil then
                str = str.." fill=\'"..value.fill.."\'"
            end
            if value.stroke_width ~= nil then
                str = str.." stroke-width="..value.stroke_width
            end
            return str.." />"
        end,
        generateNew = function(value)
            value.M = {0,0}
            value.fill = "none"
            value.stroke = "black"
            return {
                ref = value,
                moveTo = function(self, posX, posY)
                    self.ref.M = {posX, posY}
                    return self
                end,
                addQuadradicBezierCurve = function(self, posX1, posY1, posX2, posY2)
                    if self.ref.Q == nil then
                        self.ref.Q = {}
                    end
                    self.ref.Q[#self.ref.Q + 1] = {posX1, posY1, posX2, posY2}
                    return self
                end,
                addLine = function(self, posX, posY)
                    if self.ref.L == nil then
                        self.ref.L = {}
                    end
                    self.ref.L[#self.ref.L + 1] = {posX, posY}
                    return self
                end,
                setFill = function(self, v)
                    self.ref.fill = v
                    return self
                end,
                setStroke = function(self, v)
                    self.ref.stroke = v
                    return self
                end,
                setStrokeWidth = function(self, v)
                    self.ref.stroke_width = v
                    return self
                end,
                set = function(self, attribute, value)
                    if self.ref._ == nil then
                        self.ref._ = ""
                    end
                    self.ref._ = self.ref._.." "..attribute.."=\'"..value.."\'"
                    return self
                end
            }
        end
    },
    Document = function(_width, _height)
        local doc = Default.Document(_width, _height)
        doc:addPattern("circle", BasicShapes.Circle)
        doc:addPattern("rectangle", BasicShapes.Rectangle)
        doc:addPattern("line", BasicShapes.Line)
        doc:addPattern("polyline", BasicShapes.Polyline)
        doc:addPattern("polygon", BasicShapes.Polygon)
        doc:addPattern("path", BasicShapes.Path)
        return doc
    end,
}

-- Some tests

local doc = BasicShapes.Document(1000,1000)
doc:add("circle"):setRect(100,100,50)
doc:add("rectangle"):setRect(100,100,100,100)
doc:add("line"):setPoints(100,100,200,200)
doc:add("polyline"):addPoints({{0,0},{100,100},{400,10},{0,0}})
doc:add("polygon"):addPoints({{0,0},{100,100},{400,10},{0,0}})
doc:add("path"):moveTo(10,80):addQuadradicBezierCurve(95,10,180,80):addLine(140,600)
print(doc:generate())