CraigKillCounter = {};
CraigKillCounter.target = 'Craig';
CraigKillCounter.targetGrouped = false;
CraigKillCounter.targetLastHealth = nil;

-- TODOS
-- 1. save death count / source
-- 2. randomized messages
-- 3. slash commands
-- 4. search entire raid if in raid, search party if in party

function CraigKillCounter:HandleTargetHealthChange(health)
    local maxHealth = UnitHealthMax(CraigKillCounter.target);
    local healthPercent = (health / maxHealth) * 100;

    if (health <= 0) then
        SendChatMessage("OH HE DEAD" ,"YELL" ,"COMMON");
        -- TODO: increment death count & log reason
    elseif (healthPercent <= 20) then
        SendChatMessage("CRAIG BOUT TO DIE" ,"YELL" ,"COMMON");
    end
end

function CraigKillCounter:HandleGroupRosterUpdate()
    for n=1, GetNumSubgroupMembers() do
        local pname = UnitName("Party"..n);
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

    local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo();

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
    end
end

CraigKillCounter.EventFrame = CreateFrame("Frame");
CraigKillCounter.EventFrame:Show();
CraigKillCounter.EventFrame:SetScript("OnEvent", CraigKillCounter.OnEvent);
CraigKillCounter.EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE");
CraigKillCounter.EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");