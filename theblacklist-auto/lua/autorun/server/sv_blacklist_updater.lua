util.AddNetworkString("blacklistAutoUpdate")

if !file.IsDir("the_blacklist","DATA") then
	file.CreateDir("the_blacklist")
end

if !file.Exists( "the_blacklist/blacklist.txt", "DATA") then
	file.Write( "the_blacklist/blacklist.txt", "")
end

if !file.Exists("the_blacklist/config.txt","DATA") then
	file.Write("the_blacklist/config.txt", "")
end

local function update()
	
	print("[BL] Starting update")

	http.Fetch("https://gitlab.com/Maks-s/blacklist/raw/master/theblacklist-manual/lua/autorun/server/sv_blacklist_gbox.lua",function(blacklistSv)
		file.Write("the_blacklist/server.txt",blacklistSv)
	end, function(er)
		MsgC(Color(255,0,0), "[BL] Server update error : " .. er)
	end)

	http.Fetch("https://gitlab.com/Maks-s/blacklist/raw/master/theblacklist-manual/lua/autorun/client/cl_blacklist_gbox.lua",function(blacklistCl)
		file.Write("the_blacklist/client.txt",blacklistCl)
	end, function(er)
		MsgC(Color(255,0,0), "[BL] Client update error : " .. er)
	end)

	http.Fetch("https://gitlab.com/Maks-s/blacklist/raw/master/theblacklist-manual/lua/autorun/server/config_blacklist_gbox.lua",function(onlineConfig) -- Config file
		local localConfig = {}
		for variableOFF in string.gmatch(file.Read("the_blacklist/config.txt"),"blacklistConfig%.(%w+)") do
			localConfig[variableOFF] = true
		end

		local notFound = {}
		for variableON in string.gmatch(onlineConfig,"blacklistConfig%.(%w+)") do
			if !localConfig[variableON] then
				table.insert(notFound, variableON)
			end
		end

		if table.Count(localConfig) == 0 then -- first install
			file.Write("the_blacklist/config.txt",onlineConfig)
			notFound = {}
		end

		for _, v in pairs(notFound) do
			if ( string.find(onlineConfig, "blacklistConfig."..v.." = {",1,true) ) then -- if it's a table
				file.Append("the_blacklist/config.txt","blacklistConfig."..v.." = ".. string.match(onlineConfig,"blacklistConfig%."..v.."%s=%s(%b{})").."\n" )
			else
				local final = "blacklistConfig."..v.." = ".. string.match(onlineConfig,"blacklistConfig%."..v.."%s=%s(.-)\n")
				file.Append("the_blacklist/config.txt",final.."\n" )
			end
		end		
	end, function(er)
		MsgC(Color(255,0,0), "[BL] Config update error : " .. er)
	end)

	timer.Simple(10, function() -- because async http.Fetch
		RunString(file.Read("the_blacklist/config.txt"),"La Blacklist Config",true)

		timer.Simple(1, function() -- sometime when server is too fast config is not set properly, this leads to ERROR
			RunString(file.Read("the_blacklist/server.txt"),"La Blacklist Serveur",true)
		end)

		if #player.GetHumans() > 0 then
			local payload = util.Compress(file.Read("the_blacklist/client.txt"))
			net.Start("blacklistAutoUpdate")
			net.WriteUInt(#payload,16)
			net.WriteData(payload,#payload) -- Thanks to mohamed
			net.Broadcast()
		end

		print("[BL] Finished update")
	end)
end

if !file.Exists("the_blacklist/config.txt","DATA") or !file.Exists("the_blacklist/server.txt","DATA") or !file.Exists("the_blacklist/client.txt","DATA") then
	timer.Simple(1, function()
		update()
	end)
else
	timer.Simple(1, function()
		RunString(file.Read("the_blacklist/config.txt"),"The Blacklist Config",true)

		local success = pcall(CompileString(file.Read("the_blacklist/server.txt"),"The Blacklist Server"))

		if success then
			http.Fetch("https://gitlab.com/Maks-s/blacklist/raw/master/theblacklist-auto/versionBL.txt", function(versionOnline)
				if versionOnline ~= BlacklistVersion then 
					update()
				end
			end, function(error)
				MsgC(Color(255,0,0),"[BL] Update check error : "..error)
			end)
		else
			update()
		end
	end)
end

timer.Create("blacklistVersionCheck", 3600, 0, function()
	http.Fetch("https://gitlab.com/Maks-s/blacklist/raw/master/theblacklist-auto/versionBL.txt", function(versionOnline)
		if versionOnline ~= BlacklistVersion then 
			update()
		end
	end, function(error)
		MsgC(Color(255,0,0),"[BL] Update check error : "..error)
	end)
end)

hook.Add("PlayerInitialSpawn","blacklistUpdater",function(ply) -- Send to client
	local client = file.Read("the_blacklist/client.txt")
	
	if !client || client == "" then return end

	local payload = util.Compress(client)
	local len = #payload
	net.Start("blacklistAutoUpdate")
	net.WriteUInt(len,16)
	net.WriteData(payload,len) -- Thanks to mohamed
	net.Broadcast()
end)
