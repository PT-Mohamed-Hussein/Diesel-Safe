local QBCore = exports['qb-core']:GetCoreObject()

local Safes = {}

local SafesPassword = {}

MySQL.Async.fetchAll('SELECT * FROM `diesel-safe`', {}, function(result)
    if result then
        for i, v in pairs (result) do
            Safes[v.name] = {
                ['name'] = v.name,
                ['coords'] = json.decode(v.coords),
                ['owner'] = v.owner,
                ['slots'] = v.slots,
                ['weight'] = v.weight,
                ['hash'] = tonumber(v.hash),
                ['model'] = v.model
            }
            SafesPassword[v.name] = v.password
        end
    end
end)

--[[    Functions   ]]

local function GetSafeCountByCitizenId (cid) -- used to write safe name which will be in this formate safeno[NumberGeneratedFromHere]cid eg: safeno[1]MBZ58190 and this will be the name of the stash too 
    local count = 0
    for i, v in pairs (Safes) do 
        if v['owner'] == cid then 
            count = count + 1
        end
    end
    return count
end

local function GetSafeNameByParams(slots, weight)
    for i, v in pairs(Config.Safes) do 
        if v.slots == slots and v.weight == weight then 
            return v.name
        end
    end
    return false
end

--[[    CallBacks   ]]

QBCore.Functions.CreateCallback('Diesel-Safe:Server:GetCurrentSafesInfo', function(source, cb)
    cb(Safes)
end)

QBCore.Functions.CreateCallback('Diesel-Safe:Server:CheckAndTakeSafeWithType', function(source, cb, type)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem(Config.Safes[type].name, 1) then
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('Diesel-Safe:Server:CheckSafePassword', function(source, cb, safename, password)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if SafesPassword[safename] == password then
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('Diesel-Safe:Client:AddNewSafeForCoords', function (source, cb, coords, type, password)
    local src = source
    local weight = Config.Safes[type].weight
    local slots = Config.Safes[type].slots
    local model = Config.Safes[type].model
    local hash = Config.Safes[type].hash
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    local SafeName = 'safeno['..GetSafeCountByCitizenId(cid)..']'..cid
    local result = MySQL.Sync.insert('INSERT INTO `diesel-safe` (name, coords, owner, slots, weight, password, hash, model) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {SafeName, json.encode(coords), cid, slots, weight, password, hash, model})
    if result then
        SafesPassword[SafeName] = password
        Safes[SafeName] = {
            ['name'] = SafeName,
            ['coords'] = coords,
            ['owner'] = cid,
            ['slots'] = slots,
            ['weight'] = weight,
            ['hash'] = hash,
            ['model'] = model
        }
        TriggerClientEvent('Diesel-Safe:Client:FinalizeAddNewSafe', -1, hash, coords, SafeName, slots, weight, cid )
        cb(true)
    else
        cb(false, 'Unkown Error Occured At Database Connection Please Refere To Server Developer')
    end
end)

--[[    Items   ]]

for i, v in pairs (Config.Safes) do 
    QBCore.Functions.CreateUseableItem(v.name, function(source, item)
        local src = source
        TriggerClientEvent('Diesel-Safe:Client:CreateSafeWithType', source, v.type)
    end)
end

--[[    Events   ]]

RegisterNetEvent('Diesel-Safe:Server:RemoveSpecificSafe', function(name, slots, weight)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local safeitem = GetSafeNameByParams(slots, weight)
    if safeitem then 
        Player.Functions.AddItem(safeitem, 1)
    end
    Safes[name] = nil
    SafesPassword[name] = nil
    TriggerClientEvent('Diesel-Safe:Client:FinalizeRemoveSpecificSafe', -1, name)
    MySQL.Async.execute('DELETE FROM `diesel-safe` WHERE name = ?', { name })
end)