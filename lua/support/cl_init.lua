-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

module("Support",package.seeall)

net.Receive("FAQ-Open",function()
	gui.OpenURL(FAQUrl)
end)

net.Receive("Support:AdminChose",function()
	local fr = Ben_Derma.Frame({
		["text"] = "Support",
		["w"] = 250,
		["h"] = 95,
	})
	
	local b = Ben_Derma.Button({
		["parent"] = fr,
		["text"] = "Tickets bearbeiten",
 		["w"] = fr:GetWide()-10,
		["x"] = 5,
		["y"] = 35,
	})
	function b:Click()
		net.Start("Support:AdminChose")
		net.WriteBool(false)
		net.SendToServer()
		fr:Remove()
	end
	
	local b = Ben_Derma.Button({
		["parent"] = fr,
		["text"] = "Ticket erstellen",
 		["w"] = fr:GetWide()-10,
		["x"] = 5,
		["y"] = 65,
	})
	function b:Click()
		net.Start("Support:AdminChose")
		net.WriteBool(true)
		net.SendToServer()
		fr:Remove()
	end
end)