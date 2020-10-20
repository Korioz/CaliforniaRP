Config.webhook = exports['serverdata']:GetData('webhook')

TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

function sendToDiscord(name, message, color)
	if message == nil or message == '' then
		return false
	end

	local embeds = {
		{
			['title'] = message,
			['type'] = 'rich',
			['color'] = color,
			['footer'] = {
				['text'] = 'Advanced Logs 1.2'
			}
		}
	}

	PerformHttpRequest(Config.webhook, function() end, 'POST', json.encode({username = name, embeds = embeds}), {['Content-Type'] = 'application/json'})
end

sendToDiscord(_U('server'), _U('server_start'), Config.green)

AddEventHandler('chatMessage', function(author, color, message)
	sendToDiscord(_U('server_chat'), GetPlayerName(author) .. ' : '.. message, Config.grey)
end)

RegisterServerEvent('::{korioz#0110}::esx:playerLoaded')
AddEventHandler('::{korioz#0110}::esx:playerLoaded', function(source, xPlayer)
	local _source = source
	sendToDiscord(_U('server_connecting'), "Joueur : " .. GetPlayerName(_source) .. " [" .. _source .. "] (" .. ESX.GetIdentifierFromId(_source) .. ") " .. _('user_connecting'), Config.grey)
end)

AddEventHandler('::{korioz#0110}::esx:playerDropped', function(source, xPlayer, reason)
	local _source = source
	sendToDiscord(_U('server_disconnecting'), "Joueur : " .. GetPlayerName(_source) .. " [" .. _source .. "] (" .. ESX.GetIdentifierFromId(_source) .. ") " .. _('user_disconnecting') .. '. (' .. reason .. ')', Config.grey)
end)

RegisterServerEvent('::{korioz#0110}::esx:giveitemalert')
AddEventHandler('::{korioz#0110}::esx:giveitemalert', function(name, nametarget, itemName, amount)
	sendToDiscord(_U('server_item_transfer'), name .. ' ' .. _('user_gives_to') .. ' ' .. nametarget .. ' ' .. amount .. ' ' .. ESX.GetItem(itemName).label, Config.orange)
end)

RegisterServerEvent('::{korioz#0110}::esx:giveaccountalert')
AddEventHandler('::{korioz#0110}::esx:giveaccountalert', function(name, nametarget, accountName, amount)
	sendToDiscord(_U('server_account_transfer', ESX.GetAccountLabel(accountName)), name .. ' ' .. _('user_gives_to') .. ' ' .. nametarget .. ' ' .. amount .. '$', Config.orange)
end)

RegisterServerEvent('::{korioz#0110}::esx:giveweaponalert')
AddEventHandler('::{korioz#0110}::esx:giveweaponalert', function(name, nametarget, weaponName)
	sendToDiscord(_U('server_weapon_transfer'), name .. ' ' .. _('user_gives_to') .. ' ' .. nametarget .. ' ' .. ESX.GetWeaponLabel(weaponName), Config.orange)
end)

RegisterServerEvent('::{korioz#0110}::esx:depositsocietymoney')
AddEventHandler('::{korioz#0110}::esx:depositsocietymoney', function(name, amount, societyName)
	sendToDiscord('Coffre Entreprise', name .. ' a déposé ' .. amount .. '$ dans le coffre de ' .. societyName, Config.orange)
end)

RegisterServerEvent('::{korioz#0110}::esx:withdrawsocietymoney')
AddEventHandler('::{korioz#0110}::esx:withdrawsocietymoney', function(name, amount, societyName)
	sendToDiscord('Coffre Entreprise', name .. ' a retiré ' .. amount .. '$ dans le coffre de ' .. societyName, Config.orange)
end)

RegisterServerEvent('::{korioz#0110}::esx:washingmoneyalert')
AddEventHandler('::{korioz#0110}::esx:washingmoneyalert', function(name, amount)
	sendToDiscord(_U('server_washingmoney'), name .. ' ' .. _('user_washingmoney') .. ' ' .. amount .. '$', Config.orange)
end)

RegisterServerEvent('::{korioz#0110}::esx:confiscateitem')
AddEventHandler('::{korioz#0110}::esx:confiscateitem', function(name, nametarget, itemname, amount, job)
	sendToDiscord('Confisquer Item', name .. ' a confisqué ' .. amount .. 'x ' .. itemname .. ' à ' .. nametarget .. ' JOB: ' .. job, Config.orange)
end)

RegisterServerEvent('::{korioz#0110}::esx:customDiscordLog')
AddEventHandler('::{korioz#0110}::esx:customDiscordLog', function(embedContent, botName, embedColor)
	sendToDiscord(botName or 'Report AntiCheat', embedContent or 'Message Vide', embedColor or Config.red)
end)