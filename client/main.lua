VehicleData_Client = {}

-- Setup
Citizen.CreateThread(function() 
    Citizen.Wait(50)

    registerCommandSuggestions()

    registerChatTemplates()
end)

-- Sync vehicle data every minute
Citizen.CreateThread(function() 
    while true do
        TriggerServerEvent("Jay:VehicleControl:syncVehicleData")
        Citizen.Wait(60000)
    end
end)

-- Handle the exit vehicle with door open function
Citizen.CreateThread(function() 
    while true do
        
        -- Create our timer varriable
        local VehicleExitTimer = 0

        -- Run while they hold the exit key
        while IsControlPressed(0, CONTROLS["INPUT_VEH_EXIT"].ControlIndex) do

            -- Add a tick/fram to the timer
            VehicleExitTimer = VehicleExitTimer + 1

            -- Wait until they hold it for the desired amount of time
            if VehicleExitTimer > (CONFIG["KeyPressDuration"] * 60) then

                -- Execute the step out of car with door open function
                exitVehicleWithDoorOpen()
                
            end
            
            Citizen.Wait(0)
        end

        -- Stops the timer from running again while they are holding the key
        while not IsControlJustReleased(0, CONTROLS["INPUT_VEH_EXIT"].ControlIndex) do
            Citizen.Wait(0)
        end
        
        Citizen.Wait(0)
    end
end)

RegisterCommand(_("engineCmd_name"), function(source, args, rawCommands) 
    engineCommand()
end)

RegisterCommand(_("engCmd_name"), function(source, args, rawCommands) 
    engineCommand()
end)

RegisterCommand(_("doorCmd_name"), function(source, args, rawCommands) 
    if args ~= nil then
        if args[1] == "fd" then
            doorCommand(0)
        elseif args[1] == "fp" then
            doorCommand(1)
        elseif args[1] == "rd" then
            doorCommand(2)
        elseif args[1] == "rp" then
            doorCommand(3)
        else
            sendChatMessage("Jay:VehicleControl:standard", { _U("invalidArgs", "/" .. _("doorCmd_name") .. " [fd/fp/rd/rp]") })
        end
    else 
        sendChatMessage("Jay:VehicleControl:standard", { _U("invalidArgs", "/" .. _("doorCmd_name") .. " [door]") })
    end
end)

RegisterCommand(_("windowCmd_name"), function(source, args, rawCommands) 
    if args ~= nil then
        if args[1] == "fd" then
            windowCommand(0)
        elseif args[1] == "fp" then
            windowCommand(1)
        elseif args[1] == "rd" then
            windowCommand(2)
        elseif args[1] == "rp" then
            windowCommand(3)
        else
            sendChatMessage("Jay:VehicleControl:standard", { _U("invalidArgs", "/" .. _("windowCmd_name") .. " [fd/fp/rd/rp]") })
        end
    else 
        sendChatMessage("Jay:VehicleControl:standard", { _U("invalidArgs", "/" .. _("windowCmd_name") .. " [door]") })
    end
end)

RegisterCommand(_("trunkCmd_name"), function(source, args, rawCommands) 
    trunkCommand()
end)

RegisterCommand(_("hoodCmd_name"), function(source, args, rawCommands) 
    hoodCommand()
end)



function engineCommand() 
    local playerPed = GetPlayerPed(-1)

    -- Make sure the player exists
    if isPedRealAndAlive(playerPed) then

        -- Make sure their in a vehcile
        if IsPedSittingInAnyVehicle(playerPed) then 
            local vehicle = GetVehiclePedIsIn( playerPed, false )

            -- Check if their in the driver seat of the car
            if GetPedInVehicleSeat(vehicle, -1) == playerPed then

                -- Make sure vehicle exists and player is in seat.
                if vehicle ~= nil and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, 0) then
                    -- Send the appropriate message
                    if GetIsVehicleEngineRunning(vehicle) then
                        drawNotification(_("fiveMColour_red") .. _("engineOff"))
                    else 
                        drawNotification(_("fiveMColour_green") .. _("engineOff"))
                    end
                    
                    -- Toggle the engine
                    SetVehicleEngineOn(vehicle, (not GetIsVehicleEngineRunning(vehicle)), false, true)
                end

            else 
                -- Notify the player their not in the driver seat
                drawNotification(_("fiveMColour_yellow") .. _("engineNotDriver"))
            end

        else
            -- Notify the player their not in a car
            drawNotification(_("fiveMColour_yellow") .. _("engineNotInCar"))
        end 

    end

end

function doorCommand(doorIndex)
    local playerPed = GetPlayerPed(-1)

    -- Make sure the player exists
    if isPedRealAndAlive(playerPed) then

        -- Make sure their in a vehcile
        if IsPedSittingInAnyVehicle(playerPed) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            -- Make sure the vehicle has the desired door
            if doesVehicleHaveDoor(vehicle, doorIndex) then 

                -- Make sure the player would be able to reach the door
                if isPedInSeatForDoorIndex(playerPed, vehicle, doorIndex) then

                    -- Make sure the vehicle exists
                    if vehicle ~= nil and vehicle ~= 0 and vehicle ~= 1 then
    
                        -- Check if the door is open 
                        if GetVehicleDoorAngleRatio(vehicle, doorIndex) > 0 then
                            -- Close the door
                            SetVehicleDoorShut(vehicle, doorIndex, false)

                            -- Notify the player accordingly
                            drawNotification(_("fiveMColour_red") .. _("closed", translateDoorIndex(doorIndex) .. " " .. _("door")))
                        else
                            -- Open the door
                            SetVehicleDoorOpen(vehicle, doorIndex, false, false)

                            -- Notify the player accordingly
                            drawNotification(_("fiveMColour_green") .. _("opened", translateDoorIndex(doorIndex) .. " " .. _("door")))
                        end
    
                    end
    
                end

            else 
                -- Notify the player that the door doesn't exist
                drawNotification(_("fiveMColour_yellow") .. _("doorDoesNotExist", translateDoorIndex(doorIndex) .. " " .. _("door")))
            end

        else
            local playerPos = GetEntityCoords(playerPed)
            local zoneInfrontOfPlayer = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 10.0, 0.0)
            local vehicle = getVehicleInDirection(playerPos, zoneInfrontOfPlayer)
            local rangeInfrontOfPlayer = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 20.0, 0.0)
            local vehicleInRange = getVehicleInDirection(playerPos, rangeInfrontOfPlayer)

            -- Make sure the vehicle exists
            if DoesEntityExist(vehicle) then
                if vehicle ~= nil and vehicle ~= 0 and vehicle ~= 1 then

                    -- Make sure the vehicle has the desired door
                    if doesVehicleHaveDoor(vehicle, doorIndex) then 

                        -- Check if the door is open 
                        if GetVehicleDoorAngleRatio(vehicle, doorIndex) > 0 then
                            -- Close the door
                            SetVehicleDoorShut(vehicle, doorIndex, false)

                            -- Notify the player accordingly
                            drawNotification(_("fiveMColour_red") .. _("closed", translateDoorIndex(doorIndex) .. " " .. _("door")))
                        else
                            -- Open the door
                            SetVehicleDoorOpen(vehicle, doorIndex, false, false)

                            -- Notify the player accordingly
                            drawNotification(_("fiveMColour_green") .. _("opened", translateDoorIndex(doorIndex) .. " " .. _("door")))
                        end

                    else 
                        -- Notify the player that the door doesn't exist
                        drawNotification(_("fiveMColour_yellow") .. _("doorDoesNotExist", translateDoorIndex(doorIndex) .. " " .. _("door")))
                    end

                end
            else 

                if DoesEntityExist(vehicleInRange) then
                    -- Notify the player they are too far
                    drawNotification(_("fiveMColour_yellow") .. _("tooFarDoor"))
                else
                    -- Notify the player they are not near a car
                    drawNotification(_("fiveMColour_yellow") .. _("notNearCar"))
                end

            end

        end

    end

end


function windowCommand(windowIndex)
    local playerPed = GetPlayerPed(-1)

    TriggerServerEvent("Jay:VehicleControl:syncVehicleData")

    -- Make sure the player exists
    if isPedRealAndAlive(playerPed) then

        -- Make sure their in a vehcile
        if IsPedSittingInAnyVehicle(playerPed) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            -- Make sure the vehicle has the desired window
            if doesVehicleHaveWindow(vehicle, windowIndex) then 

                -- Make sure the player would be able to reach the window
                if isPedInSeatForWindowIndex(playerPed, vehicle, windowIndex) then

                    -- Make sure the vehicle exists
                    if vehicle ~= nil then
    
                        -- Check if the window is open 
                        if isVehicleWindowOpen(vehicle, windowIndex) then

                            -- Notify the player accordingly
                            drawNotification(_("fiveMColour_green") .. _("opened", translateWindowIndex(windowIndex) .. " " .. _("window"))) 
                            
                            -- Update the vehicle data
                            setWindowData(vehicle, windowIndex)

                            -- Roll the window
                            RollDownWindow(vehicle, windowIndex)

                        elseif not isVehicleWindowOpen(vehicle, windowIndex) then

                            -- Notify the player accordingly
                            drawNotification(_("fiveMColour_red") .. _("closed", translateWindowIndex(windowIndex) .. " " .. _("window"))) 
                            
                            -- Update the vehicle data
                            setWindowData(vehicle, windowIndex)

                            -- Roll the window
                            RollUpWindow(vehicle, windowIndex)

                        end
    
                    end
    
                else
                    drawNotification(_("fiveMColour_yellow") .. _("cantReachWindow"))
                end

            else 
                -- Notify the player that the window doesn't exist
                drawNotification(_("fiveMColour_yellow") .. _("windowDoesNotExist", translateDoorIndex(windowIndex) .. " " .. _("door")))
            end

        end

    end

end

function trunkCommand()
    local playerPed = GetPlayerPed(-1)

    -- Make sure the player exists
    if isPedRealAndAlive(playerPed) then

        -- Make sure their in a vehcile
        if IsPedSittingInAnyVehicle(playerPed) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            -- Make sure the vehicle has the desired door
            if doesVehicleHaveDoor(vehicle, 5) then 

                -- Make sure the player would be able to reach the door
                if isPedInSeatForDoorIndex(playerPed, vehicle, 5) then

                    -- Make sure the vehicle exists
                    if vehicle ~= nil and vehicle ~= 0 and vehicle ~= 1 then
    
                        -- Check if the door is open 
                        if GetVehicleDoorAngleRatio(vehicle, 5) > 0 then
                            -- Close the door
                            SetVehicleDoorShut(vehicle, 5, false)

                            -- Notify the player accordingly
                            drawNotification(_("fiveMColour_red") .. _("closed", translateDoorIndex(5)))
                        else
                            -- Open the door
                            SetVehicleDoorOpen(vehicle, 5, false, false)

                            -- Notify the player accordingly
                            drawNotification(_("fiveMColour_green") .. _("opened", translateDoorIndex(5)))
                        end
    
                    end
    
                end

            else 
                -- Notify the player that the door doesn't exist
                drawNotification(_("fiveMColour_yellow") .. _("doorDoesNotExist", translateDoorIndex(5)))
            end

        else
            local playerPos = GetEntityCoords(playerPed)
            local zoneInfrontOfPlayer = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 10.0, 0.0)
            local vehicle = getVehicleInDirection(playerPos, zoneInfrontOfPlayer)
            local rangeInfrontOfPlayer = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 20.0, 0.0)
            local vehicleInRange = getVehicleInDirection(playerPos, rangeInfrontOfPlayer)

            -- Make sure the vehicle exists
            if DoesEntityExist(vehicle) then
                if vehicle ~= nil and vehicle ~= 0 and vehicle ~= 1 then

                    -- Make sure the vehicle has the desired door
                    if doesVehicleHaveDoor(vehicle, 5) then 

                        -- Check if the door is open 
                        if GetVehicleDoorAngleRatio(vehicle, 5) > 0 then
                            -- Close the door
                            SetVehicleDoorShut(vehicle, 5, false)

                            -- Notify the player accordingly
                            drawNotification(_("fiveMColour_red") .. _("closed", translateDoorIndex(5)))
                        else
                            -- Open the door
                            SetVehicleDoorOpen(vehicle, 5, false, false)

                            -- Notify the player accordingly
                            drawNotification(_("fiveMColour_green") .. _("opened", translateDoorIndex(5)))
                        end

                    else 
                        -- Notify the player that the door doesn't exist
                        drawNotification(_("fiveMColour_yellow") .. _("doorDoesNotExist", translateDoorIndex(5)))
                    end

                end
            else 

                if DoesEntityExist(vehicleInRange) then
                    -- Notify the player they are too far
                    drawNotification(_("fiveMColour_yellow") .. _("tooFarDoor"))
                else
                    -- Notify the player they are not near a car
                    drawNotification(_("fiveMColour_yellow") .. _("notNearCar"))
                end

            end

        end

    end

end

function hoodCommand()
    local playerPed = GetPlayerPed(-1)

    -- Make sure the player exists
    if isPedRealAndAlive(playerPed) then

        -- Make sure their in a vehcile
        if IsPedSittingInAnyVehicle(playerPed) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            -- Make sure the vehicle has the desired door
            if doesVehicleHaveDoor(vehicle, 4) then 

                -- Make sure the player would be able to reach the door
                if isPedInSeatForDoorIndex(playerPed, vehicle, 4) then

                    -- Make sure the vehicle exists
                    if vehicle ~= nil and vehicle ~= 0 and vehicle ~= 1 then
    
                        -- Check if the door is open 
                        if GetVehicleDoorAngleRatio(vehicle, 4) > 0 then
                            -- Close the door
                            SetVehicleDoorShut(vehicle, 4, false)

                            -- Notify the player accordingly
                            drawNotification(_("fiveMColour_red") .. _("closed", translateDoorIndex(4)))
                        else
                            -- Open the door
                            SetVehicleDoorOpen(vehicle, 4, false, false)

                            -- Notify the player accordingly
                            drawNotification(_("fiveMColour_green") .. _("opened", translateDoorIndex(4)))
                        end
    
                    end
    
                end

            else 
                -- Notify the player that the door doesn't exist
                drawNotification(_("fiveMColour_yellow") .. _("doorDoesNotExist", translateDoorIndex(5)))
            end

        else
            local playerPos = GetEntityCoords(playerPed)
            local zoneInfrontOfPlayer = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 10.0, 0.0)
            local vehicle = getVehicleInDirection(playerPos, zoneInfrontOfPlayer)
            local rangeInfrontOfPlayer = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 20.0, 0.0)
            local vehicleInRange = getVehicleInDirection(playerPos, rangeInfrontOfPlayer)

            -- Make sure the vehicle exists
            if DoesEntityExist(vehicle) then
                if vehicle ~= nil and vehicle ~= 0 and vehicle ~= 1 then

                    -- Make sure the vehicle has the desired door
                    if doesVehicleHaveDoor(vehicle, 4) then 

                        -- Check if the door is open 
                        if GetVehicleDoorAngleRatio(vehicle, 4) > 0 then
                            -- Close the door
                            SetVehicleDoorShut(vehicle, 4, false)

                            -- Notify the player accordingly
                            drawNotification(_("fiveMColour_red") .. _("closed", translateDoorIndex(4)))
                        else
                            -- Open the door
                            SetVehicleDoorOpen(vehicle, 4, false, false)

                            -- Notify the player accordingly
                            drawNotification(_("fiveMColour_green") .. _("opened", translateDoorIndex(4)))
                        end

                    else 
                        -- Notify the player that the door doesn't exist
                        drawNotification(_("fiveMColour_yellow") .. _("doorDoesNotExist", translateDoorIndex(5)))
                    end

                end
            else 

                if DoesEntityExist(vehicleInRange) then
                    -- Notify the player they are too far
                    drawNotification(_("fiveMColour_yellow") .. _("tooFarHood"))
                else
                    -- Notify the player they are not near a car
                    drawNotification(_("fiveMColour_yellow") .. _("notNearCar"))
                end

            end

        end

    end

end

function exitVehicleWithDoorOpen()
    local playerPed = GetPlayerPed(-1)

    -- Make sure the player exists
    if isPedRealAndAlive(playerPed) then

        -- Make sure their in a vehcile
        if IsPedSittingInAnyVehicle(playerPed) then 
            local vehicle = GetVehiclePedIsIn( playerPed, false )

            -- Make the player exit the vehicle with the door open
            TaskLeaveVehicle(playerPed, vehicle, 256)

        end

    end
end