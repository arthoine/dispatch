ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Reçoit une alerte du client et la renvoie à tous les policiers
RegisterServerEvent('dispatch:sendAlert')
AddEventHandler('dispatch:sendAlert', function(description, coords)
    TriggerClientEvent('dispatch:receiveAlert', -1, description, coords)
end)
