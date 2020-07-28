local function test(Color, verbose)
    
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
    
    local function testColorEq(v1, v2, margin)
        local pass = eq(v1.r, v2.r, margin) and eq(v1.g, v2.g, margin) and eq(v1.b, v2.b, margin) and eq(v1.a, v2.a, margin)
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
        testEq(Color[color] ~= nil, true)
    end
    
    -- make sure __index meta isn't capturing too much
    testEq(Color.whatever, nil)
    -- make sure __index meta isn't direct access
    Color.Purple.r = 1
    testEq(Color.Purple.r, 0.627)

    testColorEq(Color(0.1, 0.2, 0.3), Color.new(0.1, 0.2, 0.3))
    testColorEq(Color(0.1, 0.2, 0.3, 0.4), Color.new({r = 0.1, g = 0.2, b = 0.3, a = 0.4}))

    do
        local c = Color(0.1, 0.2, 0.3, 0.4)
        testEq(c[1], c.r)
        testEq(c[2], c.g)
        testEq(c[3], c.b)
        testEq(c[4], c.a)
        
        -- WARNING - Moonsharp bug, below does not work
        -- c.r, c[2], c.b, c[4] = 0.91, 0.92, 0.93, 0.94
        
        c.r = 0.91
        c[2] = 0.92
        c.b = 0.93
        c[4] = 0.94
        testColorEq(c, Color(0.91, 0.92, 0.93, 0.94))
    end

    testEq(Color(0.1, 0.2, 0.3):dump(), '{ r = 0.1, g = 0.2, b = 0.3 }')
    testEq(Color(0.1, 0.2, 0.3, 0.4):dump(), '{ r = 0.1, g = 0.2, b = 0.3, a = 0.4 }')
    testEq(tostring(Color(0.1, 0.2, 0.3)), 'Color: { r = 0.1, g = 0.2, b = 0.3 }')

    testEq(Color.Purple:toString(), 'Purple')
    testEq(tostring(Color.Purple), 'Color: Purple { r = 0.627, g = 0.125, b = 0.941 }')
    
    do
        local col = Color.fromHex('deadbf42')
        testColorEq(col, Color.fromHex('#deadbf42'))
        
        testEq(col, Color(222/255, 173/255, 191/255, 66/255))
        testEq(col:toHex(), 'deadbf')
        testEq(col:toHex(true), 'deadbf42')
    end


    testError(function() return Color.fromHex('0055a') end)
    testError(function() return Color.fromHex('0055xx') end)
    testError(function() return Color.fromHex('0055ax') end)
    testError(function() return Color.fromHex('0055aaf') end)
    testError(function() return Color.fromHex('0055aafx') end)
    testError(function() return Color.fromHex('0055aaxx') end)

    Color.Add('Turquoise', Color(0.1, 0.2, 0.3))
    testEq(Color.Turquoise, Color(0.1, 0.2, 0.3))
    testEq(Color.Nonexistent, nil)
    testEq(Color[nil], nil)

    testEq(Color(0.1, 0.2, 0.3):lerp(Color(0.8, 0.8, 0.8), 0.5), Color(0.45, 0.5, 0.55))

    testEq(Color(0.1, 0.2, 0.3)[0], nil)
    testEq(Color(0.1, 0.2, 0.3)[999], nil)
    testEq(Color(0.1, 0.2, 0.3).foo, nil)

    print('Pass')
end

return test
