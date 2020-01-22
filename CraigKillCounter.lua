CraigKillCounter = {};
CraigKillCounter.target = 'Craig';
CraigKillCounter.targetGUID = "";
CraigKillCounter.targetLastHealth = nil;

-- TODOS
-- 1. save death count / source & log low health / death messages
-- 2. set targetGUID from target found in party/raid, unset when me or target leaves party/raid
--      currently using player as target

-- dev: set targetGUID to player on PLAYER_LOGIN for testing
-- prod: set targetGUID to Craig's GUID when detected he's in party. unset targetGUID when he or i leave party

function CraigKillCounter:HandleTargetHealthChange(health)
    local maxHealth = UnitHealthMax(CraigKillCounter.target);
    local healthPercent = (health / maxHealth) * 100;

    --print("health: " .. health);
    --print("maxHealth: " .. maxHealth);
    --print("healthPercent: " .. healthPercent);
    --print("-------------------");

    if (health <= 0) then
        SendChatMessage("OH HE DEAD" ,"YELL" ,"COMMON");
        -- TODO: increment death count & log reason
    elseif (healthPercent <= 20) then
        -- TODO: low health message
        SendChatMessage("CRAIG BOUT TO DIE" ,"YELL" ,"COMMON");
    end
end

function CraigKillCounter:HandleGroupRosterUpdate()
    print("searching for targetGUID");
    -- find the target by name in the party and set the targetGUID
    for n=1, GetNumSubgroupMembers() do
        local pname = UnitName("Party"..n);
        if pname == CraigKillCounter.target then
            local pguid = UnitGUID(pname);
            if (not pguid == CraigKillCounter.targetGUID) then
                CraigKillCounter.targetGUID = pguid;
                print("targetGUID: " .. pguid);
            end
            return;
        end
    end
    
    -- didn't find target so we should unset targetGUID
    CraigKillCounter.targetGUID = nil;
end

function CraigKillCounter:HandlePlayerLogin()
    -- can get the guid and max health using the player's name
    CraigKillCounter.targetGUID = UnitGUID("player");
    print("targetGUID: " .. CraigKillCounter.targetGUID);
end

function CraigKillCounter:HandleCombatEvent()
    if (CraigKillCounter.targetGUID == nil) then
        return;
    end
    
    -- if destGUID matches targetGUID
    -- then get health of the unit and
    -- notify health or record death if needed

    local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo();

    -- if ((not destName == nil) and (destGUID == CraigKillCounter.targetGUID)) then
    if (destName == CraigKillCounter.target) then
        local health = UnitHealth(destName);

        if not (health == CraigKillCounter.targetLastHealth) then
            CraigKillCounter:HandleTargetHealthChange(health);
        end

        CraigKillCounter.targetLastHealth = health;
    end
end

function CraigKillCounter.OnEvent(frame, event, ...)
    if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
        CraigKillCounter:HandleCombatEvent();
    elseif (event == "GROUP_ROSTER_UPDATE") then
        CraigKillCounter:HandleGroupRosterUpdate();
    elseif (event == "PLAYER_LOGIN") then
        CraigKillCounter:HandlePlayerLogin();
    end
end

CraigKillCounter.EventFrame = CreateFrame("Frame");
CraigKillCounter.EventFrame:Show();
CraigKillCounter.EventFrame:SetScript("OnEvent", CraigKillCounter.OnEvent);
CraigKillCounter.EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE");
CraigKillCounter.EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
--CraigKillCounter.EventFrame:RegisterEvent("PLAYER_LOGIN");