local QBCore = exports['qb-core']:GetCoreObject()
local vehicleRepairStatus = {} -- Track repair status for each player
local repairThreshold = 999.5  -- Same buffer as client side

RegisterNetEvent('qb-auto-repair:repairVehicle')
AddEventHandler('qb-auto-repair:repairVehicle', function(repairCost)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    -- Check if player has enough money
    if Player.Functions.RemoveMoney('cash', repairCost, 'vehicle-repair') then
        -- Notify the player of successful repair
        TriggerClientEvent('QBCore:Notify', src, 'Your vehicle has been repaired! Cost: $' .. repairCost, 'success')
        -- Repair the vehicle on the client side
        TriggerClientEvent('qb-auto-repair:repairVehicleClient', src)
    else
        -- Notify the player of insufficient funds
        TriggerClientEvent('QBCore:Notify', src, 'You do not have enough money to repair the vehicle. Cost: $' .. repairCost, 'error')
    end
end)