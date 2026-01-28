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
            canvas = ui.ExtraCanvas(vec2(1200, 240), 1, render.AntialiasingMode.ExtraSharpCMAA),
            distance = 0
        }
        return
    end
    ac.debug("driverTable", driverTable)
end


return driverTable, updateDriverTableData
