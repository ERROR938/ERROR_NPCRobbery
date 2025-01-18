if (Config.ESXVerison == "newESX") then
    ESX = exports['es_extended']:getSharedObject()
else
    ESX = nil
    CreateThread(function()
        while ESX == nil do
            TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)
            Wait(0)
        end
    end)
end

local peds = {}
local possibilities = {
    "attack",
    "deny",
    "accept"
}

local function CreateBlip(coords, sprite, color, text)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
    return blip
end

local function ForceNpcToAttack(ped, playerPed, weaponn)
    GiveWeaponToPed(ped, GetHashKey(weaponn), 200, false, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedCombatAttributes(ped, 5, true)
    SetPedCombatMovement(ped, 2)
    SetPedCombatRange(ped, 2)
    SetPedAlertness(ped, 3)
    SetPedAccuracy(ped, 75)

    AddRelationshipGroup("HATES_PLAYER")
    SetPedRelationshipGroupHash(ped, GetHashKey("HATES_PLAYER"))
    SetRelationshipBetweenGroups(5, GetHashKey("HATES_PLAYER"), GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("HATES_PLAYER"))

    ClearPedTasksImmediately(ped)
    TaskCombatPed(ped, playerPed, 0, 16)
end

local function PlayAnim(ped, dict, animName, duration)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
    Citizen.Wait(100)
    end
    TaskPlayAnim(ped, dict, animName, 8.0, -8, duration or -1, 49, 0, 0, 0, 0)
end

local function IsWeaponBlacklist(weapon)
    for _,v in pairs(Config.BlacklistWeapons) do
        if (weapon == GetHashKey(v)) then return true end
    end
    return false
end

CreateThread(function()
    local sleep, is_aiming, ped
    local ped_coords, handTime = nil, (Config.RobTime*1000)/2
    while (function()
        sleep = 1000
        is_aiming, ped = GetEntityPlayerIsFreeAimingAt(PlayerId(-1))
        if (not is_aiming) then return true end
        if (IsPedDeadOrDying(ped) or not DoesEntityExist(ped)) or IsPedInAnyVehicle(ped) then return true end
        if (peds[ped] or IsPedAPlayer(ped)) then return true end
        if (GetEntityScript(ped) ~= nil) then return true end
        if (IsWeaponBlacklist(GetSelectedPedWeapon(PlayerPedId()))) then return true end
        peds[ped] = "1"
        local number = math.random(1, #possibilities)
        local action = possibilities[number]
        SetBlockingOfNonTemporaryEvents(ped, true)
        if (action == "attack") then
            local weapon = (Config.NpcGuns[math.random(1, #Config.NpcGuns)]):upper()
            ForceNpcToAttack(ped, PlayerPedId(), weapon)
            Config.AlertPoliceFunction(ped)
            return true
        end

        if (action == "deny") then
            TaskReactAndFleePed(ped, PlayerPedId())
            TaskGoStraightToCoord(ped, 0.0, 0.0, 0.0, 3.0, -1, 0.0, 0.0)
            Config.AlertPoliceFunction(ped)
            SetTimeout(10000, function()
                DeleteEntity(ped)
            end)
            return true
        end
        TaskStandStill(ped, Config.RobTime*1000)
        PlayAnim(ped, "random@mugging3", "handsup_standing_base", handTime)
        Wait(handTime)
        StopAnimTask(ped, "random@mugging3", "handsup_standing_base", 1.0)
        PlayAnim(ped, "mp_common", "givetake2_a", 3003)
        Wait(1000)
        SetTimeout(GetAnimDuration("mp_common", "givetake2_a"), function() 
            TriggerServerEvent("error:robNpcReward")
            ClearPedTasks(ped)
        end)
        return true
    end) () do
        Wait(sleep)
    end
end)

RegisterNetEvent("ERROR_NPCRobbery:Client:AlertPolice", function(coords)
    print(coords)
    local streetName = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local blip = CreateBlip(coords, Config.Blip['sprite'], Config.Blip['color'], "Braquage en cours")
    ESX.ShowNotification((Config.Blip['text']):format(GetStreetNameFromHashKey(streetName)))
    SetTimeout(Config.Blip['time']*1000, function()
        RemoveBlip(blip)
    end)
end)