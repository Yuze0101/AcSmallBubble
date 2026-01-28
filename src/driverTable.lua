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

return driverTable, updateDriverTableData
