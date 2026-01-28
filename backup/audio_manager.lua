-- 音频管理模块
local audio_manager = {}
local config = require('config')

-- 音频事件存储
local audio_events = {}

-- 初始化音频系统
function audio_manager.init()
    -- 检查音频系统是否就绪
    if not ac.isAudioReady() then
        print("音频系统尚未就绪，将在稍后重试...")
        return false
    end

    
    return true
end


return audio_manager