-- for require'ing from Atom to be ran in TTS

local test = require('Tabletop-Simulator-Lua-Classes/Vector/vectorTest')
local Vector = require('Tabletop-Simulator-Lua-Classes/Vector/vector')

local _old = onLoad
function onLoad()
    if (type(_old) == 'function') then
        _old()
    end
    test(Vector, true)
end