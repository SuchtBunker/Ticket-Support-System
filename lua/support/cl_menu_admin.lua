-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

module("Support",package.seeall)

function ReadTicket()
	return {
		["ID"] = net.ReadUInt(14),
		["Creator"] = net.ReadEntity(),
		["Time"] = net.ReadUInt(17),
		["Category"] = net.ReadUInt(4),
		["Description"] = net.ReadString(),
	}
end

function ReadTickets()
	local t = {}
	for i=1, net.ReadUInt(6) do
		table.insert(t,ReadTicket())
	end
	return t
end

local function run(cmd,target)
	if cmd == "spectate" then
		RunConsoleCommand("FSpectate", target:SteamID64())
	elseif cmd == "teleport" then
		net.Start("Support:Teleport")
		net.WriteEntity(target)
		net.WriteVector(LocalPlayer():GetEyeTrace().HitPos)
		net.SendToServer()
	end
	/*
	net.Start("Admin:RunCommand")
	net.WriteString(cmd)
	net.WriteTable({["players"] = {target}})
	net.SendToServer()
	*/
end

function TicketMenu(ticket)
	if !IsValid(ticket["Creator"]) then
		Notify("Fehler beim Öffnen des Tickets!",NOTIFY_RED,5)
		return
	end
	
	local fr = Ben_Derma.Frame({
		["w"] = 345,
		["h"] = 430,
		["text"] = "Ticket - "..ticket["Creator"]:Name(),
	})

	local List = Ben_Derma.ScrollPanel({
		["parent"] = fr,
		["w"] = fr:GetWide()-10,
		["h"] = fr:GetTall()-40-60,
		["x"] = 5,
		["y"] = 35,
		["autoResizeChildrenToW"] = true,
	})

	local p = Ben_Derma.SubPanel({
		["parent"] = fr,
		["w"] = fr:GetWide()-10,
		["h"] = List:GetTall(),
	})
	List:Add(p)
	
	if Categorys[ticket["Category"]] == "Videobeweis" then
		local linkStart = select(2,string.find(ticket["Description"],"@LinkStart@"))+1
		local linkEnd, textStart = string.find(ticket["Description"],"@LinkEnd@")
		local link = string.sub(ticket["Description"],linkStart,linkEnd-1)
		ticket["Description"] = "\n\n"..string.sub(ticket["Description"],textStart+1)

		local b = Ben_Derma.Button({
			["parent"] = p,
			["w"] = p:GetWide()-23,
			["x"] = 18,
			["y"] = 105,
			["text"] = link,
			["font"] = "Font_15",
		})
		function b:Click()
			gui.OpenURL(link)
			print(link)
			chat.AddText(link)
		end
	end

	local desc = DarkRP.textWrap(ticket["Description"],"Font_20",p:GetWide()-23)
	local _, h = surface.GetTextSize(desc)

	p:SetTall(math.max(p:GetTall(),h + 85))
	function p:PrePaint()
		if !IsValid(ticket["Creator"]) then
			fr:Remove()
			Notify("Der Ersteller des Tickets ist disconnected!",NOITFY_ORANGE,5)
			return false
		end
	end
	function p:PostPaint(w,h)
		draw.SimpleText(ticket["Creator"]:Name(),"Font_25",8,0,Ben_Derma["COLOR_TEXT"])
		draw.SimpleText("Vor "..math.Round((CurTime() - ticket["Time"]) / 60).." Min","Font_20",w-5,0,Ben_Derma["COLOR_TEXT"],TEXT_ALIGN_RIGHT)
		
		draw.SimpleText("Kategorie","Font_25",13,22.5,Ben_Derma["COLOR_TEXT"])
		draw.SimpleText(Categorys[ticket["Category"]],"Font_20",18,45,Ben_Derma["COLOR_TEXT"])

		draw.SimpleText("Beschreibung","Font_25",13,75,Ben_Derma["COLOR_TEXT"])
		draw.DrawText(desc,"Font_20",18,97.5,Ben_Derma["COLOR_TEXT"])
	end

	local b = Ben_Derma.Button({
		["parent"] = fr,
		["text"] = "Spectate",
		["w"] = 100,
		["x"] = 5,
		["y"] = fr:GetTall()-60,
	})
	function b:Click()
        run("spectate",ticket["Creator"])
	end

	local b = Ben_Derma.Button({
		["parent"] = fr,
		["text"] = "Teleport",
		["w"] = 100,
		["x"] = 110,
		["y"] = fr:GetTall()-60,
	})
	function b:Click()
        run("teleport",ticket["Creator"])
	end

	local b = Ben_Derma.Button({
		["parent"] = fr,
		["text"] = "SteamID64",
		["w"] = 125,
		["x"] = 215,
		["y"] = fr:GetTall()-60,
	})
	function b:Click()
        Notify("SteamID64 kopiert!",2,5)
        SetClipboardText(ticket["Creator"]:SteamID64())
	end

	local b = Ben_Derma.Button({
		["parent"] = fr,
		["text"] = "Tode",
		["w"] = 100,
		["x"] = 5,
		["y"] = fr:GetTall()-30,
	})
	function b:Click()
		net.Start("Support:RDM")
		net.WriteEntity(ticket["Creator"])
		net.SendToServer()
		fr:Remove()
	end

	local b = Ben_Derma.Button({
		["parent"] = fr,
		["text"] = "Schließen",
		["w"] = fr:GetWide()-115,
		["x"] = 110,
		["y"] = fr:GetTall()-30,
	})
	function b:Click()
		net.Start("Support:Admin")
		net.SendToServer()
		fr:Remove()
	end
end

function TicketsMenu(tickets)
	local ticket = tickets[1]
	if !ticket then
		LocalPlayer():ChatPrint("Es sind keine Tickets offen!")
		return
	end

	local fr = Ben_Derma.Frame({
		["text"] = "Support",
		["w"] = 600,
		["h"] = 400,
	})

	local List = Ben_Derma.ScrollPanel({
		["parent"] = fr,
		["w"] = 250,
		["h"] = fr:GetTall()-40,
		["x"] = 5,
		["y"] = 35,
		["autoResizeChildrenToW"] = true,
	})

	local p = Ben_Derma.SubPanel({
		["parent"] = fr,
		["w"] = fr:GetWide()-List:GetWide()-15,
		["h"] = fr:GetTall()-40,
		["x"] = List:GetWide()+10,
		["y"] = 35,
	})

	local vidB
	for k,v in ipairs(tickets) do
		local link
		local x = select(2,string.find(v["Description"],"@LinkStart@"))
		if x then
			local linkStart = x+1
			local linkEnd, textStart = string.find(v["Description"],"@LinkEnd@")
			link = string.sub(v["Description"],linkStart,linkEnd-1)
			v["Description"] = "\n\n"..string.sub(v["Description"],textStart+1)
		end
		
		local b = Ben_Derma.Button({
			["h"] = 50,
		})
		List:Add(b)
		local tGone = 0
		function b:PrePaint(w,h)
            tGone = math.Round((CurTime() - v["Time"]) / 60)
            local percRed = tGone*60 / RedTicketTime*100
            draw.RoundedBox(0,0,0,w,h,Color(math.min(100,percRed),math.max(0,100 - percRed),0,150))
		end
		function b:PostPaint(w,h)
			local ply = v["Creator"]
			if !IsValid(ply) then
				self:Remove()
				return 
			end

			draw.SimpleText(ply:Name(),"Font_25",8,0,Ben_Derma["COLOR_TEXT"])
			draw.SimpleText(tGone.." Min","Font_20",w-5,h-2,Ben_Derma["COLOR_TEXT"],TEXT_ALIGN_RIGHT,TEXT_ALIGN_BOTTOM)
			draw.SimpleText(Categorys[v["Category"]],"Font_25",8,25,Ben_Derma["COLOR_TEXT"])
		end
		function b:Click()
			ticket = v

			if IsValid(vidB) then vidB:Remove() end

			if link then
				vidB = Ben_Derma.Button({
					["parent"] = p,
					["w"] = p:GetWide()-23,
					["x"] = 18,
					["y"] = 105,
					["text"] = link,
					["font"] = "Font_15",
				})
				function vidB:Click()
					gui.OpenURL(link)
					print(link)
					chat.AddText(link)
				end
			end
		end
		if k == 1 then b:Click() end
	end

	function p:PostPaint(w,h)
		local ply = ticket["Creator"]
		if !IsValid(ply) then
			fr:Remove()

			table.remove(tickets,k)
			TicketsMenu(tickets)

			return
		end

		draw.SimpleText(ply:Name(),"Font_25",8,0,Ben_Derma["COLOR_TEXT"])
		draw.SimpleText("Vor "..math.Round((CurTime() - ticket["Time"]) / 60).." Min","Font_20",w-5,0,Ben_Derma["COLOR_TEXT"],TEXT_ALIGN_RIGHT)
		
		draw.SimpleText("Kategorie","Font_25",13,22.5,Ben_Derma["COLOR_TEXT"])
		draw.SimpleText(Categorys[ticket["Category"]],"Font_20",18,45,Ben_Derma["COLOR_TEXT"])

		draw.SimpleText("Beschreibung","Font_25",13,75,Ben_Derma["COLOR_TEXT"])
		draw.DrawText(DarkRP.textWrap(ticket["Description"],"Font_20",w-23),"Font_20",18,97.5,Ben_Derma["COLOR_TEXT"])
	end

	local b = Ben_Derma.Button({
		["parent"] = p,
		["text"] = "Ticket annehmen",
		["w"] = p:GetWide()-13,
		["x"] = 8,
		["y"] = p:GetTall()-30,
	})
	function b:Click()
		net.Start("Support:Admin")
		net.WriteUInt(ticket["ID"],14)
		net.SendToServer()
		fr:Remove()
	end
end

net.Receive("Support:Admin",function()
	if net.ReadBool() then
		TicketMenu(ReadTicket())
	else
		TicketsMenu(ReadTickets())
	end
end)

/* RDM Manager */
local fr
net.Receive("Support:RDM",function(_,ply)
	local tar = net.ReadEntity()

	local deaths = {}
	for i=1, net.ReadUInt(4) do
		local weps = {}
		local ammo = {}
		table.insert(deaths,{
			["Time"] = net.ReadUInt(17),
			["Refunded"] = net.ReadBool(),
			["Weapons"] = weps,
			["Ammo"] = ammo,
		})

		for i2=1, net.ReadUInt(8) do
			table.insert(weps,{
				["Class"] = net.ReadString(),
				["AmmoCount"] = net.ReadUInt(16),
				["AmmoType"] = net.ReadString(),
			})
		end

		while net.ReadBool() do
			ammo[net.ReadString()] = net.ReadUInt(16)
		end
	end

	if IsValid(fr) then fr:Remove() end
	
	fr = Ben_Derma.Frame({
		["text"] = tar:Name().." - Tode",
		["w"] = 300,
		["h"] = 300,
	})

	local List = Ben_Derma.ScrollPanel({
		["parent"] = fr,
		["w"] = fr:GetWide()-10,
		["h"] = fr:GetTall()-40,
		["x"] = 5,
		["y"] = 35,
		["autoResizeChildrenToW"] = true,
	})

	for k, death in ipairs(deaths) do
		local time = os.date("%H:%M:%S",os.time()-(CurTime()-death["Time"]))
		local b = Ben_Derma.Button({
			["text"] = time,
			["h"] = 30,
		})
		function b:GreyOut() return death["Refunded"] end 
		function b:Clickable() return !death["Refunded"] end 
		function b:Click()
			local fr = Ben_Derma.Frame({
				["text"] = "Tod - "..time,
				["parent"] = fr,
				["w"] = 300,
				["h"] = 300,
			})

			local p = Ben_Derma.SubPanel({
				["parent"] = fr,
				["text"] = "Vollständiger Wert: "..DarkRP.formatMoney(CalcRefundWorth(death, false)),
				["font"] = "Font_20",
				["w"] = fr:GetWide()-10,
				["h"] = 20,
				["x"] = 5,
				["y"] = 35,
			})

			local p = Ben_Derma.SubPanel({
				["parent"] = fr,
				["text"] = "Erstattungswert: "..DarkRP.formatMoney(CalcRefundWorth(death, true)),
				["font"] = "Font_20",
				["w"] = fr:GetWide()-10,
				["h"] = 20,
				["x"] = 5,
				["y"] = 60,
			})

			local List = Ben_Derma.ScrollPanel({
				["parent"] = fr,
				["w"] = fr:GetWide()-10,
				["h"] = fr:GetTall()-115,
				["x"] = 5,
				["y"] = 85,
				["autoResizeChildrenToW"] = true,
			})

			local p = Ben_Derma.SubPanel({
				["h"] = 20,
				["font"] = "Font_20",
				["text"] = "-- Waffen --",
			})
			List:Add(p)
			for k,v in ipairs(death["Weapons"]) do
				local p = Ben_Derma.SubPanel({
					["h"] = 25,
					["text"] = ItemStoreWeaponName[v["Class"]] or v["Class"],
				})
				/*
				function p:PostPaint(w,h)
					if v["AmmoType"] == "none" then return end
					draw.SimpleText(v["AmmoCount"].." Mun.", "Font_25", w - 5, 0, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
				end
				*/
				function p:GreyOut() return NotRefundableWeapons[v["Class"]] end
				List:Add(p)
			end

			local p = Ben_Derma.SubPanel({
				["h"] = 20,
				["font"] = "Font_20",
				["text"] = "-- Munition --",
			})
			List:Add(p)
			for k,v in pairs(death["Ammo"]) do
				if v <= 0 then continue end

				local p = Ben_Derma.SubPanel({
					["h"] = 25,
					["text"] = AmmoNames[k] or k,
				})
				function p:PostPaint(w,h)
					draw.SimpleText(v, "Font_25", w - 5, 0, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
				end
				function p:GreyOut() return NotRefundableAmmo[k] end
				List:Add(p)
			end

			local b = Ben_Derma.Button({
				["parent"] = fr,
				["text"] = "Erstatten",
				["w"] = fr:GetWide()-10,
				["x"] = 5,
				["y"] = fr:GetTall()-30,
			})
			function b:Click()
				if !IsValid(tar) then
					Notify("Dieser Spieler ist disconnected!",NOTIFY_ORANGE,5)
					fr:Remove()
					return
				end

				death["Refunded"] = true
				
				net.Start("Support:RefundRDM")
				net.WriteEntity(tar)
				net.WriteUInt(k-1,4)
				net.SendToServer()
				
				fr:Remove()
				Notify("Du hast "..tar:Name().."'s Waffen erstattet!",2,5)
			end
		end
		List:Add(b)
	end
end)