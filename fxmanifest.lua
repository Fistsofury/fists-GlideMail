fx_version "adamant"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game "rdr3"

description 'Fistsofury : Glide Mail'
client_scripts {
    'client/helpers/functions.lua',
    'client/*.lua'
}

shared_scripts {
    'config.lua'
}

server_scripts {
	'server/server.lua'
}

files {
    'Mailtemplate.png',
    'selection_box_bg.png',
    'fonts/FrederickatheGreat-Regular.ttf'
}

lua54 'yes'