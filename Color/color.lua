local Color = {}
Color.__isColor = true
Color.__version = '1.0.1'

local colorMt = {}

local function clamp(val)
    return math.min(1, math.max(0, val or 0))
end
local function clampMultiple(a, b, c, d)
    return clamp(a), clamp(b), clamp(c), clamp(d)
end

function Color.new(...)
    local col = setmetatable({
        r = 0,
        g = 0,
        b = 0,
        a = 1
    }, Color)

    local argNum = select('#', ...)
    if argNum == 1 and type(...) == 'table' then
        -- Color.new(colorTable)
        local arg = ...
        col.r = clamp(arg.r or col.r)
        col.g = clamp(arg.g or col.g)
        col.b = clamp(arg.b or col.b)
        col.a = clamp(arg.a or col.a)
    elseif argNum == 3 then
        -- Color.new(r, g, b)
        col.r, col.g, col.b = clampMultiple(...)
    elseif argNum == 4 then
        col.r, col.g, col.b, col.a = clampMultiple(...)
    end
    
    return col
end
colorMt.__call = function(_, ...) return Color.new(...) end

local function normalizeName(str)
    return str:sub(1, 1):upper() .. str:sub(2, -1):lower()
end

local playerColors = {
    ['white']  = Color.new(1, 1, 1),
    ['brown']  = Color.new(0.443, 0.231, 0.09),
    ['red']    = Color.new(0.856, 0.1, 0.094),
    ['orange'] = Color.new(0.956, 0.392, 0.113),
    ['yellow'] = Color.new(0.905, 0.898, 0.172),
    ['green']  = Color.new(0.192, 0.701, 0.168),
    ['teal']   = Color.new(0.129, 0.694, 0.607),
    ['blue']   = Color.new(0.118, 0.53, 1),
    ['purple'] = Color.new(0.627, 0.125, 0.941),
    ['pink']   = Color.new(0.96, 0.439, 0.807),
    ['grey']   = Color.new(0.5, 0.5, 0.5),
    ['black']  = Color.new(0.25, 0.25, 0.25),
}
colorMt.__index = function(_, colorName)
    if type(colorName) == 'string' then
        colorName = colorName:lower()
        if playerColors[colorName] then
            return playerColors[colorName]:copy()
        end
    end
    return nil
end

Color.list = {}
for colorName in pairs(playerColors) do
    table.insert(Color.list, normalizeName(colorName))
end

function Color.Add(name, color)
    name = name:lower()
    assert(not playerColors[name], 'Color ' .. name .. ' already defined')
    assert(color.__isColor, tostring(color) .. ' is not a Color instance')
    playerColors[name] = color
    table.insert(Color.list, normalizeName(name))
end

function Color.fromString(strColor)
    local color = assert(playerColors[strColor:lower()], strColor .. ' is not a valid color string')
    return color:copy()
end

function Color.fromHex(hexColor)
    local rStr, gStr, bStr, aStr = hexColor:match('^#?(%x%x)(%x%x)(%x%x)(%x?%x?)$')
    
    assert(rStr and gStr and bStr and (aStr:len() == 0 or aStr:len() == 2), tostring(hexColor) .. ' is not a valid color hex string')

    return Color(
        tonumber(rStr, 16)/255, 
        tonumber(gStr, 16)/255, 
        tonumber(bStr, 16)/255,
        (tonumber(aStr, 16) or 255)/255
    )
end

function Color:get()
    return self.r, self.g, self.b, self.a
end

function Color:toHex(includeAlpha)
    if includeAlpha then
        return ('%02x%02x%02x%02x'):format(
            self.r*255,
            self.g*255,
            self.b*255,
            self.a*255
        )
    else
        return ('%02x%02x%02x'):format(
            self.r*255,
            self.g*255,
            self.b*255
        )
    end
end

function Color:toString(tolerance)
    for name, color in pairs(playerColors) do
        if self:equals(color, tolerance) then
            return normalizeName(name)
        end
    end
    return nil
end

do
    local remap = {'r', 'g', 'b', 'a'}
    function Color:__index(k)
        k = remap[k] or k
        return rawget(self, k) or Color[k]
    end
    function Color:__newindex(k, v)
        k = remap[k] or k
        return rawset(self, k, v)
    end
end

function Color:set(r, g, b, a)
    self.r = clamp(r or self.r)
    self.g = clamp(g or self.g)
    self.b = clamp(b or self.b)
    self.a = clamp(a or self.a)
end

function Color:setAt(key, value)
    self[key] = clamp(value)
    return self
end

function Color:equals(other, margin)
    margin = margin or 1e-2
    local diff = math.abs(self.r - other.r)
        + math.abs(self.g - other.g)
        + math.abs(self.b - other.b)
        + math.abs(self.a - other.a)
    return diff <= margin
end
Color.__eq = Color.equals

function Color:copy()
    return Color(self:get())
end

function Color:dump(prefix)
    local name = self:toString()
    local str = (self.a < 1) and '%s%s{ r = %f, g = %f, b = %f, a = %f }' or '%s%s{ r = %f, g = %f, b = %f }'
    return (str:format(
        prefix and (prefix .. ': ') or '',
        name and (name .. ' ') or '',
        self:get()
        -- cut trailing zeroes from numbers
    ):gsub('%.0+([ ,])', '%1'):gsub('%.(%d-)0+([ ,])', '.%1%2'))
end

function Color:__tostring()
    return self:dump('Color')
end

function Color:lerp(other, t)
    local mid = self:copy()
    mid.r = mid.r + (other.r - self.r)*t
    mid.g = mid.g + (other.g - self.g)*t
    mid.b = mid.b + (other.b - self.b)*t
    mid.a = mid.a + (other.a - self.a)*t
    return mid
end

setmetatable(Color, colorMt)

return Color