-- 导入模块
local vehicle_data = require('vehicle_data')
local chat_bubble_renderer = require('chat_bubble_renderer')
local collision_detector = require('collision_detector')

-- 获取模拟器数据
local Sim = ac.getSim()

-- 配置参数
local bubbleDistance = 300 -- 米
local nearRange = 0.8      -- 显示完整气泡
local midRange = 0.55      -- 显示部分气泡
local farRange = 0.3       -- 完全隐藏气泡
-- 配置结束

local driverData = {}
local chatBubbles = {}
local numberOfCars = 0
local globaldt = 0.016
local globalTimer = 0
local carsInRangeMultiplierCurrent = 1

-- 初始化车辆数据
driverData, chatBubbles, numberOfCars = vehicle_data.init(numberOfCars)

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
        chatBubbles[senderCarIndex].nearFadeTarget = 1
        chatBubbles[senderCarIndex].midFadeTarget = 1
        chatBubbles[senderCarIndex].farFadeTarget = 1
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

    -- 根据范围内的车辆数量计算乘数
    carsInRangeMultiplierCurrent = vehicle_data.calculateCarsInRangeMultiplier(Sim, bubbleDistance, chatBubbles)
    ac.debug("carsInRangeMultiplierCurrent", carsInRangeMultiplierCurrent)

    -- 更新lastCanvasUpdate计数器
    for i = 0, numberOfCars - 1 do
        if driverData[i] then
            driverData[i].lastCanvasUpdate = (driverData[i].lastCanvasUpdate or 0) + 1
        end
    end

    -- 检查是否有活动气泡需要停用
    for i, bubble in pairs(chatBubbles) do
        if bubble.active and os.clock() - bubble.timestamp > bubble.duration then
            bubble.nearFadeTarget = 0
            bubble.midFadeTarget = 0
            bubble.farFadeTarget = 0

            -- 检查是否完全淡出
            if bubble.nearFadeCurrent <= 0.01 and bubble.midFadeCurrent <= 0.01 and bubble.farFadeCurrent <= 0.01 then
                bubble.active = false
            end
        end
    end
end

-- 注册聊天气泡作为驾驶员标签覆盖层
if Sim.driverNamesShown == true then
    ui.onDriverNameTag(false, rgbm(1, 1, 1, 0), function(carData)
        chat_bubble_renderer.renderChatBubble(carData, driverData, chatBubbles, Sim, bubbleDistance, nearRange, midRange,
            farRange, globaldt)
    end, { distanceMultiplier = math.ceil(bubbleDistance / 10), tagSize = vec2(1000, 200) })
end

-- 所有车辆碰撞检测
-- collision_detector.setupAllCarsCollisionDetection(chatBubbles)
-- 焦点车辆碰撞检测
collision_detector.setupPlayerCollisionDetection(chatBubbles, Sim)
