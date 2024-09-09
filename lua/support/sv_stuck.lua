-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

module("Support",package.seeall)

function GetStuckPopupAdmins()
	local plys = {}
	if StuckPopupOnlySendToJobs then
		for k,v in player.Iterator() do
			if AdminJobs[v:Team()] then
				table.insert(plys, v)
			end
		end
	else
		for k,v in player.Iterator() do
			if IsAdmin(v) then
				table.insert(plys, v)
			end
		end
	end
	
	return plys
end

local blocked = {
	[CONTENTS_SOLID] = true,
	[134217729] = true,
}
local function isBlocked(pos)
	return blocked[util.PointContents(pos)] == true
end

local function respawnCB(info)
	local ply = info["Target"][1]
	if !IsValid(ply) then return end
	
	if info["Result"] == 0 then
		NotifyLang(ply,"UNSTUCK_RETHINK")
	elseif info["Result"] == 1 then
		local ent, pos = hook.Call("PlayerSelectSpawn", GAMEMODE, ply)
		ply:SetPos(pos or ent:GetPos())
	end
end

local function respawnSurvey(ply)
	Question.CreateSurvey(ply,"Steckst du noch fest?","Wenn du noch immer feststeckst, kannst du dich zum Spawn teleportieren lassen, da dir aktuell kein Teammitglied helfen kann.",30,respawnCB)
end

local function adminMsgEndCB(info)
	if IsValid(info["victim"]) and #info["VotesYes"] == 0 then
		respawnSurvey(info["victim"])
	end
end

local function adminMsgVoteCB(info,ply)
	if info["PlayerResponses"][ply] == 1 then
		Question.End(info["ID"],false)
		if IsValid(info["victim"]) then
			NotifyLang(info["victim"],"STUCK_ACCEPTED")
		end
	end
end

local function stillStuckCB(info)
	local ply = info["Target"][1]
	if !IsValid(ply) then return end
	
	if info["Result"] == 0 then

	elseif info["Result"] == 1 then
		local plys = Admin.GetTeamPlayers()
 
		local q = Question.CreateSurvey(plys,"Spieler Stuck",ply:Name().." ("..team.GetName(ply:Team())..") steckt fest. Hilfst du ihm?",30,adminMsgEndCB,adminMsgVoteCB)
		q["victim"] = ply
	end
end

local function cb(ply)
	if ply:InVehicle() then
		NotifyLang(ply,"UNSTUCK_IN_VEHICLE")
		return
	end
	
	if (ply["NextUnstuck"] or 0) > CurTime() then
		NotifyLang(ply,"UNSTUCK_WAIT")
		return
	end
	
	ply["NextUnstuck"] = CurTime() + 30

	NotifyLang(ply,"UNSTUCK_TRY")

	local pos = ply:GetPos()
	local eyePos = ply:EyePos()

	if isBlocked(eyePos) then -- head stuck
		for i=1, 10 do
			eyePos["z"] = eyePos["z"] - 10

			if !isBlocked(eyePos) then
				pos["z"] = pos["z"] - i*10 - 5
				ply:SetPos(pos)
				break
			end
		end
	elseif isBlocked(pos) then -- feet stuck
		for i=1, 10 do
			pos["z"] = pos["z"] + 10

			if !isBlocked(pos) then
				ply:SetPos(pos)
				break
			end
		end
	end

	local anyOnline = #Admin.GetTeamPlayers()
	if anyOnline then
		Question.CreateSurvey(ply,"Steckst du noch fest?","Wenn du noch immer feststeckst, wird ein Teammitglied informiert.",30,stillStuckCB)
	else
		respawnSurvey(ply)
	end
end

Command.Add("stuck",cb)
Command.Add("unstuck",cb)