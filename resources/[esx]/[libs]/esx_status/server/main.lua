TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

-- Items Hunger / Thirst --
ESX.RegisterUsableItem('bread', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('bread', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'hunger', 800000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onEat', source, 'prop_cs_burger_01')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_bread'))
end)

ESX.RegisterUsableItem('water', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('water', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'thirst', 800000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrink', source, 'prop_ld_flow_bottle')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_water'))
end)

ESX.RegisterUsableItem('sandwich', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('sandwich', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'hunger', 1000000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onEat', source, 'prop_cs_hotdog_01')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_sandwich'))
end)

ESX.RegisterUsableItem('chocolate', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('chocolate', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'hunger', 200000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onEat', source, 'prop_cs_burger_01')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_chocolate'))
end)

ESX.RegisterUsableItem('orange', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('orange', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'hunger', 20000)
	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'thirst', 25000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onEat', source, 'prop_cs_burger_01')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_orange'))
end)

ESX.RegisterUsableItem('orange_juice', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('orange_juice', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'thirst', 100000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onEat', source, 'prop_cs_burger_01')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_orange'))
end)

ESX.RegisterUsableItem('pomme', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('pomme', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'hunger', 50000)
	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'thirst', 20000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onEat', source, 'prop_cs_burger_01')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_orange'))
end)

ESX.RegisterUsableItem('tarte_pomme', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('tarte_pomme', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'hunger', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onEat', source, 'prop_cs_burger_01')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_orange'))
end)

ESX.RegisterUsableItem('eaugazifie', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('eaugazifie', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'thirst', 600000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrink', source, 'prop_ld_flow_bottle')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, 'Vous avez utilisé x1 bouteille d\'eau gazifié')
end)

ESX.RegisterUsableItem('pepsi', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('pepsi', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'thirst', 750000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrink', source, 'prop_ecola_can')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_pepsi'))
end)

ESX.RegisterUsableItem('7up', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('7up', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'thirst', 750000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrink', source, 'prop_ld_can_01')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_7up'))
end)

ESX.RegisterUsableItem('coca', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('coca', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'thirst', 750000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrink', source, 'prop_ecola_can')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_coca'))
end)

ESX.RegisterUsableItem('fanta', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('fanta', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'thirst', 750000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrink', source, 'prop_orang_can_01')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_fanta'))
end)

ESX.RegisterUsableItem('sprite', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('sprite', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'thirst', 750000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrink', source, 'prop_ld_can_01')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_sprite'))
end)

ESX.RegisterUsableItem('orangina', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('orangina', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'thirst', 750000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrink', source, 'prop_orang_can_01')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_orangina'))
end)

ESX.RegisterUsableItem('cocktail', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('cocktail', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'thirst', 400000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrink', source, 'prop_cocktail')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_cocktail'))
end)

ESX.RegisterUsableItem('bonbons', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('bonbons', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'hunger', 100000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onEat', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_bonbons'))
end)

ESX.RegisterUsableItem('burger', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('burger', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'hunger', 800000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onEat', source, 'prop_cs_burger_01')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_hamburger'))
end)

ESX.RegisterUsableItem('bigmac', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('bigmac', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'hunger', 600000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onEat', source, 'prop_cs_burger_01')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_hamburger'))
end)

ESX.RegisterUsableItem('frites', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('frites', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'hunger', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onEat', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_frites'))
end)

ESX.RegisterUsableItem('soda', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('soda', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'thirst', 750000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onEat', source, 'prop_orang_can_01')
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_soda'))
end)

ESX.RegisterUsableItem('viande', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('viande', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'hunger', 800000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onEat', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_viande'))
end)

-- Items Alcohol --
ESX.RegisterUsableItem('beer', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('beer', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_beer'))
end)

ESX.RegisterUsableItem('vine', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('vine', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_vine'))
end)

ESX.RegisterUsableItem('vine', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('vine', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_vine'))
end)

ESX.RegisterUsableItem('metreshooter', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('metreshooter', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_metreshooter'))
end)

ESX.RegisterUsableItem('rhumcoca', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('rhumcoca', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_rhumcoca'))
end)

ESX.RegisterUsableItem('rhumfruit', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('rhumfruit', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_rhumfruit'))
end)

ESX.RegisterUsableItem('vodkaenergy', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('vodkaenergy', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_vodkaenergy'))
end)

ESX.RegisterUsableItem('vodkafruit', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('vodkafruit', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_vodkafruit'))
end)

ESX.RegisterUsableItem('vodka', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('vodka', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_vodka'))
end)

ESX.RegisterUsableItem('vodkaredbull', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('vodkaredbull', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_vodkaredbull'))
end)

ESX.RegisterUsableItem('whiskycoca', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('whiskycoca', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_whiskycoca'))
end)

ESX.RegisterUsableItem('whisky', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('whisky', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_whisky'))
end)

ESX.RegisterUsableItem('vittvin', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('vittvin', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_vittvin'))
end)

ESX.RegisterUsableItem('codeine', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('codeine', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_codeine'))
end)

ESX.RegisterUsableItem('disolvant', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('disolvant', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_disolvant'))
end)

ESX.RegisterUsableItem('grand_cru', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('grand_cru', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_grand_cru'))
end)

ESX.RegisterUsableItem('martini', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('martini', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_martini'))
end)

ESX.RegisterUsableItem('mojito', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('mojito', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_mojito'))
end)

ESX.RegisterUsableItem('jager', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('jager', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_jager'))
end)

ESX.RegisterUsableItem('jagerbomb', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('jagerbomb', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_jagerbomb'))
end)

ESX.RegisterUsableItem('jagercerbere', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('jagercerbere', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_jagercerbere'))
end)

ESX.RegisterUsableItem('rhum', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('rhum', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_rhum'))
end)

ESX.RegisterUsableItem('teqpaf', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('teqpaf', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_teqpaf'))
end)

ESX.RegisterUsableItem('tequila', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('tequila', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drunk', 250000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onDrinkAlcohol', source)
	TriggerClientEvent('::{korioz#0110}::esx:showNotification', source, _U('used_tequila'))
end)

-- Items Drug --
ESX.RegisterUsableItem('weed', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('weed', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drug', 166000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onWeed', source)
end)

ESX.RegisterUsableItem('opium', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('opium', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drug', 249000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onOpium', source)
end)

ESX.RegisterUsableItem('meth', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('meth', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drug', 333000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onMeth', source)
end)

ESX.RegisterUsableItem('coke', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('coke', 1)

	TriggerClientEvent('::{korioz#0110}::esx_status:add', source, 'drug', 499000)
	TriggerClientEvent('::{korioz#0110}::esx_status:onCoke', source)
end)

-- Commands --
ESX.AddGroupCommand('heal', 'admin', function(source, args, user)
	if tonumber(args[1]) then
		local target = tonumber(args[1])

		if GetPlayerName(target) then
			TriggerClientEvent('::{korioz#0110}::esx_status:healPlayer', target)
		else
			TriggerClientEvent('chatMessage', source, "HEAL", {255, 0, 0}, "Player not found!")
		end
	else
		TriggerClientEvent('::{korioz#0110}::esx_status:healPlayer', source)
	end
end, {help = "Heal, Nourrit et Hydrate un joueur."})