fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'jvl_reparto'
author 'JVL MediaCode'
description 'Trabajo de repartidor multi-framework (proyecto del libro Lua para FiveM)'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales/es.lua',
}
client_script 'client/main.lua'
server_scripts {
    'bridge/server.lua',
    'server/main.lua',
}
dependency 'ox_lib'
