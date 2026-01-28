-- 车辆数据管理模块
local vehicle_data = {}
local config = require('config')

-- 初始化所有车辆的数据结构
function vehicle_data.init()
    local driverData = {}
    local chatBubbles = {}

    -- 使用ac.iterateCars API获取车辆数据
    for i, car in ac.iterateCars() do
        driverData[i] = {}
        chatBubbles[i] = {
            canvas = ui.ExtraCanvas(vec2(1200, 240), 1, render.AntialiasingMode.ExtraSharpCMAA),
            fadeCurrent = 0,
            fadeTarget = 0,
            message = "",   -- 当前消息
            timestamp = 0,  -- 消息接收时间
            duration = config.bubble.duration,   -- 显示消息的持续时间（秒）
            active = false, -- 气泡是否处于活动状态
            gifPlayer = ui.GIFPlayer(config.images.AMD), -- 创建GIFPlayer实例，使用配置中的AMD图片路径
            lastHitTime = 0, -- 上次撞击时间
            hitAnimationProgress = 0 -- 撞击动画进度 (0-1)
        }
        driverData[i].driverName = car:driverName()
    end

    return driverData, chatBubbles
end

-- 更新会话开始时的车辆数据
function vehicle_data.onSessionStart(driverData, chatBubbles)
    -- 使用ac.iterateCars API获取车辆数据
    for i, car in ac.iterateCars() do
        driverData[i].driverName = car:driverName()
       
        -- 为新车添加模拟消息
        if not chatBubbles[i].mockMessage then
            chatBubbles[i].mockMessage = "Hello from " ..
            (car and car:driverName() or "Unknown Driver") .. "!"
            chatBubbles[i].mockActive = true
        end
    end
end


-- 查找最近的车辆并计算距离（不考虑车辆朝向）
function vehicle_data.findLeadCar(currentCarIndex)
    local currentCar = ac.getCar(currentCarIndex)
    if not currentCar then
        return nil, 0
    end
    
    local currentPosition = currentCar.position
    
    if not currentPosition then
        return nil, 0
    end
    
    local minDistance = math.huge
    local closestCarIndex = nil
    
    -- 使用ac.iterateCars遍历所有车辆
    for i, otherCar in ac.iterateCars() do
        if i ~= currentCarIndex and otherCar and otherCar.isConnected then
            if otherCar and otherCar.position then
                -- 计算两车之间的距离
                local distance = (otherCar.position - currentPosition):length()
                
                if distance > 0 and distance < minDistance then  -- 确保距离大于0且小于当前最小距离
                    minDistance = distance
                    closestCarIndex = i
                end
            end
        end
    end
    
    if closestCarIndex then
        return closestCarIndex, minDistance
    else
        return nil, 0
    end
end

return vehicle_data