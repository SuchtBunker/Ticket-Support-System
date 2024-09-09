-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

module("Support",package.seeall)

net.Receive("Support:RanOver",function()
	local ply = net.ReadEntity()
	if !IsValid(ply) then return end
	
	if net.ReadBool() then
		local am = net.ReadUInt(6)
		Ben_Derma.Question({
			["textYes"] = "Ansehen",
			["textNo"] = "Ignorieren",
			["title"] = "Trolling-Verdacht",
			["text"] = ply:Name().." ("..team.GetName(ply:Team())..") hat in den letzten "..(RunOverTime/60).." Minuten "..am.." Spieler überfahren!",
			["length"] = 45,
			["id"] = "runover_"..ply:UserID(),
			["onYesCallback"] = function()
				FTU.Menu(ply:SteamID64())
				net.Start("Support:RanOver")
				net.WriteEntity(ply)
				net.SendToServer()
			end,
		})
	else
		Ben_Derma.RemoveQuestion("runover_"..ply:UserID())
	end
end)

net.Receive("Support:MassRDM",function()
	local ply = net.ReadEntity()
	if !IsValid(ply) then return end

	if net.ReadBool() then
		local am = net.ReadUInt(6)
		Ben_Derma.Question({
			["textYes"] = "Ansehen",
			["textNo"] = "Ignorieren",
			["title"] = "MassenRDM-Verdacht",
			["text"] = ply:Name().." ("..team.GetName(ply:Team())..") hat in den letzten "..(MassRDMTime/60).." Minuten "..am.." Spieler getötet!",
			["length"] = 45,
			["id"] = "massRDM_"..ply:UserID(),
			["onYesCallback"] = function()
				FTU.Menu(ply:SteamID64())
				net.Start("Support:MassRDM")
				net.WriteEntity(ply)
				net.SendToServer()
			end,
		})
	else
		Ben_Derma.RemoveQuestion("massRDM_"..ply:UserID())
	end
end)