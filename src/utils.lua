local driverTable = require "driverTable"

--- @param focusedCar ac.StateCar
local function calculateDistance(focusedCar)
    for index, driverData in pairs(driverTable) do
        driverTable[index].distance = (driverData.carInfo.position - focusedCar.position):length()
    end
    ac.debug("计算后 driverTable", driverTable)
end

return calculateDistance
