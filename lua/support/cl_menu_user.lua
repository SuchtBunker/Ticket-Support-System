-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

module("Support",package.seeall)

local constructors = {
	["Base"] = function(fr,p,cb)
		local tb = Ben_Derma.TextEntry({
			["parent"] = p,
			["text"] = "Beschreibung",
			["w"] = p:GetWide()-13,
			["h"] = 105,
			["x"] = 8,
			["y"] = 55,
			["multiline"] = true,
		})

		local b = Ben_Derma.Button({
			["parent"] = p,
			["text"] = "Absenden",
			["w"] = p:GetWide()-13,
			["x"] = 8,
			["y"] = p:GetTall()-30,
		})
		function b:Click()
			net.Start("Support:User")
			net.WriteUInt(cb:GetValue(),4)
			net.WriteString(tb:GetValue())
			net.SendToServer()
			fr:Remove()
		end
	end,
	["Videobeweis"] = function(fr,p,cb)
		local tb1 = Ben_Derma.TextEntry({
			["parent"] = p,
			["text"] = "Videolink",
			["w"] = p:GetWide()-13,
			["h"] = 25,
			["x"] = 8,
			["y"] = 55,
		})
		local tb2 = Ben_Derma.TextEntry({
			["parent"] = p,
			["text"] = "Zeitpunkt im Video",
			["w"] = p:GetWide()-13,
			["h"] = 25,
			["x"] = 8,
			["y"] = 85,
		})
		local tb3 = Ben_Derma.TextEntry({
			["parent"] = p,
			["text"] = "Regelbruch",
			["w"] = p:GetWide()-13,
			["h"] = 45,
			["x"] = 8,
			["y"] = 115,
			["multiline"] = true,
		})

		local b = Ben_Derma.Button({
			["parent"] = p,
			["text"] = "Absenden",
			["w"] = p:GetWide()-13,
			["x"] = 8,
			["y"] = p:GetTall()-30,
		})
		function b:Click()
			net.Start("Support:User")
			net.WriteUInt(cb:GetValue(),4)
			net.WriteString("@LinkStart@"..tb1:GetValue().."@LinkEnd@Zeitstempel: "..tb2:GetValue().."\nRegelbruch: "..tb3:GetValue())
			net.SendToServer()
			fr:Remove()
		end
	end
}

local text = [[
Willkommen im Support-System
Hier kannst du ein Ticket erstellen, um von unseren Teammitgliedern Hilfe bei Problemen oder Antworten auf Fragen zu erhalten.

Jedoch solltest du versuchen, Konflikte vorher ohne Support zu lösen und Fragen in unserem FAQ (!faq) nachzusehen.]]

net.Receive("Support:User",function()
	if net.ReadBool() then // Create a Ticket
		local fr = Ben_Derma.Frame({
			["text"] = "Support",
			["w"] = 400,
			["h"] = 405,
		})

		local p = Ben_Derma.SubPanel({
			["parent"] = fr,
			["text"] = text,
			["w"] = fr:GetWide()-10,
			["font"] = "Font_20",
			["hToText"] = true,
			["x"] = 5,
			["y"] = 35,
		})

		local p = Ben_Derma.SubPanel({
			["parent"] = fr,
			["text"] = "Ticket erstellen",
			["w"] = fr:GetWide()-10,
			["h"] = fr:GetTall()-210,
			["x"] = 5,
			["y"] = 205,
		})

		local ops = {}
		for k,v in ipairs(Categorys) do
			table.insert(ops,{
				["text"] = v,
				["value"] = k,
			})
		end
		local cb = Ben_Derma.ComboBox({
			["parent"] = p,
			["w"] = p:GetWide()-13,
			["x"] = 8,
			["y"] = 25,
			["options"] = ops,
		})
		function cb:OnValueChanged(new,new2)
			for k,v in ipairs(p:GetChildren()) do
				if k == 1 then continue end
				v:Remove()
			end
			local const = constructors[ops[new]["text"]] or constructors["Base"]
			const(fr,p,self)
		end
		cb:SetValue(1)
	else
		local timeCreated = net.ReadUInt(17)
		local amBefore = net.ReadUInt(6)
		local fr = Ben_Derma.Frame({
			["w"] = 400,
			["h"] = 170,
			["text"] = "Support",
		})

		local p = Ben_Derma.SubPanel({
			["parent"] = fr,
			["text"] = "Du hast bereits ein offenes Ticket.\nEs ist seit "..math.Round((CurTime() - timeCreated) / 60).." Minuten offen.\nVor deinem Ticket "..(amBefore == 1 and "ist noch 1 anderes Ticket" or "sind noch "..amBefore.." andere Tickets")..".",
			["font"] = "Font_25",
			["w"] = fr:GetWide()-10,
			["h"] = 100,
			["x"] = 5,
			["y"] = 35,
		})

		local b = Ben_Derma.Button({
			["parent"] = fr,
			["text"] = "Ticket schließen",
			["w"] = fr:GetWide()-10,
			["x"] = 5,
			["y"] = p:GetTall()+40,
		})
		function b:Click()
			net.Start("Support:User")
			net.SendToServer()
			fr:Remove()
		end
	end
end)


local mat = Material("icon16/star.png")
net.Receive("Support:Rate",function(_,ply)
	local ply = net.ReadEntity()
	local name = ply:Name()

/******/
local text = [[
Hier kannst du deinen letzten Support von ]]..name..[[ bewerten.

Bitte gib eine faire Bewertung ab, diese sollte sich nicht auf die Strafe, welche du erhalten hast, beziehen, sondern die Qualität und Sachlichkeit des Supports betreffen.]]
/******/

	Notify("Dein Ticket wurde von "..ply:Name().." geschlossen!",NOTIFY_BLUE,5)
	local popped = false
	local fr = Ben_Derma.Frame({
		["text"] = "Bewertung (F3)",
		["w"] = 400,
		["h"] = 370,
		["x"] = ScrW()-405,
		["y"] = 35,
		["dontPopup"] = true,
	})
	function fr:ExtraThink()
		if !popped then
			if input.IsKeyDown(KEY_F3) then
				popped = true
				self:MakePopup()
			end
		end
	end
	function fr:OnRemove()
		gui.EnableScreenClicker(false)
	end

	local p = Ben_Derma.SubPanel({
		["parent"] = fr,
		["text"] = text,
		["w"] = fr:GetWide()-10,
		["font"] = "Font_20",
		["hToText"] = true,
		["x"] = 5,
		["y"] = 35,
	})

	local p = Ben_Derma.SubPanel({
		["parent"] = fr,
		["text"] = "Bewertung abgeben",
		["w"] = fr:GetWide()-10,
		["h"] = 180,
		["x"] = 5,
		["y"] = p:GetTall()+40,
	})

	local b = Ben_Derma.Button({
		["parent"] = p,
		["w"] = 5*32,
		["h"] = 32,
		["x"] = p:GetWide()/2 - (5*32)/2,
		["y"] = 30,
	})
	function b:GetCurStars()
		if !self:IsHovered() then return 0 end
		local x = self:LocalCursorPos()
		return math.ceil(x / 32)
	end
	b["Stars"] = 1
	function b:Paint(w,h)
		local hoverAmount = self:IsHovered() and self:GetCurStars() or false
		
		surface.SetMaterial(mat)
		for i=1, 5 do
			if (hoverAmount) then
				if hoverAmount < i then
					surface.SetDrawColor(255,255,255,50)
				else
					surface.SetDrawColor(COLOR_WHITE)
				end
			else
				if self["Stars"] < i then
					surface.SetDrawColor(255,255,255,50)
				else
					surface.SetDrawColor(COLOR_WHITE)
				end
			end
			surface.DrawTexturedRect((i-1)*32,0,32,32)
		end
	end
	function b:Click()
		b["Stars"] = self:GetCurStars()
	end

	local tb = Ben_Derma.TextEntry({
		["parent"] = p,
		["text"] = "Begründung, Kritik, Verbesserungsvorschläge etc.",
		["w"] = p:GetWide()-13,
		["h"] = 75,
		["x"] = 8,
		["y"] = 70,
		["multiline"] = true,
	})

	local steam = ply:SteamID64()
	local bs = Ben_Derma.Button({
		["parent"] = p,
		["text"] = "Absenden",
		["w"] = p:GetWide()-13,
		["x"] = 8,
		["y"] = 150,
	})
	function bs:Click()
		net.Start("Support:Rate")
		net.WriteSteamID64(steam)
		net.WriteUInt(b["Stars"],3)
		net.WriteString(tb:GetValue())
		net.SendToServer()
		fr:Remove()
		Notify("Danke für deine Bewertung!",NOTIFY_BLUE,5)
	end
end)