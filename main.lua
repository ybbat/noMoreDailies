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
