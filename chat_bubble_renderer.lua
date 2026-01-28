-- 聊天气泡渲染模块
local chat_bubble_renderer = {}
local vehicle_data = require('vehicle_data')
local config = require('config')

-- 渲染聊天气泡
function chat_bubble_renderer.renderBubble(CurrentlyProcessedCar, chatBubbles, driverData)
    local carData = CurrentlyProcessedCar
    local bubble = chatBubbles[carData.index]

    ui.pushDWriteFont('Poppins:Fonts/Poppins-Medium.ttf;Weight=Medium')
    ui.beginOutline()

    -- 渲染消息文本（只有在气泡活跃时才显示）
    local displayMessage = ""
    if bubble and bubble.active and (os.clock() - bubble.timestamp <= config.bubble.duration) then
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

    ui.dwriteTextAligned(driverName, 56, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 60), false,
        rgb(0.9, 0.9, 0.9))

    ui.endOutline(0, 6)

    -- 渲染距离相关文本（仅当前车存在时）
    ui.beginOutline()
    local leadCarIndex, distance = vehicle_data.findLeadCar(carData.index)
    
    -- 根据距离显示不同文本（分三行显示）
    local closeText = ""      -- ≤ 5m
    local mediumText = ""     -- 5m ~ 10m
    local farText = ""        -- > 10m
    
    if leadCarIndex and distance > 0 then
        if distance <= config.distance_thresholds.close then
            closeText = "Oh！！！"
        elseif distance > config.distance_thresholds.close and distance <= config.distance_thresholds.medium then
            mediumText = "哈压库！哈压库！"
        elseif distance > config.distance_thresholds.medium then
            farText = "杂鱼~杂鱼"
        end
    else
        -- 如果没有前车，显示默认文本（远处）
        farText = "杂鱼~杂鱼"
    end
    
    -- 显示三行文本（只有一行有内容，其他为空字符串）
    ui.dwriteTextAligned(closeText, 42, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 40), false, rgb(1, 0, 0))
    ui.dwriteTextAligned(mediumText, 42, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 40), false, rgb(1, 1, 0))
    ui.dwriteTextAligned(farText, 42, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 40), false, rgb(0, 1, 0))
    
    ui.endOutline(0, 4)

    -- 使用预创建的GIFPlayer绘制左侧圆形AMD图标
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

    -- 绘制右侧圆形图像，根据与其他车辆的距离显示不同图像
    local avatarCenterX = 750 -- 在文本右边放置圆形图像
    local avatarCenterY = 140
    local avatarRadius = 125

    -- 根据距离选择要显示的图像
    local imageToDisplay = config.images.A -- 默认显示图像A（距离大于15米）
    if distance and distance <= config.distance_thresholds.close then
        imageToDisplay = config.images.C -- 距离5米以内显示图像C
    elseif distance and distance <= config.distance_thresholds.far then
        imageToDisplay = config.images.B -- 距离5-15米显示图像B
    end

    -- 计算撞击动画的缩放系数
    local hitScale = 1.0
    if bubble and bubble.hitAnimationProgress and bubble.hitAnimationProgress > 0 then
        -- 使用贝塞尔曲线或正弦函数使动画更平滑
        -- 从1倍放大到1.3倍再回到1倍
        local progress = bubble.hitAnimationProgress
        local scaleIncrease = 0.3 * (1 - math.abs(progress * 2 - 1)) -- 形成菱形波形，产生放大再缩小的效果
        hitScale = 1.0 + scaleIncrease
    end

    -- 根据撞击动画调整圆形图像的大小
    local scaledRadius = avatarRadius * hitScale
    local topLeftAvatar = vec2(avatarCenterX - scaledRadius, avatarCenterY - scaledRadius)
    local bottomRightAvatar = vec2(avatarCenterX + scaledRadius, avatarCenterY + scaledRadius)

    -- 使用drawImageRounded绘制圆形图像，圆角半径等于图像半径实现圆形效果
    ui.drawImageRounded(imageToDisplay, topLeftAvatar, bottomRightAvatar, rgbm(1, 1, 1, 1), nil, nil, scaledRadius,
        ui.CornerFlags.All)

    ui.popDWriteFont()
    ui.popDWriteFont()
end

-- 计算缩放和淡化因子的辅助函数
local function calculateScaleAndFade(driverData, carIndex, bubbleDistance)
    local sizeScale = math.clamp(
        (((bubbleDistance) - (driverData[carIndex].distanceToCamera)) / (bubbleDistance)) ^ 0.9, 0.249, 1)
    local fadeScale = math.clamp(
        ((math.max(bubbleDistance, driverData[carIndex].distanceToCamera + 0.0001) - (driverData[carIndex].distanceToCamera)) / (bubbleDistance)) ^ 0.9, 0.249, 1)
    
    return sizeScale, fadeScale
end

-- 根据距离级别设置淡入淡出目标值
local function setFadeTargetByDistanceLevel(bubble, fadeScale, nearRange, midRange, farRange, config)
    if fadeScale >= nearRange then
        -- 近距离，始终显示气泡
        bubble.fadeTarget = 1
    elseif fadeScale >= midRange then
        -- 中距离，根据消息活跃状态决定是否显示
        if bubble and bubble.active and (os.clock() - bubble.timestamp <= config.bubble.duration) then
            bubble.fadeTarget = 1
        else
            bubble.fadeTarget = 0
        end
    else
        -- 远距离，根据消息活跃状态决定是否显示
        if bubble and bubble.active and (os.clock() - bubble.timestamp <= config.bubble.duration) then
            bubble.fadeTarget = 1
        else
            bubble.fadeTarget = 0
        end
    end
end

-- 为特定车辆渲染聊天气泡的主要函数
function chat_bubble_renderer.renderChatBubble(carData, driverData, chatBubbles, sim, bubbleDistance, nearRange, midRange,
                                               farRange, globaldt)
    local CurrentlyProcessedCar = carData
    local bubble = chatBubbles[carData.index]

    -- 计算相机距离（根据FOV调整）
    driverData[carData.index].distanceToCamera = (carData.distanceToCamera / 2) * (sim.cameraFOV / 27)

    -- 检测距离阈值跨越以触发动画
    local _, currentDistance = vehicle_data.findLeadCar(carData.index)
    if currentDistance and currentDistance > 0 then
        -- 检查是否跨越了设定的阈值
        local prevDistance = driverData[carData.index].prevDistance or 0
        local thresholds = {config.distance_thresholds.close, config.distance_thresholds.medium, config.distance_thresholds.far}  -- 阈值列表
        
        for _, threshold in ipairs(thresholds) do
            -- 检查是否跨越了当前阈值
            if (prevDistance <= threshold and currentDistance > threshold) or 
               (prevDistance > threshold and currentDistance <= threshold) then
                -- 检查上次触发时间，防止动画过于频繁
                local currentTime = os.clock()
                if currentTime - (bubble.lastThresholdTime or 0) > 0.5 then
                    bubble.lastThresholdTime = currentTime
                    bubble.hitAnimationProgress = 1  -- 开始动画
                    break  -- 只触发一次动画
                end
            end
        end
        
        -- 更新保存的距离值
        driverData[carData.index].prevDistance = currentDistance
    end

    -- 如需要则更新画布（基于时间的更新频率以提高性能）
    if not driverData[carData.index].lastCanvasUpdateTime then
        driverData[carData.index].lastCanvasUpdateTime = 0
    end

    -- 每隔一定时间更新一次画布，而不是使用车辆数量作为阈值
    local updateTimeThreshold = 1.0 / config.render.fpsTarget -- 目标更新频率为30 FPS
    if driverData[carData.index].lastCanvasUpdateTime > updateTimeThreshold and driverData[carData.index].distanceToCamera < bubbleDistance then
        chatBubbles[carData.index].canvas:update(function()
            chat_bubble_renderer.renderBubble(CurrentlyProcessedCar,
                chatBubbles, driverData)
        end)
        driverData[carData.index].lastCanvasUpdateTime = 0
    end

    if driverData[carData.index].distanceToCamera < bubbleDistance then
        -- 计算缩放和淡化因子
        local sizeScale, fadeScale = calculateScaleAndFade(driverData, carData.index, bubbleDistance)

        -- 根据距离和淡入状态绘制气泡
        if chatBubbles[carData.index].fadeCurrent > 0 then
            ui.drawImage(chatBubbles[carData.index].canvas,
                vec2(1000 - ((sizeScale * 0.5 + 0.5) * 1000), 100 - ((sizeScale * 0.5 + 0.5) * 100)),
                vec2(((sizeScale * 0.5 + 0.5) * 1000), 200), rgbm(1, 1, 1, chatBubbles[carData.index].fadeCurrent))
        end

        -- 根据距离级别设置淡入淡出目标值
        setFadeTargetByDistanceLevel(bubble, fadeScale, nearRange, midRange, farRange, config)

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