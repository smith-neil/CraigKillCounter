CraigKillCounter = {};
CraigKillCounter.target = "Areiz";
CraigKillCounter.targetGrouped = false;
CraigKillCounter.targetLastHealth = nil;
CraigKillCounter.currentDeaths = {};
CraigKillCounter.currentInstance = "";
CraigKillCounter.currentTimestamp = nil;

CraigKillCounterMCDeaths = {};
CraigKillCounterONYDeaths = {};

-- MoltenCore: {
--     timestamp1: 2
--     timestamp2: 4,
-- },
-- Onyxia: {
--     timestamp1: 1,
--     timestamp2: 4
-- }


-- TODOS
-- 2. randomized messages
-- 3. slash commands

-- TESTS
-- 1. If GetNumRaidMembers works
--    /run for n=1, GetNumGroupMembers() do print(UnitName("Raid"..n));end
-- 2. If SavedVariables works in raid & party

function CraigKillCounter:HandleTargetHealthChange(health)
    local maxHealth = UnitHealthMax(CraigKillCounter.target);
    local healthPercent = (health / maxHealth) * 100;

    if (health <= 0) then
        SendChatMessage("Near, far, wherever you are" ,"YELL" ,"COMMON");
        SendChatMessage("I believe that the heart does, go on" ,"YELL" ,"COMMON");
        SendChatMessage("Once more you open the door" ,"YELL" ,"COMMON");
        SendChatMessage("And you're here in my heart" ,"YELL" ,"COMMON");
        SendChatMessage("And my heart will go on, and on" ,"YELL" ,"COMMON");
        if (CraigKillCounter.currentInstance == "Molten Core") then
            if (CraigKillCounter.currentDeaths[CraigKillCounter.currentTimestamp] == nil) then
                CraigKillCounter.currentDeaths[CraigKillCounter.currentTimestamp] = 0;
            end
            if (CraigKillCounterMCDeaths[timestamp] == nil) then
                CraigKillCounterMCDeaths[timestamp] = 0;
            end
            CraigKillCounter.currentDeaths[CraigKillCounter.currentTimestamp] += 1;
        end
    elseif (healthPercent <= 20) then
        -- SendChatMessage(CraigKillCounter.target.." BOUT TO DIE" ,"YELL" ,"COMMON");
    end
end

function CraigKillCounter:HandleGroupRosterUpdate()
    for n=1, GetNumGroupMembers() do
        local pname = UnitName("Raid"..n);
        if pname == CraigKillCounter.target then
            CraigKillCounter.targetGrouped = true;
            return;
        end
    end
    
    -- target not in group so unset flag
    CraigKillCounter.targetGrouped = false;
end

function CraigKillCounter:HandleCombatEvent()
    if (CraigKillCounter.targetFound == false) then
        return;
    end
    if (CraigKillCounter.currentInstance == "") then
        return;
    end

    local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo();

    if (destName == CraigKillCounter.target) then
        local health = UnitHealth(destName);
        if not (health == CraigKillCounter.targetLastHealth) then
            CraigKillCounter:HandleTargetHealthChange(health);
        end
        CraigKillCounter.targetLastHealth = health;
    end
end

function CraigKillCounter:HandlePlayerEnteringWorld(isInitialLogin, isReloadingUi)
    local zoneText = GetRealZoneText();
    if ((zoneText == "Molten Core") or (zoneText == "Onyxia's Lair")) then
        CraigKillCounter.currentInstance = zoneText;
        CraigKillCounter.currentTimestamp = time();
    else
        CraigKillCounter.currentInstance = "";
        CraigKillCounter.currentTimestamp = nil;
    end
end

function CraigKillCounter.OnEvent(frame, event, ...)
    if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
        CraigKillCounter:HandleCombatEvent();
    elseif (event == "GROUP_ROSTER_UPDATE") then
        CraigKillCounter:HandleGroupRosterUpdate();
    elseif (event == "PLAYER_ENTERING_WORLD") then
        CraigKillCounter:HandlePlayerEnteringWorld(...);
    end
end

CraigKillCounter.EventFrame = CreateFrame("Frame");
CraigKillCounter.EventFrame:Show();
CraigKillCounter.EventFrame:SetScript("OnEvent", CraigKillCounter.OnEvent);
CraigKillCounter.EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE");
CraigKillCounter.EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
CraigKillCounter.EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");