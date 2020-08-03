fx_version "adamant"
game "gta5"
description 'fizzfau-vale'

client_scripts {
	'client/client.lua',
	'config.lua'
}

server_scripts {
	'server/server.lua',
	'config.lua',
	'@mysql-async/lib/MySQL.lua'
}