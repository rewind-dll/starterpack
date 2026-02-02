fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Starter Pack System with Discord Booster Integration'
version '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

ui_page 'web/dist/index.html'
files { 
    'web/dist/**/*',
    'images/**/*'  -- Optional: for local images
}

client_scripts { 'client/*.lua' }

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'oxmysql'
}
