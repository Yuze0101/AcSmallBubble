Sim = ac.getSim()

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

-- 为所有车辆初始化数据结构
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

-- 处理会话开始事件
function onSessionStart()
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

-- 渲染远距离画布上的气泡（最低细节）
function renderBubbleFar()
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
    ui.popDWriteFont()
end

-- 渲染中距离画布上的气泡（中等细节）
function renderBubbleMid()
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
    ui.popDWriteFont()
end

-- 渲染近距离画布上的气泡（最高细节）
function renderBubbleNear()
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
    ui.popDWriteFont()
end

-- 为特定车辆渲染聊天气泡的主要函数
function renderChatBubble(carData)
    CurrentlyProcessedCar = carData
    local bubble = chatBubbles[carData.index]

    -- 计算相机距离（根据FOV调整）
    driverData[carData.index].distanceToCamera = (carData.distanceToCamera / 2) * (Sim.cameraFOV / 27)

    -- 如需要则更新画布（减少更新频率以提高性能）
    if not driverData[carData.index].lastCanvasUpdate then
        driverData[carData.index].lastCanvasUpdate = 0
    end

    if driverData[carData.index].lastCanvasUpdate > 2 * numberOfCars and driverData[carData.index].distanceToCamera < bubbleDistance and (bubble.active or bubble.mockActive) then
        chatBubbles[carData.index].far:update(renderBubbleFar)
        chatBubbles[carData.index].mid:update(renderBubbleMid)
        chatBubbles[carData.index].near:update(renderBubbleNear)
        driverData[carData.index].lastCanvasUpdate = 0
    end

    if driverData[carData.index].distanceToCamera < bubbleDistance then
        -- 计算缩放和淡化因子
        sizeScale = math.clamp((((bubbleDistance) - (driverData[carData.index].distanceToCamera)) / (bubbleDistance)) ^
        0.9, 0.249, 1)
        fadeScale = math.clamp(
        ((math.max(bubbleDistance / carsInRangeMultiplierCurrent, driverData[carData.index].distanceToCamera + 0.0001) - (driverData[carData.index].distanceToCamera)) / (bubbleDistance / carsInRangeMultiplierCurrent)) ^
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
    carsInRangeMultiplierCurrent = 0
    for i = 0, 1000 do
        if not ac.getCar(i) then
            break
        end
        if i ~= Sim.focusedCar and ac.getCar(i).isConnected and ac.getCar(i).distanceToCamera < bubbleDistance then
            carsInRangeMultiplierCurrent = carsInRangeMultiplierCurrent +
            math.clamp(((bubbleDistance - (ac.getCar(i).distanceToCamera)) / bubbleDistance) ^ 0.9, 0, 1)
        end
    end
    carsInRangeMultiplierCurrent = math.clamp(math.max(1, carsInRangeMultiplierCurrent / 2), 1, 5)
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
    ui.onDriverNameTag(false, rgbm(1, 1, 1, 0), renderChatBubble,
        { distanceMultiplier = math.ceil(bubbleDistance / 10), tagSize = vec2(1000, 200) })
end
