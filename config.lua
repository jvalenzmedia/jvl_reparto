Config = {}

Config.Framework = 'auto'     -- 'auto', 'esx', 'qbcore', 'qbox', 'nd' o 'standalone'
Config.Trabajo = false        -- nombre del trabajo requerido (ej. 'repartidor'), o false = abierto a todos
Config.Debug = false

Config.Centro = vector3(-256.13, -2591.83, 5.99)   -- donde se toman los paquetes (zona del puerto)

Config.Destinos = {
    vector3(40.47, -1911.60, 21.97),     -- Grove Street
    vector3(171.69, -1871.18, 24.40),    -- Davis
    vector3(-161.24, -1638.61, 34.03),   -- Chamberlain Hills
    vector3(-1076.19, -1027.02, 4.54),   -- Vespucci
    vector3(-1309.17, -1220.43, 8.98),   -- Vespucci Canals
    vector3(979.40, -716.49, 58.22),     -- Mirror Park
}

Config.Pago = { minimo = 350, maximo = 650 }
Config.DistanciaEntrega = 5.0       -- metros máximos para entregar (lo valida el servidor)
Config.TiempoMinimo = 30            -- segundos mínimos entre tomar y entregar
Config.DuracionEntrega = 4000       -- milisegundos de la barra de progreso
