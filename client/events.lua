
--[[
    TriggerEvent("Jay:VehicleControl:syncVehicleData", VehicleData)
    TriggerClientEvent("Jay:VehicleControl:syncVehicleData", VehicleData)
    
    Receives vehicle data from the server and updates

    @param {Object} VehicleData - The VehicleData object to set
]]
RegisterNetEvent("Jay:VehicleControl:syncVehicleData")
AddEventHandler("Jay:VehicleControl:syncVehicleData", function(VehicleData) 
    VehicleData_Client = VehicleData
end)