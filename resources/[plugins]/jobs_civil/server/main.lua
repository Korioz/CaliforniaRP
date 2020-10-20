TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent("::{korioz#0110}::jobs_civil:pay")
AddEventHandler("::{korioz#0110}::jobs_civil:pay", function(money)
    local _source = source

    if money < 1000 then
        local xPlayer = ESX.GetPlayerFromId(_source)
        xPlayer.addAccountMoney('cash', money)
    else
        DropPlayer("NTM FDP DOU TU CHEAT SUR CALIF")
    end
end)