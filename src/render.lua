local driverTable                                                        = require "driverTable"
local config                                                             = require "config"
---@type fun(focusedCar: ac.StateCar), fun(distance: number): number, fun(scale: number): vec2, vec2
local calculateDistance, calculateScaleByDistance, calculateDrawPosition = require "utils"

--- @param carInfo ac.StateCar
local function renderName(carInfo)
    ui.pushDWriteFont()
    ui.beginOutline()
    -- 居中渲染消息文本
    ui.dwriteTextAligned(carInfo:driverName(), 52, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 80), false,
        rgbm(1, 1, 1, 1))
    ui.endOutline(rgbm(1, 1, 1, 0.1))
    ui.popDWriteFont()
end

--- @param distance number
local function renderDistance(distance)
    ui.pushDWriteFont()
    ui.dwriteTextAligned(string.format("%.1f", distance), 42, ui.Alignment.Center, ui.Alignment.Center,
        vec2(1000, 80), false, rgbm(1, 1, 1, 1))
    ui.endOutline(rgbm(1, 1, 1, 0.1))
    ui.popDWriteFont()
end

--- @param distance number
local function renderImage(distance)
    if distance > config.render.maxDistance then
        ui.drawImage(config.images.A, vec2(1000, 240), vec2(1200, 240), rgbm(1, 1, 1, 1))
    elseif distance > config.render.maxDistance * 0.5 then
        ui.drawImage(config.images.B, vec2(1000, 240), vec2(1200, 240), rgbm(1, 1, 1, 1))
    else
        ui.drawImage(config.images.C, vec2(1000, 240), vec2(1200, 240), rgbm(1, 1, 1, 1))
    end
end


--- @param carData ac.StateCar
local function renderCustom(carData)
    if driverTable[carData.index] then
        local driverData = driverTable[carData.index]
        local canvas, carInfo, distance = driverData.canvas, driverData.carInfo, driverData.distance

        -- 更新画布
        canvas:update(function()
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
