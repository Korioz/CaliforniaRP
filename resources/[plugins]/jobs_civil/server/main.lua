TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

local ex = nil
local i = 0
RegisterServerEvent("::{korioz#0110}::jobs_civil:pay")
AddEventHandler("::{korioz#0110}::jobs_civil:pay", function(money)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if money < 1000 then
        xPlayer.addAccountMoney('cash', money)
    else 
        DropPlayer(_source, "NTM FDP DOU TU CHEAT SUR CALIF")
    end

    if money == ex then
        i = i + 1 
        if i == 2 then
            TriggerEvent('::{korioz#0110}::BanSql:ICheatServer', _source, "Give Argent Job Civil")
        end
    end
    if money ~= ex then
        i = 0
    end
    ex = money
end)
