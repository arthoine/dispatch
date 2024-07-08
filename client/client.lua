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
        lib.alertDialog({
            header = 'Dispatch',
            content = 'Un coup de feu a été tiré. Voulez-vous prendre en charge cet incident?',
            centered = false,
            cancel = true,
            size = 'md',
            overflow = true,
            labels = {
                cancel = 'Non',
                confirm = 'Oui'
            },
            style = {
                top = '10px',
                right = '10px',
                position = 'fixed'
            }
        }).next(function(response)
            if response == 'confirm' then
                SetNewWaypoint(data.coords.x, data.coords.y)
                lib.notify({
                    title = 'Dispatch',
                    description = 'Vous avez accepté l\'incident.',
                    type = 'success',
                    icon = 'fa-solid fa-check',
                    position = 'top-right'
                })
            else
                lib.notify({
                    title = 'Dispatch',
                    description = 'Vous avez refusé l\'incident.',
                    type = 'error',
                    icon = 'fa-solid fa-times',
                    position = 'top-right'
                })
            end
        end)
    end
end)
