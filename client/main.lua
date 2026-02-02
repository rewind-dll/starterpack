-- Command to open starter pack menu
RegisterCommand('starterpack', function()
    TriggerServerEvent('starterpack:server:getPacks')
end, false)

-- Receive pack data from server and open UI
RegisterNetEvent('starterpack:client:receiveData', function(packs)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'setVisible',
        visible = true,
        packs = packs
    })
end)

-- NUI Callback: Close the UI
RegisterNuiCallback('close', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'setVisible',
        visible = false,
        packs = {}
    })
    cb('ok')
end)

-- NUI Callback: Claim a pack
RegisterNuiCallback('claimPack', function(data, cb)
    if not data.packId then
        cb('error')
        return
    end
    
    TriggerServerEvent('starterpack:server:claimPack', data.packId)
    
    -- Close UI after claiming
    SetTimeout(500, function()
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = 'setVisible',
            visible = false,
            packs = {}
        })
    end)
    
    cb('ok')
end)
