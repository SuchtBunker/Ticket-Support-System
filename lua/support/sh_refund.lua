-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

module("Support",package.seeall)

/*
-- Legacy SuchtBunker Function
function CalcRefundWorth(death, ignoreNonRefundable)
	local price = 0
	local weaponAmmoCount = {}
	
	for k,v in ipairs(death["Weapons"]) do
		if !ignoreNonRefundable or !NotRefundableWeapons[v["Class"]] then
			price = price + (Worth.classDarkRPPrice(v["Class"]) or 0)
		end
		
		weaponAmmoCount[v["AmmoType"]] = (weaponAmmoCount[v["AmmoType"]] or 0) + v["AmmoCount"]
	end
	
	for k, v in pairs(death["Ammo"]) do
		if k == "none" then continue end
		
		if !ignoreNonRefundable or !NotRefundableAmmo[k] then
			price = price + math.Round((AmmoPricesByType[k] or 0) * (v + (weaponAmmoCount[k] or 0)))
		end
	end
	
	return price, weaponAmmoCount
end
*/

-- For DarkRP Base
WeaponPrices = WeaponPrices or {}
AmmoPrices = AmmoPrices or {}

hook.Add("PostGamemodeLoaded", "Support:Prices", function()
	for k,v in ipairs(CustomShipments) do
		if v["seperate"] then
			WeaponPrices[v["entity"]] = v["pricesep"]
		elseif !v["noship"] then
			WeaponPrices[v["entity"]] = math.Round(v["price"]/v["amount"])
		end
	end
	
	for k,v in ipairs(GAMEMODE.AmmoTypes) do
		AmmoPrices[v["ammoType"]] = v["price"]/v["amountGiven"]
	end
end)

function CalcRefundWorth(death, ignoreNonRefundable)
	local price = 0
	local weaponAmmoCount = {}
	
	for k,v in ipairs(death["Weapons"]) do
		if !ignoreNonRefundable or !NotRefundableWeapons[v["Class"]] then
			price = price + (WeaponPrices[v["Class"]] or 0)
		end
		
		weaponAmmoCount[v["AmmoType"]] = (weaponAmmoCount[v["AmmoType"]] or 0) + v["AmmoCount"]
	end
	
	for k, v in pairs(death["Ammo"]) do
		if k == "none" then continue end
		
		if !ignoreNonRefundable or !NotRefundableAmmo[k] then
			price = price + math.Round((AmmoPrices[k] or 0) * (v + (weaponAmmoCount[k] or 0)))
		end
	end
	
	return price, weaponAmmoCount
end