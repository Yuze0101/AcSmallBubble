local driverTable = require "driverTable"

--- @param focusedCar ac.StateCar
local function calculateDistance(focusedCar)
    for index, driverData in ipairs(driverTable) do
        driverTable[index].distance = (driverData.carInfo.position - focusedCar.position):length()
    end
end

return calculateDistance
