local function test(Vec, verbose)
    
    local function eq(val1, val2, margin)
        assert(type(val1) == type(val2), type(val1) .. ' & ' .. type(val2))    
        if type(val1) == 'number' then
            return math.abs(val1 - val2) < (margin or 10e-5)
        else
            return val1 == val2
        end
    end
    
    local counter = 1
    local function handle(result, ...)
        if result then 
            if verbose then
                print('Test no. ' .. counter .. ' passed')
            end
            counter = counter + 1
        else
            local args = {}
            for k = 1, select('#', ...) do
                table.insert(args, tostring(select(k, ...)))
            end
            error('Busted test no. ' .. counter .. ' with (' .. table.concat(args, ', ') .. ')!', 3)
        end
    end
    
    local function testVecEq(v1, v2, margin)
        local pass = eq(v1.x, v2.x, margin) and eq(v1.y, v2.y, margin) and eq(v1.z, v2.z, margin)
        handle(pass, v1, v2, margin)
    end

    local function testEq(v1, v2, margin)
        local pass = eq(v1, v2, margin)
        handle(pass, v1, v2, margin)
    end

    local function testError(f)
        local pass = not pcall(f)
        handle(pass)
    end

    local function randElement()
        return 20*(math.random()-0.5)
    end

    local function randomVector()
        return Vec(randElement(), randElement(), randElement())
    end

    testVecEq(Vec(), Vec(0, 0, 0))
    testVecEq(Vec({1, 2, 3}), Vec(1, 2, 3))

    testVecEq(Vec(1, 2, 3), Vec():setAt('x', 1):setAt('y', 2):setAt('z', 3))

    do
        local v = randomVector()
        testEq(v[1], v.x)
        testEq(v[2], v.y)
        testEq(v[3], v.z)
        v.x, v.y, v.z = 1, 2, 3
        testVecEq(v, Vec(1, 2, 3))
    end

    testVecEq(Vec(1, 0, 3), Vec():set(1, nil, 3))
    testVecEq(Vec(1, 2, 3), Vec():set(1, 2, 3))

    do
        local v = randomVector()
        testVecEq(v, v:copy())
    end

    testVecEq(Vec(1, 2, 3), Vec(1, 1, 1):add(Vec(0, 1, 2)))
    testVecEq(Vec(1, 2, 3), Vec(1, 1, 1) + Vec(0, 1, 2))

    testVecEq(Vec(1, 2, 3), Vec(3, 3, 3):sub(Vec(2, 1, 0)))
    testVecEq(Vec(1, 2, 3), Vec(3, 3, 3) - Vec(2, 1, 0))

    testEq(Vec(1, 3, -5):dot(Vec(4, -2, -1)), 3)

    testEq(Vec(1, 2, 3):sqrMagnitude(), 14)

    testVecEq(Vec(1, 2, 3), Vec(0.5, 1, 1.5):scale(2))
    testVecEq(Vec(1, 2, 3), Vec(1, 1, 1):scale(1, 2, 3))
    testVecEq(Vec(3, 2, 1), Vec(1, 2, 3):scale(Vec(3, 1, 1/3)))

    testEq(Vec(1, 2, 3):sqrDistance(Vec(3, 2, 1)), 8)

    testVecEq(Vec(1, 2, 3) * 2, Vec(2, 4, 6))
    testVecEq(2 * Vec(1, 2, 3), Vec(2, 4, 6))

    testEq(Vec(1, 2, 3):equals(Vec(0.999, 2.001, 3)), true)
    testEq(Vec(1, 2, 3) == Vec(1.001, 1.999, 3), true)

    testEq(tostring(Vec(1, 222.22000, -3)), 'Vector: { 1, 222.22, -3 }')
    testEq(Vec(1, 222.22000, -3):string(), '{ 1, 222.22, -3 }')
    testEq(Vec(1, 222.22000, -3):string('Name'), 'Name: { 1, 222.22, -3 }')

    testEq(select('#', tostring(Vec(0, 0, 0))), 1)
    testEq(select('#', Vec(0, 0, 0):string()), 1)
    testEq(select('#', Vec(0, 0, 0):string('Name')), 1)

    testEq(Vec(1, 1, 0):angle(Vec(0, 1, 1)), 60)

    testVecEq(Vec(1, 1, 1), Vec(3, 3, 3):clamp(math.sqrt(3)))

    testVecEq(Vec(1, 0, 0):cross(Vec(0, 1, 0)), Vec(0, 0, 1))
        
    testVecEq(Vec.between(Vec(1, 2, 3), Vec(2, 3, 4)), Vec(1, 1, 1))
        
    testVecEq(Vec(3, 0, 0):lerp(Vec(2, -1, 2), 0.5), Vec(2.5, -0.5, 1))

    testVecEq(Vec(1, 0, 0):moveTowards(Vec(20, 0, 0), 3), Vec(4, 0, 0))

    do
        local s2 = math.sqrt(2)
        testVecEq(Vec(3, 4, 5):normalized(), Vec(3/(5*s2), (2*s2)/5, 1/s2))
    end

    testVecEq(Vec(1, 2, 3):project(Vec(1, 1, 1)), Vec(2, 2, 2))

    testVecEq(Vec(1, 2, 3):projectOnPlane(Vec(1, 0, 0)), Vec(0, 2, 3))

    do
        local v, target = Vec(1, 0, 0), Vec(0, 0, 1)
        for k = 1, 6 do
            v:rotateTowards(target, 15)
        end
        testVecEq(v, target, 0.05)
    end

    testVecEq(Vec(1, 2, 3):reflect(Vec(0, 1, 1)), Vec(1, -3, -2))

    testVecEq(Vec.max(Vec(1, 2, 3), Vec(3, 2, 1)), Vec(3, 2, 3))
    testVecEq(Vec.min(Vec(1, 2, 3), Vec(3, 2, 1)), Vec(1, 2, 1))

    do
        local baseOne, baseTwo, baseThree = Vec(1, 2, 3):orthoNormalize()
        testEq(baseOne:angle(baseTwo), 90)
        testEq(baseOne:angle(baseThree), 90)
        testEq(baseTwo:angle(baseThree), 90)
    end

    testVecEq(Vec(math.sqrt(2), 0, 0):rotateOver('y', -45), Vec(1, 0, 1))
    testVecEq(Vec(2, 2, 1):rotateOver('z', 60), Vec(-0.73205, 2.73205, 1))

    testEq(Vec(math.sqrt(2), 0, math.sqrt(2)):heading('y'), 45)
    testEq(Vec(-math.sqrt(2), 0, -math.sqrt(2)):heading('y'), -135)
    
    testVecEq(Vec(1, 2, 3), Vec(-1, -2, -3):inverse())
    
    testVecEq(Vec(1, 2, 3), Vec(1, 1/2, 1/3):reciprocal())
    
    testVecEq(Vec(2, 2, 1):rotateOver('z', 60):rotateOver('x', -45):rotateOver('y', 10), Vec(2, 2, 1):rotateOver(Vec(-45, 10, 60)))
    
    print('Pass')
end

return test
