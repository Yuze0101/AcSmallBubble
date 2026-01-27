-- 车辆数据管理模块
local vehicle_data = {}

-- 初始化所有车辆的数据结构
function vehicle_data.init(numberOfCars)
    local driverData = {}
    local chatBubbles = {}

    for i = 0, 1000 do
        if not ac.getCar(i) then
            break
        end
        numberOfCars = numberOfCars + 1
        driverData[i] = {}
        chatBubbles[i] = {
            far = ui.ExtraCanvas(vec2(1000, 200), 1, render.AntialiasingMode.ExtraSharpCMAA),
            farFadeCurrent = 0,
            farFadeTarget = 0,
            mid = ui.ExtraCanvas(vec2(1000, 200), 1, render.AntialiasingMode.ExtraSharpCMAA),
            midFadeCurrent = 0,
            midFadeTarget = 0,
            near = ui.ExtraCanvas(vec2(1000, 200), 1, render.AntialiasingMode.ExtraSharpCMAA),
            nearFadeCurrent = 0,
            nearFadeTarget = 0,
            message = "",   -- 当前消息
            timestamp = 0,  -- 消息接收时间
            duration = 5,   -- 显示消息的持续时间（秒）
            active = false, -- 气泡是否处于活动状态
            -- 添加模拟数据
            mockMessage = "Hello ,Mock message",
            mockActive = true
        }
        driverData[i].driverName = ac.getCar(i).driverName
    end

    return driverData, chatBubbles, numberOfCars
end

-- 更新会话开始时的车辆数据
function vehicle_data.onSessionStart(driverData, chatBubbles)
    for i = 0, 1000 do
        if not ac.getCar(i) then
            break
        end
        driverData[i].driverName = ac.getCar(i).driverName
        -- 为新车添加模拟消息
        if not chatBubbles[i].mockMessage then
            chatBubbles[i].mockMessage = "Hello from " ..
            (ac.getCar(i) and ac.getCar(i).driverName or "Unknown Driver") .. "!"
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

-- 查找前车并计算距离
function vehicle_data.findLeadCar(currentCarIndex, angleThreshold)
    if not ac.getCar(currentCarIndex) then
        return nil, 0
    end
    
    local currentCar = ac.getCar(currentCarIndex)
    local currentPosition = currentCar.position
    local currentForward = currentCar.forward
    
    if not currentPosition or not currentForward then
        return nil, 0
    end
    
    angleThreshold = angleThreshold or math.rad(45) -- 默认45度
    local minDistance = math.huge
    local leadCarIndex = nil
    
    for i = 0, 1000 do
        if i ~= currentCarIndex and ac.getCar(i) and ac.getCar(i). isConnected then
            local otherCar = ac.getCar(i)
            if otherCar and otherCar.position then
                -- 计算两车之间的向量
                local directionToOther = (otherCar.position - currentPosition):normalize()
                
                -- 检查是否在前方（角度小于阈值）
                local dotProduct = currentForward:dot(directionToOther)
                local angle = math.acos(math.clamp(dotProduct, -1, 1))
                
                if angle <= angleThreshold then
                    -- 计算距离
                    local distance = (otherCar.position - currentPosition):len()
                    
                    if distance < minDistance then
                        minDistance = distance
                        leadCarIndex = i
                    end
                end
            end
        end
    end
    
    if leadCarIndex then
        return leadCarIndex, minDistance
    else
        return nil, 0
    end
end

return vehicle_data