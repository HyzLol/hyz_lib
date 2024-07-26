fx_version "cerulean"
game "gta5"

author "Hyz"
description "A lib made for hyz resources"

lua54 "y"
use_fxv2_oal "true"


client_scripts {
    "client.lua"
}

shared_scripts {
    "shared.lua"
}

server_scripts {
    "server.lua"
}

files {
    "html/*"
}

ui_page "html/index.html"