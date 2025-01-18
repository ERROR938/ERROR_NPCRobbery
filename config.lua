Config = {}
Config.ESXVerison = "newESX" -- esx or newESX
Config.RobTime = 10 -- temps en seconde
Config.rewards = {
    {type = "item", name = "bread", amount = 1},
    {type = "money", acount = "money", amount = 2500},
    {type = "money", acount = "black_money", amount = 10000},
}

Config.Blip = {
    time = 15, -- temps qu'il reste en secondes,
    sprite = 42,
    color = 1,
    text = "Un citoyen se faire braquer sur %s"
}

Config.BlacklistWeapons = {
    "weapon_unarmed",
    "weapon_fireextinguisher",
    "weapon_petrolcan",
    "weapon_hazardcan",
    "weapon_fertilizercan"
}

Config.AlertJobs = {
    "police",
}

Config.NpcGuns = {
    "weapon_knuckle",
    "weapon_switchblade",
    "weapon_snspistol"
}

Config.AlertPoliceFunction = function(ped)
    TriggerServerEvent("ERROR_NPCRobbery:Server:AlertPolice", GetEntityCoords(ped))
end