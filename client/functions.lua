--[[
    sendChatMessage(templateID, arguments) 

    @param {String} templateID - The tempalte ID of the template to use
    @param {Array} arguments - Array of the arguments for the message
]]
function sendChatMessage(templateID, arguments) 
    TriggerEvent('chat:addMessage', 
        { 
            templateId = templateID, 
            multiline = true, 
            args = arguments
        }
    )
end


--[[
    Registers command suggestions for each command
    in the common/commands.lua file
]]
function registerCommandSuggestions()
    for i, command in ipairs(COMMANDS) do
        
        if #command.parameters == 0 then
            TriggerEvent("chat:addSuggestion", "/" .. command.name, command.description)
        else 
            TriggerEvent("chat:addSuggestion", "/" .. command.name, command.description, command.parameters)
        end

        print(GetThisScriptName() .. _("registeredCommand") .. command.name)
        Citizen.Wait(25)
        
    end
end


--[[
    Registers chat templates for each template
    in the common/chatTemplates.lua file
]]
function registerChatTemplates()
    for i, chatTemplate in ipairs(CHAT_TEMPLATES) do
        TriggerEvent("chat:addTemplate", chatTemplate.templateId, chatTemplate.htmlString)
    
        print(GetThisScriptName() .. _("registeredChatTemplate") .. chatTemplate.templateId)
        Citizen.Wait(25)
    end
end


--[[
    drawNotification(message)
    Displayes a message above the map

    @param {String} message - The message to display
]]
function drawNotification(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
end


--[[
    isPedRealAndAlive(playerPed)
    Checks to make sure a player exists and is not dead

    @param {Entity} - The player ped of the entity to test (See GetPlayerPed())

    @returns {Boolean} Returns true when the ped is real and alive and false otherwise
]]
function isPedRealAndAlive(playerPed) 

    if DoesEntityExist(playerPed) and not IsEntityDead(playerPed) then 
        return true 
    else
        return false 
    end

end


--[[
    isVehicleLocked(vehicle) 
    Checks to see if a vehicle is locked

    @param {Vehicle} vehicle - The vehicle to check

    @returns {nil|Boolean} returns nil when the vehicle 
    doesn't exist otherwise will return a boolean
]]
function isVehicleLocked(vehicle) 

    if not DoesEntityExist(vehicle) then return nil end         -- Make sure the vehicle is real

    local lockState = GetVehicleDoorLockStatus(vehicle)

    if lockstate == 0 then return nil end

    if lockState == 0 or lockState == 1 then
        return false
    else
        return true
    end

end


--[[
    doesVehicleHaveDoor(vehicle, doorIndex)
    Checks if a vehicle has a specific door

    Vehicle Door Indexes:
    0 = Front Driver
    1 = Rear Driver
    2 = Front Passenger
    3 = Rear Passenger
    4 = Hood
    5 = Trunk

    @param {Vehicle} vehicle - The vehicle to check
    @param {Integer} doorIndex - The index of the door to check

    @returns {nil|Boolean} returns nil when either the vehicle
    doesn't exist or the doorIndex is out of value otherwise
    it returns a boolean
]]
function doesVehicleHaveDoor(vehicle, doorIndex) 

    if not isDoorIndexValid(doorIndex) then return nil end      -- Make sure the doorIndex is valid
    if not DoesEntityExist(vehicle) then return nil end         -- Make sure the vehicle is real

    local value = GetIsDoorValid(vehicle, doorIndex)

    return value

end


--[[
    doesVehicleHaveWindow(vehicle, windowIndex)
    Checks if a vehicle has a specific window

    Vehicle Window Indexes:
    0 = Front Driver
    1 = Front Passenger
    2 = Rear Driver
    3 = Rear Passenger

    @param {Vehicle} vehicle - The vehicle to check
    @param {Integer} windowIndex - The index of the window to check

    @returns {nil|Boolean} returns nil when either the vehicle
    doesn't exist or the windowIndex is out of value otherwise
    it returns a boolean
]]
function doesVehicleHaveWindow(vehicle, windowIndex) 

    if not isWindowIndexValid(windowIndex) then return nil end      -- Make sure the windowIndex is valid
    if not DoesEntityExist(vehicle) then return nil end         -- Make sure the vehicle is real

    doorIndex = windowIndexToDoorIndex(windowIndex)

    local value = GetIsDoorValid(vehicle, doorIndex)

    return value

end


--[[
    isVehicleDoorOpen(vehicle, doorIndex)
    Checks if a vehicle's door is open or not

    Vehicle Door Indexes:
    0 = Front Driver
    1 = Rear Driver
    2 = Front Passenger
    3 = Rear Passenger
    4 = Hood
    5 = Trunk

    @param {Vehicle} vehicle - The vehicle to check
    @param {Integer} doorIndex - The index of the door to check

    @returns {nil|Boolean} The function will return nil when either
    the vehicle doesn't exist, the doorIndex is out of value, 
    the vehicle doesn't have the requested door. Otherwise it returns
]]
function isVehicleDoorOpen(vehicle, doorIndex)

    if not isDoorIndexValid(doorIndex) then return nil end                      -- Make sure the doorIndex is valid
    if not DoesEntityExist(vehicle) then return nil end                         -- Make sure the vehicle is real
    if not doesVehicleHaveDoor(vehicle, doorIndex) then return nil end           -- Make sure the vehicle has the door

    if GetVehicleDoorAngleRatio(vehicle, doorIndex) > 0 then
        return true
    else
        return false
    end

end


--[[
    isVehicleWindowOpen(vehicle, windowIndex)
    Checks if a vehicle's window is open or not

    Vehicle Window Indexes:
    0 = Front Driver
    1 = Front Passenger
    2 = Rear Driver
    3 = Rear Passenger

    @param {Vehicle} vehicle - The vehicle to check
    @param {Integer} windowIndex - The index of the window to check

    @returns {nil|Boolean} The function will return nil when either,
    the vehicle doesn't exist, the windowIndex is out of value,
    the vehicle doesn't have the requested windowwindowIndex otherwise
    it will return a boolean.

]]
function isVehicleWindowOpen(vehicle, windowIndex)
    key = getKeyFromWindowIndex(windowIndex)

    if key == nil then return nil end
    if not isWindowIndexValid(windowIndex) then return nil end                      -- Make sure the windowIndex is valid
    if not DoesEntityExist(vehicle) then return nil end                         -- Make sure the vehicle is real
    if not doesVehicleHaveWindow(vehicle, windowIndex) then return nil end           -- Make sure the vehicle has the window

    TriggerServerEvent("Jay:VehicleControl:syncVehicleData")

    Citizen.Wait(100)

    if VehicleData_Client[vehicle] == nil then
        return true
    else
        if VehicleData_Client[vehicle]["windows"][key] then
            return true
        elseif not VehicleData_Client[vehicle]["windows"][key] then
            return false
        end
    end

end


--[[
    isDoorIndexValid(doorIndex) 
    Checks if a value is allowed as a doorIndex

    Vehicle Door Indexes:
    0 = Front Driver
    1 = Rear Driver
    2 = Front Passenger
    3 = Rear Passenger
    4 = Hood
    5 = Trunk

    @param {Interger} doorIndex - The index of the door to check

    @returns {Boolean} Returns true when the index is valid
    and false otherwise.
]]
function isDoorIndexValid(doorIndex) 
    if doorIndex >= 0 and doorIndex <= 5 then
        return true
    else
        return false
    end
end


--[[
    isWindowIndexValid(windowIndex) 
    Checks if a value is allowed as a windowIndex

    Vehicle Window Indexes:
    0 = Front Driver
    1 = Front Passenger
    2 = Rear Driver
    3 = Rear Passenger

    @windowIndex - The index of the window to check

    @returns - boolean
]]
function isWindowIndexValid(windowIndex) 
    if windowIndex >= 0 and windowIndex <= 3 then
        return true
    else
        return false
    end
end


--[[
    windowIndexToDoorIndex(windowIndex) 
    Gets the door index for a window index

    Vehicle Window Indexes:
    0 = Front Driver
    1 = Front Passenger
    2 = Rear Driver
    3 = Rear Passenger

    Vehicle Door Indexes:
    0 = Front Driver
    1 = Rear Driver
    2 = Front Passenger
    3 = Rear Passenger

    @windowIndex - The index of the window to check

    @returns - number
]]
function windowIndexToDoorIndex(windowIndex) 
    if windowIndex == 0 then
        return 0
    elseif windowIndex == 1 then
        return 1
    elseif windowIndex == 2 then
        return 2
    elseif windowIndex == 3 then
        return 3
    else 
        return nil
    end
end


--[[
    translateDoorIndex(doorIndex)
    Coverts a doorIndex int to a string

    Vehicle Door Indexes:
    0 = Front Driver
    1 = Rear Driver
    2 = Front Passenger
    3 = Rear Passenger
    4 = Hood
    5 = Trunk

    @doorIndex - The index of the door

    @returns - String

    @nilReturns
    The function will return nil when
        the doorIndex is out of value
]]
function translateDoorIndex(doorIndex)

    if not isDoorIndexValid(doorIndex) then return nil end      -- Make sure the doorIndex is valid

    if doorIndex == 0 then
        return _U("frontDriver")
    elseif doorIndex == 1 then
        return _U("frontPassenger")
    elseif doorIndex == 2 then
        return _U("rearDriver")
    elseif doorIndex == 3 then
        return _U("rearPassenger")
    elseif doorIndex == 4 then
        return _U("hood")
    elseif doorIndex == 5 then
        return _U("trunk")
    end

end


--[[
    translateWindowIndex(windowIndex)
    Coverts a windowIndex int to a string

    Vehicle Window Indexes:
    0 = Front Driver
    1 = Front Passenger
    2 = Rear Driver
    3 = Rear Passenger

    @windowIndex - The index of the window

    @returns - String

    @nilReturns
    The function will return nil when
        the windowIndex is out of value
]]
function translateWindowIndex(windowIndex)

    if not isWindowIndexValid(windowIndex) then return nil end      -- Make sure the windowIndex is valid

    if windowIndex == 0 then
        return _U("frontDriver")
    elseif windowIndex == 1 then
        return _U("frontPassenger")
    elseif windowIndex == 2 then
        return _U("rearDriver")
    elseif windowIndex == 3 then
        return _U("rearPassenger")
    end

end


--[[
    isPedInSeatForDoorIndex(playerPed, vehicle, doorIndex)
    Checks if the player is in an appropriate seat to access
    a sepcific door.

    @playerPed - The player to check
    @vehicle - The vehicle to check
    @doorIndex - The index of the door to check

    @returns - boolean

    @nilReturns 
    The function will return nil when either 
        the player doesn't exist
        the vehicle doesn't exist
        the doorIndex is out of value
        the vehicle doesn't have the requested door
]]
function isPedInSeatForDoorIndex(playerPed, vehicle, doorIndex) 

    if not isPedRealAndAlive(playerPed) then return nil end                 -- Make sure the playerPed is real
    if not DoesEntityExist(vehicle) then return nil end                     -- Make sure the vehicle is real
    if not isDoorIndexValid(doorIndex) then return nil end                  -- Make sure the doorIndex is valid
    if not doesVehicleHaveDoor(vehicle, doorIndex) then return nil end      -- Make sure the vehicle has that door    

    if doorIndex == 0 or doorIndex == 4 or doorIndex == 5 then
        -- check for front driver
        if GetPedInVehicleSeat(vehicle, -1) == playerPed then
            return true
        else 
            return false
        end
    elseif doorIndex == 2 then
        -- check for front passenger
        if GetPedInVehicleSeat(vehicle, 0) == playerPed then
            return true
        else 
            return false
        end
    elseif doorIndex == 1 then
        -- check for rear driver
        if GetPedInVehicleSeat(vehicle, 1) == playerPed then
            return true
        else 
            return false
        end
    elseif doorIndex == 3 then
        -- check for rear passenger
        if GetPedInVehicleSeat(vehicle, 2) == playerPed then
            return true
        else 
            return false
        end
    end

end


--[[
    isPedInSeatForWindowIndex(playerPed, vehicle, windowIndex)
    Checks if the player is in an appropriate seat to access
    a sepcific door.

    Vehicle Window Indexes:
    0 = Front Driver
    1 = Front Passenger
    2 = Rear Driver
    3 = Rear Passenger

    @playerPed - The player to check
    @vehicle - The vehicle to check
    @windowIndex - The index of the window to check

    @returns - boolean

    @nilReturns 
    The function will return nil when either 
        the player doesn't exist
        the vehicle doesn't exist
        the windowIndex is out of value
        the vehicle doesn't have the requested window
]]
function isPedInSeatForWindowIndex(playerPed, vehicle, windowIndex) 

    if not isPedRealAndAlive(playerPed) then return nil end                     -- Make sure the playerPed is real
    if not DoesEntityExist(vehicle) then return nil end                         -- Make sure the vehicle is real
    if not isWindowIndexValid(windowIndex) then return nil end                  -- Make sure the windowIndex is valid
    if not doesVehicleHaveWindow(vehicle, windowIndex) then return nil end      -- Make sure the vehicle has that window    

    if windowIndex == 0 then
        -- check for front driver
        if GetPedInVehicleSeat(vehicle, -1) == playerPed then
            return true
        else 
            return false
        end
    elseif windowIndex == 1 then
        -- check for front passenger
        if GetPedInVehicleSeat(vehicle, 0) == playerPed or GetPedInVehicleSeat(vehicle, -1) == playerPed then
            return true
        else 
            return false
        end
    elseif windowIndex == 2 then
        -- check for rear driver
        if GetPedInVehicleSeat(vehicle, 1) == playerPed or GetPedInVehicleSeat(vehicle, -1) == playerPed then
            return true
        else 
            return false
        end
    elseif windowIndex == 3 then
        -- check for rear passenger
        if GetPedInVehicleSeat(vehicle, 2) == playerPed or GetPedInVehicleSeat(vehicle, -1) == playerPed then
            return true
        else 
            return false
        end
    end

end


--[[
    DO NOT USE, OLD METHOD
]]
function getKeyFromWindowIndex(windowIndex) 
    if windowIndex == 0 then
        return "fd"
    elseif windowIndex == 1 then
        return "fp"
    elseif windowIndex == 2 then
        return"rd"
    elseif windowIndex == 3 then
        return "rp"
    else
        return nil
    end
end


--[[
    TODO: Document Function
]]
function setWindowData(vehicle, windowIndex) 
    key = getKeyFromWindowIndex(windowIndex)

    if key == nil then return nil end
    
    if VehicleData_Client[vehicle] == nil then
        VehicleData_Client[vehicle] = {
            locked = false,
            key = nil,
            windows = {
                fd = true,
                fp = true,
                rd = true,
                rp = true
            }
        }
    end

    VehicleData_Client[vehicle]["windows"][key] = not VehicleData_Client[vehicle]["windows"][key]

    TriggerServerEvent("Jay:VehicleControl:setVehicleData", vehicle, VehicleData_Client[vehicle])

    TriggerServerEvent("Jay:VehicleControl:syncVehicleData")
end


--[[
    TODO: Document Function
]]
function getVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed(-1), 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end