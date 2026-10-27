local blipDestino = nil
local puntoDestino = nil

-- Blip fijo del centro de reparto
CreateThread(function()
    local blip = AddBlipForCoord(Config.Centro.x, Config.Centro.y, Config.Centro.z)
    SetBlipSprite(blip, 478)
    SetBlipColour(blip, 17)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Centro de reparto')
    EndTextCommandSetBlipName(blip)
end)

local function dibujarMarcador(coords)
    DrawMarker(2, coords.x, coords.y, coords.z + 0.3, 0, 0, 0, 0, 0, 0,
        0.3, 0.3, 0.3, 255, 122, 26, 180, false, true, 2, false, nil, nil, false)
end

-- jvl_textui y jvl_progressbar son opcionales: si están arrancados se usan, si no, ox_lib
local function iniciado(recurso)
    return GetResourceState(recurso) == 'started'
end

local function mostrarTexto(texto)
    if iniciado('jvl_textui') then exports.jvl_textui:Show(texto) else lib.showTextUI(texto) end
end

local function ocultarTexto()
    if iniciado('jvl_textui') then exports.jvl_textui:Hide() else lib.hideTextUI() end
end

--- Devuelve true si la barra terminó y false si se canceló
local function barraProgreso()
    local dict, clip = 'anim@heists@box_carry@', 'idle'
    local bloquear = { move = true, car = true, combat = true }

    if iniciado('jvl_progressbar') then
        if exports.jvl_progressbar:isProgressActive() then return false end
        -- jvl_progressbar avisa con callbacks: una promesa lo convierte en una espera
        local p = promise.new()
        exports.jvl_progressbar:startProgressbar(Config.DuracionEntrega, Textos.entregando, dict, clip,
            function() p:resolve(true) end, function() p:resolve(false) end, bloquear)
        return Citizen.Await(p)
    end

    return lib.progressBar({
        duration = Config.DuracionEntrega,
        label = Textos.entregando,
        canCancel = true,
        disable = bloquear,
        anim = { dict = dict, clip = clip },
    })
end

local function limpiarDestino()
    if blipDestino then RemoveBlip(blipDestino) end
    if puntoDestino then puntoDestino:remove() end
    blipDestino, puntoDestino = nil, nil
    ocultarTexto()
end

local function entregar()
    local completo = barraProgreso()

    if not completo then
        lib.notify({ description = Textos.cancelado, type = 'error' })
        return
    end

    -- El cliente solo AVISA. Cuánto se paga y si es válido lo decide el servidor
    TriggerServerEvent('jvl_reparto:entregar')
end

local function crearDestino(coords)
    blipDestino = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blipDestino, 501)
    SetBlipColour(blipDestino, 17)
    SetBlipRoute(blipDestino, true) -- ruta en el GPS

    puntoDestino = lib.points.new({ coords = coords, distance = 15 })

    function puntoDestino:nearby()
        dibujarMarcador(self.coords)
        if self.currentDistance < 2.0 and IsControlJustReleased(0, 38) then
            entregar()
        end
    end

    function puntoDestino:onEnter() mostrarTexto(Textos.entregar) end
    function puntoDestino:onExit() ocultarTexto() end
end

-- Punto del centro: tomar paquete
local centro = lib.points.new({ coords = Config.Centro, distance = 15 })

function centro:nearby()
    dibujarMarcador(self.coords)
    if self.currentDistance < 2.0 and IsControlJustReleased(0, 38) then
        local destino, motivo = lib.callback.await('jvl_reparto:tomarPaquete', false)
        if not destino then
            -- con cooldown el servidor no manda motivo: no mostramos una notificación vacía
            if motivo then lib.notify({ description = motivo, type = 'error' }) end
            return
        end
        crearDestino(destino)
        lib.notify({ description = Textos.nuevo_destino, type = 'inform' })
    end
end

function centro:onEnter() mostrarTexto(Textos.tomar_paquete) end
function centro:onExit() ocultarTexto() end

-- El servidor confirma la entrega: limpiamos el destino
RegisterNetEvent('jvl_reparto:entregaConfirmada', limpiarDestino)

AddEventHandler('onResourceStop', function(recurso)
    if recurso == GetCurrentResourceName() then limpiarDestino() end
end)
