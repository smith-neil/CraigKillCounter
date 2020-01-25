CraigKillCounter = {};
CraigKillCounter.target = "Craig";
CraigKillCounter.targetGrouped = false;
CraigKillCounter.targetLastHealth = nil;
CraigKillCounter.currentDeaths = {};
CraigKillCounter.currentInstance = "";
CraigKillCounter.currentTimestamp = nil;
CraigKillCounter.voice = true;

-- SaveVariablesPerCharacter
CraigKillCounterMCDeaths = {};
CraigKillCounterONYDeaths = {};

SLASH_TEST1, SLASH_TEST2 = '/CraigKillCounter', '/ckc';

-- TODOS
-- 2. randomized messages

SlashCmdList["TEST"] = function (msg, editbox)
    if (msg == 'deaths') then
        CraigKillCounter:WriteKillCount();
    elseif (msg == 'toggle') then
        CraigKillCounter:ToggleVoice();
        SendChatMessage("CKC Voice: "..CraigKillCounter.voice, "RAID", "COMMON");
    end
end

function CraigKillCounter:GetPastInstanceDeaths()
    local totalInstanceDeaths = 0;
    if (CraigKillCounter.currentInstance == "Molten Core") then
        for k, v in pairs(CraigKillCounterMCDeaths) do
            totalInstanceDeaths = totalInstanceDeaths + v;
        end
    elseif (CraigKillCounter.currentInstance == "Onyxia's Lair") then
        for k, v in pairs(CraigKillCounterONYDeaths) do
            totalInstanceDeaths = totalInstanceDeaths + v;
        end
    end
    return totalInstanceDeaths;
end
function CraigKillCounter:GetPastNonInstanceDeaths()
    local totalInstanceDeaths = 0;
    if (CraigKillCounter.currentInstance == "Molten Core") then
        for k, v in pairs(CraigKillCounterONYDeaths) do
            totalInstanceDeaths = totalInstanceDeaths + v;
        end
    elseif (CraigKillCounter.currentInstance == "Onyxia's Lair") then
        for k, v in pairs(CraigKillCounterMCDeaths) do
            totalInstanceDeaths = totalInstanceDeaths + v;
        end
    end
    return totalInstanceDeaths;
end

function CraigKillCounter:ToggleVoice()
    if (CraigKillCounter.voice == false) then
        CraigKillCounter.voice = true;
    else
        CraigKillCounter.voice = false;
    end;
end

function CraigKillCounter:WriteKillCount()
    local deathsTonight = CraigKillCounter.currentDeaths[CraigKillCounter.currentTimestamp];
    local pastInstanceDeaths = CraigKillCounterMCDeaths:GetPastInstanceDeaths();
    local pastNonInstanceDeaths = CraigKillCounter:GetPastNonInstanceDeaths();

    local allInstanceDeaths = deathsTonight + pastInstanceDeaths;
    local allDeaths = deathsTonight + pastInstanceDeaths + pastNonInstanceDeaths;

    SendChatMessage("Near, far, wherever you are" ,"RAID" ,"COMMON");
    SendChatMessage("I believe that the heart does, go on" ,"YELL" ,"COMMON");
    SendChatMessage("Once more you open the door" ,"RAID" ,"COMMON");
    SendChatMessage("And you're here in my heart" ,"RAID" ,"COMMON");
    SendChatMessage("And my heart will go on, and on" ,"RAID" ,"COMMON");
    SendChatMessage("----------------------------------", "RAID", "COMMON");
    SendChatMessage("Craig has died "..deathsTonight.." times tonight", "RAID", "COMMON");
    SendChatMessage("and has died "..allInstanceDeaths.. " in "..CraigKillCounter.currentInstance, "RAID", "COMMON");
    SendChatMessage("for a total of "..pastNonInstanceDeaths.. " deaths in all raids.", "RAID", "COMMON");
    SendChatMessage("----------------------------------", "RAID", "COMMON");
end

function CraigKillCounter:HandleTargetHealthChange(health)
    local maxHealth = UnitHealthMax(CraigKillCounter.target);
    local healthPercent = (health / maxHealth) * 100;

    if (health <= 0) then
        -- update currentDeats
        if (CraigKillCounter.currentDeaths[CraigKillCounter.currentTimestamp] == nil) then
            CraigKillCounter.currentDeaths[CraigKillCounter.currentTimestamp] = 0;
        end
        CraigKillCounter.currentDeaths[CraigKillCounter.currentTimestamp] = 1 + CraigKillCounter.currentDeaths[CraigKillCounter.currentTimestamp];

        -- update SavedVariable for current raid instance
        if (CraigKillCounter.currentInstance == "Molten Core") then
            if (CraigKillCounterMCDeaths[timestamp] == nil) then
                CraigKillCounterMCDeaths[timestamp] = 0;
            end
            CraigKillCounterMCDeaths[timestamp] = 1 + CraigKillCounterMCDeaths[timestamp];
        end

        if (CraigKillCounter.voice) then
            CraigKillCounter:WriteKillCount();
        end;
    end
end

function CraigKillCounter:HandleGroupRosterUpdate()
    for n=1, GetNumGroupMembers() do
        local pname = UnitName("Raid"..n);
        if (pname == CraigKillCounter.target) then
            CraigKillCounter.targetGrouped = true;
            return;
        end
    end
    
    -- target not in group so unset flag
    CraigKillCounter.targetGrouped = false;
end

function CraigKillCounter:HandleCombatEvent()
    if (CraigKillCounter.targetGrouped == false) then
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