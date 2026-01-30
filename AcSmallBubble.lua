-- Auto-generated single file build
-- Generated at 2026-01-30 11:08:47
-- Original modules combined: config, utils, driverTable, render, main

-- Module: config
--- 配置模块
local config = {}

--- 渲染配置
config.render = {
    --- 最大显示距离（超过此距离将不再显示）
    maxDistance = 100,

    --- 最小缩放比例（最远距离时的缩放）
    minScale = 0.3,

    --- 最大缩放比例（最近距离时的缩放）
    maxScale = 1,

    --- 基础画布宽度
    baseWidth = 1200,

    --- 基础画布高度
    baseHeight = 500,

    --- 驾驶员名字字体大小
    driverNameFontSize = 52,

    --- 距离字体大小
    distanceFontSize = 42,

    --- 驾驶员名字显示区域大小
    driverNameArea = vec2(1000, 60),

    --- 距离显示区域大小
    distanceArea = vec2(1000, 40)
}

--- UI标签配置
config.ui = {
    --- 驾驶员标签大小
    driverTagSize = vec2(1000, 500)
}

config.images = {
    A = 'http://youke.xn--y7xa690gmna.cn/s1/2026/01/28/69797247a03ff.webp', -- 默认显示图像A（距离大于15米）
    B = 'http://youke.xn--y7xa690gmna.cn/s1/2026/01/28/697972490f343.webp', -- 距离5-15米显示图像B
    C = 'http://youke.xn--y7xa690gmna.cn/s1/2026/01/28/69797249dbbc5.webp', -- 距离5米以内显示图像C
}


--- 车辆的距离
config.carDistance = {
    near = 5,
    mid = 10,
    far = 15,
}

-- Module: driverTable
--- @class DriverData
--- @field carInfo ac.StateCar
--- @field chatMessage string
--- @field canvas ui.ExtraCanvas
--- @field distance number


--- @type table<integer, DriverData>
local driverTable = {}

--- @type function
--- @param index integer
local function updateDriverTableData(index)
    local carInfo = ac.getCar(index)
    if not carInfo then
        return
    end

    -- 没有所以的数据，新加到表里
    if not driverTable[index] then
        -- 保存车辆信息、聊天信息、画布信息
        driverTable[index] = {
            carInfo = carInfo,
            chatMessage = "",
            canvas = ui.ExtraCanvas(vec2(config.render.baseWidth, config.render.baseHeight), 1, render.AntialiasingMode.ExtraSharpCMAA),
            distance = 0
        }
        return
    end
    ac.debug("driverTable", driverTable)
end



-- Module: utils
--- @param focusedCar ac.StateCar
local function calculateDistance(focusedCar)
    for index, driverData in pairs(driverTable) do
        driverTable[index].distance = (driverData.carInfo.position - focusedCar.position):length()
    end
end

--- 根据距离计算缩放因子
--- @param distance number 距离
--- @return number 缩放因子
local function calculateScaleByDistance(distance)
    local maxDist = config.render.maxDistance
    local minScale = config.render.minScale
    local maxScale = config.render.maxScale

    -- 距离越小（越近），缩放越大
    -- 距离越大（越远），缩放越小
    local normalizedDistance = math.min(distance / maxDist, 1) -- 归一化到[0,1]，超过最大距离视为1
    local scale = maxScale - (maxScale - minScale) * normalizedDistance

    return math.max(minScale, scale) -- 确保不低于最小缩放
end

--- 根据缩放因子计算绘制位置
--- @param scale number 缩放因子
--- @return vec2 p1 左上角坐标
--- @return vec2 p2 右下角坐标
local function calculateDrawPosition(scale)
    local baseWidth = config.render.baseWidth
    local baseHeight = config.render.baseHeight

    local scaledWidth = baseWidth * scale
    local scaledHeight = baseHeight * scale

    local p1 = vec2((baseWidth - scaledWidth) / 2, (baseHeight - scaledHeight) / 2)
    local p2 = vec2((baseWidth + scaledWidth) / 2, (baseHeight + scaledHeight) / 2)

    return p1, p2
end


-- Module: render
--- @param carInfo ac.StateCar
local function renderName(carInfo)
    local font = ui.DWriteFont("Segoe UI"):weight(ui.DWriteFont.Weight.Regular)
    ui.pushDWriteFont(font)
    ui.beginOutline()
    -- 居中渲染消息文本
    ui.dwriteTextAligned(carInfo:driverName(), config.render.driverNameFontSize, ui.Alignment.Center, ui.Alignment
        .Center,
        config.render.driverNameArea, false, rgbm(1, 1, 1, 1))
    ui.endOutline(rgbm(1, 1, 1, 0.1))
    ui.popDWriteFont()
end

--- @param distance number
local function renderDistance(distance)
    local font = ui.DWriteFont("Segoe UI"):weight(ui.DWriteFont.Weight.Light)
    ui.pushDWriteFont(font)
    ui.dwriteTextAligned(string.format("%.1f", distance), config.render.distanceFontSize, ui.Alignment.Center,
        ui.Alignment.Center,
        config.render.distanceArea, false, rgbm(1, 1, 1, 1))
    ui.endOutline(rgbm(1, 1, 1, 0.1))
    ui.popDWriteFont()
end

--- @param distance number
local function renderImage(distance)
    local imageSource = config.images.A
    if distance < config.carDistance.near then
        imageSource = config.images.C
    elseif distance < config.carDistance.mid then
        imageSource = config.images.B
    else
        imageSource = config.images.A
    end
    if ui.isImageReady(imageSource) then
        local size = ui.imageSize(imageSource)
        local width = 800
        local height = size.y / size.x * width
        local screenWidth = config.render.baseWidth
        local screenHeight = config.render.baseHeight
        local posX = (screenWidth - width) / 2
        local posY = screenHeight - height - 20 -- 20像素边距
        ui.drawImage(imageSource, vec2(posX, posY), vec2(posX + width, posY + height), rgbm.colors.white)
    end
end

--- @param carData ac.StateCar
local function renderCustom(carData)
    if driverTable[carData.index] then
        local driverData = driverTable[carData.index]
        local canvas, carInfo, distance = driverData.canvas, driverData.carInfo, driverData.distance
        canvas:clear()
            :update(function()
                renderName(carInfo)
                renderDistance(distance)
                renderImage(distance)
            end)

        -- 根据距离计算缩放和位置
        local scale = calculateScaleByDistance(distance)
        local p1, p2 = calculateDrawPosition(scale)

        -- 绘制带缩放的画布
        ui.drawImage(canvas, p1, p2, rgbm(1, 1, 1, 1))
    else
        print("没有在driverTable 表里找到这个数据 index:", carData.index)
    end
end

-- Main module:

local Sim                                = ac.getSim()

if Sim.driverNamesShown == true then
    ui.onDriverNameTag(true, rgbm(1, 1, 1, 0.7), renderCustom, {
        tagSize = config.ui.driverTagSize
    })
end


local function getFocusedCar()
    if Sim.focusedCar ~= -1 then
        return ac.getCar(Sim.focusedCar)
    else
        return nil
    end
end

setInterval(function()
    -- 表同步
    for index, car in ac.iterateCars() do
        updateDriverTableData(car.index)
    end
    -- 有焦点车辆时，计算距离
    local focusedCar = getFocusedCar()
    ac.debug("焦点车辆", focusedCar)
    if focusedCar then
        calculateDistance(focusedCar)
    end
end, 200)



function script.update(dt)
end
