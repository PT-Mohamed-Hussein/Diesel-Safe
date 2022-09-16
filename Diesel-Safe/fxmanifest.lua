fx_version 'adamant'

game 'gta5'

description 'Safe Script With Password To Store Your Items In It Created For QB-Core FrameWork'

version '1.0.0'

client_scripts {
	'config.lua',
	'client/client.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'server/server.lua'
}

dependencies {
	'qb-target',
	'qb-core',
}

lua54 'yes'