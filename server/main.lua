-- Create database table on resource start
MySQL.ready(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS starter_packs (
            identifier VARCHAR(60) PRIMARY KEY,
            packs_claimed TEXT
        )
    ]])
end)

-- Check if player has claimed a specific pack
local function hasClaimedPack(identifier, packId)
    local result = MySQL.query.await('SELECT packs_claimed FROM starter_packs WHERE identifier = ?', { identifier })
    
    if not result or #result == 0 then
        return false
    end
    
    local claimed = json.decode(result[1].packs_claimed) or {}
    return claimed[packId] == true
end

-- Save claimed pack to database
local function saveClaimedPack(identifier, packId)
    local result = MySQL.query.await('SELECT packs_claimed FROM starter_packs WHERE identifier = ?', { identifier })
    local claimed = {}
    
    if result and #result > 0 then
        claimed = json.decode(result[1].packs_claimed) or {}
    end
    
    claimed[packId] = true
    
    MySQL.insert('INSERT INTO starter_packs (identifier, packs_claimed) VALUES (?, ?) ON DUPLICATE KEY UPDATE packs_claimed = ?', {
        identifier,
        json.encode(claimed),
        json.encode(claimed)
    })
end

-- Check if player is a Discord booster
local function isDiscordBooster(source)
    -- If no bot token configured, deny booster packs
    if not Config.DiscordBotToken or Config.DiscordBotToken == '' then
        return false
    end
    
    local discordId = nil
    
    -- Extract Discord ID from identifiers
    for _, id in pairs(GetPlayerIdentifiers(source)) do
        if string.match(id, 'discord:') then
            discordId = string.gsub(id, 'discord:', '')
            break
        end
    end
    
    if not discordId then
        return false
    end
    
    -- Check booster status via Discord API (synchronous using promise)
    local endpoint = ('https://discord.com/api/v10/guilds/%s/members/%s'):format(Config.DiscordGuildId, discordId)
    local p = promise.new()
    
    PerformHttpRequest(endpoint, function(statusCode, response, headers)
        if statusCode == 200 then
            local data = json.decode(response)
            if data and data.premium_since then
                p:resolve(true)
            else
                p:resolve(false)
            end
        else
            p:resolve(false)
        end
    end, 'GET', '', {
        ['Authorization'] = 'Bot ' .. Config.DiscordBotToken
    })
    
    return Citizen.Await(p)
end

-- Get available packs for player
RegisterNetEvent('starterpack:server:getPacks', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    local packs = {}
    
    for _, pack in ipairs(Config.Packs) do
        local claimed = hasClaimedPack(xPlayer.identifier, pack.id)
        local canClaim = true
        
        -- Check booster requirement
        if pack.requiresBooster and not claimed then
            canClaim = isDiscordBooster(src)
        end
        
        table.insert(packs, {
            id = pack.id,
            name = pack.name,
            description = pack.description,
            image = pack.image,
            requiresBooster = pack.requiresBooster,
            rewards = pack.rewards,
            claimed = claimed,
            canClaim = canClaim
        })
    end
    
    TriggerClientEvent('starterpack:client:receiveData', src, packs)
end)

-- Claim a starter pack
RegisterNetEvent('starterpack:server:claimPack', function(packId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    -- Find the pack
    local pack = nil
    for _, p in ipairs(Config.Packs) do
        if p.id == packId then
            pack = p
            break
        end
    end
    
    if not pack then
        lib.notify(src, {
            title = 'Error',
            description = 'Invalid starter pack',
            type = 'error'
        })
        return
    end
    
    -- Check if already claimed
    if hasClaimedPack(xPlayer.identifier, packId) then
        lib.notify(src, {
            title = 'Already Claimed',
            description = 'You have already claimed this pack',
            type = 'error'
        })
        return
    end
    
    -- Check booster requirement
    if pack.requiresBooster and not isDiscordBooster(src) then
        lib.notify(src, {
            title = 'Booster Required',
            description = 'You must be boosting the Discord server to claim this pack',
            type = 'error'
        })
        return
    end
    
    -- Give rewards
    for _, reward in ipairs(pack.rewards) do
        if reward.type == 'item' then
            xPlayer.addInventoryItem(reward.name, reward.amount)
        elseif reward.type == 'money' then
            if reward.account == 'money' then
                xPlayer.addMoney(reward.amount)
            elseif reward.account == 'bank' then
                xPlayer.addAccountMoney('bank', reward.amount)
            end
        end
    end
    
    -- Save claimed status
    saveClaimedPack(xPlayer.identifier, packId)
    
    -- Notify player
    lib.notify(src, {
        title = 'Pack Claimed!',
        description = ('You have claimed the %s'):format(pack.name),
        type = 'success'
    })
    
    -- Send updated pack data
    TriggerEvent('starterpack:server:getPacks')
end)

-- Admin command to reset claims for a player
RegisterCommand('resetstarterpacks', function(source, args, rawCommand)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if not xPlayer then return end
    
    -- Check if player is admin (adjust this based on your admin system)
    if xPlayer.getGroup() ~= 'admin' and xPlayer.getGroup() ~= 'superadmin' then
        lib.notify(src, {
            title = 'No Permission',
            description = 'You must be an admin to use this command',
            type = 'error'
        })
        return
    end
    
    local targetId = tonumber(args[1])
    
    if not targetId then
        -- Reset own claims
        MySQL.query('DELETE FROM starter_packs WHERE identifier = ?', { xPlayer.identifier })
        lib.notify(src, {
            title = 'Claims Reset',
            description = 'Your starter pack claims have been reset',
            type = 'success'
        })
    else
        -- Reset target player claims
        local targetPlayer = ESX.GetPlayerFromId(targetId)
        if targetPlayer then
            MySQL.query('DELETE FROM starter_packs WHERE identifier = ?', { targetPlayer.identifier })
            lib.notify(src, {
                title = 'Claims Reset',
                description = ('Reset claims for player ID %s'):format(targetId),
                type = 'success'
            })
            lib.notify(targetId, {
                title = 'Claims Reset',
                description = 'Your starter pack claims have been reset by an admin',
                type = 'info'
            })
        else
            lib.notify(src, {
                title = 'Error',
                description = 'Player not found',
                type = 'error'
            })
        end
    end
end, false)
