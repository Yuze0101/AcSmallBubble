-- 聊天气泡渲染模块
local chat_bubble_renderer = {}
local vehicle_data = require('vehicle_data')

-- 渲染聊天气泡
function chat_bubble_renderer.renderBubble(CurrentlyProcessedCar, chatBubbles, driverData)
    local carData = CurrentlyProcessedCar
    local bubble = chatBubbles[carData.index]

    ui.pushDWriteFont('Poppins:Fonts/Poppins-Medium.ttf;Weight=Medium')
    ui.beginOutline()

    -- 渲染消息文本（只有在气泡活跃时才显示）
    local displayMessage = ""
    if bubble and bubble.active and (os.clock() - bubble.timestamp <= bubble.duration) then
        displayMessage = bubble.message
    end

    -- 居中渲染消息文本
    ui.dwriteTextAligned(displayMessage, 56, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 80), false,
        rgb(1, 1, 1))

    ui.endOutline(0, 10)

    -- 渲染车手名字
    ui.pushDWriteFont('Poppins:Fonts/Poppins-Regular.ttf')
    ui.beginOutline()

    local driverName = driverData[carData.index] and driverData[carData.index].driverName or "Unknown Driver"


    ui.dwriteTextAligned(driverName, 36, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 60), false,
        rgb(0.9, 0.9, 0.9))

    ui.endOutline(0, 6)

    -- 渲染前车距离（仅当前车存在时）
    ui.beginOutline()
    local leadCarIndex, distance = vehicle_data.findLeadCar(carData.index)
    local distanceText = ""
    if leadCarIndex and distance > 0 then
        distanceText = string.format("%.1f m", distance)
    end
    ui.dwriteTextAligned(distanceText, 32, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 85), false,
        rgb(0.7, 0.7, 0.7))
    ui.endOutline(0, 4)

    -- 使用预创建的GIFPlayer绘制左侧圆形AMD图标，使用 Images/amd.gif
    local amdCenterX = 250 -- 左侧位置
    local amdCenterY = 140
    local amdRadius = 65

    -- 计算AMD图标的左上角和右下角坐标
    local topLeftAmd = vec2(amdCenterX - amdRadius, amdCenterY - amdRadius)
    local bottomRightAmd = vec2(amdCenterX + amdRadius, amdCenterY + amdRadius)

    -- 使用预创建的GIFPlayer实例并绘制圆形GIF动画
    if bubble and bubble.gifPlayer then
        -- 使用drawImageRounded绘制圆形图像，圆角半径等于图像半径实现圆形效果
        ui.drawImageRounded(bubble.gifPlayer, topLeftAmd, bottomRightAmd, rgbm(1, 1, 1, 1), nil, nil, amdRadius,
            ui.CornerFlags.All)
    end

    -- 绘制右侧圆形头像占位符，使用 Images/rust.jpg 图像
    local avatarCenterX = 750 -- 在文本右边放置圆形头像
    local avatarCenterY = 140
    local avatarRadius = 65

    -- 计算头像的左上角和右下角坐标
    local topLeftAvatar = vec2(avatarCenterX - avatarRadius, avatarCenterY - avatarRadius)
    local bottomRightAvatar = vec2(avatarCenterX + avatarRadius, avatarCenterY + avatarRadius)

    -- 使用drawImageRounded绘制圆形图像，圆角半径等于图像半径实现圆形效果
    ui.drawImageRounded('Images/rust.jpg', topLeftAvatar, bottomRightAvatar, rgbm(1, 1, 1, 1), nil, nil, avatarRadius,
        ui.CornerFlags.All)

    ui.popDWriteFont()
    ui.popDWriteFont()
end

-- 为特定车辆渲染聊天气泡的主要函数
function chat_bubble_renderer.renderChatBubble(carData, driverData, chatBubbles, sim, bubbleDistance, nearRange, midRange, farRange, globaldt)
    local CurrentlyProcessedCar = carData
    local bubble = chatBubbles[carData.index]

    -- 计算相机距离（根据FOV调整）
    driverData[carData.index].distanceToCamera = (carData.distanceToCamera / 2) * (sim.cameraFOV / 27)

    -- 如需要则更新画布（基于时间的更新频率以提高性能）
    if not driverData[carData.index].lastCanvasUpdateTime then
        driverData[carData.index].lastCanvasUpdateTime = 0
    end

    -- 每隔一定时间更新一次画布，而不是使用车辆数量作为阈值
    local updateTimeThreshold = 1.0 / 30  -- 目标更新频率为30 FPS
    if driverData[carData.index].lastCanvasUpdateTime > updateTimeThreshold and driverData[carData.index].distanceToCamera < bubbleDistance then
        chatBubbles[carData.index].canvas:update(function()
            chat_bubble_renderer.renderBubble(CurrentlyProcessedCar,
                chatBubbles, driverData)
        end)
        driverData[carData.index].lastCanvasUpdateTime = 0
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
            -- 如果是活跃的真实消息，则显示气泡
            if bubble and bubble.active and (os.clock() - bubble.timestamp <= bubble.duration) then
                chatBubbles[carData.index].fadeTarget = 1
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
