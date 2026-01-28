-- 碰撞检测模块
local collision_detector = {}
local config = require('config')
local audio_manager = require('audio_manager')

-- 为焦点车辆（玩家车辆）设置碰撞检测
function collision_detector.setupPlayerCollisionDetection(chatBubbles, sim)
    local playerCarIndex = sim.focusedCar or 0 -- 使用当前焦点车辆，如果获取不到则默认为0号车

    local collisionDisposable = ac.onCarCollision(playerCarIndex, function(carIndex)
        -- 当焦点车辆发生碰撞时执行
        print("焦点车辆发生了碰撞!")

        -- 触发撞击动画效果
        if chatBubbles[carIndex] then
            local currentTime = os.clock()
            -- 检查上次撞击时间，确保不会连续触发
            if currentTime - (chatBubbles[carIndex].lastHitTime or 0) > config.collision.cooldown then -- 至少间隔0.5秒
                chatBubbles[carIndex].lastHitTime = currentTime
                chatBubbles[carIndex].hitAnimationProgress = 1                                         -- 开始动画

                -- 更新消息内容和时间戳
                chatBubbles[carIndex].message = "碰撞! Collision detected!"
                chatBubbles[carIndex].timestamp = currentTime
                chatBubbles[carIndex].active = true
                chatBubbles[carIndex].fadeTarget = 1
            end
        end

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

return collision_detector
