-- 合并后的 AcSmallBubble 项目
-- 此文件由 build_single_file.lua 自动生成

local config = {}

-- 聊天气泡配置
config.bubble = {
    distance = 300,  -- 米
    nearRange = 0.8, -- 显示完整气泡
    midRange = 0.55, -- 显示部分气泡
    farRange = 0.3,  -- 完全隐藏气泡
    duration = 5,    -- 消息显示持续时间（秒）
}

-- 渲染配置
config.render = {
    fpsTarget = 30,  -- 目标渲染帧率
}

-- 碰撞检测配置
config.collision = {
    cooldown = 0.5,  -- 碰撞响应冷却时间（秒）
}

-- 车辆距离阈值配置
config.distance_thresholds = {
    close = 5,       -- ≤ 5m
    medium = 10,     -- 5m ~ 10m
    far = 15,        -- > 10m
}

-- 撞击动画配置
config.animation = {
    duration = 0.3,  -- 撞击动画持续时间（秒）
}

-- 图片资源配置

-- https://youke.xn--y7xa690gmna.cn/s1/2026/01/28/69797247a03ff.webp
-- https://youke.xn--y7xa690gmna.cn/s1/2026/01/28/697972490f343.webp
-- https://youke.xn--y7xa690gmna.cn/s1/2026/01/28/69797249dbbc5.webp

config.images = {
    A = 'https://youke.xn--y7xa690gmna.cn/s1/2026/01/28/69797247a03ff.webp',  -- 默认显示图像A（距离大于15米）
    B = 'https://youke.xn--y7xa690gmna.cn/s1/2026/01/28/697972490f343.webp',  -- 距离5-15米显示图像B
    C = 'https://youke.xn--y7xa690gmna.cn/s1/2026/01/28/69797249dbbc5.webp',  -- 距离5米以内显示图像C
    AMD = 'Images/amd.gif'  -- AMD图标
}



local vehicle_data = {}


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

-- 计算车辆到相机的距离
function vehicle_data.calculateDistanceToCamera(carData, sim)
    return (carData.distanceToCamera / 2) * (sim.cameraFOV / 27)
end

-- 计算范围内车辆的数量乘数
function vehicle_data.calculateCarsInRangeMultiplier(sim, bubbleDistance, chatBubbles)
    local carsInRangeMultiplierCurrent = 0
    for i, car in ac.iterateCars() do
        if i ~= sim.focusedCar and car.isConnected and car.distanceToCamera < bubbleDistance then
            carsInRangeMultiplierCurrent = carsInRangeMultiplierCurrent +
            math.clamp(((bubbleDistance - (car.distanceToCamera)) / bubbleDistance) ^ 0.9, 0, 1)
        end
    end
    return math.clamp(math.max(1, carsInRangeMultiplierCurrent / 2), 1, 5)
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



local chat_bubble_renderer = {}



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
    local closeText = ""  -- ≤ 5m
    local mediumText = "" -- 5m ~ 10m
    local farText = ""    -- > 10m

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
        imageToDisplay = config.images.C   -- 距离5米以内显示图像C
    elseif distance and distance <= config.distance_thresholds.far then
        imageToDisplay = config.images.B   -- 距离5-15米显示图像B
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
        ((math.max(bubbleDistance, driverData[carIndex].distanceToCamera + 0.0001) - (driverData[carIndex].distanceToCamera)) / (bubbleDistance)) ^
        0.9, 0.249, 1)

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
    ac.debug("driverData", driverData)
    ac.debug("cardData", carData)
    -- 检测距离阈值跨越以触发动画
    local _, currentDistance = vehicle_data.findLeadCar(carData.index)
    if currentDistance and currentDistance > 0 then
        -- 检查是否跨越了设定的阈值
        local prevDistance = driverData[carData.index].prevDistance or 0
        local thresholds = { config.distance_thresholds.close, config.distance_thresholds.medium, config
            .distance_thresholds.far } -- 阈值列表

        for _, threshold in ipairs(thresholds) do
            -- 检查是否跨越了当前阈值
            if (prevDistance <= threshold and currentDistance > threshold) or
                (prevDistance > threshold and currentDistance <= threshold) then
                -- 检查上次触发时间，防止动画过于频繁
                local currentTime = os.clock()
                if currentTime - (bubble.lastThresholdTime or 0) > 0.5 then
                    bubble.lastThresholdTime = currentTime
                    bubble.hitAnimationProgress = 1 -- 开始动画
                    break                           -- 只触发一次动画
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




local collision_detector = {}



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




local audio_manager = {}


-- 音频事件存储
local audio_events = {}

-- 初始化音频系统
function audio_manager.init()
    -- 检查音频系统是否就绪
    if not ac.isAudioReady() then
        print("音频系统尚未就绪，将在稍后重试...")
        return false
    end

    
    return true
end




-- 导入模块






-- 获取模拟器数据
local Sim = ac.getSim()

-- 初始化音频系统
local audio_initialized = audio_manager.init()

-- 配置参数（从配置模块读取）
local bubbleDistance = config.bubble.distance
local nearRange = config.bubble.nearRange
local midRange = config.bubble.midRange
local farRange = config.bubble.farRange
-- 配置结束

local driverData = {}
local chatBubbles = {}
local globaldt = 0.016
local globalTimer = 0
local carsInRangeMultiplierCurrent = 1
local fpsCounter = 0
local fpsUpdateInterval = 0               -- 控制更新频率的时间间隔（秒）
local fpsTarget = config.render.fpsTarget -- 目标更新帧率

-- 初始化车辆数据
driverData, chatBubbles = vehicle_data.init()

-- 处理会话开始事件
function onSessionStart()
    vehicle_data.onSessionStart(driverData, chatBubbles)
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
        chatBubbles[senderCarIndex].fadeTarget = 1
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

    -- 根据目标帧率计算更新间隔
    fpsUpdateInterval = 1.0 / fpsTarget

    -- 根据范围内的车辆数量计算乘数
    carsInRangeMultiplierCurrent = vehicle_data.calculateCarsInRangeMultiplier(Sim, bubbleDistance, chatBubbles)
    ac.debug("carsInRangeMultiplierCurrent", carsInRangeMultiplierCurrent)

    -- 检查是否有活动气泡需要停用
    for i, bubble in pairs(chatBubbles) do
        if bubble.active and os.clock() - bubble.timestamp > config.bubble.duration then
            bubble.fadeTarget = 0

            -- 检查是否完全淡出
            if bubble.fadeCurrent <= 0.01 then
                bubble.active = false
            end
        end

        -- 更新撞击动画进度
        if bubble.hitAnimationProgress > 0 then
            bubble.hitAnimationProgress = math.max(0, bubble.hitAnimationProgress - dt / config.animation.duration) -- 0.3秒内完成动画
        end
    end


    -- 更新lastCanvasUpdate计数器
    for index, _ in pairs(driverData) do
        -- 增加一个基于时间的更新计数器，而不是简单的递增
        driverData[index].lastCanvasUpdateTime = (driverData[index].lastCanvasUpdateTime or 0) + dt
    end
end

-- 注册聊天气泡作为驾驶员标签覆盖层
if Sim.driverNamesShown == true then
    ui.onDriverNameTag(true, rgbm(1, 1, 1, 0), function(carData)
        chat_bubble_renderer.renderChatBubble(carData, driverData, chatBubbles, Sim, bubbleDistance, nearRange, midRange,
            farRange, globaldt)
    end, { distanceMultiplier = math.ceil(bubbleDistance / 10), tagSize = vec2(1000, 200) })
end


-- 焦点车辆碰撞检测
collision_detector.setupPlayerCollisionDetection(chatBubbles, Sim)
