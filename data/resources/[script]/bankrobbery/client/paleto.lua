local requiredItemsShowed = false
local requiredItemsShowed2 = false

Citizen.CreateThread(function()
    Citizen.Wait(2000)
    local requiredItems = {
        [1] = {name = rg.datapankki.Items["security_card_01"]["name"], image = rg.datapankki.Items["security_card_01"]["image"]},
    }

    local requiredItems2 = {
        [1] = {name = rg.datapankki.Items["thermite"]["name"], image = rg.datapankki.Items["thermite"]["image"]},
    }
    while true do
        local ped = GetPlayerPed(-1)
        local pos = GetEntityCoords(ped)
        local inRange = false
        if rg ~= nil then
            if GetDistanceBetweenCoords(pos, Config.BigBanks["paleto"]["coords"]["x"], Config.BigBanks["paleto"]["coords"]["y"], Config.BigBanks["paleto"]["coords"]["z"]) < 20.0 then
                inRange = true
                if not Config.BigBanks["paleto"]["isOpened"] then
                    local dist = GetDistanceBetweenCoords(pos, Config.BigBanks["paleto"]["coords"]["x"], Config.BigBanks["paleto"]["coords"]["y"], Config.BigBanks["paleto"]["coords"]["z"])
                    if dist < 1 then
                        if not requiredItemsShowed then
                            requiredItemsShowed = true
                            TriggerEvent('inventory:client:requiredItems', requiredItems, true)
                        end
                    else
                        if requiredItemsShowed then
                            requiredItemsShowed = false
                            TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                        end
                    end
                end
                if Config.BigBanks["paleto"]["isOpened"] then
                    for k, v in pairs(Config.BigBanks["paleto"]["lockers"]) do
                        local lockerDist = GetDistanceBetweenCoords(pos, Config.BigBanks["paleto"]["lockers"][k].x, Config.BigBanks["paleto"]["lockers"][k].y, Config.BigBanks["paleto"]["lockers"][k].z)
                        if not Config.BigBanks["paleto"]["lockers"][k]["isBusy"] then
                            if not Config.BigBanks["paleto"]["lockers"][k]["isOpened"] then
                                if lockerDist < 5 then
                                    DrawMarker(2, Config.BigBanks["paleto"]["lockers"][k].x, Config.BigBanks["paleto"]["lockers"][k].y, Config.BigBanks["paleto"]["lockers"][k].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.1, 0.05, 255, 255, 255, 255, false, false, false, 1, false, false, false)
                                    if lockerDist < 0.5 then
                                        DrawText3Ds(Config.BigBanks["paleto"]["lockers"][k].x, Config.BigBanks["paleto"]["lockers"][k].y, Config.BigBanks["paleto"]["lockers"][k].z + 0.3, '[E] Crack the vault')
                                        if IsControlJustPressed(0, Keys["E"]) then
                                            if CurrentCops >= Config.MinimumPaletoPolice then
                                                openLocker("paleto", k)
                                            else
                                                rg.toiminnot.Notify("Não existe policias suficientes.. ", "error")
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if GetDistanceBetweenCoords(pos, Config.BigBanks["paleto"]["thermite"][1]["x"], Config.BigBanks["paleto"]["thermite"][1]["y"], Config.BigBanks["paleto"]["thermite"][1]["z"], true) < 10.0 then
                inRange = true
                if not Config.BigBanks["pacific"]["thermite"][1]["isOpened"] then
                    local dist = GetDistanceBetweenCoords(pos, Config.BigBanks["paleto"]["thermite"][1]["x"], Config.BigBanks["paleto"]["thermite"][1]["y"], Config.BigBanks["paleto"]["thermite"][1]["z"], true)
                    if dist < 1 then
                        currentThermiteGate = Config.BigBanks["paleto"]["thermite"][1]["doorId"]
                        if not requiredItemsShowed2 then
                            requiredItemsShowed2 = true
                            TriggerEvent('inventory:client:requiredItems', requiredItems2, true)
                        end
                    else
                        currentThermiteGate = 0
                        if requiredItemsShowed2 then
                            requiredItemsShowed2 = false
                            TriggerEvent('inventory:client:requiredItems', requiredItems2, false)
                        end
                    end
                end
            end
            if not inRange then
                Citizen.Wait(2500)
            end
        end
        Citizen.Wait(1)
    end
end)

RegisterNetEvent('bankrobbery:UseBankcardA')
AddEventHandler('bankrobbery:UseBankcardA', function()
    local ped = GetPlayerPed(-1)
    local pos = GetEntityCoords(ped)
    local dist = GetDistanceBetweenCoords(pos, Config.BigBanks["paleto"]["coords"]["x"], Config.BigBanks["paleto"]["coords"]["y"],Config.BigBanks["paleto"]["coords"]["z"])
    if math.random(1, 100) <= 85 and not IsWearingHandshoes() then
        TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
    end
    if dist < 1.5 then
        rg.toiminnot.HuutoKaiku('bankrobbery:server:isRobberyActive', function(isBusy)
            if not isBusy then
                if CurrentCops >= Config.MinimumPaletoPolice then
                    if not Config.BigBanks["paleto"]["isOpened"] then 
                        TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                        rg.toiminnot.Progressbar("security_pass", "Validitating card..", math.random(5000, 10000), false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {
                            animDict = "anim@gangops@facility@servers@",
                            anim = "hotwire",
                            flags = 16,
                        }, {}, {}, function()
                            StopAnimTask(GetPlayerPed(-1), "anim@gangops@facility@servers@", "hotwire", 1.0)
                            TriggerServerEvent('bankrobbery:server:setBankState', "paleto", true)
                            TriggerServerEvent("rg:Server:RemoveItem", "security_card_01", 1)
                            TriggerServerEvent('doorlock:server:updateState', 85, false)
                            if not copsCalled then
                                local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, pos.x, pos.y, pos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
                                local street1 = GetStreetNameFromHashKey(s1)
                                local street2 = GetStreetNameFromHashKey(s2)
                                local streetLabel = street1
                                if street2 ~= nil then 
                                    streetLabel = streetLabel .. " " .. street2
                                end
                                if Config.BigBanks["paleto"]["alarm"] then
                                    TriggerServerEvent("bankrobbery:server:callCops", "paleto", 0, streetLabel, pos)
                                    copsCalled = true
                                end
                            end
                        end, function()
                            StopAnimTask(GetPlayerPed(-1), "anim@gangops@facility@servers@", "hotwire", 1.0)
                            rg.toiminnot.Notify("No voi vittu..", "error")
                        end)
                    else
                        rg.toiminnot.Notify("It looks like the bank was already broken into..", "error")
                    end
                else
                    rg.toiminnot.Notify("There are not sufficient police..", "error")
                end
            else
                rg.toiminnot.Notify("The security code is active, for the moment it is not possible to break the door..", "error", 5500)
            end
        end)
    end 
end)

function OpenPaletoDoor()
    TriggerServerEvent('doorlock:server:updateState', 85, false)
    local object = GetClosestObjectOfType(Config.BigBanks["paleto"]["coords"]["x"], Config.BigBanks["paleto"]["coords"]["y"], Config.BigBanks["paleto"]["coords"]["z"], 5.0, Config.BigBanks["paleto"]["object"], false, false, false)
    local timeOut = 10
    local entHeading = Config.BigBanks["paleto"]["heading"].closed

    if object ~= 0 then
        SetEntityHeading(object, Config.BigBanks["paleto"]["heading"].open)
    end
end