local driverTable = require "driverTable"
local config = require "config"

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
    local centerX = config.render.centerX
    local centerY = config.render.centerY

    local scaledWidth = baseWidth * scale
    local scaledHeight = baseHeight * scale

    local p1 = vec2(centerX - scaledWidth / 2, centerY - scaledHeight / 2)
    local p2 = vec2(centerX + scaledWidth / 2, centerY + scaledHeight / 2)

    return p1, p2
end

return calculateDistance, calculateScaleByDistance, calculateDrawPosition
