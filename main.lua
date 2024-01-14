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
    -- Configuration options
    cracked_crown = 5,
    broken_modem = 7,
    dedication_flag = nmd.dedication_flags[1],
    dedication_victories = 31,
    dedication_achievements = 200,
    -- Other persistent data
    random_streak = 0,
    random_runs = 0,
    cur_random = false,
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
            Default = 5,
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
            Default = 7,
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
            Default = "# runs",
            Info = {
                "# runs will unlock dedication after N runs (victory or loss)",
                "# achievements will unlock dedication after N achievements are unlocked"
            }
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
                Default = 31,
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
                Default = 200,
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

function nmd:gameStart(isContinued)
    nmd:loadData(isContinued)
    print(nmd.persistentData.cur_random)
end

function nmd:loadData(isContinued)
    if not nmd:HasData() then
        return
    end

    local jsonString = nmd:LoadData()
    nmd.persistentData = json.decode(jsonString)

    if isContinued then -- If continued, then saved value is correct
    else                -- If new run, then the new value is correct
        nmd.persistentData.cur_random = nmd.randomed
    end
    -- print(nmd.persistentData.cur_random)
    ModConfigMenu.RemoveSubcategory("No More Dailies", "Config")
    nmd:modConfigMenuInit()
end

nmd:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, nmd.gameStart)

function nmd:gameEnd(IsGameOver)
    print(nmd.persistentData.cur_random)
    if nmd.persistentData.cur_random then
        print("was random")
        nmd.persistentData.random_runs = nmd.persistentData.random_runs + 1
        if not IsGameOver then
            nmd.persistentData.random_streak = nmd.persistentData.random_streak + 1
        else
            nmd.persistentData.random_streak = 0
        end
    end
    print(nmd.persistentData.random_runs)
    print(nmd.persistentData.random_streak)

    local gd = Isaac:GetPersistentGameData()
    nmd:checkDailies(gd)
    nmd.randomed = false
end

function nmd:checkDailies(gd)
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

nmd:AddCallback(ModCallbacks.MC_POST_GAME_END, nmd.gameEnd)

nmd.last = false
nmd.init = os.clock()
nmd.randomed = false

function nmd:randomDetectorInMenu()
    if MenuManager.GetActiveMenu() == MainMenuType.CHARACTER then
        local id = CharacterMenu:GetSelectedCharacterID()
        local now = os.clock()
        local diff = now - nmd.init
        nmd.init = now

        -- random always ends at somewhere in range [0.5, 0.58]
        if diff > 0.6 then
            nmd.randomed = false
        end

        if id ~= nmd.last then
            -- first time diff when randoming is always approx 0.05, cannot be easily replicated manually
            if nmd.randomed == false and diff <= 0.06 then
                nmd.randomed = true
            end

            nmd.last = id
        end
    end
end

nmd:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, nmd.randomDetectorInMenu)


Console.RegisterMacro("win", { "stage 8", "debug 10", "giveitem k5" })
