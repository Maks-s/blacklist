blacklistConfig = {}

blacklistConfig.updateAtStart = true -- Update at start ?
blacklistConfig.minuteAvantUpdate = 60 -- Minutes before checking if an update is available, 0 to deactivate ( Default: Every hour )
blacklistConfig.dontLogMe = false -- true to not be shown on https://g-box.fr/the-worst-people/la-blacklist/
blacklistConfig.nombreCommand = 10 -- Number of command before ban
blacklistConfig.tempsCommand = 70 -- Time before ban ( seconds )
blacklistConfig.doNotShare = true -- True to not allow familly sharing games
blacklistConfig.doBan = false -- Is the player banned when he spawn ( true ) or we play with him first then ban him ( false )
blacklistConfig.banIP = true -- Is the player banned ip too
blacklistConfig.bypassBanCheck = true -- Add some ban bypass protection
blacklistConfig.minPlayTime = 0 -- Minimum playtime in minutes
blacklistConfig.Whitelist = { -- Whitelisted players won't be banned
	--"STEAM_0:0:466454565",
	--"STEAM_0:1:11644158"
}
blacklistConfig.groups = { -- Banned groups, use group name in http://steamcommunity.com/groups/[group name] for adding groups, e.g http://steamcommunity.com/groups/superGroup :
	--"superGroup",
	--"ExampleGroup2"
}
blacklistConfig.countryBan = { -- Banned country, use code like FR, EN, US, AU ect...
	--"FR",
	--"US"
}