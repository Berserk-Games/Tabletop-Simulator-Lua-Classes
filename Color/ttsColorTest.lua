-- for require'ing from Atom to be ran in TTS

local test = require('tts_lua_classes/Color/colorTest')
local Color = require('tts_lua_classes/Color/color')

local _old = onLoad
function onLoad()
    if (type(_old) == 'function') then
        _old()
    end
    test(Color, true)
end