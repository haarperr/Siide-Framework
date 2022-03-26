rg = nil

Citizen.CreateThread(function()
	while rg == nil do
		TriggerEvent('rg:HaeAsia', function(obj) rg = obj end)
		Citizen.Wait(0)
	end
end)

local closestDoorKey, closestDoorValue = nil, nil

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

Citizen.CreateThread(function()
	while true do
		for key, doorID in ipairs(Zontti.Doors) do
			if doorID.doors then
				for k,v in ipairs(doorID.doors) do
					if not v.object or not DoesEntityExist(v.object) then
						v.object = GetClosestObjectOfType(v.objCoords, 1.0, GetHashKey(v.objHash), false, false, false)
					end
				end
			else
				if not doorID.object or not DoesEntityExist(doorID.object) then
					doorID.object = GetClosestObjectOfType(doorID.objCoords, 1.0, GetHashKey(doorID.objHash), false, false, false)
				end
			end
		end

		Citizen.Wait(2500)
	end
end)

local maxDistance = 1.25

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerCoords, awayFromDoors = GetEntityCoords(GetPlayerPed(-1)), true

		for k,doorID in ipairs(Zontti.Doors) do
			local distance

			if doorID.doors then
				distance = #(playerCoords - doorID.doors[1].objCoords)
			else
				distance = #(playerCoords - doorID.objCoords)
			end

			if doorID.distance then
				maxDistance = doorID.distance
			end
			if distance < 50 then
				awayFromDoors = false
				if doorID.doors then
					for _,v in ipairs(doorID.doors) do
						FreezeEntityPosition(v.object, doorID.locked)

						if doorID.locked and v.objYaw and GetEntityRotation(v.object).z ~= v.objYaw then
							SetEntityRotation(v.object, 0.0, 0.0, v.objYaw, 2, true)
						end
					end
				else
					FreezeEntityPosition(doorID.object, doorID.locked)

					if doorID.locked and doorID.objYaw and GetEntityRotation(doorID.object).z ~= doorID.objYaw then
						SetEntityRotation(doorID.object, 0.0, 0.0, doorID.objYaw, 2, true)
					end
				end
			end

			if distance < maxDistance then
				awayFromDoors = false
				if doorID.size then
					size = doorID.size
				end

				local isAutrgzed = IsAutrgzed(doorID)

				if isAutrgzed then
					if doorID.locked then
						displayText = "~g~E~w~ - Lock"
					elseif not doorID.locked then
						displayText = "~g~E~w~ - Open"
					end
				elseif not isAutrgzed then
					if doorID.locked then
						displayText = "Closed"
					elseif not doorID.locked then
						displayText = "Open"
					end
				end

				if doorID.locking then
					if doorID.locked then
						displayText = "To open.."
					else
						displayText = "Close.."
					end
				end

				if doorID.objCoords == nil then
					doorID.objCoords = doorID.textCoords
				end

				DrawText3Ds(doorID.objCoords.x, doorID.objCoords.y, doorID.objCoords.z, displayText)

				print(k)

				if IsControlJustReleased(0, 38) then
					if isAutrgzed then
						setDoorLocking(doorID, k)
					end
				end
			end
		end

		if awayFromDoors then
			Citizen.Wait(1000)
		end
	end
end)

-- local props = {
-- 	"prison_prop_door1",
-- 	"prison_prop_door2",
-- 	"v_ilev_gtdoor",
-- 	"prison_prop_door1a"
-- }

-- Citizen.CreateThread(function()
-- 	while true do
-- 		for k, v in pairs(props) do
-- 			local ped = GetPlayerPed(-1)
-- 			local pos = GetEntityCoords(ped)
-- 			local ClosestDoor = GetClosestObjectOfType(pos.x, pos.y, pos.z, 5.0, GetHashKey(v), 0, 0, 0)
-- 			if ClosestDoor ~= 0 then
-- 				local DoorCoords = GetEntityCoords(ClosestDoor)
	
-- 				DrawText3Ds(DoorCoords.x, DoorCoords.y, DoorCoords.z, "OBJ: "..v..", x: "..round(DoorCoords.x, 0)..", y: "..round(DoorCoords.y, 0)..", z: "..round(DoorCoords.z, 0))
-- 			end
-- 		end
-- 		Citizen.Wait(1)
-- 	end
-- end)

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

RegisterNetEvent('lockpicks:UseLockpick')
AddEventHandler('lockpicks:UseLockpick', function()
	local ped = GetPlayerPed(-1)
	local pos = GetEntityCoords(ped)
	rg.toiminnot.HuutoKaiku('doorlock:server:GetItem', function(hasItem)
		for k, v in pairs(Zontti.Doors) do
			local dist = GetDistanceBetweenCoords(pos, Zontti.Doors[k].textCoords.x, Zontti.Doors[k].textCoords.y, Zontti.Doors[k].textCoords.z)
			if dist < 1.5 then
				if Zontti.Doors[k].pickable then
					if Zontti.Doors[k].locked then
						if hasItem then
							closestDoorKey, closestDoorValue = k, v
							TriggerEvent('lockpick:client:openLockpick', lockpickFinish)
						else
							rg.toiminnot.Notify("A toolkit is missing...", "error")
						end
					else
						rg.toiminnot.Notify('The door is already unlocked ??', 'error', 2500)
					end
				else
					rg.toiminnot.Notify('The door lock is very strong.', 'error', 2500)
				end
			end
		end
    end, "screwdriverset")
end)

function lockpickFinish(success)
    if success then
		rg.toiminnot.Notify('Success!', 'success', 2500)
		setDoorLocking(closestDoorValue, closestDoorKey)
    else
        rg.toiminnot.Notify('Failed..', 'error', 2500)
    end
end

function setDoorLocking(doorId, key)
	doorId.locking = true
	openDoorAnim()
    SetTimeout(400, function()
		doorId.locking = false
		doorId.locked = not doorId.locked
		TriggerServerEvent('doorlock:server:updateState', key, doorId.locked)
	end)
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

function IsAutrgzed(doorID)
	local PlayerData = rg.toiminnot.GetPlayerData()

	for _,job in pairs(doorID.autrgzedJobs) do
		if job == PlayerData.job.name then
			return true
		end
	end
	
	return false
end

function openDoorAnim()
    loadAnimDict("anim@heists@keycard@") 
    TaskPlayAnim(GetPlayerPed(-1), "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0)
	SetTimeout(400, function()
		ClearPedTasks(GetPlayerPed(-1))
	end)
end

RegisterNetEvent('doorlock:client:setState')
AddEventHandler('doorlock:client:setState', function(doorID, state)
	Zontti.Doors[doorID].locked = state
end)

RegisterNetEvent('doorlock:client:setDoors')
AddEventHandler('doorlock:client:setDoors', function(doorList)
	Zontti.Doors = doorList
end)

RegisterNetEvent('rg:Client:OnPlayerLoaded')
AddEventHandler('rg:Client:OnPlayerLoaded', function()
    TriggerServerEvent("doorlock:server:setupDoors")
end)