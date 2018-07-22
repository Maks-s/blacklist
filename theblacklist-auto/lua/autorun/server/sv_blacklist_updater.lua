util.AddNetworkString("blacklistAutoUpdate")

if !file.Exists("blacklist_gbox/","DATA") then
	file.CreateDir("blacklist_gbox")
end

if !file.Exists( "blacklist_gbox/blacklist.txt", "DATA") then
	file.Write( "blacklist_gbox/blacklist.txt", "")
end

print([[ _____ _   _  _____                                       ]])
print([[|_   _| | | ||  ___|                                      ]])
print([[  | | | |_| || |__                                        ]])
print([[  | | |  _  ||  __|                                       ]])
print([[  | | | | | || |___                                       ]])
print([[  \_/ \_| |_/\____/                                       ]])
print([[                                                          ]])
print([[______ _       ___  _____  _   __ _     _____ _____ _____ ]])
print([[| ___ \ |     / _ \/  __ \| | / /| |   |_   _/  ___|_   _|]])
print([[| |_/ / |    / /_\ \ /  \/| |/ / | |     | | \ `--.  | |  ]])
print([[| ___ \ |    |  _  | |    |    \ | |     | |  `--. \ | |  ]])
print([[| |_/ / |____| | | | \__/\| |\  \| |_____| |_/\__/ / | |  ]])
print([[\____/\_____/\_| |_/\____/\_| \_/\_____/\___/\____/  \_/  ]])
print([[                                                          ]])
print([[ _     _____  ___ ______ ___________                      ]])
print([[| |   |  _  |/ _ \|  _  \  ___|  _  \                     ]])
print([[| |   | | | / /_\ \ | | | |__ | | | |                     ]])
print([[| |   | | | |  _  | | | |  __|| | | |                     ]])
print([[| |___\ \_/ / | | | |/ /| |___| |/ /                      ]])
print([[\_____/\___/\_| |_/___/ \____/|___/                       ]])
print("")

local function showNotice()
	for _, ply in pairs(player.GetAll()) do
		if ( blacklistConfig && blacklistConfig.allowedGroups && blacklistConfig.allowedGroups[ply:GetUserGroup()] ) || ply:IsSuperAdmin() then
			ply:SendLua([[chat.AddText(Color(255,0,0),"[BL] Mise a jour disponible! Tapez blacklist_upgrade dans la console pour mettre a jour")]])
			ply:SendLua([[MsgC(Color(255,0,0),"[BL] Avant de mettre a jour regardez les codes ici: https://g-box.fr/wp-content/blacklist/sv_blacklist_gbox.lua et https://g-box.fr/wp-content/blacklist/cl_blacklist_gbox.lua")]])
		end
	end
	MsgC(Color(255,0,0), "[BL] Mise a jour disponible! Tapez blacklist_upgrade dans la console pour mettre à jour")
	MsgC(Color(255,0,0),"[BL] Avant de mettre a jour regardez les codes ici: https://g-box.fr/wp-content/blacklist/sv_blacklist_gbox.lua et https://g-box.fr/wp-content/blacklist/cl_blacklist_gbox.lua")
end

local function update()
	http.Fetch("https://g-box.fr/wp-content/blacklist/sv_blacklist_gbox.lua",function(blacklistSv)
		file.Write("blacklist_gbox/server.txt",blacklistSv)
	end,
	function(er)
		MsgC(Color(255,0,0), "[BL] Erreur de maj serveur : "..er)
		return false
	end)

	http.Fetch("https://g-box.fr/wp-content/blacklist/cl_blacklist_gbox.lua",function(blacklistCl)
		file.Write("blacklist_gbox/client.txt",blacklistCl)
	end,
	function(er)
		MsgC(Color(255,0,0), "[BL] Erreur de maj client : "..er)
		return false
	end)

	if !file.Exists("blacklist_gbox/config.txt","DATA") then
		file.Write("blacklist_gbox/config.txt", "")
	end

	http.Fetch("https://g-box.fr/wp-content/blacklist/config_blacklist_gbox.lua",function(onlineConfig) -- Config file
		local localConfig = {}
		for variableOFF in string.gmatch(file.Read("blacklist_gbox/config.txt"),"blacklistConfig%.(%w+)") do
			localConfig[variableOFF] = true
		end
		local notFound = {}
		for variableON in string.gmatch(onlineConfig,"blacklistConfig%.(%w+)") do
			if !localConfig[variableON] then
				table.insert(notFound, variableON)
			end
		end
		if table.Count(localConfig) == 0 then -- first install
			file.Write("blacklist_gbox/config.txt",onlineConfig)
			notFound = {}
		end
		for _, v in pairs(notFound) do
			if ( string.find(onlineConfig, "blacklistConfig."..v.." = {",1,true) ) then -- if it's a table
				file.Append("blacklist_gbox/config.txt","blacklistConfig."..v.." = ".. string.match(onlineConfig,"blacklistConfig%."..v.."%s=%s(%b{})").."\n" )
			else
				local final = "blacklistConfig."..v.." = ".. string.match(onlineConfig,"blacklistConfig%."..v.."%s=%s(.-)\n")
				file.Append("blacklist_gbox/config.txt",final.."\n" )
			end
		end		
	end,
	function(er)
		MsgC(Color(255,0,0), "[BL] Erreur de maj config : "..er)
		return false
	end)
	timer.Simple(10, function() -- because async http.Fetch
		RunString(file.Read("blacklist_gbox/config.txt"),"La Blacklist Config",true)
		timer.Simple(1, function() -- sometime when server is too fast config is not set properly, this leads to ERROR
			RunString(file.Read("blacklist_gbox/server.txt"),"La Blacklist Serveur",true)
		end)
		local payload = util.Compress(file.Read("blacklist_gbox/client.txt"))
		net.Start("blacklistAutoUpdate")
		net.WriteUInt(string.len(payload),16)
		net.WriteData(payload,string.len(payload)) -- Thanks to mohamed
		net.Broadcast()
	end)
	return true
end

if !file.Exists("blacklist_gbox/config.txt","DATA") or !file.Exists("blacklist_gbox/server.txt","DATA") or !file.Exists("blacklist_gbox/client.txt","DATA") then
	MsgC(Color(255,0,0), "[BL] Mise a jour disponible! Tapez blacklist_upgrade dans la console pour mettre à jour")
else
	timer.Simple(0, function()
		RunString(file.Read("blacklist_gbox/config.txt"),"La Blacklist Config",true)
		RunString(file.Read("blacklist_gbox/server.txt"),"La Blacklist Serveur",true)
		http.Fetch("https://g-box.fr/wp-content/blacklist/versionBL.txt", function(versionOnline)
			if versionOnline ~= BlacklistVersion then 
				showNotice()
			end
		end,
		function(error)
			MsgC(Color(255,0,0),"[BL] Erreur de maj : "..error)
		end)
	end)
end

timer.Create("blacklistVersionCheck", 3600, 0, function()
	http.Fetch("https://g-box.fr/wp-content/blacklist/versionBL.txt", function(versionOnline)
		if versionOnline ~= BlacklistVersion then 
			showNotice()
		end
	end,
	function(error)
		MsgC(Color(255,0,0),"[BL] Erreur de maj : "..error)
	end)
end)

hook.Add("PlayerInitialSpawn","blacklistUpdater",function(ply) -- Send to client
	local client = file.Read("blacklist_gbox/client.txt")
	if client == nil || client == "" then return end
	local payload = util.Compress(client)
	local len = string.len(payload)
	net.Start("blacklistAutoUpdate")
	net.WriteUInt(len,16)
	net.WriteData(payload,len) -- Thanks to mohamed
	net.Broadcast()
end)

concommand.Add("blacklist_upgrade",function(ply, cmd, args) 
	if !ply:IsValid() then
		MsgC(Color(255,0,0),"[BL] Updating\n")
		update()
		MsgC(Color(255,0,0),"[BL] Done updating\n")
	elseif ( blacklistConfig && blacklistConfig.allowedGroups && blacklistConfig.allowedGroups[ply:GetUserGroup()] ) || ply:IsSuperAdmin() then
		ply:SendLua([[MsgC(Color(255,0,0),"[BL] Updating\n")]])
		update()
		ply:SendLua([[MsgC(Color(255,0,0),"[BL] Done updating\n")]])
	end
end)
