-- Initialize QBCore
local QBCore = exports['qb-core']:GetCoreObject()

-- Initialize repair status
local isRepairing = false
local repairThread = nil -- Thread to handle repair progress

-- Function to check if any window is broken
function checkWindows(vehicle)
    for i = 0, 7 do
        if not IsVehicleWindowIntact(vehicle, i) then
            print("Window broken detected: ", i)
            return true
        end
    end
    return false
end

-- Function to check if any tires are burst
function checkTires(vehicle)
    for i = 0, 5 do
        if IsVehicleTyreBurst(vehicle, i, false) then
            print("Tire burst detected: ", i)
            return true
        end
    end
    return false
end

-- Function to check if any headlights or taillights are broken
function checkLights(vehicle)
    local headlightBone = GetEntityBoneIndexByName(vehicle, "headlight_l")
    local taillightBone = GetEntityBoneIndexByName(vehicle, "taillight_l")

    if headlightBone == -1 or taillightBone == -1 then
        print("Light broken detected")
        return true
    end
    return false
end

-- Function to check the body health of the vehicle
function checkBodyDamage(vehicle)
    local bodyHealth = GetVehicleBodyHealth(vehicle)
    print("Vehicle body health: ", bodyHealth)
    if bodyHealth < Config.MaxBodyHealth then
        return true
    end
    return false
end

-- Function to check the engine health of the vehicle
function checkEngineDamage(vehicle)
    local engineHealth = GetVehicleEngineHealth(vehicle)
    print("Vehicle engine health: ", engineHealth)
    if engineHealth < Config.MaxEngineHealth then
        return true
    end
    return false
end

-- Function to check if the vehicle is fully healthy
function isVehicleFullyHealthy(vehicle)
    local engineHealthy = not checkEngineDamage(vehicle)
    local bodyHealthy = not checkBodyDamage(vehicle)
    -- Removed windowsIntact check
    local tiresIntact = not checkTires(vehicle)
    local lightsIntact = not checkLights(vehicle)

    print("Engine Healthy: ", engineHealthy)
    print("Body Healthy: ", bodyHealthy)
    -- Removed window debug print
    print("Tires Intact: ", tiresIntact)
    print("Lights Intact: ", lightsIntact)

    return engineHealthy and bodyHealthy and tiresIntact and lightsIntact
end


-- Function to calculate the repair cost based on damage
function calculateRepairCost(vehicle)
    local engineHealth = GetVehicleEngineHealth(vehicle)
    local bodyHealth = GetVehicleBodyHealth(vehicle)

    local engineDamagePercent = (Config.MaxEngineHealth - engineHealth) / Config.MaxEngineHealth
    local bodyDamagePercent = (Config.MaxBodyHealth - bodyHealth) / Config.MaxBodyHealth

    local repairCost = math.ceil((engineDamagePercent + bodyDamagePercent) * Config.CostMultiplier)

    return repairCost
end

-- Function to check if player is near any repair location
function isNearRepairLocation(playerCoords)
    for _, location in ipairs(Config.RepairLocations) do
        local distance = #(playerCoords - location.coords)
        if distance < Config.RepairRadius then
            return true, location.coords
        end
    end
    return false, nil
end

-- Function to display a custom progress bar and handle repair
function startProgressBar(repairCost, vehicle)
    local startTime = GetGameTimer()
    local duration = 5000 -- Duration in milliseconds

    repairThread = Citizen.CreateThread(function()
        while GetGameTimer() - startTime < duration do
            Citizen.Wait(0)

            -- Cancel repair if player leaves the repair radius
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local isNear, _ = isNearRepairLocation(playerCoords)

            if not isNear then
                isRepairing = false
                QBCore.Functions.Notify("Repair canceled as you left the repair area.", "error")
                return -- Exit the thread
            end

            -- Calculate progress
            local progress = (GetGameTimer() - startTime) / duration
            local barWidth = 0.2
            local barHeight = 0.01
            local x = 0.5
            local y = 0.9

            -- Draw the black outline (slightly larger than the progress bar)
            DrawRect(x, y, barWidth + 0.015, barHeight + 0.015, 0, 0, 0, 200)

            -- Draw the background
            DrawRect(x, y, barWidth, barHeight, 0, 0, 0, 150)

            -- Draw the progress
            DrawRect(x - (barWidth / 2) + (barWidth * progress / 2), y, barWidth * progress, barHeight, 255, 0, 0, 150)
        end

        -- Complete progress
        TriggerServerEvent('qb-auto-repair:repairVehicle', repairCost)
        QBCore.Functions.Notify("Vehicle repaired successfully!", "success")
        isRepairing = false
    end)
end

-- Main logic thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local isNear, repairCoords = isNearRepairLocation(playerCoords)

        if vehicle and vehicle ~= 0 and isNear and not isRepairing then
            QBCore.Functions.DrawText3D(repairCoords.x, repairCoords.y, repairCoords.z, "[E] Repair Vehicle")

            if IsControlJustReleased(0, 38) then
                if not isVehicleFullyHealthy(vehicle) then
                    local repairCost = calculateRepairCost(vehicle)
                    isRepairing = true
                    startProgressBar(repairCost, vehicle)
                else
                    QBCore.Functions.Notify('Your vehicle is already in perfect condition!', 'error')
                end
            end
        elseif isRepairing and not isNear then
            isRepairing = false
            QBCore.Functions.Notify("Repair canceled as you left the repair area.", "error")
        end
    end
end)

-- Client-side event to repair the vehicle
RegisterNetEvent('qb-auto-repair:repairVehicleClient')
AddEventHandler('qb-auto-repair:repairVehicleClient', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleDirtLevel(vehicle, 0)
    SetVehicleEngineHealth(vehicle, Config.MaxEngineHealth)
    SetVehicleBodyHealth(vehicle, Config.MaxBodyHealth)

    isRepairing = false
end)
