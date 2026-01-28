-- 导入模块
local config = require('config')
local vehicle_data = require('vehicle_data')
local chat_bubble_renderer = require('chat_bubble_renderer')
local collision_detector = require('collision_detector')
local audio_manager = require('audio_manager')

-- 获取模拟器数据
local Sim = ac.getSim()

-- 初始化音频系统
local audio_initialized = audio_manager.init()

-- 配置参数（从配置模块读取）
local bubbleDistance = config.bubble.distance
local nearRange = config.bubble.nearRange
local midRange = config.bubble.midRange
local farRange = config.bubble.farRange
-- 配置结束

local driverData = {}
local chatBubbles = {}
local globaldt = 0.016
local globalTimer = 0
local carsInRangeMultiplierCurrent = 1
local fpsCounter = 0
local fpsUpdateInterval = 0               -- 控制更新频率的时间间隔（秒）
local fpsTarget = config.render.fpsTarget -- 目标更新帧率

-- 初始化车辆数据
driverData, chatBubbles = vehicle_data.init()

-- 处理会话开始事件
function onSessionStart()
    vehicle_data.onSessionStart(driverData, chatBubbles)
end

ac.onSessionStart(onSessionStart)

-- 显示聊天气泡函数
local function showChatBubble(message, senderCarIndex, senderSessionID)
    if chatBubbles[senderCarIndex] then
        -- 更新消息内容和时间戳
        chatBubbles[senderCarIndex].message = message
        chatBubbles[senderCarIndex].timestamp = os.clock()
        chatBubbles[senderCarIndex].active = true

        -- 设置淡入目标值以显示气泡
        chatBubbles[senderCarIndex].fadeTarget = 1
    end
end

-- 监听聊天消息
ac.onChatMessage(function(message, senderCarIndex, senderSessionID)
    showChatBubble(message, senderCarIndex, senderSessionID)
    -- 返回false以允许消息出现在标准聊天窗口中
    return false
end)

function script.update(dt)
    globaldt = dt
    globalTimer = globalTimer + dt

    Sim = ac.getSim()

    -- 根据目标帧率计算更新间隔
    fpsUpdateInterval = 1.0 / fpsTarget

    -- 根据范围内的车辆数量计算乘数
    carsInRangeMultiplierCurrent = vehicle_data.calculateCarsInRangeMultiplier(Sim, bubbleDistance, chatBubbles)
    ac.debug("carsInRangeMultiplierCurrent", carsInRangeMultiplierCurrent)

    -- 检查是否有活动气泡需要停用
    for i, bubble in pairs(chatBubbles) do
        if bubble.active and os.clock() - bubble.timestamp > config.bubble.duration then
            bubble.fadeTarget = 0

            -- 检查是否完全淡出
            if bubble.fadeCurrent <= 0.01 then
                bubble.active = false
            end
        end

        -- 更新撞击动画进度
        if bubble.hitAnimationProgress > 0 then
            bubble.hitAnimationProgress = math.max(0, bubble.hitAnimationProgress - dt / config.animation.duration) -- 0.3秒内完成动画
        end
    end


    -- 更新lastCanvasUpdate计数器
    for index, _ in pairs(driverData) do
        -- 增加一个基于时间的更新计数器，而不是简单的递增
        driverData[index].lastCanvasUpdateTime = (driverData[index].lastCanvasUpdateTime or 0) + dt
    end
end

-- 注册聊天气泡作为驾驶员标签覆盖层
if Sim.driverNamesShown == true then
    ui.onDriverNameTag(true, rgbm(1, 1, 1, 0), function(carData)
        chat_bubble_renderer.renderChatBubble(carData, driverData, chatBubbles, Sim, bubbleDistance, nearRange, midRange,
            farRange, globaldt)
    end, { distanceMultiplier = math.ceil(bubbleDistance / 10), tagSize = vec2(1000, 200) })
end


-- 焦点车辆碰撞检测
collision_detector.setupPlayerCollisionDetection(chatBubbles, Sim)
