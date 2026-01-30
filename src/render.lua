local driverTable                                                        = require "driverTable"
local config                                                             = require "config"
---@type fun(focusedCar: ac.StateCar), fun(distance: number): number, fun(scale: number): vec2, vec2
local calculateDistance, calculateScaleByDistance, calculateDrawPosition = require "utils"

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
    -- if ui.isImageReady(imageSource) then
        local size = ui.imageSize(imageSource)
        if size.x == 0 then return end -- Avoid division by zero if size is invalid
        local width = 800
        local height = size.y / size.x * width
        local screenWidth = config.render.baseWidth
        local screenHeight = config.render.baseHeight
        local posX = (screenWidth - width) / 2
        local posY = screenHeight - height - 20 -- 20像素边距
        ui.drawImage(imageSource, vec2(posX, posY), vec2(posX + width, posY + height), rgbm.colors.white)
    -- end
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



return renderCustom
