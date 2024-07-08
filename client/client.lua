ESX = nil
local isPolice = false
local lastShotTime = {}
local lastDrugDealTime = {}
local cooldownTime = 15 -- secondes

-- Initialisation de ESX
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    ESX.PlayerData = ESX.GetPlayerData()

    -- Vérifie si le joueur est policier
    if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then
        isPolice = true
    end
end)

-- Met à jour le statut du job du joueur
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    if job.name == 'police' then
        isPolice = true
    else
        isPolice = false
    end
end)

-- Vérifie si un joueur tire
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        if IsPedShooting(playerPed) then
            local playerId = PlayerId()
            if not lastShotTime[playerId] or (GetGameTimer() - lastShotTime[playerId]) > (cooldownTime * 1000) then
                lastShotTime[playerId] = GetGameTimer()
                local coords = GetEntityCoords(playerPed)
                TriggerServerEvent('dispatch:sendAlert', 'Un coup de feu a été tiré.', coords)
            end
        end
    end
end)

-- todo(drogue event)
--local coords = GetEntityCoords(playerPed)
--TriggerServerEvent('dispatch:sendAlert', 'Une vente de drogue a été détectée.', coords)

-- Reçoit les alertes et affiche une notification
RegisterNetEvent('dispatch:receiveAlert')
AddEventHandler('dispatch:receiveAlert', function(description, coords)
    if isPolice then
        local id = 'dispatch_' .. math.random(1000, 9999)
        lib.notify({
            id = id,
            title = 'Dispatch',
            description = description .. '\n\n**[Enter] Oui** | **[Delete] Non**',
            type = 'inform',
            icon = 'fa-solid fa-bullhorn',
            position = 'top-right',
            duration = 15000,  -- 15 seconds to respond
            showDuration = true
        })

        Citizen.CreateThread(function()
            local timeout = GetGameTimer() + 15000
            local responded = false

            while not responded and GetGameTimer() < timeout do
                Citizen.Wait(0)

                if IsControlJustReleased(0, 191) then
                    responded = true
                    lib.notify({
                        id = id,
                        title = 'Dispatch',
                        description = 'Vous avez accepté l\'incident.',
                        type = 'success',
                        icon = 'fa-solid fa-check',
                        position = 'top-right'
                    })
                    SetNewWaypoint(coords.x, coords.y)
                elseif IsControlJustReleased(0, 178) then
                    responded = true
                    lib.notify({
                        id = id,
                        title = 'Dispatch',
                        description = 'Vous avez refusé l\'incident.',
                        type = 'error',
                        icon = 'fa-solid fa-times',
                        position = 'top-right'
                    })
                end
            end
        end)
    end
end)
