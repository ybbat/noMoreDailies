local nmd = RegisterMod("No More Dailies", 1)

--@param IsGameOver bool
function nmd:checkDailies(IsGameOver)
    local gd = Isaac:GetPersistentGameData()

    if (not gd:Unlocked(Achievement.CRACKED_CROWN) and gd:GetEventCounter(EventCounter.STREAK_COUNTER) >= 5) then
        gd:TryUnlock(Achievement.CRACKED_CROWN)
    end

    if (not gd:Unlocked(Achievement.BROKEN_MODEM) and gd:GetEventCounter(EventCounter.MOM_KILLS) >= 7) then
        gd:TryUnlock(Achievement.BROKEN_MODEM)
    end

    if
        (not gd:Unlocked(Achievement.DEDICATION) and
            (gd:GetEventCounter(EventCounter.MOM_KILLS) + gd:GetEventCounter(EventCounter.DEATHS)) >= 31)
    then
        gd:TryUnlock(Achievement.DEDICATION)
    end
end

nmd:AddCallback(ModCallbacks.MC_POST_GAME_END, nmd.checkDailies)

local last = nil
local init = os.clock()
local randoming = false

local last_streak = nil

function nmd:randomDetectorInMenu()
    if MenuManager.GetActiveMenu() == MainMenuType.CHARACTER then
        local id = CharacterMenu:GetSelectedCharacterID()
        if id ~= last then
            local now = os.clock()
            local diff = now - init

            -- first time diff when randoming is always approx 0.05, cannot be easily replicated manually
            if randoming == false and diff <= 0.06 then
                randoming = true
            end

            -- random always ends at somewhere in range [0.5, 0.58]
            if diff > 0.6 then
                randoming = false
            end

            init = now
            last = id
        end
    end
end

function nmd:saveLastStreak()
    if last_streak == nil then
        local gd = Isaac:GetPersistentGameData()
        last_streak = gd:GetEventCounter(EventCounter.STREAK_COUNTER)
    end
end

nmd:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, nmd.randomDetectorInMenu)
nmd:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, nmd.saveLastStreak)
