AddEventHandler('onClientResourceStart', function(resource)
	if resource ~= GetCurrentResourceName() then
		return
	end
	local success = pcall(function() 
		local micClicksKvp = GetResourceKvpString('pma-voice_enableMicClicks')
		if not micClicksKvp then
			SetResourceKvp('pma-voice_enableMicClicks', tostring(true))
		else
			if micClicksKvp ~= 'true' and micClicksKvp ~= 'false' then
				error('Invalid Kvp, throwing error for automatic cleaning')
			end
			micClicks = micClicksKvp
		end
	end)
	if not success then
		logger.warn('Failed to load resource Kvp, likely was inappropriately modified by another server, resetting the Kvp.')
		SetResourceKvp('pma-voice_enableMicClicks', tostring(true))
		micClicks = 'true'
	end
	Wait(1000)
	if GetConvarInt('voice_enableUi', 1) == 1 then
		SendNUIMessage({voiceModes = json.encode(Cfg.voiceModes), voiceMode = mode - 1})
	end
end)
