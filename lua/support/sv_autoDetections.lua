-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

module("Support",package.seeall)

local function cleanupTable(tab, time)
	for i=#tab-1, 1, -1 do
		if tab[i] < time then
			table.remove(tab,i)
		end
	end
end

local function getPlys()
	local plys = {}
	for k,v in ipairs(player.GetAll()) do
		if !IsAdmin(v) then continue end
		if v:Team() != TEAM_ADMIN then continue end

		table.insert(plys,v)
	end
	return plys
end

-- Run Over
util.AddNetworkString("Support:RanOver")
function RanOver(driver,ply)
	local tab = driver["RanOver"]
	if !tab then
		tab = {}
		driver["RanOver"] = tab
	end

	local ct = CurTime()
	table.insert(tab,ct)
	cleanupTable(tab, ct - RunOverTime)

	if (#tab >= RunOverAmount) then
		local plys = getPlys()
		if #plys == 0 then return end

		net.Start("Support:RanOver")
		net.WriteEntity(driver)
		net.WriteBool(true)
		net.WriteUInt(#tab,6)
		net.Send(plys)
	end
end

net.Receive("Support:RanOver",function(_,ply)
	if !IsAdmin(ply) then return end

	local tar = net.ReadEntity()
	tar["RanOver"] = nil

	net.Start("Support:RanOver")
	net.WriteEntity(tar)
	net.WriteBool(false)
	net.Broadcast()
end)

-- MassRDM
util.AddNetworkString("Support:MassRDM")
hook.Add("PlayerDeath","Support:MassRDM",function(dead, inf, killer)
	if !IsValid(killer) or killer == dead or !killer:IsPlayer() then return end
	
	local tab = killer["MassRDM"]
	if !tab then
		tab = {}
		killer["MassRDM"] = tab
	end

	local ct = CurTime()
	table.insert(tab,ct)
	cleanupTable(tab, ct - RunOverTime)

	if (#tab >= MassRDMAmount) then
		local plys = getPlys()
		if #plys == 0 then return end

		net.Start("Support:MassRDM")
		net.WriteEntity(killer)
		net.WriteBool(true)
		net.WriteUInt(#tab,6)
		net.Send(plys)
	end
end)

net.Receive("Support:MassRDM",function(_,ply)
	if !IsAdmin(ply) then return end

	local tar = net.ReadEntity()
	tar["MassRDM"] = nil

	net.Start("Support:MassRDM")
	net.WriteEntity(tar)
	net.WriteBool(false)
	net.Broadcast()
end)
