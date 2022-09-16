
local QBCore = exports['qb-core']:GetCoreObject()

local Safes = {}

local SafesObjects = {}

function Init ()
    for i, v in pairs (Safes) do 
        QBCore.Functions.LoadModel(v.hash)
        SafesObjects[v.name] = CreateObject(v.hash, v.coords.x, v.coords.y, v.coords.z, false)
        SetEntityHeading(SafesObjects[v.name], v.coords.w)
        FreezeEntityPosition(SafesObjects[v.name], true)
        exports['qb-target']:AddEntityZone(v.name, SafesObjects[v.name], {
            name = v.name,
            heading = v.coords.w,
            debugPoly = false,
        }, {
            options = {
                {
                    type = "client",
                    event = "Diesel-Safe:Client:OpenSafeKeyPad",
                    icon = "fa-solid fa-vault",
                    label = "Open Safe",
                    name = v.name,
                    slots = v.slots,
                    weight = v.weight
                },
                {
                    type = "client",
                    event = "Diesel-Safe:Client:RemoveSpecificSafe",
                    icon = "fa-solid fa-skull-crossbones",
                    label = "Remove Safe And Lose All Its Contents",
                    name = v.name,
                    slots = v.slots,
                    weight = v.weight,
                    canInteract = function ()
                        if QBCore.Functions.GetPlayerData().citizenid == v.owner then return true else return false end
                    end
                },
            },
            distance = 1.5
        })

    end
end

local function AnySafesNearbye (coords) 
    local Objs = GetGamePool('CObject')
    for i, v in pairs (Objs) do 
        for k, m in pairs (Config.Safes) do 
            if GetEntityModel(v) == m.hash then 
                if #(GetEntityCoords(v) - coords) < 5 then 
                    return true
                end
            end
        end
    end
    return false
end

AddEventHandler ('QBCore:Client:OnPlayerLoaded', function ()
	QBCore.Functions.TriggerCallback('Diesel-Safe:Server:GetCurrentSafesInfo', function(CurrSafes) -- to keep sync of owned and closed state when the player joins the server
		Safes = CurrSafes
        Init()
	end)
end)

RegisterNetEvent('Diesel-Safe:Client:OpenSafeKeyPad', function(data)
    local name = data.name
    local slots = data.slots
    local weight = data.weight
    local password = exports['qb-input']:ShowInput({
        header = "Enter Safe " .. name .." Password",
        submitText = "Submit",
        inputs = {
            {
                text = "Enter Password", -- text you want to be displayed as a place holder
                name = "safepassword", -- name of the input should be unique otherwise it might override
                type = "password", -- type of the input
                isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
            },
        },
    })
    if password ~= nil then
        if password.safepassword ~= nil then
            QBCore.Functions.TriggerCallback('Diesel-Safe:Server:CheckSafePassword', function(result)
                if result then 
                    TriggerServerEvent("inventory:server:OpenInventory", "stash", name, {maxweight = tonumber(weight), slots = tonumber(slots)})
	                TriggerEvent("inventory:client:SetCurrentStash", name) 
                else
                    QBCore.Functions.Notify('Wrong Password', 'error', 5000)
                end
            end, name, password.safepassword)
        end
    end
end)

RegisterNetEvent('Diesel-Safe:Client:RemoveSpecificSafe', function(data)
    TriggerServerEvent('Diesel-Safe:Server:RemoveSpecificSafe', data.name, data.slots, data.weight)
end)

RegisterNetEvent('Diesel-Safe:Client:FinalizeRemoveSpecificSafe', function(safename)
    DeleteObject(SafesObjects[safename])
end)

RegisterNetEvent('Diesel-Safe:Client:CreateSafeWithType', function(type)
    local ped = PlayerPedId()
    local head = GetEntityHeading(ped)
    local forward, _, _, pos = GetEntityMatrix(ped)
    local initSafePos = pos + forward/2
    if not AnySafesNearbye(pos) then
        QBCore.Functions.TriggerCallback('Diesel-Safe:Server:CheckAndTakeSafeWithType', function(result)
            if result then 
                local safePos = {x = initSafePos.x, y = initSafePos.y, z = initSafePos.z-1, w = head}
                local password = exports['qb-input']:ShowInput({
                    header = "Generate Safe Password",
                    submitText = "Generate",
                    inputs = {
                        {
                            text = "Secret Code (Give to Nobody)", -- text you want to be displayed as a place holder
                            name = "safepassword", -- name of the input should be unique otherwise it might override
                            type = "password", -- type of the input
                            isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
                        },
                    },
                })
                if password ~= nil then
                    if password.safepassword ~= nil then
                        QBCore.Functions.TriggerCallback('Diesel-Safe:Client:AddNewSafeForCoords', function(result, errorMessage)
                            if result then 
                                QBCore.Functions.Notify('Safe Added Successfully ', 'success', 5000)
                            else
                                QBCore.Functions.Notify(errorMessage, 'error', 5000)
                            end
                        end, safePos, type, password.safepassword)
                    end
                end
            else
                QBCore.Functions.Notify('Error!', 'error', 3000)
            end
        end, type)
    else
        QBCore.Functions.Notify('There Is Safe Near You', 'error', 5000)
    end
end)

RegisterNetEvent('Diesel-Safe:Client:FinalizeAddNewSafe', function (hash, coords, name, slots, weight, owner)
    QBCore.Functions.LoadModel(hash)
    SafesObjects[name] = CreateObject(hash, coords.x, coords.y, coords.z, false)
    SetEntityHeading(SafesObjects[name], coords.w)
    FreezeEntityPosition(SafesObjects[name], true)

    exports['qb-target']:AddEntityZone(name, SafesObjects[name], {
        name = name,
        heading = coords.w,
        debugPoly = false,
    }, {
        options = {
            {
                type = "client",
                event = "Diesel-Safe:Client:OpenSafeKeyPad",
                icon = "fa-solid fa-vault",
                label = "Open Safe",
                name = name,
                slots = slots,
                weight = weight
            },
            {
                type = "client",
                event = "Diesel-Safe:Client:RemoveSpecificSafe",
                icon = "fa-solid fa-skull-crossbones",
                label = "Remove Safe And Lose All Its Contents",
                name = name,
                slots = slots,
                weight = weight,
                canInteract = function ()
                    if QBCore.Functions.GetPlayerData().citizenid == owner then return true else return false end
                end
            },
        },
        distance = 1.5
    })
end)