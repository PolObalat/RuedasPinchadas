local vehicle = nil
local lastFlatTireCount = 0

AddEventHandler('playerEnteredVehicle', function(veh)
    vehicle = veh
    lastFlatTireCount = 0
    Citizen.CreateThread(function()
        while IsPedInAnyVehicle(PlayerPedId(), false) do
            Citizen.Wait(500)

            local flatTireCount = 0
            for i = 0, 3 do
                if IsVehicleTyreBurst(vehicle, i, false) then
                    flatTireCount = flatTireCount + 1
                end
            end

            if flatTireCount ~= lastFlatTireCount then
                if flatTireCount == 2 then
                    local maxSpeed = 50.0 / 3.6
                    SetEntityMaxSpeed(vehicle, maxSpeed)
                elseif flatTireCount >= 3 then
                    SetVehicleForwardSpeed(vehicle, 0.0)
                    SetVehicleHandbrake(vehicle, true)
                else
                    SetEntityMaxSpeed(vehicle, GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDriveMaxFlatVel'))
                    SetVehicleHandbrake(vehicle, false)
                end
                lastFlatTireCount = flatTireCount
            end
        end
        vehicle = nil
    end)
end)

AddEventHandler('playerExitedVehicle', function()
    vehicle = nil
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()

        if IsPedInAnyVehicle(playerPed, false) and vehicle == nil then
            local veh = GetVehiclePedIsIn(playerPed, false)
            TriggerEvent('playerEnteredVehicle', veh)
        elseif not IsPedInAnyVehicle(playerPed, false) and vehicle ~= nil then
            TriggerEvent('playerExitedVehicle')
        end
    end
end)