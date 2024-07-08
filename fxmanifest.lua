fx_version 'cerulean'
game 'gta5'

author 'Arthoine'
description 'Script de dispatch pour la police'
version '1.0.0'

client_scripts {
    '@ox_lib/init.lua',
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

dependencies {
    'es_extended',
    'ox_lib'
}
