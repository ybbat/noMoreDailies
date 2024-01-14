local nmd = RegisterMod("No More Dailies", 1)

local json = require("json")

nmd.persistentData = {
    cracked_crown = 5,
    broken_modem = 7,
    dedication = 31
}

function nmd:modConfigMenuInit(_)
    if ModConfigMenu == nil then
        return
    end

    ModConfigMenu.AddSetting(
        "No More Dailies",
        nil,
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
        nil,
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
    ModConfigMenu.AddSetting(
        "No More Dailies",
        nil,
        {
            Type = ModConfigMenu.OptionType.NUMBER,
            CurrentSetting = function()
                return nmd.persistentData.dedication
            end,
            OnChange = function(n)
                nmd.persistentData.dedication = n
                nmd:saveData()
            end,
            Display = function()
                return "Runs to unlock dedication " .. (nmd.persistentData.dedication)
            end,
            Minimum = 1,
            Maximum = 100,
        }
    )
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
end

nmd:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, nmd.loadData)

function nmd:checkDailies(IsGameOver)
    local gd = Isaac:GetPersistentGameData()

    if (not gd:Unlocked(Achievement.CRACKED_CROWN) and gd:GetEventCounter(EventCounter.STREAK_COUNTER) >= nmd.persistentData.cracked_crown) then
        gd:TryUnlock(Achievement.CRACKED_CROWN)
    end

    if (not gd:Unlocked(Achievement.BROKEN_MODEM) and gd:GetEventCounter(EventCounter.MOM_KILLS) >= nmd.persistentData.broken_modem) then
        gd:TryUnlock(Achievement.BROKEN_MODEM)
    end

    if
        (not gd:Unlocked(Achievement.DEDICATION) and
            (gd:GetEventCounter(EventCounter.MOM_KILLS) + gd:GetEventCounter(EventCounter.DEATHS)) >= nmd.persistentData.dedication)
    then
        gd:TryUnlock(Achievement.DEDICATION)
    end
end

nmd:AddCallback(ModCallbacks.MC_POST_GAME_END, nmd.checkDailies)
