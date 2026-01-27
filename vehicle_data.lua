-- 车辆数据管理模块
local vehicle_data = {}

-- 初始化所有车辆的数据结构
function vehicle_data.init(numberOfCars)
    local driverData = {}
    local chatBubbles = {}

    for i = 0, 100 do
        if not ac.getCar(i) then
            break
        end
        numberOfCars = numberOfCars + 1
        driverData[i] = {}
        chatBubbles[i] = {
            canvas = ui.ExtraCanvas(vec2(1200, 240), 1, render.AntialiasingMode.ExtraSharpCMAA),
            fadeCurrent = 0,
            fadeTarget = 0,
            message = "",   -- 当前消息
            timestamp = 0,  -- 消息接收时间
            duration = 5,   -- 显示消息的持续时间（秒）
            active = false, -- 气泡是否处于活动状态
            gifPlayer = ui.GIFPlayer('Images/amd.gif') -- 创建GIFPlayer实例
        }
        driverData[i].driverName = ac.getCar(i):driverName()
    end

    return driverData, chatBubbles, numberOfCars
end

-- 更新会话开始时的车辆数据
function vehicle_data.onSessionStart(driverData, chatBubbles)
    for i = 0, 1000 do
        if not ac.getCar(i) then
            break
        end
        driverData[i].driverName = ac.getCar(i):driverName()
       
        -- 为新车添加模拟消息
        if not chatBubbles[i].mockMessage then
            chatBubbles[i].mockMessage = "Hello from " ..
            (ac.getCar(i) and ac.getCar(i):driverName() or "Unknown Driver") .. "!"
            chatBubbles[i].mockActive = true
        end
    end
end

-- 计算车辆到相机的距离
function vehicle_data.calculateDistanceToCamera(carData, sim)
    return (carData.distanceToCamera / 2) * (sim.cameraFOV / 27)
end

-- 计算范围内车辆的数量乘数
function vehicle_data.calculateCarsInRangeMultiplier(sim, bubbleDistance, chatBubbles)
    local carsInRangeMultiplierCurrent = 0
    for i = 0, 1000 do
        if not ac.getCar(i) then
            break
        end
        if i ~= sim.focusedCar and ac.getCar(i).isConnected and ac.getCar(i).distanceToCamera < bubbleDistance then
            carsInRangeMultiplierCurrent = carsInRangeMultiplierCurrent +
            math.clamp(((bubbleDistance - (ac.getCar(i).distanceToCamera)) / bubbleDistance) ^ 0.9, 0, 1)
        end
    end
    return math.clamp(math.max(1, carsInRangeMultiplierCurrent / 2), 1, 5)
end

-- 查找最近的车辆并计算距离（不考虑车辆朝向）
function vehicle_data.findLeadCar(currentCarIndex)
    if not ac.getCar(currentCarIndex) then
        return nil, 0
    end
    
    local currentCar = ac.getCar(currentCarIndex)
    local currentPosition = currentCar.position
    
    if not currentPosition then
        return nil, 0
    end
    
    local minDistance = math.huge
    local closestCarIndex = nil
    
    -- 获取实际存在的车辆数量，避免不必要的循环
    local maxCarIndex = 0
    for i = 0, 1000 do
        if not ac.getCar(i) then
            maxCarIndex = i
            break
        end
    end
    
    for i = 0, maxCarIndex - 1 do
        if i ~= currentCarIndex and ac.getCar(i) and ac.getCar(i).isConnected then
            local otherCar = ac.getCar(i)
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