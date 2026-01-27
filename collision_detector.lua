-- 碰撞检测模块
local collision_detector = {}

--- 显示碰撞提示聊天气泡
-- @param carIndex 发生碰撞的车辆索引
-- @param chatBubbles 聊天气泡数据表
local function showCollisionBubble(carIndex, chatBubbles)
    if chatBubbles[carIndex] then
        -- 更新消息内容和时间戳
        chatBubbles[carIndex].message = "碰撞! Collision detected!"
        chatBubbles[carIndex].timestamp = os.clock()
        chatBubbles[carIndex].active = true

        -- 设置淡入目标值以显示气泡
        chatBubbles[carIndex].nearFadeTarget = 1
        chatBubbles[carIndex].midFadeTarget = 1
        chatBubbles[carIndex].farFadeTarget = 1
    end
end

-- 为焦点车辆（玩家车辆）设置碰撞检测
function collision_detector.setupPlayerCollisionDetection(chatBubbles, sim)
    local playerCarIndex = sim.focusedCar or 0  -- 使用当前焦点车辆，如果获取不到则默认为0号车
    
    local collisionDisposable = ac.onCarCollision(playerCarIndex, function(carIndex)
        -- 当焦点车辆发生碰撞时执行
        print("焦点车辆发生了碰撞!")
        
        -- 显示碰撞提示气泡
        showCollisionBubble(carIndex, chatBubbles)
        
        -- 获取车辆数据以进行更详细的分析
        local car = ac.getCar(carIndex)
        if car then
            -- 检查碰撞的详细信息
            print("碰撞力度: " .. tostring(car.collisionDepth or "N/A"))
            -- 这里可以添加额外的碰撞响应逻辑
        end
    end)
    
    return collisionDisposable
end

-- 为所有车辆设置碰撞检测
function collision_detector.setupAllCarsCollisionDetection(chatBubbles)
    local collisionDisposable = ac.onCarCollision(-1, function(carIndex)
        print("车辆 " .. carIndex .. " 发生了碰撞!")
        
        -- 显示碰撞提示气泡
        showCollisionBubble(carIndex, chatBubbles)
        
        -- 获取车辆数据以进行更详细的分析
        local car = ac.getCar(carIndex)
        if car then
            print("碰撞力度: " .. tostring(car.collisionDepth or "N/A"))
        end
    end)
    
    return collisionDisposable
end

return collision_detector