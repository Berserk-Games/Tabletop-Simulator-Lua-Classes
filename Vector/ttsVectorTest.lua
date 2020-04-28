-- for require'ing from Atom to be ran in TTS

local test = require('tts_lua_classes/Vector/vectorTest')
local Vector = require('tts_lua_classes/Vector/vector')

local _old = onLoad
function onLoad()
    if (type(_old) == 'function') then
        _old()
    end
    test(Vector, true)
end