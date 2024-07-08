ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Reçoit une alerte de tir du client et la renvoie à tous les policiers
RegisterServerEvent('dispatch:sendShotAlert')
AddEventHandler('dispatch:sendShotAlert', function(coords)
    TriggerClientEvent('dispatch:receiveShotAlert', -1, { coords = coords })
end)
