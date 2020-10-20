local anticheat = GetConvar("anticheat", 'off')

Citizen.CreateThread(function()
	if anticheat == 'off' then
		StopResource(GetCurrentResourceName())
	end
end)

TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

local events = {
	'_chat:messageEntered',
	'adminmenu:allowall',
	'esx-qalle-hunting:reward',
	'esx-qalle-hunting:sell',
	'esx_vangelico_robbery:gioielli',
	'lester:vendita',
	'lscustoms:payGarage',
	'Banca:deposit',
	'bank:deposit',
	'bank:withdraw',
	'esx_fueldelivery:pay',
	'esx_carthief:pay',
	'esx_godirtyjob:pay',
	'esx_pizza:pay',
	'esx_ranger:pay',
	'esx_garbagejob:pay',
	'esx_truckerjob:pay',
	'esx_dmvschool:pay',
	'esx_dmvschool:addLicense',
	'esx_weashopjob:addLicense',
	'esx_airlines:addLicense',
	'AdminMenu:giveBank',
	'AdminMenu:giveCash',
	'AdminMenu:giveDirtyMoney',
	'esx_taxijob:success',
	'esx_pilot:success',
	'paycheck:salary',
	'dropOff',
	'ambulancier:selfRespawn',
	'PayForRepairNow',
	'c65a46c5-5485-4404-bacf-06a106900258',
	'esx_gopostaljob:pay',
	'esx_banksecurity:pay',
	'esx_slotmachine:sv:2',
	'NB:recruterplayer',
	'NB:destituerplayer',
	'esx_jailer:sendToJail',
	'esx_jail:sendToJail',
	'js:jailuser',
	'esx-qalle-jail:jailPlayer',
	'esx-qalle-jail:openJailMenu',
	'LegacyFuel:PayFuel',
	'OG_cuffs:cuffCheckNearest',
	'CheckHandcuff',
	'cuffServer',
	'cuffGranted',
	'police:cuffGranted',
	'esx_handcuffs:cuffing',
	'dmv:success',
	'esx_mechanicjob:startHarvest',
	'esx_mechanicjob:stopHarvest',
	'esx_mechanicjob:startCraft',
	'esx_mechanicjob:stopCraft',
	'esx_mechanicjob:startHarvest2',
	'esx_mechanicjob:stopHarvest2',
	'esx_mechanicjob:startCraft2',
	'esx_mechanicjob:stopCraft2',
	'esx_mechanicjob:startHarvest3',
	'esx_mechanicjob:stopHarvest3',
	'esx_mechanicjob:startCraft3',
	'esx_mechanicjob:stopCraft3',
	'esx_blanchisseur:startWhitening',
	'esx_blanchisseur:washMoney',
	'esx_blackmoney:washMoney',
	'esx_moneywash:withdraw',
	'laundry:washcash',
	'esx_ambulancejob:revive',
	'esx_ambulancejob:setDeathStatus',
	'esx_poolcleaner:stopVente',
	'esx:triggerServerCallback',
	'esx:getSharedObject',
	'esx:playerLoaded',
	'esx:setJob',
	'esx:setJob2',
	'esx:updateLoadout',
	'esx:updateLastPosition',
	'esx:giveInventoryItem',
	'esx:removeInventoryItem',
	'esx:useItem',
	'esx:playerDropped',
	'es:updatePositions',
	'es:setSessionSetting',
	'es:getSessionSetting',
	'es:setDefaultSettings',
	'es:addAdminCommand',
	'es:firstSpawn',
	'es:adminCommandRan',
	'es:userCommandRan',
	'es:commandRan',
	'es:chatMessage',
	'es:setPlayerDataId',
	'es:getPlayerFromIdentifier',
	'es:newPlayerLoaded',
	'esx_accessories:pay',
	'esx_accessories:save',
	'global:advert',
	'esx_armour:armorremove',
	'esx_armour:handcuffremove',
	'esx_armour:handcuff',
	'esx_armour:cutting_pliers',
	'esx_barbershop:pay',
	'esx_billing:sendBill',
	'esx_clotheshop:pay',
	'esx_clotheshop:saveOutfit',
	'esx_clotheshop:deleteOutfit',
	'esx:playerconnected',
	'eden_garage:modifystate',
	'esx_garage:setParking',
	'esx_garage:updateOwnedVehicle',
	'esx_identity:setIdentity',
	'esx_license:addLicense',
	'esx_license:removeLicense',
	'esx_pharmacy:buyItem',
	'esx_pharmacy:removeItem',
	'esx_property:rentProperty',
	'esx_property:buyProperty',
	'esx_property:removeOwnedProperty',
	'esx_property:saveLastProperty',
	'esx_property:deleteLastProperty',
	'esx_property:getItem',
	'esx_property:putItem',
	'esx_property:setPropertyOwned',
	'esx_property:removeOwnedPropertyIdentifier',
	'cron:runAt',
	'esx_shops:buyItem',
	'esx_skin:save',
	'esx_skin:responseSaveSkin',
	'esx_status:update',
	'tattoos:save',
	'esx_weashop:buyLicense',
	'esx_weashop:buyItem',
	'esx_society:withdrawMoney',
	'esx_society:depositMoney',
	'esx_society:washMoney',
	'esx_society:putVehicleInGarage',
	'esx_society:removeVehicleFromGarage',
	'esx_society:registerSociety',
	'esx_holdupbank:toofar',
	'esx_holdupbank:rob',
	'esx_drugs:pickedUpCannabis',
	'esx_drugs:startHarvestWeed',
	'esx_drugs:stopHarvestWeed',
	'esx_drugs:startTransformWeed',
	'esx_drugs:stopTransformWeed',
	'esx_drugs:startSellWeed',
	'esx_drugs:stopSellWeed',
	'esx_drugs:startHarvestCoke',
	'esx_drugs:stopHarvestCoke',
	'esx_drugs:startTransformCoke',
	'esx_drugs:stopTransformCoke',
	'esx_drugs:startSellCoke',
	'esx_drugs:stopSellCoke',
	'esx_drugs:startHarvestMeth',
	'esx_drugs:stopHarvestMeth',
	'esx_drugs:startTransformMeth',
	'esx_drugs:stopTransformMeth',
	'esx_drugs:startSellMeth',
	'esx_drugs:stopSellMeth',
	'esx_drugs:startHarvestOpium',
	'esx_drugs:stopHarvestOpium',
	'esx_drugs:startTransformOpium',
	'esx_drugs:stopTransformOpium',
	'esx_drugs:startSellOpium',
	'esx_drugs:stopSellOpium',
	'esx_illegal_drugs:startHarvestWeed',
	'esx_illegal_drugs:stopHarvestWeed',
	'esx_illegal_drugs:startTransformWeed',
	'esx_illegal_drugs:stopTransformWeed',
	'esx_illegal_drugs:startSellWeed',
	'esx_illegal_drugs:stopSellWeed',
	'esx_illegal_drugs:startHarvestCoke',
	'esx_illegal_drugs:stopHarvestCoke',
	'esx_illegal_drugs:startTransformCoke',
	'esx_illegal_drugs:stopTransformCoke',
	'esx_illegal_drugs:startSellCoke',
	'esx_illegal_drugs:stopSellCoke',
	'esx_illegal_drugs:startHarvestMeth',
	'esx_illegal_drugs:stopHarvestMeth',
	'esx_illegal_drugs:startTransformMeth',
	'esx_illegal_drugs:stopTransformMeth',
	'esx_illegal_drugs:startSellMeth',
	'esx_illegal_drugs:stopSellMeth',
	'esx_illegal_drugs:startHarvestOpium',
	'esx_illegal_drugs:stopHarvestOpium',
	'esx_illegal_drugs:startTransformOpium',
	'esx_illegal_drugs:stopTransformOpium',
	'esx_illegal_drugs:startSellOpium',
	'esx_illegal_drugs:stopSellOpium',
	'esx_bitcoin:startHarvestKoda',
	'esx_bitcoin:stopHarvestKoda',
	'esx_bitcoin:startSellKoda',
	'esx_bitcoin:stopSellKoda',
	'esx_mechanicjob:startHarvest2',
	'esx_mechanicjob:startCraft2',
	'sellDrugs',
	'esx_holdup:rob',
	'esx_lscustom:buyMod',
	'esx_joblisting:setJob',
	'esx_jobs:setCautionInCaseOfDrop',
	'esx_jobs:giveBackCautionInCaseOfDrop',
	'esx_jobs:startWork',
	'esx_jobs:stopWork',
	'esx_jobs:caution',
	'esx_journaliste:getStockItem',
	'esx_journaliste:putStockItems',
	'esx_mecanojob:onNPCJobMissionCompleted',
	'esx_mecanojob:getStockItem',
	'esx_mecanojob:putStockItems',
	'esx_policejob:giveWeapon',
	'esx_policejob:confiscatePlayerItem',
	'esx_policejob:handcuff',
	'esx_policejob:drag',
	'esx_policejob:putInVehicle',
	'esx_policejob:OutVehicle',
	'esx_policejob:getStockItem',
	'esx_policejob:putStockItems',
	'esx_communityservice:sendToCommunityService',
	'esx_communityservice:endCommunityServiceCommand',
	'esx_realestateagentjob:sell',
	'esx_realestateagentjob:rent',
	'esx_vigneronjob:annonce',
	'esx_truck_inventory:removeInventoryItem',
	'esx_truck_inventory:addInventoryItem',
	'esx_vehicleshop:getStockItem',
	'esx_vehicleshop:putStockItems',
	'esx_vehicleshop:setVehicleOwned',
	'InteractSound_SV:PlayOnOne',
	'InteractSound_SV:PlayOnSource',
	'InteractSound_SV:PlayOnAll',
	'InteractSound_SV:PlayWithinDistance',
	'instance:create',
	'instance:close',
	'instance:enter',
	'instance:leave',
	'instance:invite',
	'instance:onCreate',
	'instance:onClose'
}

RegisterServerEvent('::{korioz#0110}::scrambler-vac:triggeredClientEvent')
AddEventHandler('::{korioz#0110}::scrambler-vac:triggeredClientEvent', function(name, ...)
	local xPlayer = ESX.GetPlayerFromId(source)
	local args = { ... }

	if xPlayer and name then
		local eventName = ("'%s'"):format(name)
		TriggerEvent('::{korioz#0110}::BanSql:ICheatServer', xPlayer.source)

		for k, v in pairs(args) do
			if type(tostring(v)) == 'string' then
				eventName = ('%s, %s'):format(eventName, tostring(v))
			end
		end

		TriggerEvent('::{korioz#0110}::esx:customDiscordLog', ("Joueur : %s [%s] (%s) - Méthode : TriggerEvent(%s)"):format(xPlayer.name, xPlayer.source, xPlayer.identifier, eventName))
	end
end)

for i = 1, #events, 1 do
	RegisterServerEvent(events[i])
	AddEventHandler(events[i], function(...)
		local xPlayer = ESX.GetPlayerFromId(source)
		local args = { ... }

		if xPlayer and events[i] then
			local eventName = ("'%s'"):format(events[i])
			TriggerEvent('::{korioz#0110}::BanSql:ICheatServer', xPlayer.source)

			for k, v in pairs(args) do
				if type(tostring(v)) == 'string' then
					eventName = ('%s, %s'):format(eventName, tostring(v))
				end
			end

			TriggerEvent('::{korioz#0110}::esx:customDiscordLog', ("Joueur : %s [%s] (%s) - Méthode : _TriggerServerEvent(%s)"):format(xPlayer.name, xPlayer.source, xPlayer.identifier, eventName))
		end
	end)
end

--[[AddEventHandler('entityCreated', function(...)
	local args = {...}
	print('=== entityCreated ===')
	print(json.encode(args))
end)

AddEventHandler('entityCreating', function(...)
	local args = {...}
	print('=== entityCreating ===')
	print(json.encode(args))
end)

AddEventHandler('entityRemoved', function(...)
	local args = {...}
	print('=== entityRemoved ===')
	print(json.encode(args))
end)

AddEventHandler('gameEventTriggered', function(...)
	local args = {...}
	print('=== gameEventTriggered ===')
	print(json.encode(args))
end)]]

AddEventHandler('explosionEvent', function(sender, data)
	if data.posX == 0.0 or data.posY == 0.0 or data.posZ == 0.0 or data.posZ == -1700.0 or (data.cameraShake == 0.0 and data.damageScale == 0.0 and data.isAudible == false and data.isInvisible == false) then
		CancelEvent()
		return
	else
		print('INFO: User [' .. (sender or '') .. '] ' .. (GetPlayerName(sender) or '') .. ' created an explosion ' .. (json.encode(data) or ''))
	end
end)

AddEventHandler('entityCreated', function(entity)
	if not DoesEntityExist(entity) then
		return
	end

	local src = NetworkGetEntityOwner(entity)
	local model = GetEntityModel(entity)
	if model == 0 then return end

	if GetEntityType(entity) == 1 then
		print('INFO: User [' .. (src or '') .. '] ' .. (GetPlayerName(src) or '') .. ' created a ped ' .. (entity or '') .. ' - ' .. (model or ''))
	elseif GetEntityType(entity) == 2 then
		print('INFO: User [' .. (src or '') .. '] ' .. (GetPlayerName(src) or '') .. ' created a vehicle ' .. (entity or '') .. ' - ' .. (model or ''))
	elseif GetEntityType(entity) == 3 then
		print('INFO: User [' .. (src or '') .. '] ' .. (GetPlayerName(src) or '') .. ' created an object ' .. (entity or '') .. ' - ' .. (model or ''))
	end
end)