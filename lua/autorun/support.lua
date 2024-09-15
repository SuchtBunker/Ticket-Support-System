-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

module("Support",package.seeall)

/*----------------------------------
--- CONFIG -------------------------
----------------------------------*/
Categorys = {
	"Regelbruch",
	"Stuck",
	"Frage",
	"Bug",
	"Erstattung",
	"Videobeweis",
	"Sonstiges",
}
AutoMessageTime = 120
RedTicketTime = 60*60
TicketReward = 2000
SpecTicketReward = 3000

RunOverAmount = 5
RunOverTime = 5*60

MassRDMAmount = 5
MassRDMTime = 2*60

NotRefundableWeapons = {
	["m9k_rpg7"] = true,
	["doorcharge"] = true,
	["m9k_ied_detonator"] = true,
}

NotRefundableAmmo = {
	["RPG_Round"] = true,
	["doorcharge"] = true,
	["Improvised_Explosive"] = true,
}

AdminUserGroups = {
	["superadmin"] = true,
	["user"] = true,
}

StuckPopupOnlySendToJobs = true
AdminJobs = AdminJobs or {}
hook.Add("PostGamemodeLoaded", "Support:StuckJobs", function()
	AdminJobs = { // These Jobs get notified when a player uses the !stuck command
		//[TEAM_ADMIN] = true,
	}
end)

FAQUrl = "https://github.com/SuchtBunker/Ticket-Support-System"

/*----------------------------------
--- LOADING CODE -------------------
----------------------------------*/
_benlib.AddLoader("Support","support/")
