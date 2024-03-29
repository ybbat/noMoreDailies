local nmd = RegisterMod("No More Dailies", 1)

nmd.init = Isaac.GetTime()

function nmd:set_init()
    nmd.init = Isaac.GetTime()
end

function nmd:repentogon_text()
    if Isaac.GetTime() - nmd.init <= 5000 then
        Isaac.RenderText("No More Dailies Error:", 200, 45, 1, 0, 0, 1)
        Isaac.RenderText("REPENTOGON not installed", 200, 60, 1, 0, 0, 1)
    else
        nmd:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, nmd.set_init)
        nmd:RemoveCallback(ModCallbacks.MC_POST_RENDER, nmd.repentogon_text)
    end
end

if not REPENTOGON then
    nmd:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, nmd.set_init)
    nmd:AddCallback(ModCallbacks.MC_POST_RENDER, nmd.repentogon_text)
    error("REPENTOGON not installed")
    return
end

local json = require("json")

nmd.dedication_options = {
    "# runs",
    "# random runs",
    "# achievements"
}

nmd.cracked_options = {
    "Regular streak",
    "Random streak"
}

nmd.modem_options = {
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
    cracked_option = nmd.cracked_options[1],
    cracked_crown_reg = 5,
    cracked_crown_random = 5,
    modem_option = nmd.modem_options[1],
    broken_modem_reg = 7,
    broken_modem_random = 7,
    dedication_option = nmd.dedication_options[1],
    dedication_runs = 31,
    dedication_runs_rand = 31,
    dedication_achievements = 200,
    debug = false,
    -- Other persistent data
    random_streak = 0,
    random_runs = 0,
    random_wins = 0,
    cur_random = false,
}

function nmd:showdebug()
    Isaac.RenderText("Is run randomed?: " .. tostring(nmd.persistentData.cur_random), 55, 45, 1, 1, 1, 1)
end

if nmd.persistentData.debug then
    nmd:AddCallback(ModCallbacks.MC_POST_RENDER, nmd.showdebug)
end

function nmd:modConfigMenuInit(_)
    if ModConfigMenu == nil then
        return
    end

    ModConfigMenu.RemoveSubcategory("No More Dailies", "Config")

    -- Cracked crown option selection
    ModConfigMenu.AddSetting(
        "No More Dailies",
        "Config",
        {
            Type = ModConfigMenu.OptionType.NUMBER,
            CurrentSetting = function()
                return getTableIndex(nmd.cracked_options, nmd.persistentData.cracked_option)
            end,
            OnChange = function(n)
                nmd.persistentData.cracked_option = nmd.cracked_options[n]
                nmd:saveData()
                ModConfigMenu.RemoveSubcategory("No More Dailies", "Config")
                nmd:modConfigMenuInit()
            end,
            Display = function()
                return "Cracked crown unlock method: " .. (nmd.persistentData.cracked_option)
            end,
            Minimum = 1,
            Maximum = #nmd.cracked_options,
            Default = "Regular streak",
            Info = {
                "For random streaks you must click the random button on character select",
                "You do not have to do them consequtively, as long as 5 randoms in a row at any time are wins"
            }
        }
    )

    if nmd.persistentData.cracked_option == "Regular streak" then
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
    elseif nmd.persistentData.cracked_option == "Random streak" then
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

    -- broken modem option selection
    ModConfigMenu.AddSetting(
        "No More Dailies",
        "Config",
        {
            Type = ModConfigMenu.OptionType.NUMBER,
            CurrentSetting = function()
                return getTableIndex(nmd.modem_options, nmd.persistentData.modem_option)
            end,
            OnChange = function(n)
                nmd.persistentData.modem_option = nmd.modem_options[n]
                nmd:saveData()
                ModConfigMenu.RemoveSubcategory("No More Dailies", "Config")
                nmd:modConfigMenuInit()
            end,
            Display = function()
                return "Modem unlock method: " .. (nmd.persistentData.modem_option)
            end,
            Minimum = 1,
            Maximum = #nmd.modem_options,
            Default = "Regular victories",
            Info = {
                "For random runs you must click the random button on character select"
            }
        }
    )
    if nmd.persistentData.modem_option == "Regular victories" then
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
    elseif nmd.persistentData.modem_option == "Random victories" then
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

    -- Dedication option selection
    ModConfigMenu.AddSetting(
        "No More Dailies",
        "Config",
        {
            Type = ModConfigMenu.OptionType.NUMBER,
            CurrentSetting = function()
                return getTableIndex(nmd.dedication_options, nmd.persistentData.dedication_option)
            end,
            OnChange = function(n)
                nmd.persistentData.dedication_option = nmd.dedication_options[n]
                nmd:saveData()
                ModConfigMenu.RemoveSubcategory("No More Dailies", "Config")
                nmd:modConfigMenuInit()
            end,
            Display = function()
                return "Dedication unlock method: " .. (nmd.persistentData.dedication_option)
            end,
            Minimum = 1,
            Maximum = #nmd.dedication_options,
            Default = "# runs",
        }
    )

    if nmd.persistentData.dedication_option == "# runs" then
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
    elseif nmd.persistentData.dedication_option == "# random runs" then
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
    elseif nmd.persistentData.dedication_option == "# achievements" then
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

    ModConfigMenu.AddSpace("No More Dailies", "Config")

    -- Display random runs/wins/streak
    ModConfigMenu.AddSetting(
        "No More Dailies",
        "Config",
        {
            Type = ModConfigMenu.OptionType.TEXT,
            Display = function()
                return "Random runs: " .. tostring(nmd.persistentData.random_runs)
            end
        }
    )
    ModConfigMenu.AddSetting(
        "No More Dailies",
        "Config",
        {
            Type = ModConfigMenu.OptionType.TEXT,
            Display = function()
                return "Random wins: " .. tostring(nmd.persistentData.random_wins)
            end
        }
    )
    ModConfigMenu.AddSetting(
        "No More Dailies",
        "Config",
        {
            Type = ModConfigMenu.OptionType.TEXT,
            Display = function()
                return "Random streak: " .. tostring(nmd.persistentData.random_streak)
            end
        }
    )

    -- Reset random runs/wins/streak
    ModConfigMenu.AddSetting(
        "No More Dailies",
        "Config",
        {
            Type = ModConfigMenu.OptionType.NUMBER,
            CurrentSetting = function()
                return 0
            end,
            OnChange = function(_)
                nmd.persistentData.random_runs = 0
                nmd.persistentData.random_wins = 0
                nmd.persistentData.random_streak = 0
                nmd:saveData()
                ModConfigMenu.RemoveSubcategory("No More Dailies", "Config")
                nmd:modConfigMenuInit()
            end,
            Display = function()
                return "Reset random runs/wins/streak to 0"
            end,
            Info = {
                "Press left/right to reset",
                "Note: this will not remove achievements already gained"
            },
            Minimum = 0,
            Maximum = 0,
        }
    )

    ModConfigMenu.AddSpace("No More Dailies", "Config")

    -- Debug option
    ModConfigMenu.AddSetting(
        "No More Dailies",
        "Config",
        {
            Type = ModConfigMenu.OptionType.BOOLEAN,
            CurrentSetting = function()
                return nmd.persistentData.debug
            end,
            OnChange = function(b)
                nmd.persistentData.debug = b
                nmd:saveData()
                if b then
                    nmd:AddCallback(ModCallbacks.MC_POST_RENDER, nmd.showdebug)
                else
                    nmd:RemoveCallback(ModCallbacks.MC_POST_RENDER, nmd.showdebug)
                end
            end,
            Display = function()
                return "Debug mode: " .. (nmd.persistentData.debug and "on" or "off")
            end,
            Info = {
                "Displays some random-related info",
                "on char select and in game"
            }
        }
    )
end

nmd:modConfigMenuInit()

function nmd:saveData(_)
    local jsonString = json.encode(nmd.persistentData)
    nmd:SaveData(jsonString)
end

nmd:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, nmd.saveData)

function nmd:gameStart(isContinued)
    if Isaac:GetChallenge() ~= 0 then
        nmd.persistentData.cur_random = false
    end
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

    nmd:modConfigMenuInit()
end

nmd:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, nmd.gameStart)

function nmd:gameEnd(IsGameOver)
    if nmd.persistentData.cur_random then
        nmd.persistentData.random_runs = nmd.persistentData.random_runs + 1
        if not IsGameOver then
            nmd.persistentData.random_wins = nmd.persistentData.random_wins + 1
            nmd.persistentData.random_streak = nmd.persistentData.random_streak + 1
        else
            nmd.persistentData.random_streak = 0
        end
    end

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
    if nmd.persistentData.cracked_option == "Regular streak" then
        return gd:GetEventCounter(EventCounter.STREAK_COUNTER) >= nmd.persistentData.cracked_crown_reg
    elseif nmd.persistentData.cracked_option == "Random streak" then
        return nmd.persistentData.random_streak >= nmd.persistentData.cracked_crown_random
    end
end

function nmd:modemCheck(gd)
    if nmd.persistentData.modem_option == "Regular victories" then
        return gd:GetEventCounter(EventCounter.MOM_KILLS) >= nmd.persistentData.broken_modem_reg
    elseif nmd.persistentData.modem_option == "Random victories" then
        return nmd.persistentData.random_runs >= nmd.persistentData.broken_modem_random
    end
end

function nmd:dedicationCheck(gd)
    if nmd.persistentData.dedication_option == "# runs" then
        return (gd:GetEventCounter(EventCounter.MOM_KILLS) + gd:GetEventCounter(EventCounter.DEATHS)) >=
            nmd.persistentData.dedication_runs
    elseif nmd.persistentData.dedication_option == "# random runs" then
        return nmd.persistentData.random_runs >= nmd.persistentData.dedication_runs_rand
    elseif nmd.persistentData.dedication_option == "# achievements" then
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

nmd.last = 0
nmd.randomed = false
nmd.diffonchange = 0.00
nmd.lastn = { 0, 0, 0, 0, 0 }

function nmd:checkLastN(lastn)
    for i = 2, #lastn do
        if lastn[i] ~= 0 and lastn[i] <= lastn[i - 1] then
            return false
        end
    end
    return true
end

function nmd:randomDetectorInMenu()
    if MenuManager.GetActiveMenu() == MainMenuType.CHARACTER then
        local id = CharacterMenu:GetSelectedCharacterID()
        local now = Isaac.GetTime()
        local diff = (now - nmd.init) / 1000

        -- Debug display
        if nmd.persistentData.debug then
            Isaac.RenderText("Randomed: " .. tostring(nmd.randomed), 1, 0, 1, 1, 1, 1)
            Isaac.RenderText("Diff: " .. tostring(diff), 1, 15, 1, 1, 1, 1)
            Isaac.RenderText("Selected ID: " .. tostring(id), 1, 30, 1, 1, 1, 1)
            Isaac.RenderText("Last ID: " .. tostring(nmd.last), 1, 45, 1, 1, 1, 1)
            Isaac.RenderText("Last 5: " .. "[" .. table.concat(nmd.lastn, ", ") .. "]", 1, 60, 1, 1, 1, 1)
            Isaac.RenderText("Diff on change: " .. tostring(nmd.diffonchange), 1, 75, 1, 1, 1, 1)
        end

        -- If hovering on selection for more than 2 seconds we definitely aren't randoming
        if diff > 2000 then
            nmd.randomed = false
        end

        if id ~= nmd.last then
            table.remove(nmd.lastn, 1)
            table.insert(nmd.lastn, 5, id)
            local increasing = nmd:checkLastN(nmd.lastn)

            nmd.diffonchange = diff
            -- first time diff when randoming is always approx 0.05, cannot be easily replicated manually
            if nmd.randomed == false and diff <= 60 then
                nmd.randomed = true
            end

            if id < nmd.last and id ~= 0 then
                nmd.randomed = false
            end

            -- random always ends at somewhere in range [0.5, 0.58] seconds
            if diff > 600 then
                nmd.randomed = false
            end

            if not increasing then
                nmd.randomed = false
            end

            nmd.last = id
            nmd.init = now
        end
    end
end

nmd:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, nmd.randomDetectorInMenu)
