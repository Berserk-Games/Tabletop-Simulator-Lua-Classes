local Vector = {}
Vector.__isVector = true
Vector.__version = '1.0.1'

function Vector.isVector(arg)
    return type(arg) == 'table' and arg.__isVector or false
end

local function ensureIsVector(arg)
    if Vector.isVector(arg) then
        return arg
    end
    return Vector.new(arg)
end

local function typesOf(...)
    local types = {...}
    for k, v in ipairs(types) do
        types[k] = type(v)
    end
    return types
end

function Vector.new(...)
    local vec = setmetatable({
        x = 0,
        y = 0,
        z = 0
    }, Vector)
    
    local argNum = select('#', ...)
    if argNum == 3 then
        -- Vector.new(x, y, z)
        vec.x, vec.y, vec.z = ...
    elseif argNum == 1 and type(...) == 'table' then
        -- Vector.new(table)
        local src = ...
        vec.x = src.x or src[1] or vec.x
        vec.y = src.y or src[2] or vec.y
        vec.z = src.z or src[3] or vec.z
    elseif argNum > 0 then
        error(('Vector.new: (num, num, num) or (table) expected, got (%s)'):format(table.concat(typesOf(...), ', ')))
    end
    
    return vec
end
setmetatable(Vector, {__call = function(_, ...) return Vector.new(...) end})

do
    local remap = {'x', 'y', 'z'}
    function Vector:__index(k)
        k = remap[k] or k
        return rawget(self, k) or Vector[k]
    end
    function Vector:__newindex(k, v)
        k = remap[k] or k
        return rawset(self, k, v)
    end
end

function Vector:setAt(k, v)
    self[k] = v
    return self
end

function Vector:set(x, y, z)
    self.x = x or self.x
    self.y = y or self.y
    self.z = z or self.z
    return self
end

function Vector:get()
    return self.x, self.y, self.z
end

function Vector:copy()
    return Vector(self)
end

function Vector:add(other)
    other = ensureIsVector(other)
    self.x = self.x + other.x
    self.y = self.y + other.y
    self.z = self.z + other.z
    return self
end

function Vector.__add(v1, v2)
    v1 = ensureIsVector(v1)
    return v1:copy():add(v2)
end

function Vector:sub(other)
    other = ensureIsVector(other)
    self.x = self.x - other.x
    self.y = self.y - other.y
    self.z = self.z - other.z
    return self
end

function Vector.__sub(v1, v2)
    v1 = ensureIsVector(v1)
    return v1:copy():sub(v2)
end

function Vector:dot(other)
    other = ensureIsVector(other)
    return self.x * other.x
        + self.y * other.y
        + self.z * other.z
end

function Vector:sqrMagnitude()
    return self:dot(self)
end

function Vector:magnitude()
    return math.sqrt(self:dot(self))
end

function Vector:scale(...)
    local sx, sy, sz
    
    local argNum = select('#', ...)
    if argNum == 1 then
        local arg = ...
        if type(arg) == 'number' then
            -- vec:scale(number)
            sx, sy, sz = arg, arg, arg
        else
            -- vec:scale(vector)
            arg = ensureIsVector(arg)
            sx, sy, sz = arg:get()
        end
    elseif argNum == 3 then
        -- vec:scale(x, y, z)
        sx, sy, sz = ...
        sx = sx or 1
        sy = sy or 1
        sz = sz or 1
    end
    
    self.x = self.x * sx
    self.y = self.y * sy
    self.z = self.z * sz
    return self
end

function Vector.__mul(val1, val2)
    if type(val1) == 'number' then
        val1, val2 = val2, val1
    end
    val1 = ensureIsVector(val1)
    return val1:copy():scale(val2)
end

function Vector:sqrDistance(other)
    other = ensureIsVector(other)
    local dx = self.x - other.x
    local dy = self.y - other.y
    local dz = self.z - other.z
    return dx*dx + dy*dy + dz*dz
end

function Vector:distance(other)
    other = ensureIsVector(other)
    return math.sqrt(self:sqrDistance(other))
end

function Vector:equals(other, margin)
    other = ensureIsVector(other)
    margin = margin or 1e-3
    return self:sqrDistance(other) <= margin
end

Vector.__eq = Vector.equals

function Vector:string(prefix)
    prefix = prefix and (prefix .. ': ') or ''
    return (('%s{ %f, %f, %f }'):format(
        prefix,
        self.x,
        self.y,
        self.z
        -- cut trailing zeroes from numbers
    ):gsub('%.0+([ ,])', '%1'):gsub('%.(%d-)0+([ ,])', '.%1%2'))
end

function Vector:__tostring()
    return self:string('Vector')
end

function Vector:angle(other)
    other = ensureIsVector(other)
    local cosAng = self:dot(other) / (self:magnitude() * other:magnitude())
    return math.deg(math.acos(cosAng))
end

function Vector:clamp(maxLen)
    local len = self:magnitude()
    if len <= maxLen then
        return self
    end
    local factor = maxLen/len
    return self:scale(factor)
end

function Vector:cross(other)
    other = ensureIsVector(other)
    return Vector(
        self.y * other.z - self.z * other.y,
        self.z * other.x - self.x * other.z,
        self.x * other.y - self.y * other.x
    )
end

function Vector.between(from, to)
    to = ensureIsVector(to)
    return to - from
end

function Vector:lerp(target, t)
    target = ensureIsVector(target)
    return self:between(target):scale(t):add(self)
end

function Vector:moveTowards(target, maxDist)
    target = ensureIsVector(target)
    local delta = self:between(target):clamp(maxDist)
    return self:add(delta)
end

function Vector:normalize()
    local sqrLen = self:sqrMagnitude()
    if sqrLen == 1 or sqrLen == 0 then
        return self
    end
        
    return self:scale(1/math.sqrt(sqrLen))
end

function Vector:normalized()
    return self:copy():normalize()
end

function Vector:project(other)
    other = ensureIsVector(other)
    if other:sqrMagnitude() ~= 1 then
        other = other:normalized()
    end
    local scalar = self:dot(other)
    return self:set(other:get()):scale(scalar)
end

do
    -- skew symmetric cross product
    local function sscp(v)
        return { Vector(   0,  -v.z,  v.y ),
                 Vector(  v.z,   0,  -v.x ),
                 Vector( -v.y,  v.x,   0  ) }
    end
    
    --[[
    local function mDump(m)
        return ('{ %s,\n  %s,\n  %s }'):format(
            m[1], m[2], m[3]
        )
    end
    --]]
    
    local function qMult(x, y, z, w, factor)
        return x*factor, y*factor, z*factor, w*factor
    end
    
    local function qNormalize(x, y, z, w)
        local norm = math.sqrt(x*x + y*y + z*z + w*w)
        return qMult(x, y, z, w, 1/norm)
    end
    
    -- interpolate quaternion
    local function qSlerp(x, y, z, w, t)
        local dot = w
        if dot > 0.0005 then
            return qNormalize(t*x, t*y, t*z, 1 + t*w - t)
        end
        
        local th0 = math.acos(dot)
        local th = th0*t
        local sth = math.sin(th)
        local sth0 = math.sin(th0)
        
        local s1 = sth/sth0
        local s0 = math.cos(th) - dot*s1

        return qMult(x, y, z, w + s0, s1)
    end
        
    local function matrixToQuat(m, scale)
        local w = math.sqrt(1.0 + m[1].x + m[2].y + m[3].z)/2;
        local x = (m[3].y - m[2].z) / (w * 4)
        local y = (m[1].z - m[3].x) / (w * 4)
        local z = (m[2].x - m[1].y) / (w * 4)
        if scale then
            x, y, z, w = qSlerp(x, y, z, w, scale)
        end
        return x, y, z, w
    end
    
    local function quatToMatrix(x, y, z, w)
        return {
            Vector(1-2*y*y-2*z*z, 2*x*y-2*z*w, 2*x*z+2*y*w),
            Vector(2*x*y+2*z*w, 1-2*x*x-2*z*z, 2*y*z-2*x*w),
            Vector(2*x*z-2*y*w, 2*y*z+2*x*w, 1-2*x*x-2*y*y)
        }
    end
    
    -- scale rotation matrix
    local function mInterp(m, factor)
        return quatToMatrix(matrixToQuat(m, factor))
    end
    
    local function mScale(m, factor)
        for _, row in ipairs(m) do
            row:scale(factor)
        end
        return m
    end
    
    -- apply a rotation matrix to vector
    local function mApply(m, v)
        v:set(m[1]:dot(v), m[2]:dot(v), m[3]:dot(v))
        return v
    end
    
    -- matrix multiplication
    local function mMult(m1, m2)
        local trans = {
            Vector(m2[1].x, m2[2].x, m2[3].x),
            Vector(m2[1].y, m2[2].y, m2[3].y),
            Vector(m2[1].z, m2[2].z, m2[3].z),
        }
        local result = { Vector(), Vector(), Vector() }
        for row = 1, 3 do
            result[row]:set( m1[row]:dot(trans[1]), m1[row]:dot(trans[2]), m1[row]:dot(trans[3]) )
        end
        return result
    end
    
    -- matrix addition
    local function mAdd(m1, m2)
        for row = 1, 3 do
            m1[row]:add(m2[row])
        end
        return m1
    end
    
    -- eye matrix
    local function mUnit()
        return { Vector(1, 0, 0),
                 Vector(0, 1, 0),
                 Vector(0, 0, 1) }
    end
    
    local function rotationMatrix(from, to)
        local sscross = sscp(from:cross(to))
        local dot = from:dot(to)
        -- maybe skew one of them instead to not bother the user
        -- or include a bool/etc result
        assert(math.abs(dot + 1) > 0.05, 'Vectors too close to opposite of each other')
        local factor = 1 / (1 + dot)
        local ss2scaled = mScale(mMult(sscross, sscross), factor)
        return mAdd(mAdd(mUnit(), sscross), ss2scaled)
    end
    
    local function mTrail(m)
        return m[1].x + m[2].y + m[3].z
    end
    
    -- Amount of rotation in degrees
    local function mDeg(m)
        return math.deg(math.acos((mTrail(m)-1)/2))
    end    
    
    function Vector:rotateTowardsUnit(unitTarget, maxDelta)
        local m = rotationMatrix(self, unitTarget)
        if maxDelta then
            local angle = mDeg(m)
            if angle > maxDelta then
                m = mInterp(m, maxDelta/angle)
            end
        end
        return mApply(m, self)
    end
    
    function Vector:rotateTowards(target, maxDelta)
        local len = self:magnitude()
        return self:normalize()
            :rotateTowardsUnit(target:normalized(), maxDelta)
            :scale(len)
    end
    
    function Vector:reflect(planeNormal)
        local x, y, z = planeNormal:normalized():get()
        local reflectMatrix = {
            Vector(1-2*x*x, -2*x*y, -2*x*z),
            Vector(-2*x*y, 1-2*y*y, -2*y*z),
            Vector(-2*x*z, -2*y*z, 1-2*z*z)
        }
        return mApply(reflectMatrix, self)
    end
    
    local function basicRotationMatrix(axis, angle)
        angle = math.rad(angle)
        local sin, cos = math.sin(angle), math.cos(angle)
        
        if axis == 'x' then
            return {
                Vector( 1,   0,    0  ),
                Vector( 0,  cos, -sin ),
                Vector( 0,  sin,  cos )
            }
        elseif axis == 'y' then
            return {
                Vector( cos,  0,  sin ),
                Vector(  0,   1,   0  ),
                Vector(-sin,  0,  cos )
            }
        elseif axis == 'z' then
            return {
                Vector( cos, -sin,  0 ),
                Vector( sin,  cos,  0 ),
                Vector(  0,    0,   1 )
            }
        end
    end    
    
    function Vector:rotateOverAxis(axis, angle)
        return mApply(basicRotationMatrix(axis, angle), self)
    end
    
    function Vector:rotateOverVector(vec)
        vec = ensureIsVector(vec)
        return self
            :rotateOverAxis('z', vec.z)
            :rotateOverAxis('x', vec.x)
            :rotateOverAxis('y', vec.y)
    end
    
    function Vector:rotateOver(axisOrVector, angle)
        if type(axisOrVector) == 'string' then
            return self:rotateOverAxis(axisOrVector, angle)
        else
            return self:rotateOverVector(axisOrVector)
        end
    end
end

function Vector.max(v1, v2)
    return Vector(
        math.max(v1.x, v2.x),
        math.max(v1.y, v2.y),
        math.max(v1.z, v2.z)
    )
end

function Vector.min(v1, v2)
    return Vector(
        math.min(v1.x, v2.x),
        math.min(v1.y, v2.y),
        math.min(v1.z, v2.z)
    )
end

function Vector:inverse()
    return self:set(-1*self.x, -1*self.y, -1*self.z)
end

function Vector:reciprocal()
    return self:set(1/self.x, 1/self.y, 1/self.z)
end

function Vector:projectOnPlane(planeNormal)
    local _, _, planeShadow = planeNormal:orthoNormalize(self)
    if self:angle(planeShadow) > 90 then
        planeShadow:inverse()
    end
    return self:project(planeShadow)
end

function Vector:orthoNormalize(binormalPlanar)
    
    -- if no vector was supplied, create an arbitrary one
    if not binormalPlanar then
        binormalPlanar = Vector(1, 0, 0)
        if self:angle(binormalPlanar) < 10 then
            binormalPlanar = Vector(0, 0, 1)
        end
    elseif binormalPlanar:sqrMagnitude() ~= 1 then
        binormalPlanar = binormalPlanar:normalized()
    end
    
    local base = self:normalized()
    local normal = base:cross(binormalPlanar:normalized())
    local binormal = base:cross(normal)
   
    return base, normal, binormal
end

function Vector:heading(axis)
    if not axis then
        return self:heading('x'), self:heading('y'), self:heading('z')
    end
    
    local c1, c2
    
    if axis == 'x' then
        c1, c2 = self.y, self.z
    elseif axis == 'y' then
        c1, c2 = self.x, self.z
    elseif axis == 'z' then
        c1, c2 = self.x, self.y
    end
    
    return math.deg(math.atan2(c1, c2))
end

return Vector