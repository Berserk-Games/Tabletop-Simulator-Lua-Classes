local Color = require 'color'

for _, color in ipairs({
    'White',
    'Brown',
    'Red',
    'Orange',
    'Yellow',
    'Green',
    'TEAL',
    'Blue',
    'purple',
    'Pink',
    'grey',
    'Black'
}) do
    -- Player colors access
    assert(Color[color])
end

-- make sure __index meta isn't capturing too much
assert(Color.whatever == nil)
-- make sure __index meta isn't direct access
Color.Purple.r = 1
assert(Color.Purple.r == 0.627)

local function eq(val1, val2, margin)
    assert(type(val1) == type(val2), type(val1) .. ' & ' .. type(val2))    
    if type(val1) == 'number' then
        return math.abs(val1 - val2) < (margin or 10e-5)
    else
        return val1 == val2
    end
end

local function testColorEq(v1, v2, margin)
    local pass = eq(v1.r, v2.r, margin) and eq(v1.g, v2.g, margin) and eq(v1.b, v2.b, margin) and eq(v1.a, v2.a, margin)
    if not pass then
        error('Busted test!', 2)
    end
end

local function testEq(val1, val2, margin)
    local pass = eq(val1, val2, margin)
    if not pass then
        print(tostring(val1) .. ' : ' .. tostring(val2))
        error('Busted test!', 2)
    end
end

testColorEq(Color(0.1, 0.2, 0.3), Color.new(0.1, 0.2, 0.3))
testColorEq(Color(0.1, 0.2, 0.3, 0.4), Color.new({r = 0.1, g = 0.2, b = 0.3, a = 0.4}))

do
    local c = Color(0.1, 0.2, 0.3, 0.4)
    testEq(c[1], c.r)
    testEq(c[2], c.g)
    testEq(c[3], c.b)
    testEq(c[4], c.a)
    c.r, c[2], c.b, c[4] = 0.91, 0.92, 0.93, 0.94
    testColorEq(c, Color(0.91, 0.92, 0.93, 0.94))
end

testEq(Color(0.1, 0.2, 0.3):dump(), '{ r = 0.1, g = 0.2, b = 0.3 }')
testEq(Color(0.1, 0.2, 0.3, 0.4):dump(), '{ r = 0.1, g = 0.2, b = 0.3, a = 0.4 }')
testEq(tostring(Color(0.1, 0.2, 0.3)), 'Color: { r = 0.1, g = 0.2, b = 0.3 }')

testEq(Color.Purple:toString(), 'Purple')
testEq(tostring(Color.Purple), 'Color: Purple { r = 0.627, g = 0.125, b = 0.941 }')

Color.Add('Turquoise', Color(0.1, 0.2, 0.3))
testEq(Color.Turquoise, Color(0.1, 0.2, 0.3))
testEq(Color.Nonexistent, nil)

testEq(Color(0.1, 0.2, 0.3):lerp(Color(0.8, 0.8, 0.8), 0.5), Color(0.45, 0.5, 0.55))
