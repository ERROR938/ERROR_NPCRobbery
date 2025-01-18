local function HasJob(xPlayer)
    for k,v in pairs(Config.AlertJobs) do
        if (xPlayer.job.name == v) then return true end
    end
    return false
end

RegisterNetEvent("error:robNpcReward", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local reward = Config.rewards[math.random(#Config.rewards)]
    if (reward.type) == "money" then
        xPlayer.addAccountMoney(reward.acount, reward.amount)
    else
        xPlayer.addInventoryItem(reward.name, reward.amount)
    end
end)

RegisterNetEvent("ERROR_NPCRobbery:Server:AlertPolice", function(coords)
    local xPlayers = ESX.GetExtendedPlayers()
    for k,v in pairs(xPlayers) do
        local xPlayer = ESX.GetPlayerFromId(v)
        if (HasJob(v)) then
            v.triggerEvent("ERROR_NPCRobbery:Client:AlertPolice", coords)
        end
    end
end)