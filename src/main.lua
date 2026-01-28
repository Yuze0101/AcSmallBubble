local renderCustom                       = require "render"
local calculateDistance                  = require "utils"

---@type table<integer, DriverData>, fun(index: integer)
local driverTable, updateDriverTableData = require "driverTable"

local Sim                                      = ac.getSim()

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

function script.update(dt)
    -- 每frame 刷新更新车辆信息，如果没有就添加到表里, 为了表同步
    for index, car in ac.iterateCars() do
        updateDriverTableData(car.index)
    end

    -- 有焦点车辆时，计算距离
    local focusedCar = getFocusedCar()
    ac.debug("焦点车辆", focusedCar)
    if focusedCar then
        calculateDistance(focusedCar)
    end
end
