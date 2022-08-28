--[[
    TriggerEvent("Jay:VehicleControl:syncVehicleData", VehicleData, cb)
    TriggerClientEvent("Jay:VehicleControl:syncVehicleData", VehicleData, cb)
    
    Receives vehicle data from the server and updates

    @param {String} VehicleData - The VehicleData object to set
]]
RegisterServerEvent("Jay:VehicleControl:setVehicleData")
AddEventHandler("Jay:VehicleControl:setVehicleData", function(vehicle, tableData) 
    VehicleData_Server[vehicle] = tableData
end)

--[[
    TriggerEvent("Jay:VehicleControl:syncVehicleData", VehicleData, cb)
    TriggerClientEvent("Jay:VehicleControl:syncVehicleData", VehicleData, cb)
    
    Receives vehicle data from the server and updates

    @param {String} VehicleData - The VehicleData object to set
]]
RegisterNetEvent("Jay:VehicleControl:syncVehicleData")
AddEventHandler("Jay:VehicleControl:syncVehicleData", function() 
    TriggerClientEvent("Jay:VehicleControl:syncVehicleData", -1, VehicleData_Server)
end)