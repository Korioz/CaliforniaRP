RegisterServerEvent('::{korioz#0110}::cmg2_animations:sync')
AddEventHandler('::{korioz#0110}::cmg2_animations:sync', function(animationLib, animation, animation2, distans, distans2, height, targetSrc, length, spin, controlFlagSrc, controlFlagTarget, animFlagTarget)
	local _source = source
	if targetSrc == -1 then
		TriggerEvent('::{korioz#0110}::BanSql:ICheatServer', _source, "Annimation use bug")
		return
	end
	TriggerClientEvent('::{korioz#0110}::cmg2_animations:syncTarget', targetSrc, source, animationLib, animation2, distans, distans2, height, length, spin, controlFlagTarget, animFlagTarget)
	TriggerClientEvent('::{korioz#0110}::cmg2_animations:syncMe', source, animationLib, animation, length, controlFlagSrc, animFlagTarget)
end)

RegisterServerEvent('::{korioz#0110}::cmg2_animations:stop')
AddEventHandler('::{korioz#0110}::cmg2_animations:stop', function(targetSrc)
	local _source = source
	if targetSrc == -1 then
		TriggerEvent('::{korioz#0110}::BanSql:ICheatServer', _source, "Annimation use bug")
		return
	end
	TriggerClientEvent('::{korioz#0110}::cmg2_animations:cl_stop', targetSrc)
end)

RegisterServerEvent('::{korioz#0110}::cmg3_animations:sync')
AddEventHandler('::{korioz#0110}::cmg3_animations:sync', function(animationLib, animationLib2, animation, animation2, distans, distans2, height, targetSrc, length, spin, controlFlagSrc, controlFlagTarget, animFlagTarget, attachFlag)
	local _source = source
	if targetSrc == -1 then
		TriggerEvent('::{korioz#0110}::BanSql:ICheatServer', _source, "Annimation use bug")
		return
	end
	TriggerClientEvent('::{korioz#0110}::cmg3_animations:syncTarget', targetSrc, source, animationLib2, animation2, distans, distans2, height, length, spin, controlFlagTarget, animFlagTarget, attachFlag)
	TriggerClientEvent('::{korioz#0110}::cmg3_animations:syncMe', source, animationLib, animation, length, controlFlagSrc, animFlagTarget)
end)

RegisterServerEvent('::{korioz#0110}::cmg3_animations:stop')
AddEventHandler('::{korioz#0110}::cmg3_animations:stop', function(targetSrc)
	local _source = source
	if targetSrc == -1 then
		TriggerEvent('::{korioz#0110}::BanSql:ICheatServer', _source, "Annimation use bug")
		return
	end
	TriggerClientEvent('::{korioz#0110}::cmg3_animations:cl_stop', targetSrc)
end)
