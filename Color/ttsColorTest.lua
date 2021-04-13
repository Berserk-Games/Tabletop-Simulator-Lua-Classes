-- for require'ing from Atom to be ran in TTS

local test = require('Tabletop-Simulator-Lua-Classes/Color/colorTest')
local Color = require('Tabletop-Simulator-Lua-Classes/Color/color')

local _old = onLoad
function onLoad()
    if (type(_old) == 'function') then
        _old()
    end
    test(Color, true)
end