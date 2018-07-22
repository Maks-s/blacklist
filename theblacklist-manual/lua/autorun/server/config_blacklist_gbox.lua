blacklistConfig = {}

blacklistConfig.updateAtStart = true -- Pretty self-explanatory
blacklistConfig.minuteAvantUpdate = 60 -- Minutes before checking if an update is available, 0 to deactivate ( Default: Every hour )
blacklistConfig.nombreCommand = 10 -- Number of command before ban
blacklistConfig.tempsCommand = 70 -- Time before ban ( seconds )
blacklistConfig.doNotShare = true -- True to not allow familly shared games
blacklistConfig.doBan = false -- Is the player banned when he spawn ( true ) or we play with him first then ban him ( false )
blacklistConfig.banIP = true -- Is the player banned ip too
blacklistConfig.bypassBanCheck = true -- Add some ban bypass protection
blacklistConfig.minPlayTime = 0 -- Minimum playtime in minutes
blacklistConfig.Whitelist = { -- Whitelisted players won't be blacklisted
	--["STEAM_0:0:466454565"] = true,
	--["STEAM_0:1:11644158"] = true
}
blacklistConfig.groups = { -- Banned groups, use group name in http://steamcommunity.com/groups/[group name] for adding groups
	-- "roqjfanclub",
	-- "citizenhacksupport",
	-- "veryleaks",
	-- "odiumrp",
	-- "odiumpro",
	-- "BigPacket",
	-- "MPGH",
}
blacklistConfig.countryBan = { -- Banned country, use code like FR, EN, JP ect...
	--["FR"] = true,
	--["US"] = true
}
blacklistConfig.allowedGroups = { -- Groups who can use !blacklist_report and blacklist_update
	["superadmin"] = true
}
blacklistConfig.servers = { -- Blacklist server to get bans (ENDS WITH /)
	"http://localhost/"
}