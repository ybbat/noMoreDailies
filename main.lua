local nmd = RegisterMod("No More Dailies", 1)

local json = require("json")

nmd.dedication_flags = {
    "# runs",
    "# achievements"
}

local function getTableIndex(tbl, val)
    for i, v in ipairs(tbl) do
        if v == val then
            return i
        end
    end

    return 0
end

nmd.persistentData = {
    cracked_crown = 5,
    broken_modem = 7,
    dedication_flag = nmd.dedication_flags[1],
    dedication_victories = 31,
    dedication_achievements = 200
}


function nmd:modConfigMenuInit(_)
    if ModConfigMenu == nil then
        return
    end

    ModConfigMenu.AddSetting(
        "No More Dailies",
        "Config",
        {
            Type = ModConfigMenu.OptionType.NUMBER,
            CurrentSetting = function()
                return nmd.persistentData.cracked_crown
            end,
            OnChange = function(n)
                nmd.persistentData.cracked_crown = n
                nmd:saveData()
            end,
            Display = function()
                return "Win streak to unlock cracked crown " .. (nmd.persistentData.cracked_crown)
            end,
            Minimum = 1,
            Maximum = 100,
        }
    )
    ModConfigMenu.AddSetting(
        "No More Dailies",
        "Config",
        {
            Type = ModConfigMenu.OptionType.NUMBER,
            CurrentSetting = function()
                return nmd.persistentData.broken_modem
            end,
            OnChange = function(n)
                nmd.persistentData.broken_modem = n
                nmd:saveData()
            end,
            Display = function()
                return "Victories to unlock broken modem " .. (nmd.persistentData.broken_modem)
            end,
            Minimum = 1,
            Maximum = 100,
        }
    )

    -- Dedication flag selection
    ModConfigMenu.AddSetting(
        "No More Dailies",
        "Config",
        {
            Type = ModConfigMenu.OptionType.NUMBER,
            CurrentSetting = function()
                return getTableIndex(nmd.dedication_flags, nmd.persistentData.dedication_flag)
            end,
            OnChange = function(n)
                print(n)
                print(nmd.dedication_flags)
                print(nmd.dedication_flags[n])
                nmd.persistentData.dedication_flag = nmd.dedication_flags[n]
                nmd:saveData()
                ModConfigMenu.RemoveSubcategory("No More Dailies", "Config")
                nmd:modConfigMenuInit()
            end,
            Display = function()
                return "Dedication unlock method: " .. (nmd.persistentData.dedication_flag)
            end,
            Minimum = 1,
            Maximum = #nmd.dedication_flags,
        }
    )

    if nmd.persistentData.dedication_flag == "# runs" then
        ModConfigMenu.AddSetting(
            "No More Dailies",
            "Config",
            {
                Attribute = "dedication",
                Type = ModConfigMenu.OptionType.NUMBER,
                CurrentSetting = function()
                    return nmd.persistentData.dedication_victories
                end,
                OnChange = function(n)
                    nmd.persistentData.dedication_victories = n
                    nmd:saveData()
                end,
                Display = function()
                    return "Runs to unlock dedication " .. (nmd.persistentData.dedication_victories)
                end,
                Minimum = 1,
                Maximum = 100,
            }
        )
    elseif nmd.persistentData.dedication_flag == "# achievements" then
        ModConfigMenu.AddSetting(
            "No More Dailies",
            "Config",
            {
                Attribute = "dedication",
                Type = ModConfigMenu.OptionType.NUMBER,
                CurrentSetting = function()
                    return nmd.persistentData.dedication_achievements
                end,
                OnChange = function(n)
                    nmd.persistentData.dedication_achievements = n
                    nmd:saveData()
                end,
                Display = function()
                    return "Achievements to unlock dedication " .. (nmd.persistentData.dedication_achievements)
                end,
                Minimum = 1,
                Maximum = 637,
            }
        )
    end
end

nmd:modConfigMenuInit()

function nmd:saveData(_)
    local jsonString = json.encode(nmd.persistentData)
    nmd:SaveData(jsonString)
end

nmd:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, nmd.saveData)

function nmd:loadData(_)
    if not nmd:HasData() then
        return
    end

    local jsonString = nmd:LoadData()
    nmd.persistentData = json.decode(jsonString)
    ModConfigMenu.RemoveSubcategory("No More Dailies", "Config")
    nmd:modConfigMenuInit()
end

nmd:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, nmd.loadData)

function nmd:checkDailies(_)
    local gd = Isaac:GetPersistentGameData()

    if not gd:Unlocked(Achievement.CRACKED_CROWN) and nmd:crownCheck(gd) then
        gd:TryUnlock(Achievement.CRACKED_CROWN)
    end

    if not gd:Unlocked(Achievement.BROKEN_MODEM) and nmd:modemCheck(gd) then
        gd:TryUnlock(Achievement.BROKEN_MODEM)
    end

    if not gd:Unlocked(Achievement.DEDICATION) and nmd:dedicationCheck(gd) then
        gd:TryUnlock(Achievement.DEDICATION)
    end
end

function nmd:crownCheck(gd)
    return gd:GetEventCounter(EventCounter.STREAK_COUNTER) >= nmd.persistentData.cracked_crown
end

function nmd:modemCheck(gd)
    return gd:GetEventCounter(EventCounter.MOM_KILLS) >= nmd.persistentData.broken_modem
end

function nmd:dedicationCheck(gd)
    if nmd.persistentData.dedication_flag == "# runs" then
        return (gd:GetEventCounter(EventCounter.MOM_KILLS) + gd:GetEventCounter(EventCounter.DEATHS)) >=
            nmd.persistentData.dedication_victories
    elseif nmd.persistentData.dedication_flag == "# achievements" then
        local count = 0
        for i = 1, 637 do
            if gd:Unlocked(i) then
                count = count + 1
            end
        end
        return count > nmd.persistentData.dedication_achievements
    end
end

nmd:AddCallback(ModCallbacks.MC_POST_GAME_END, nmd.checkDailies)
