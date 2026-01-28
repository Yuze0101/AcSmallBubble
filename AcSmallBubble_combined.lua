-- Auto-generated single file build
-- Generated at 2026-01-28 15:21:09
-- Original modules combined: utils, driverTable, render, main

-- Define globals
Sim = nil

-- Module: driverTable
--- @class DriverData
--- @field carInfo ac.StateCar
--- @field chatMessage string
--- @field canvas ui.ExtraCanvas
--- @field distance number


--- @type table<integer, DriverData>
local driverTable = {}
ac.debug("driverTable", driverTable)
--- @type function
--- @param index integer
local function updateDriverTableData(index)
    local carInfo = ac.getCar(index)
    if not carInfo then
        print("找不到这个车 索引:", index)
        return
    end

    -- 没有所以的数据，新加到表里
    if not driverTable[index] then
        print("表里没这个车", index, " 添加入 driverTable")

        -- 保存车辆信息、聊天信息、画布信息
        driverTable[index] = {
            carInfo = carInfo,
            chatMessage = "",
            canvas = ui.ExtraCanvas(vec2(1200, 240), 1, render.AntialiasingMode.ExtraSharpCMAA),
            distance = 0
        }
        return
    end
end

-- --- @param index integer
-- --- @type function
-- local function deleteDriverTableData(index)
--     if driverTable[index] then
--         print("删除 driverTable", index)
--         -- 删除canvas资源
--         if driverTable[index].canvas then
--             driverTable[index].canvas:dispose()
--         end
--         driverTable[index] = nil
--     end
-- end



-- Module: utils
--- @param focusedCar ac.StateCar
local function calculateDistance(focusedCar)
    for index, driverData in pairs(driverTable) do
        driverTable[index].distance = (driverData.carInfo.position - focusedCar.position):length()
    end
end



-- Module: render
--- @param carInfo ac.StateCar
local function renderName(carInfo)
    ui.pushDWriteFont('Poppins:Fonts/Poppins-Medium.ttf;Weight=Medium')
    -- 居中渲染消息文本
    ui.dwriteTextAligned(carInfo:driverName(), 56, ui.Alignment.Center, ui.Alignment.Center, vec2(1000, 80), false,
        rgbm(1, 1, 1, 1))
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
    end
end

--- @param carData ac.StateCar
local function renderCustom(carData)
    if driverTable[carData.index] then
        local driverData = driverTable[carData.index]
        local canvas, carInfo, distance = driverData.canvas, driverData.carInfo, driverData.distance
        -- 先清除画布 防止文字重叠
        canvas:clear()
        -- 更新画布
        canvas:update(function()
            renderName(carInfo)
            renderDistance(distance)
        end)
    else
        print("没有在driverTable 表里找到这个数据 index:", carData.index)
    end
end





-- Main module:
---
Sim                                      = ac.getSim()

if Sim.driverNamesShown == true then
    ui.onDriverNameTag(true, rgbm(1, 1, 1, 0.3), renderCustom)
end

local function getFocusedCar()
    if Sim.focusedCar ~= -1 then
        return ac.getCar(Sim.focusedCar)
    else
        return nil
    end
end

local focusedCar = getFocusedCar()
ac.debug("焦点车辆", focusedCar)



function script.update(dt)
    -- 每frame 刷新更新车辆信息，如果没有就添加到表里, 为了表同步
    for index, car in ac.iterateCars() do
        updateDriverTableData(car.index)
    end

    -- 有焦点车辆时，计算距离

    if focusedCar then
        calculateDistance(focusedCar)
    end
end
