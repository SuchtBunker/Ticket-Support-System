-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

module("Support",package.seeall)

/* TICKET COUNTING */
_benlib.AddDB(Support, "base")
Support.Query("CREATE TABLE IF NOT EXISTS supports (steam CHAR(17), spectator BOOL DEFAULT FALSE, `time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP);")
Support.Query("CREATE TABLE IF NOT EXISTS support_ratings (admin CHAR(17), user CHAR(17), stars INT, description TEXT, `time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP);")

function IsAdmin(ply)
	return AdminUserGroups[ply:GetUserGroup()] == true
end

hook.Add("Support:FinishedTicket","TicketCounter",function(ticket)
	local ply = ticket["Admin"]
	if !IsValid(ply) then return end

	Support.Query("INSERT INTO supports (steam, spectator) VALUES ('"..ply:SteamID64().."',false);")

	local spec = ply["Support_Spectator"]
	if IsValid(spec) then
		Support.Query("INSERT INTO supports (steam, spectator) VALUES ('"..spec:SteamID64().."',true);")
	end
end)

Command.Add("setspectator",function(ply)
	local tr = ply:GetEyeTrace()
	local tar = tr["Player"]
	if tar then
		ply["Support_Spectator"] = tar
		ply:ChatPrint("Du hast "..tar:Name().." als deinen Spectator festgelegt!")
	else
		ply:ChatPrint("Du schaust keinen Spieler an!")
	end
end)
Command.Add("unsetspectator",function(ply)
	ply["Support_Spectator"] = nil
	ply:ChatPrint("Du hast deinen Spectator entfernt!")
end)

/* ACTUAL TICKET SYSTEM */
function GetTicketsUntil(ticket)
	local am = 0
	for k,v in ipairs(Tickets) do
		if v == ticket then break end
		am = am + 1
	end
	return am
end

function FindTicketByID(id)
	for k,v in ipairs(Tickets) do
		if v["ID"] == id then
			return v, k
		end
	end
	return false
end

function CloseTicket(ticket)
	local creator = ticket["Creator"]
	local admin = ticket["Admin"]

	if IsValid(admin) then
		admin.ATicket = nil
	end

	if IsValid(creator) then
		creator.UTicket = nil
	end
 
	table.RemoveByValueI(Tickets,ticket)
	//Tickets[ticket["ID"]] = nil

	return admin, creator
end

function WriteTicket(ticket)
	net.WriteUInt(ticket["ID"],14)
	net.WriteEntity(ticket["Creator"])
	net.WriteUInt(ticket["Time"],17)
	net.WriteUInt(ticket["Category"],4)
	net.WriteString(ticket["Description"])
end

function WriteTickets()
	net.WriteUInt(#Tickets,6)
	for k,v in ipairs(Tickets) do
		WriteTicket(v)
	end
end

// Remove on DC
hook.Add("PlayerDisconnected","Support",function(ply)
	local ticket = ply.ATicket
	if ticket then
		CloseTicket(ticket)
	end

	local ticket = ply.UTicket
	if ticket then
		CloseTicket(ticket)
	end
end)


local function openMenuUser(ply)
	local ticket = ply.UTicket
	if ticket then
		net.Start("Support:User")
		net.WriteBool(false)
		net.WriteUInt(ticket["Time"],17)
		net.WriteUInt(GetTicketsUntil(ticket),6)
		net.Send(ply)
	else
		net.Start("Support:User")
		net.WriteBool(true)
		net.Send(ply)
	end
end

local function openMenuAdmin(ply)
	local ticket = ply.ATicket
	if ticket then
		net.Start("Support:Admin")
		net.WriteBool(true)
		WriteTicket(ticket)
		net.Send(ply)
	else
		if #Tickets != 0 then	
			net.Start("Support:Admin")
			net.WriteBool(false)
			WriteTickets()
			net.Send(ply)
		else
			ply:ChatPrint("Es sind keine Tickets offen!")
		end
	end
end

util.AddNetworkString("Support:AdminChose")
net.Receive("Support:AdminChose",function(_,ply)
	if !IsAdmin(ply) then return end

	if net.ReadBool() then // User Mode
		openMenuUser(ply)
	else
		openMenuAdmin(ply)
	end
end)

util.AddNetworkString("FAQ-Open")
util.AddNetworkString("Support:Admin")
util.AddNetworkString("Support:User")
// Chat Commands
local function cb(ply)
	if IsAdmin(ply) then
		if ply:Team() == TEAM_ADMIN then
			openMenuAdmin(ply)
		else
			net.Start("Support:AdminChose")
			net.Send(ply)
		end
	else
		openMenuUser(ply)
	end
end
Command.Add("support",cb)
Command.Add("supports",cb)
Command.Add("ticket",cb)
Command.Add("tickets",cb)
Command.Add("report",cb)
Command.Add("hilfe",cb)

local function cb(ply)
	net.Start("FAQ-Open")
	net.Send(ply)
end
Command.Add("faq",cb)
Command.Add("frage",cb)

Tickets = Tickets or {}
TicketID = TicketID or 0

// User Stuff
net.Receive("Support:User",function(_,ply)
	local ticket = ply.UTicket
	if ticket then // Close a Ticket
		CloseTicket(ticket)
	else // Create a Ticket
		local thisID = TicketID + 1
		TicketID = thisID

		local category = net.ReadUInt(4)
		if !Categorys[category] then return end
		
		local t = {
			["ID"] = thisID,
			["Creator"] = ply,
			["Time"] = CurTime(),
			["Category"] = category,
			["Description"] = net.ReadString()
		}
		ply.UTicket = t
		//Tickets[thisID] = t
		table.insert(Tickets,t)

		local plys = {}
		local am, amInJob = 0, 0
		for k,v in ipairs(player.GetAll()) do
			if !IsAdmin(v) then continue end

			/*
			if !v:IsStreaming() then
				table.insert(plys,v)
			end
			*/
			table.insert(plys,v)
			
			am = am + 1
			if v:Team() == TEAM_ADMIN then
				amInJob = amInJob + 1
			end
		end
		if am > 0 then
			Notify(plys,ply:Name().." hat ein Ticket in der Kategorie "..Categorys[t["Category"]].." erstellt!",2,5)
		end
		Notify(ply,"Dein Ticket wurde erstellt, es "..(am == 1 and "ist" or "sind").." "..am.." Teammitglied"..(am == 1 and "" or "er").." online ("..amInJob.." am supporten)!",2,5)
	end
end)

function NextTicketMessage()
	local ticket = Tickets[1]
	if !ticket then return end
	NotifyLang(ticket["Creator"],"TICKET_NEXT")
	
	/*
	local nxt = next(Tickets)
	if !nxt then return end
	local ticket = Tickets[nxt]
	Notify(ticket["Creator"],"Dein Ticket ist als nächstes an der Reihe, falls du gerade in einer RP-Situation bist, beende diese bitte so schnell wie möglich!",2,15)
	*/
end

timer.Create("TicketMessage",180,0,function()
	local tickets = #Tickets //table.Count(Tickets)
	if tickets == 0 then return end

	local plys = {}
	local am = 0
	for k,v in ipairs(player.GetAll()) do
		if !IsAdmin(v) /*or v:IsStreaming()*/ then continue end
		table.insert(plys,v)

		if v:Team() == TEAM_ADMIN then
			am = am + 1
		end
	end
	if #plys == 0 then return end
	
	Notify(plys,"Es sind "..tickets.." Ticket(s) offen und "..am.." Teammitglied(er) im Dienst!",am == 0 and 1 or 2,15)
end)

util.AddNetworkString("Support:Rate")
function Support.Rate(user,admin)
	user["Support_Rate"] = admin:SteamID64()

	net.Start("Support:Rate")
	net.WriteEntity(admin)
	net.Send(user)
end
net.Receive("Support:Rate",function(_,user)
	local admin = net.ReadSteamID64()
	if user["Support_Rate"] != admin then return end
	user["Support_Rate"] = nil
	
	Support.Query("INSERT INTO support_ratings (admin, user, stars, description) VALUES ("..admin..","..user:SteamID64()..","..math.Clamp(net.ReadUInt(3),1,5)..",'"..Support.Escape(net.ReadString()).."');")
end)

// Admin Stuff
net.Receive("Support:Admin",function(_,ply)
	if !IsAdmin(ply) then return end
	
	local ticket = ply.ATicket
	if ticket then
		CloseTicket(ticket)
		local creator = ticket["Creator"]
		Support.Rate(creator,ply)
		//Notify(creator,"Dein Ticket wurde von "..ply:Name().." geschlossen!",2,5)

		if SBLogsInstalled then
			Logs.Log("support",{
				["creator"] = creator,
				["admin"] = ply,
				["closed"] = true,
			})
		end

		ply:addMoney(TicketReward)
		NotifyLang(ply,"TICKET_REWARD")

		local spec = ply["Support_Spectator"]
		if IsValid(spec) then
			spec:addMoney(SpecTicketReward)
			NotifyLang(spec,"TICKET_REWARD_SPEC")
		end 

		hook.Run("Support:FinishedTicket",ticket)
	else
		local id = net.ReadUInt(14)
		local ticket, ticketID = FindTicketByID(id)
		if ticket then
			//Tickets[ticketID] = nil
			table.remove(Tickets,ticketID)

			ticket["Admin"] = ply
			ply.ATicket = ticket
			
			local creator = ticket["Creator"]
			Notify(creator,"Dein Ticket wurde von "..ply:Name().." angenommen, falls du gerade in einer RP-Situation bist, beende diese bitte so schnell wie möglich!",3,15)
			
			if SBLogsInstalled then
				Logs.Log("support",{
					["creator"] = creator,
					["admin"] = ply,
					["closed"] = false,
					["message"] = ticket["Description"],
				})
			end

			net.Start("Support:Admin")
			net.WriteBool(true) 
			WriteTicket(ticket)
			net.Send(ply)

			NextTicketMessage()
		else
			Notify(ply,"Fehler beim annehmen des Tickets!",0,5)

			net.Start("Support:Admin")
			net.WriteBool(false)
			WriteTickets()
			net.Send(ply)
		end
	end
end)

/* RDM Refunder */
hook.Add("PlayerInitialSpawn","RDM Refunder",function(ply)
	ply["LastDeaths"] = {}
end)

hook.Add("DoPlayerDeath","RDM Refunder",function(ply)
	local weps = {}
	for k,v in ipairs(ply:GetWeapons()) do
		if !hook.Call("canDropWeapon", GAMEMODE, ply, v) then continue end
		table.insert(weps,{
			["Class"] = v:GetClass(),
			["AmmoCount"] = v:Clip1(),
			["AmmoType"] = v.Primary.Ammo,
		})
	end

	if #weps == 0 then return end

	local ammo = {}
	local death = {
		["Weapons"] = weps,
		["Ammo"] = ammo,
		["Time"] = CurTime(),
		["Refunded"] = false,
	}
	for k,v in ipairs(weps) do
		ammo[v["AmmoType"]] = ply:GetAmmoCount(v["AmmoType"])
	end

	local deaths = ply["LastDeaths"]
	table.insert(deaths,death)
	if #deaths == 17 then
		table.remove(deaths,1)
	end
end)

util.AddNetworkString("Support:RDM")
net.Receive("Support:RDM",function(_,ply)
	if !IsAdmin(ply) then return end

	local tar = net.ReadEntity()
	local deaths = tar["LastDeaths"]
	if !deaths then return end // wtf

	if #deaths == 0 then
		Notify(ply,tar:Name().." hat keine Tode!",0,5)
		return
	end

	net.Start("Support:RDM")
	net.WriteEntity(tar)
	net.WriteUInt(#deaths,4)
	for k, death in ipairs(deaths) do
		net.WriteUInt(death["Time"],17)
		net.WriteBool(death["Refunded"])

		local weps = death["Weapons"]
		net.WriteUInt(#weps,8)
		for k,v in ipairs(weps) do
			net.WriteString(v["Class"])
			net.WriteUInt(v["AmmoCount"],16)
			net.WriteString(v["AmmoType"])
		end

		local ammo = death["Ammo"]
		for k,v in pairs(ammo) do
			net.WriteBool(true)
			net.WriteString(k)
			net.WriteUInt(v,16)
		end
		net.WriteBool(false)
	end
	net.Send(ply)
end)

util.AddNetworkString("Support:RefundRDM")
net.Receive("Support:RefundRDM",function(_,ply)
	local tar = net.ReadEntity()
	local deathID = net.ReadUInt(4)
	local death = tar.LastDeaths[deathID + 1]
	if !death then return end
	if death["Refunded"] then return end -- check clientside
	
	death["Refunded"] = true

	local stuff = "Waffen: "
	local worth, actualAmmo = CalcRefundWorth(death, true)

	for k,v in ipairs(death["Weapons"]) do
		if NotRefundableWeapons[v["Class"]] then continue end

		stuff = stuff..(ItemStoreWeaponName[v["Class"]] or v["Class"])..", "
		
		local wep = tar:Give(v["Class"])
		if !IsValid(wep) then
			wep = tar:GetWeapon(v["Class"])
		end

		if IsValid(wep) then
			wep:SetClip1(v["AmmoCount"])
		end
	end

	stuff = string.sub(stuff, 0, -3).." Munition: "

	for k,v in pairs(death["Ammo"]) do
		if NotRefundableAmmo[k] then continue end
		
		stuff = stuff..((actualAmmo[k] or 0) + v).."x"..(AmmoNames[k] or k)..", "

		tar:SetAmmo(v, k)
	end

	Notify(tar,ply:Name().." hat dir Waffen erstattet!",2,5)

	if SBLogsInstalled then
		Logs.Log("refunds",{
			["admin"] = ply,
			["player"] = tar,
			["worth"] = worth,
			["stuff"] = string.sub(stuff, 0, -3),
		})
	end
end)

util.AddNetworkString("Support:Teleport")
net.Receive("Support:Teleport", function(_,ply)
	if !IsAdmin(ply) then return end

	net.ReadEntity():SetPos(net.ReadVector())
end)