fx_version 'cerulean'
game 'gta5'

author 'Lordbeerusza'
description 'Advanced Auto Repair QB-Core'
version '1.0.1'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
    '@qb-core/server/main.lua',
}

dependencies {
    'qb-core',
    'qb-progressbar',
}
