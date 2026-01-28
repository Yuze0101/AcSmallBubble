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

    -- 预加载常用的音频事件
    audio_events.collision_sound = ac.AudioEvent('/common/collision', false, false)
    audio_events.chat_notification = ac.AudioEvent('/common/chat_notify', false, false)
    
    -- 设置默认参数
    if audio_events.collision_sound and audio_events.collision_sound.isValid() then
        audio_events.collision_sound.volume = 0.7
        audio_events.collision_sound.pitch = 1.0
    end
    
    if audio_events.chat_notification and audio_events.chat_notification.isValid() then
        audio_events.chat_notification.volume = 0.5
        audio_events.chat_notification.pitch = 1.0
    end
    
    return true
end

-- 播放碰撞音效
function audio_manager.play_collision_sound(carIndex)
    if not audio_events.collision_sound or not audio_events.collision_sound.isValid() then
        return
    end
    
    local car = ac.getCar(carIndex)
    if not car then
        return
    end
    
    -- 设置音效位置
    audio_events.collision_sound:setPosition(car.position, car.direction, car.up, car.velocity)
    
    -- 播放音效
    audio_events.collision_sound:resumeIf(true)
end

-- 播放聊天通知音效
function audio_manager.play_chat_notification(carIndex)
    if not audio_events.chat_notification or not audio_events.chat_notification.isValid() then
        return
    end
    
    local car = ac.getCar(carIndex)
    if not car then
        return
    end
    
    -- 设置音效位置
    audio_events.chat_notification:setPosition(car.position, car.direction, car.up, car.velocity)
    
    -- 播放音效
    audio_events.chat_notification:resumeIf(true)
end

-- 更新音频事件的位置
function audio_manager.update_positions(sim)
    -- 可以在这里更新所有正在播放的音频事件的位置
    -- 特别是在跟随车辆移动的音效
end

return audio_manager