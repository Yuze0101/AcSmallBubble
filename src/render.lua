local driverTable = require "driverTable"


--- @param carInfo ac.StateCar
local function renderName(carInfo)
    ui.pushDWriteFont('Poppins:Fonts/Poppins-Medium.ttf;Weight=Medium')
    ui.beginOutline()
    -- 居中渲染消息文本
    ui.dwriteTextAligned(carInfo:driverName(), 56, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 80), false,
        rgbm(1, 1, 1, 1))
    ui.endOutline(rgbm(1, 1, 1, 0.1))
    ui.popDWriteFont()
end

--- @param distance number
local function renderDistance(distance)
    -- 有焦点车 才渲染距离
    local focusedCar = ac.getCar(Sim.focusedCar)
    if focusedCar then
        ui.pushDWriteFont('Poppins:Fonts/Poppins-Medium.ttf;Weight=Medium')
        ui.dwriteTextAligned(string.format("%.1f", distance), 56, ui.Alignment.Center, ui.Alignment.Center,
            vec2(1000, 80), false, rgbm(1, 1, 1, 1))
        ui.endOutline(rgbm(1, 1, 1, 0.1))
        ui.popDWriteFont()
    end
end

--- @param carData ac.StateCar
local function renderCustom(carData)
    ac.debug('nameTag渲染', carData)
    ac.debug('nameTag渲染 index', carData.index)
    ac.debug('nameTag渲染  driverTable[carData.index]', driverTable[carData.index])
    if driverTable[carData.index] then
        local driverData = driverTable[carData.index]
        local canvas, carInfo, distance = driverData.canvas, driverData.carInfo, driverData.distance
        -- 更新画布
        canvas:update(function()
            renderName(carInfo)
            renderDistance(distance)
        end)
    else
        print("没有在driverTable 表里找到这个数据 index:", carData.index)
    end
end



return renderCustom
