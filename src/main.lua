local renderCustom                       = require "render"
local calculateDistance, _, _            = require "utils"

---@type table<integer, DriverData>, fun(index: integer)
local driverTable, updateDriverTableData = require "driverTable"

local config                             = require "config"

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
end, 0.2)



function script.update(dt)
end
