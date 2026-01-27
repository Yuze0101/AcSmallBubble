-- 聊天气泡渲染模块
local chat_bubble_renderer = {}
local vehicle_data = require('vehicle_data')

-- 渲染远距离画布上的气泡（最低细节）
function chat_bubble_renderer.renderBubbleFar(CurrentlyProcessedCar, chatBubbles, driverData)
    local carData = CurrentlyProcessedCar
    local bubble = chatBubbles[carData.index]

    if not bubble or not (bubble.active or bubble.mockActive) then
        ui.dwriteTextAligned("", 28, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 30), false, rgb(1, 1, 1))
        return
    end

    -- 检查消息是否应该继续显示（真实消息）
    if bubble.active and os.clock() - bubble.timestamp > bubble.duration then
        bubble.nearFadeTarget = 0
        bubble.midFadeTarget = 0
        bubble.farFadeTarget = 0
    end

    ui.pushDWriteFont('Poppins:Fonts/Poppins-Medium.ttf;Weight=Medium')
    ui.beginOutline()

    -- 渲染消息文本（优先显示真实消息，否则显示模拟消息）
    local displayMessage = ""
    if bubble.active and (os.clock() - bubble.timestamp <= bubble.duration) then
        displayMessage = bubble.message
    elseif bubble.mockActive then
        displayMessage = bubble.mockMessage
    end

    -- 居中渲染消息文本
    ui.dwriteTextAligned(displayMessage, 28, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 30), false, rgb(1, 1, 1))

    ui.endOutline(0, 10)
    
    -- 渲染车手名字
    ui.pushDWriteFont('Poppins:Fonts/Poppins-Regular.ttf')
    ui.beginOutline()
    
    local driverName = driverData[carData.index] and driverData[carData.index].driverName or "Unknown Driver"
    ui.dwriteTextAligned(driverName, 18, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 60), false, rgb(0.9, 0.9, 0.9))
    
    ui.endOutline(0, 6)
    
    -- 渲染前车距离（仅当前车存在时）
    ui.beginOutline()
    local leadCarIndex, distance = vehicle_data.findLeadCar(carData.index)
    if leadCarIndex and distance > 0 then
        local distanceText = string.format("%.1f m", distance)
        ui.dwriteTextAligned(distanceText, 16, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 85), false, rgb(0.7, 0.7, 0.7))
    end
    ui.endOutline(0, 4)
    
    -- 绘制圆形头像占位符
    local avatarCenterX = 950 -- 在文本左边放置圆形头像
    local avatarCenterY = 60
    local avatarRadius = 15
    ui.drawCircle(vec2(avatarCenterX, avatarCenterY), avatarRadius, rgbm(0.5, 0.5, 0.5, 0.8))
    
    ui.popDWriteFont()
    ui.popDWriteFont()
end

-- 渲染中距离画布上的气泡（中等细节）
function chat_bubble_renderer.renderBubbleMid(CurrentlyProcessedCar, chatBubbles, driverData)
    local carData = CurrentlyProcessedCar
    local bubble = chatBubbles[carData.index]

    if not bubble or not (bubble.active or bubble.mockActive) then
        ui.dwriteTextAligned("", 28, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 30), false, rgb(1, 1, 1))
        return
    end

    -- 检查消息是否应该继续显示（真实消息）
    if bubble.active and os.clock() - bubble.timestamp > bubble.duration then
        bubble.nearFadeTarget = 0
        bubble.midFadeTarget = 0
        bubble.farFadeTarget = 0
    end

    ui.pushDWriteFont('Poppins:Fonts/Poppins-Medium.ttf;Weight=Medium')
    ui.beginOutline()

    -- 渲染消息文本（优先显示真实消息，否则显示模拟消息）
    local displayMessage = ""
    if bubble.active and (os.clock() - bubble.timestamp <= bubble.duration) then
        displayMessage = bubble.message
    elseif bubble.mockActive then
        displayMessage = bubble.mockMessage
    end

    -- 居中渲染消息文本
    ui.dwriteTextAligned(displayMessage, 28, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 30), false, rgb(1, 1, 1))

    ui.endOutline(0, 10)
    
    -- 渲染车手名字
    ui.pushDWriteFont('Poppins:Fonts/Poppins-Regular.ttf')
    ui.beginOutline()
    
    local driverName = driverData[carData.index] and driverData[carData.index].driverName or "Unknown Driver"
    ui.dwriteTextAligned(driverName, 18, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 60), false, rgb(0.9, 0.9, 0.9))
    
    ui.endOutline(0, 6)
    
    -- 渲染前车距离（仅当前车存在时）
    ui.beginOutline()
    local leadCarIndex, distance = vehicle_data.findLeadCar(carData.index)
    if leadCarIndex and distance > 0 then
        local distanceText = string.format("%.1f m", distance)
        ui.dwriteTextAligned(distanceText, 16, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 85), false, rgb(0.7, 0.7, 0.7))
    end
    ui.endOutline(0, 4)
    
    -- 绘制圆形头像占位符
    local avatarCenterX = 950 -- 在文本左边放置圆形头像
    local avatarCenterY = 60
    local avatarRadius = 15
    ui.drawCircle(vec2(avatarCenterX, avatarCenterY), avatarRadius, rgbm(0.5, 0.5, 0.5, 0.8))
    
    ui.popDWriteFont()
    ui.popDWriteFont()
end

-- 渲染近距离画布上的气泡（最高细节）
function chat_bubble_renderer.renderBubbleNear(CurrentlyProcessedCar, chatBubbles, driverData)
    local carData = CurrentlyProcessedCar
    local bubble = chatBubbles[carData.index]

    if not bubble or not (bubble.active or bubble.mockActive) then
        ui.dwriteTextAligned("", 28, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 30), false, rgb(1, 1, 1))
        return
    end

    -- 检查消息是否应该继续显示（真实消息）
    if bubble.active and os.clock() - bubble.timestamp > bubble.duration then
        bubble.nearFadeTarget = 0
        bubble.midFadeTarget = 0
        bubble.farFadeTarget = 0
    end

    ui.pushDWriteFont('Poppins:Fonts/Poppins-Medium.ttf;Weight=Medium')
    ui.beginOutline()

    -- 渲染消息文本（优先显示真实消息，否则显示模拟消息）
    local displayMessage = ""
    if bubble.active and (os.clock() - bubble.timestamp <= bubble.duration) then
        displayMessage = bubble.message
    elseif bubble.mockActive then
        displayMessage = bubble.mockMessage
    end

    -- 居中渲染消息文本
    ui.dwriteTextAligned(displayMessage, 28, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 30), false, rgb(1, 1, 1))

    ui.endOutline(0, 10)
    
    -- 渲染车手名字
    ui.pushDWriteFont('Poppins:Fonts/Poppins-Regular.ttf')
    ui.beginOutline()
    
    local driverName = driverData[carData.index] and driverData[carData.index].driverName or "Unknown Driver"
    ui.dwriteTextAligned(driverName, 18, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 60), false, rgb(0.9, 0.9, 0.9))
    
    ui.endOutline(0, 6)
    
    -- 渲染前车距离（仅当前车存在时）
    ui.beginOutline()
    local leadCarIndex, distance = vehicle_data.findLeadCar(carData.index)
    if leadCarIndex and distance > 0 then
        local distanceText = string.format("%.1f m", distance)
        ui.dwriteTextAligned(distanceText, 16, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 85), false, rgb(0.7, 0.7, 0.7))
    end
    ui.endOutline(0, 4)
    
    -- 绘制圆形头像占位符
    local avatarCenterX = 950 -- 在文本左边放置圆形头像
    local avatarCenterY = 60
    local avatarRadius = 15
    ui.drawCircle(vec2(avatarCenterX, avatarCenterY), avatarRadius, rgbm(0.5, 0.5, 0.5, 0.8))
    
    ui.popDWriteFont()
    ui.popDWriteFont()
end

-- 为特定车辆渲染聊天气泡的主要函数
function chat_bubble_renderer.renderChatBubble(carData, driverData, chatBubbles, sim, bubbleDistance, nearRange, midRange, farRange, globaldt)
    local CurrentlyProcessedCar = carData
    local bubble = chatBubbles[carData.index]

    -- 计算相机距离（根据FOV调整）
    driverData[carData.index].distanceToCamera = (carData.distanceToCamera / 2) * (sim.cameraFOV / 27)

    -- 如需要则更新画布（减少更新频率以提高性能）
    if not driverData[carData.index].lastCanvasUpdate then
        driverData[carData.index].lastCanvasUpdate = 0
    end

    if driverData[carData.index].lastCanvasUpdate > 2 * #chatBubbles and driverData[carData.index].distanceToCamera < bubbleDistance and (bubble.active or bubble.mockActive) then
        chatBubbles[carData.index].far:update(function() chat_bubble_renderer.renderBubbleFar(CurrentlyProcessedCar, chatBubbles, driverData) end)
        chatBubbles[carData.index].mid:update(function() chat_bubble_renderer.renderBubbleMid(CurrentlyProcessedCar, chatBubbles, driverData) end)
        chatBubbles[carData.index].near:update(function() chat_bubble_renderer.renderBubbleNear(CurrentlyProcessedCar, chatBubbles, driverData) end)
        driverData[carData.index].lastCanvasUpdate = 0
    end

    if driverData[carData.index].distanceToCamera < bubbleDistance then
        -- 计算缩放和淡化因子
        local sizeScale = math.clamp((((bubbleDistance) - (driverData[carData.index].distanceToCamera)) / (bubbleDistance)) ^
        0.9, 0.249, 1)
        local fadeScale = math.clamp(
        ((math.max(bubbleDistance, driverData[carData.index].distanceToCamera + 0.0001) - (driverData[carData.index].distanceToCamera)) / (bubbleDistance)) ^
        0.9, 0.249, 1)

        -- 根据距离和淡入状态绘制气泡
        if chatBubbles[carData.index].farFadeCurrent > 0 then
            ui.drawImage(chatBubbles[carData.index].far,
                vec2(1000 - ((sizeScale * 0.5 + 0.5) * 1000), 100 - ((sizeScale * 0.5 + 0.5) * 100)),
                vec2(((sizeScale * 0.5 + 0.5) * 1000), 200), rgbm(1, 1, 1, chatBubbles[carData.index].farFadeCurrent))
        end
        if chatBubbles[carData.index].midFadeCurrent > 0 then
            ui.drawImage(chatBubbles[carData.index].mid,
                vec2(1000 - ((sizeScale * 0.5 + 0.5) * 1000), 100 - ((sizeScale * 0.5 + 0.5) * 100)),
                vec2(((sizeScale * 0.5 + 0.5) * 1000), 200), rgbm(1, 1, 1, chatBubbles[carData.index].midFadeCurrent))
        end
        if chatBubbles[carData.index].nearFadeCurrent > 0 then
            ui.drawImage(chatBubbles[carData.index].near,
                vec2(1000 - ((sizeScale * 0.5 + 0.5) * 1000), 100 - ((sizeScale * 0.5 + 0.5) * 100)),
                vec2(((sizeScale * 0.5 + 0.5) * 1000), 200), rgbm(1, 1, 1, chatBubbles[carData.index].nearFadeCurrent))
        end

        -- 根据距离确定显示哪个画布
        if fadeScale >= nearRange then
            chatBubbles[carData.index].nearFadeTarget = 1
        else
            -- 如果不是真实消息，则保持模拟消息的激活状态
            if not (chatBubbles[carData.index].active and (os.clock() - chatBubbles[carData.index].timestamp <= chatBubbles[carData.index].duration)) then
                chatBubbles[carData.index].nearFadeTarget = chatBubbles[carData.index].mockActive and 1 or 0
            else
                chatBubbles[carData.index].nearFadeTarget = 0
            end
        end

        if fadeScale >= midRange and fadeScale <= nearRange then
            chatBubbles[carData.index].midFadeTarget = 1
        else
            -- 如果不是真实消息，则保持模拟消息的激活状态
            if not (chatBubbles[carData.index].active and (os.clock() - chatBubbles[carData.index].timestamp <= chatBubbles[carData.index].duration)) then
                chatBubbles[carData.index].midFadeTarget = chatBubbles[carData.index].mockActive and 1 or 0
            else
                chatBubbles[carData.index].midFadeTarget = 0
            end
        end

        if fadeScale >= farRange and fadeScale <= midRange then
            chatBubbles[carData.index].farFadeTarget = 1
        else
            -- 如果不是真实消息，则保持模拟消息的激活状态
            if not (chatBubbles[carData.index].active and (os.clock() - chatBubbles[carData.index].timestamp <= chatBubbles[carData.index].duration)) then
                chatBubbles[carData.index].farFadeTarget = chatBubbles[carData.index].mockActive and 1 or 0
            else
                chatBubbles[carData.index].farFadeTarget = 0
            end
        end

        -- 平滑过渡淡入淡出值
        if chatBubbles[carData.index].nearFadeTarget > chatBubbles[carData.index].nearFadeCurrent then
            chatBubbles[carData.index].nearFadeCurrent = math.clamp(
            chatBubbles[carData.index].nearFadeCurrent + globaldt * 2, 0, 1)
        elseif chatBubbles[carData.index].nearFadeTarget < chatBubbles[carData.index].nearFadeCurrent then
            chatBubbles[carData.index].nearFadeCurrent = math.clamp(
            chatBubbles[carData.index].nearFadeCurrent - globaldt, 0, 1)
        end

        if chatBubbles[carData.index].midFadeTarget > chatBubbles[carData.index].midFadeCurrent then
            chatBubbles[carData.index].midFadeCurrent = math.clamp(
            chatBubbles[carData.index].midFadeCurrent + globaldt * 2, 0, 1)
        elseif chatBubbles[carData.index].midFadeTarget < chatBubbles[carData.index].midFadeCurrent then
            chatBubbles[carData.index].midFadeCurrent = math.clamp(chatBubbles[carData.index].midFadeCurrent - globaldt,
                0, 1)
        end

        if chatBubbles[carData.index].farFadeTarget > chatBubbles[carData.index].farFadeCurrent then
            chatBubbles[carData.index].farFadeCurrent = math.clamp(
            chatBubbles[carData.index].farFadeCurrent + globaldt * 2, 0, 1)
        elseif chatBubbles[carData.index].farFadeTarget < chatBubbles[carData.index].farFadeCurrent then
            chatBubbles[carData.index].farFadeCurrent = math.clamp(chatBubbles[carData.index].farFadeCurrent - globaldt,
                0, 1)
        end
    else
        -- 车辆太远，隐藏所有气泡
        chatBubbles[carData.index].nearFadeTarget = 0
        chatBubbles[carData.index].midFadeTarget = 0
        chatBubbles[carData.index].farFadeTarget = 0
        chatBubbles[carData.index].nearFadeCurrent = 0
        chatBubbles[carData.index].midFadeCurrent = 0
        chatBubbles[carData.index].farFadeCurrent = 0
    end
end

return chat_bubble_renderer