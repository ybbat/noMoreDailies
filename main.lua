local nmd = RegisterMod("No More Dailies", 1)

local json = require("json")

nmd.dedication_flags = {
    "# runs",
    "# random runs",
    "# achievements"
}

nmd.cracked_flags = {
    "Regular streak",
    "Random streak"
}

nmd.modem_flags = {
    "Regular victories",
    "Random victories"
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
    cracked_flag = nmd.cracked_flags[1],
    cracked_crown_reg = 5,
    cracked_crown_random = 5,
    modem_flag = nmd.modem_flags[1],
    broken_modem_reg = 7,
    broken_modem_random = 7,
    dedication_flag = nmd.dedication_flags[1],
    dedication_runs = 31,
    dedication_runs_rand = 31,
    dedication_achievements = 200,
    -- Other persistent data
    random_streak = 0,
    random_runs = 0,
    random_wins = 0,
    cur_random = false,
}


function nmd:modConfigMenuInit(_)
    if ModConfigMenu == nil then
        return
    end

    -- Cracked crown flag selection
    ModConfigMenu.AddSetting(
        "No More Dailies",
        "Config",
        {
            Type = ModConfigMenu.OptionType.NUMBER,
            CurrentSetting = function()
                return getTableIndex(nmd.cracked_flags, nmd.persistentData.cracked_flag)
            end,
            OnChange = function(n)
                nmd.persistentData.cracked_flag = nmd.cracked_flags[n]
                nmd:saveData()
                ModConfigMenu.RemoveSubcategory("No More Dailies", "Config")
                nmd:modConfigMenuInit()
            end,
            Display = function()
                return "Cracked crown unlock method: " .. (nmd.persistentData.cracked_flag)
            end,
            Minimum = 1,
            Maximum = #nmd.cracked_flags,
            Default = "Regular streak",
            Info = {
                "For random streaks you must click the random button on character select",
                "You do not have to do them consequtively, as long as 5 randoms in a row at any time are wins"
            }
        }
    )

    if nmd.persistentData.cracked_flag == "Regular streak" then
        ModConfigMenu.AddSetting(
            "No More Dailies",
            "Config",
            {
                Type = ModConfigMenu.OptionType.NUMBER,
                CurrentSetting = function()
                    return nmd.persistentData.cracked_crown_reg
                end,
                OnChange = function(n)
                    nmd.persistentData.cracked_crown_reg = n
                    nmd:saveData()
                end,
                Display = function()
                    return "Streak to unlock cc: " .. (nmd.persistentData.cracked_crown_reg)
                end,
                Minimum = 1,
                Maximum = 100,
                Default = 5,
            }
        )
    elseif nmd.persistentData.cracked_flag == "Random streak" then
        ModConfigMenu.AddSetting(
            "No More Dailies",
            "Config",
            {
                Type = ModConfigMenu.OptionType.NUMBER,
                CurrentSetting = function()
                    return nmd.persistentData.cracked_crown_random
                end,
                OnChange = function(n)
                    nmd.persistentData.cracked_crown_random = n
                    nmd:saveData()
                end,
                Display = function()
                    return "Random streak to unlock cc: " ..
                        (nmd.persistentData.cracked_crown_random)
                end,
                Minimum = 1,
                Maximum = 100,
                Default = 5,
            }
        )
    end

    -- broken modem flag selection
    ModConfigMenu.AddSetting(
        "No More Dailies",
        "Config",
        {
            Type = ModConfigMenu.OptionType.NUMBER,
            CurrentSetting = function()
                return getTableIndex(nmd.modem_flags, nmd.persistentData.modem_flag)
            end,
            OnChange = function(n)
                nmd.persistentData.modem_flag = nmd.modem_flags[n]
                nmd:saveData()
                ModConfigMenu.RemoveSubcategory("No More Dailies", "Config")
                nmd:modConfigMenuInit()
            end,
            Display = function()
                return "Modem unlock method: " .. (nmd.persistentData.modem_flag)
            end,
            Minimum = 1,
            Maximum = #nmd.modem_flags,
            Default = "Regular victories",
            Info = {
                "For random runs you must click the random button on character select"
            }
        }
    )
    if nmd.persistentData.modem_flag == "Regular victories" then
        ModConfigMenu.AddSetting(
            "No More Dailies",
            "Config",
            {
                Type = ModConfigMenu.OptionType.NUMBER,
                CurrentSetting = function()
                    return nmd.persistentData.broken_modem_reg
                end,
                OnChange = function(n)
                    nmd.persistentData.broken_modem_reg = n
                    nmd:saveData()
                end,
                Display = function()
                    return "Wins to unlock modem: " .. (nmd.persistentData.broken_modem_reg)
                end,
                Minimum = 1,
                Maximum = 100,
                Default = 7,
            }
        )
    elseif nmd.persistentData.modem_flag == "Random victories" then
        ModConfigMenu.AddSetting(
            "No More Dailies",
            "Config",
            {
                Type = ModConfigMenu.OptionType.NUMBER,
                CurrentSetting = function()
                    return nmd.persistentData.broken_modem_random
                end,
                OnChange = function(n)
                    nmd.persistentData.broken_modem_random = n
                    nmd:saveData()
                end,
                Display = function()
                    return "Random wins to unlock modem: " ..
                        (nmd.persistentData.broken_modem_random)
                end,
                Minimum = 1,
                Maximum = 100,
                Default = 7,
            }
        )
    end

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
                    return nmd.persistentData.dedication_runs
                end,
                OnChange = function(n)
                    nmd.persistentData.dedication_runs = n
                    nmd:saveData()
                end,
                Display = function()
                    return "Runs to unlock dedication: " .. (nmd.persistentData.dedication_runs)
                end,
                Minimum = 1,
                Maximum = 100,
                Default = 31,
            }
        )
    elseif nmd.persistentData.dedication_flag == "# random runs" then
        ModConfigMenu.AddSetting(
            "No More Dailies",
            "Config",
            {
                Attribute = "dedication",
                Type = ModConfigMenu.OptionType.NUMBER,
                CurrentSetting = function()
                    return nmd.persistentData.dedication_runs_rand
                end,
                OnChange = function(n)
                    nmd.persistentData.dedication_runs_rand = n
                    nmd:saveData()
                end,
                Display = function()
                    return "Random runs to unlock dedication: " .. (nmd.persistentData.dedication_runs_rand)
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
                    return "Achievements to unlock dedication: " .. (nmd.persistentData.dedication_achievements)
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
end

function nmd:loadData(isContinued)
    if not nmd:HasData() then
        return
    end

    local jsonString = nmd:LoadData()
    local savedData = json.decode(jsonString)
    for k, v in pairs(savedData) do
        nmd.persistentData[k] = v
    end

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
        nmd.persistentData.random_runs = nmd.persistentData.random_runs + 1
        if not IsGameOver then
            nmd.persistentData.random_wins = nmd.persistentData.random_wins + 1
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
    if nmd.persistentData.cracked_flag == "Regular streak" then
        return gd:GetEventCounter(EventCounter.STREAK_COUNTER) >= nmd.persistentData.cracked_crown_reg
    elseif nmd.persistentData.cracked_flag == "Random streak" then
        return nmd.persistentData.random_streak >= nmd.persistentData.cracked_crown_random
    end
end

function nmd:modemCheck(gd)
    if nmd.persistentData.modem_flag == "Regular victories" then
        return gd:GetEventCounter(EventCounter.MOM_KILLS) >= nmd.persistentData.broken_modem_reg
    elseif nmd.persistentData.modem_flag == "Random victories" then
        return nmd.persistentData.random_runs >= nmd.persistentData.broken_modem_random
    end
end

function nmd:dedicationCheck(gd)
    if nmd.persistentData.dedication_flag == "# runs" then
        return (gd:GetEventCounter(EventCounter.MOM_KILLS) + gd:GetEventCounter(EventCounter.DEATHS)) >=
            nmd.persistentData.dedication_runs
    elseif nmd.persistentData.dedication_flag == "# random runs" then
        return nmd.persistentData.random_runs >= nmd.persistentData.dedication_runs_rand
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
