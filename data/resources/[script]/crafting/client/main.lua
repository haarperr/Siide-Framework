Keys = {['ESC'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169, ['F9'] = 56, ['F10'] = 57, ['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177, ['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['['] = 39, [']'] = 40, ['ENTER'] = 18, ['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182, ['LEFTSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81, ['LEFTCTRL'] = 36, ['LEFTALT'] = 19, ['SPACE'] = 22, ['RIGHTCTRL'] = 70, ['HOME'] = 213, ['PAGEUP'] = 10, ['PAGEDOWN'] = 11, ['DELETE'] = 178, ['LEFT'] = 174, ['RIGHT'] = 175, ['TOP'] = 27, ['DOWN'] = 173}

rg = nil
local itemInfos = {}

Citizen.CreateThread(function()
	while rg == nil do
		TriggerEvent('rg:HaeAsia', function(obj) rg = obj end)
		Citizen.Wait(0)
	end
	ItemsToItemInfo()
end)

function DrawText3D(x, y, z, text)
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

local maxDistance = 1.25
Citizen.CreateThread(function()
	
		local blip = AddBlipForCoord(3618.32,3730.28,28.69)
        SetBlipSprite(blip, 466)
        --SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        SetBlipColour(blip, 81)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Seppä")
        EndTextCommandSetBlipName(blip)
	
    Citizen.Wait(1000)
    
end)
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local pos, awayFromObject = GetEntityCoords(GetPlayerPed(-1)), true
		local craftObject = GetClosestObjectOfType(pos, 2.0, -573669520, false, false, false)
		if craftObject ~= 0 then
			local objectPos = GetEntityCoords(craftObject)
			if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, objectPos.x, objectPos.y, objectPos.z, true) < 1.5 then
				awayFromObject = false
				DrawText3D(objectPos.x, objectPos.y, objectPos.z + 1.0, "~g~E~w~ - Craft")
				if IsControlJustReleased(0, Keys["E"]) then
					local crafting = {}
					crafting.label = "Crafting"
					crafting.items = GetThresholdItems()
					TriggerServerEvent("inventory:server:OpenInventory", "crafting", math.random(1, 99), crafting)
				end
			end
		end

		if awayFromObject then
			Citizen.Wait(1000)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		local ped = GetPlayerPed(-1)
		local pos = GetEntityCoords(ped)
		local inRange = false
		local distance = GetDistanceBetweenCoords(pos, Config.AttachmentCrafting["location"].x, Config.AttachmentCrafting["location"].y, Config.AttachmentCrafting["location"].z, true)

		if distance < 10 then
			inRange = true
			if distance < 1.5 then
				DrawText3D(Config.AttachmentCrafting["location"].x, Config.AttachmentCrafting["location"].y, Config.AttachmentCrafting["location"].z, "~g~E~w~ - Craft")
				if IsControlJustPressed(0, Keys["E"]) then
					local crafting = {}
					crafting.label = "Attachment Crafting"
					crafting.items = GetAttachmentThresholdItems()
					TriggerServerEvent("inventory:server:OpenInventory", "attachment_crafting", math.random(1, 99), crafting)
				end
			end
		end

		if not inRange then
			Citizen.Wait(1000)
		end

		Citizen.Wait(3)
	end
end)

function GetThresholdItems()
	local items = {}
	for k, item in pairs(Config.CraftingItems) do
		if rg.toiminnot.GetPlayerData().metadata["craftingrep"] >= Config.CraftingItems[k].threshold then
			items[k] = Config.CraftingItems[k]
		end
	end
	return items
end

function SetupAttachmentItemsInfo()
	itemInfos = {
		[1] = {costs = rg.datapankki.Items["metalscrap"]["label"] .. ": 140x, " .. rg.datapankki.Items["steel"]["label"] .. ": 250x, " .. rg.datapankki.Items["rubber"]["label"] .. ": 60x"},
		[2] = {costs = rg.datapankki.Items["metalscrap"]["label"] .. ": 165x, " .. rg.datapankki.Items["steel"]["label"] .. ": 285x, " .. rg.datapankki.Items["rubber"]["label"] .. ": 75x"},
		[3] = {costs = rg.datapankki.Items["metalscrap"]["label"] .. ": 190x, " .. rg.datapankki.Items["steel"]["label"] .. ": 305x, " .. rg.datapankki.Items["rubber"]["label"] .. ": 85x"},
		[4] = {costs = rg.datapankki.Items["metalscrap"]["label"] .. ": 205x, " .. rg.datapankki.Items["steel"]["label"] .. ": 340x, " .. rg.datapankki.Items["rubber"]["label"] .. ": 110x"},
		[5] = {costs = rg.datapankki.Items["metalscrap"]["label"] .. ": 230x, " .. rg.datapankki.Items["steel"]["label"] .. ": 365x, " .. rg.datapankki.Items["rubber"]["label"] .. ": 130x"},
		[6] = {costs = rg.datapankki.Items["metalscrap"]["label"] .. ": 255x, " .. rg.datapankki.Items["steel"]["label"] .. ": 390x, " .. rg.datapankki.Items["rubber"]["label"] .. ": 145x"},
		[7] = {costs = rg.datapankki.Items["metalscrap"]["label"] .. ": 270x, " .. rg.datapankki.Items["steel"]["label"] .. ": 435x, " .. rg.datapankki.Items["rubber"]["label"] .. ": 155x"},
		[8] = {costs = rg.datapankki.Items["metalscrap"]["label"] .. ": 300x, " .. rg.datapankki.Items["steel"]["label"] .. ": 469x, " .. rg.datapankki.Items["rubber"]["label"] .. ": 170x"},
		[9] = {costs = rg.datapankki.Items["metalscrap"]["label"] .. ": 300x, " .. rg.datapankki.Items["steel"]["label"] .. ": 469x, " .. rg.datapankki.Items["rubber"]["label"] .. ": 170x"},
	}

	local items = {}
	for k, item in pairs(Config.AttachmentCrafting["items"]) do
		local itemInfo = rg.datapankki.Items[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = itemInfos[item.slot],
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"], 
			type = itemInfo["type"], 
			unique = itemInfo["unique"], 
			useable = itemInfo["useable"], 
			image = itemInfo["image"],
			slot = item.slot,
			costs = item.costs,
			threshold = item.threshold,
			points = item.points,
		}
	end
	Config.AttachmentCrafting["items"] = items
end

function GetAttachmentThresholdItems()
	SetupAttachmentItemsInfo()
	local items = {}
	for k, item in pairs(Config.AttachmentCrafting["items"]) do
		if rg.toiminnot.GetPlayerData().metadata["attachmentcraftingrep"] >= Config.AttachmentCrafting["items"][k].threshold then
			items[k] = Config.AttachmentCrafting["items"][k]
		end
	end
	return items
end

function ItemsToItemInfo()
	itemInfos = {
		[1] = {costs = rg.datapankki.Items["metalscrap"]["label"] .. ": 22x, " ..rg.datapankki.Items["plastic"]["label"] .. ": 32x."},
		[2] = {costs = rg.datapankki.Items["metalscrap"]["label"] .. ": 30x, " ..rg.datapankki.Items["plastic"]["label"] .. ": 42x."},
		[3] = {costs = rg.datapankki.Items["metalscrap"]["label"] .. ": 30x, " ..rg.datapankki.Items["plastic"]["label"] .. ": 45x, "..rg.datapankki.Items["aluminum"]["label"] .. ": 28x."},
		[4] = {costs = rg.datapankki.Items["electronickit"]["label"] .. ": 2x, " ..rg.datapankki.Items["plastic"]["label"] .. ": 52x, "..rg.datapankki.Items["steel"]["label"] .. ": 40x."},
		[5] = {costs = rg.datapankki.Items["metalscrap"]["label"] .. ": 10x, " ..rg.datapankki.Items["plastic"]["label"] .. ": 50x, "..rg.datapankki.Items["aluminum"]["label"] .. ": 30x, "..rg.datapankki.Items["iron"]["label"] .. ": 17x, "..rg.datapankki.Items["electronickit"]["label"] .. ": 1x."},
		[6] = {costs = rg.datapankki.Items["metalscrap"]["label"] .. ": 36x, " ..rg.datapankki.Items["steel"]["label"] .. ": 24x, "..rg.datapankki.Items["aluminum"]["label"] .. ": 28x."},
		[7] = {costs = rg.datapankki.Items["metalscrap"]["label"] .. ": 32x, " ..rg.datapankki.Items["steel"]["label"] .. ": 43x, "..rg.datapankki.Items["plastic"]["label"] .. ": 61x."},
		[8] = {costs = rg.datapankki.Items["metalscrap"]["label"] .. ": 50x, " ..rg.datapankki.Items["steel"]["label"] .. ": 37x, "..rg.datapankki.Items["copper"]["label"] .. ": 26x."},
		[9] = {costs = rg.datapankki.Items["iron"]["label"] .. ": 60x, " ..rg.datapankki.Items["glass"]["label"] .. ": 30x."},
		[10] = {costs = rg.datapankki.Items["aluminum"]["label"] .. ": 60x, " ..rg.datapankki.Items["glass"]["label"] .. ": 30x."},
		[11] = {costs = rg.datapankki.Items["iron"]["label"] .. ": 33x, " ..rg.datapankki.Items["steel"]["label"] .. ": 44x, "..rg.datapankki.Items["plastic"]["label"] .. ": 55x, "..rg.datapankki.Items["aluminum"]["label"] .. ": 22x."},
		[12] = {costs = rg.datapankki.Items["iron"]["label"] .. ": 50x, " ..rg.datapankki.Items["steel"]["label"] .. ": 50x, "..rg.datapankki.Items["screwdriverset"]["label"] .. ": 3x, "..rg.datapankki.Items["advancedlockpick"]["label"] .. ": 2x."},
	}

	local items = {}
	for k, item in pairs(Config.CraftingItems) do
		local itemInfo = rg.datapankki.Items[item.name:lower()]
		items[item.slot] = {
			name = itemInfo["name"],
			amount = tonumber(item.amount),
			info = itemInfos[item.slot],
			label = itemInfo["label"],
			description = itemInfo["description"] ~= nil and itemInfo["description"] or "",
			weight = itemInfo["weight"], 
			type = itemInfo["type"], 
			unique = itemInfo["unique"], 
			useable = itemInfo["useable"], 
			image = itemInfo["image"],
			slot = item.slot,
			costs = item.costs,
			threshold = item.threshold,
			points = item.points,
		}
	end
	Config.CraftingItems = items
end