ESX = nil
local isPolice = false
local lastShotTime = {}
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
                TriggerServerEvent('dispatch:sendShotAlert', coords)
            end
        end
    end
end)

-- Reçoit les alertes de tir et affiche une notification
RegisterNetEvent('dispatch:receiveShotAlert')
AddEventHandler('dispatch:receiveShotAlert', function(data)
    if isPolice then
        local id = 'dispatch_' .. math.random(1000, 9999)
        local notification = {
            id = id,
            title = 'Dispatch',
            description = 'Un coup de feu a été tiré. Voulez-vous prendre en charge cet incident?\n\n**[Y] Oui** | **[N] Non**',
            type = 'inform',
            icon = 'fa-solid fa-bullhorn',
            position = 'top-right',
            duration = 15000,  -- 15 seconds to respond
            showDuration = true,
            sound = { bank = 'DLC_WMSIRENS_SOUNDSET', set = 'WMSIRENS_SOUNDSET', name = 'SIRENS_AIRHORN' }
        }

        lib.notify(notification)

        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(0)
                if IsControlJustReleased(0, 246) then -- Y key
                    lib.notify({
                        id = id,
                        title = 'Dispatch',
                        description = 'Vous avez accepté l\'incident.',
                        type = 'success',
                        icon = 'fa-solid fa-check',
                        position = 'top-right'
                    })
                    SetNewWaypoint(data.coords.x, data.coords.y)
                    break
                elseif IsControlJustReleased(0, 249) then -- N key
                    lib.notify({
                        id = id,
                        title = 'Dispatch',
                        description = 'Vous avez refusé l\'incident.',
                        type = 'error',
                        icon = 'fa-solid fa-times',
                        position = 'top-right'
                    })
                    break
                end
            end
        end)
    end
end)
