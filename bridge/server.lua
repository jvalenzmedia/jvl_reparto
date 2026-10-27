Bridge = {}

local function iniciado(recurso)
    return GetResourceState(recurso) == 'started'
end

-- Qbox antes que QBCore: Qbox también ofrece 'qb-core' por compatibilidad
if Config.Framework ~= 'auto' then
    Bridge.framework = Config.Framework
elseif iniciado('qbx_core') then
    Bridge.framework = 'qbox'
elseif iniciado('qb-core') then
    Bridge.framework = 'qbcore'
elseif iniciado('es_extended') then
    Bridge.framework = 'esx'
elseif iniciado('ND_Core') then
    Bridge.framework = 'nd'
else
    Bridge.framework = 'standalone'
end

print(('[jvl_reparto] Framework detectado: %s'):format(Bridge.framework))

local ESX, QBCore
if Bridge.framework == 'esx' then
    ESX = exports.es_extended:getSharedObject()
elseif Bridge.framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
end

--- Devuelve el nombre del trabajo del jugador, o nil
function Bridge.obtenerTrabajo(src)
    if Bridge.framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        return xPlayer and xPlayer.job.name
    elseif Bridge.framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(src)
        return Player and Player.PlayerData.job.name
    elseif Bridge.framework == 'qbox' then
        local player = exports.qbx_core:GetPlayer(src)
        return player and player.PlayerData.job.name
    elseif Bridge.framework == 'nd' then
        local player = exports.ND_Core:getPlayer(src)
        return player and player.job
    end
    -- standalone: el "trabajo" es un permiso ACE
    return IsPlayerAceAllowed(src, 'reparto.trabajar') and Config.Trabajo or nil
end

--- Da dinero en efectivo. Devuelve true si salió bien
function Bridge.darDinero(src, cantidad, motivo)
    if Bridge.framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return false end
        xPlayer.addAccountMoney('money', cantidad, motivo)
        return true
    elseif Bridge.framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(src)
        return Player ~= nil and Player.Functions.AddMoney('cash', cantidad, motivo)
    elseif Bridge.framework == 'qbox' then
        return exports.qbx_core:AddMoney(src, 'cash', cantidad, motivo)
    elseif Bridge.framework == 'nd' then
        local player = exports.ND_Core:getPlayer(src)
        return player ~= nil and player.addMoney('cash', cantidad, motivo) == true
    end
    return (exports.ox_inventory:AddItem(src, 'money', cantidad))
end

--- Notifica al jugador
function Bridge.notificar(src, texto, tipo)
    tipo = tipo or 'inform'
    if Bridge.framework == 'esx' then
        TriggerClientEvent('esx:showNotification', src, texto, tipo == 'inform' and 'info' or tipo)
    elseif Bridge.framework == 'qbcore' then
        QBCore.Functions.Notify(src, texto, tipo == 'inform' and 'primary' or tipo)
    else
        -- Qbox, ND y standalone usan ox_lib
        TriggerClientEvent('ox_lib:notify', src, { description = texto, type = tipo })
    end
end
