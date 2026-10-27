local paquetes = {}       -- [src] = { destino = indice, desde = os.time() }
local ultimaAccion = {}

local function debug(...)
    if Config.Debug then print('[jvl_reparto]', ...) end
end

local function enCooldown(src, segundos)
    local ahora = os.time()
    if ultimaAccion[src] and ahora - ultimaAccion[src] < segundos then return true end
    ultimaAccion[src] = ahora
    return false
end

local function distanciaA(src, coords)
    return #(GetEntityCoords(GetPlayerPed(src)) - coords)
end

local function sospechoso(src, motivo)
    print(('[jvl_reparto][SOSPECHOSO] %s (%d): %s'):format(GetPlayerName(src) or '?', src, motivo))
end

-- Config.Trabajo = false deja el trabajo abierto a todos
local function tieneTrabajo(src)
    return not Config.Trabajo or Bridge.obtenerTrabajo(src) == Config.Trabajo
end

-- Tomar paquete: el servidor elige el destino y lo recuerda
lib.callback.register('jvl_reparto:tomarPaquete', function(source)
    local src = source

    if enCooldown(src, 2) then return false end

    if not tieneTrabajo(src) then
        return false, Textos.sin_trabajo
    end

    if paquetes[src] then
        return false, Textos.ya_tienes
    end

    if distanciaA(src, Config.Centro) > 5.0 then
        sospechoso(src, 'tomar paquete lejos del centro')
        return false
    end

    local indice = math.random(#Config.Destinos)
    paquetes[src] = { destino = indice, desde = os.time() }
    debug(src, 'tomó paquete hacia el destino', indice)

    return Config.Destinos[indice]
end)

-- Entregar: se valida TODO antes de pagar
RegisterNetEvent('jvl_reparto:entregar', function()
    local src = source

    if enCooldown(src, 2) then return end

    local paquete = paquetes[src]
    if not paquete then return end -- no tomó paquete: evento disparado a mano

    if not tieneTrabajo(src) then return end

    local destino = Config.Destinos[paquete.destino]
    local distancia = distanciaA(src, destino)
    if distancia > Config.DistanciaEntrega then
        sospechoso(src, ('entrega a %.0f m del destino'):format(distancia))
        return
    end

    local segundos = os.time() - paquete.desde
    if segundos < Config.TiempoMinimo then
        sospechoso(src, ('entrega en %d s (mínimo %d)'):format(segundos, Config.TiempoMinimo))
        return
    end

    paquetes[src] = nil -- primero cerramos el paquete: no se puede cobrar dos veces

    local pago = math.random(Config.Pago.minimo, Config.Pago.maximo)
    if Bridge.darDinero(src, pago, 'Entrega de paquete') then
        Bridge.notificar(src, Textos.entrega_ok:format(pago), 'success')
    end
    TriggerClientEvent('jvl_reparto:entregaConfirmada', src)
    debug(src, 'entregó y cobró', pago)
end)

AddEventHandler('playerDropped', function()
    paquetes[source] = nil
    ultimaAccion[source] = nil
end)
