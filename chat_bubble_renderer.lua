-- 聊天气泡渲染模块
local chat_bubble_renderer = {}
local vehicle_data = require('vehicle_data')

-- 渲染聊天气泡
function chat_bubble_renderer.renderBubble(CurrentlyProcessedCar, chatBubbles, driverData)
    local carData = CurrentlyProcessedCar
    local bubble = chatBubbles[carData.index]

    if not bubble or not (bubble.active or bubble.mockActive) then
        -- 如果没有气泡或气泡未激活，绘制空白画布
        ui.dwriteTextAligned("", 56, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 30), false, rgb(0, 0, 0, 0))
        return
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
    ui.dwriteTextAligned(displayMessage, 56, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 80), false, rgb(1, 1, 1))

    ui.endOutline(0, 10)
    
    -- 渲染车手名字
    ui.pushDWriteFont('Poppins:Fonts/Poppins-Regular.ttf')
    ui.beginOutline()
    
    local driverName = driverData[carData.index] and driverData[carData.index].driverName or "Unknown Driver"
   
    ui.dwriteTextAligned(driverName, 46, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 60), false, rgb(0.9, 0.9, 0.9))
    
    ui.endOutline(0, 6)
    
    -- 渲染前车距离（仅当前车存在时）
    ui.beginOutline()
    local leadCarIndex, distance = vehicle_data.findLeadCar(carData.index)
    local distanceText = ""
    if leadCarIndex and distance > 0 then
        distanceText = string.format("%.1f m", distance)
    end
    ui.dwriteTextAligned(distanceText, 42, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 85), false, rgb(0.7, 0.7, 0.7))
    ui.endOutline(0, 4)
    
    -- 绘制圆形头像占位符，使用 Images/rust.jpg 图像
    local avatarCenterX = 750 -- 在文本左边放置圆形头像
    local avatarCenterY = 140
    local avatarRadius = 65
    
    -- 计算头像的左上角和右下角坐标
    local topLeft = vec2(avatarCenterX - avatarRadius, avatarCenterY - avatarRadius)
    local bottomRight = vec2(avatarCenterX + avatarRadius, avatarCenterY + avatarRadius)
    
    -- 使用圆形剪切蒙版绘制图像
    ui.drawImage('Images/rust.jpg', topLeft, bottomRight, rgbm(1, 1, 1, 1))

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
        chatBubbles[carData.index].canvas:update(function() chat_bubble_renderer.renderBubble(CurrentlyProcessedCar, chatBubbles, driverData) end)
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
        if chatBubbles[carData.index].fadeCurrent > 0 then
            ui.drawImage(chatBubbles[carData.index].canvas,
                vec2(1000 - ((sizeScale * 0.5 + 0.5) * 1000), 100 - ((sizeScale * 0.5 + 0.5) * 100)),
                vec2(((sizeScale * 0.5 + 0.5) * 1000), 200), rgbm(1, 1, 1, chatBubbles[carData.index].fadeCurrent))
        end

        -- 设置淡入淡出目标
        if fadeScale >= nearRange then
            chatBubbles[carData.index].fadeTarget = 1
        else
            -- 如果不是真实消息，则保持模拟消息的激活状态
            if not (chatBubbles[carData.index].active and (os.clock() - chatBubbles[carData.index].timestamp <= chatBubbles[carData.index].duration)) then
                chatBubbles[carData.index].fadeTarget = chatBubbles[carData.index].mockActive and 1 or 0
            else
                chatBubbles[carData.index].fadeTarget = 0
            end
        end

        -- 平滑过渡淡入淡出值
        if chatBubbles[carData.index].fadeTarget > chatBubbles[carData.index].fadeCurrent then
            chatBubbles[carData.index].fadeCurrent = math.clamp(
            chatBubbles[carData.index].fadeCurrent + globaldt * 2, 0, 1)
        elseif chatBubbles[carData.index].fadeTarget < chatBubbles[carData.index].fadeCurrent then
            chatBubbles[carData.index].fadeCurrent = math.clamp(
            chatBubbles[carData.index].fadeCurrent - globaldt, 0, 1)
        end
    else
        -- 车辆太远，隐藏气泡
        chatBubbles[carData.index].fadeTarget = 0
        chatBubbles[carData.index].fadeCurrent = 0
    end
end

return chat_bubble_renderer