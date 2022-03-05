TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

local ANTI_SAME_AMOUNT = true

local paidPlayers = {}
RegisterServerEvent("::{korioz#0110}::jobs_civil:pay")
AddEventHandler("::{korioz#0110}::jobs_civil:pay", function(money)
    local _source = source

    if ANTI_SAME_AMOUNT then
        local paidPlayer = paidPlayers[_source]

        if paidPlayer then
            if paidPlayer.m == money then
                paidPlayer.i = paidPlayer.i + 1

                if paidPlayer.i == 3 then
                    TriggerEvent('::{korioz#0110}::BanSql:ICheatServer', _source, "Give Argent Job Civil")
                end
            else
                paidPlayer.m = money
                paidPlayer.i = 1
            end
        else
            paidPlayers[_source] = { m = money, i = 1 }
        end
    end

    if money < 1000 then
        local xPlayer = ESX.GetPlayerFromId(_source)
        xPlayer.addAccountMoney('cash', money)
    else
        DropPlayer(_source, "Cheat")
    end
end)
