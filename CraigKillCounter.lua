CraigKillCounter = {};
CraigKillCounter.loaded = false;
CraigKillCounter.target = 'Piznimp';
CraigKillCounter.target_guid = '';

-- 1. detect if Craig is in party/raid
--     - set his GUID aside when he's active
--         - print(UnitGUID(...));
-- 2. on COMBAT_LOG_EVENT_UNFILTERED for player's GUID:
--     - watch health, notify when low, record when dead


function CraigKillCounter.OnMemberUpdate()
    if not IsInGroup() then
        return
    end

    for n=1, GetNumSubgroupMembers() do
        local pname = UnitName("Party"..n);
        if pname == CraigKillCounter.target then
            local pguid = UnitGUID(pname);

            if not pguid == CraigKillCounter.target_guid then
                print('setting target_guid ' ... pguid);
                CraigKillCounter.target_guid = pguid;
            end

            return;
        end
	end

    -- didn't find target so unset guid
    print('unsetting target_guid');
    CraigKillCounter.target_guid = '';
end

function CraigKillCounter.OnCombatEvent(...)
    -- skip if target_guid isn't set
    if CraigKillCounter.target_guid == '' then
        return;
    end

    local time, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags = ...;

    -- print(CraigKillCounter.target_guid);
    -- print(sourceGUID);

    -- skip if not affecting target
    if not destGUID == CraigKillCounter.target_guid then
        return;
    end

    -- local health = UnitHealth(CraigKillCounter.target_guid);
    -- print(health);
end

function CraigKillCounter.OnEvent(frame, event, ...)
    if event == 'GROUP_ROSTER_UPDATE' then
        CraigKillCounter.OnMemberUpdate();
    elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
        local time, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags = ...;
        print(time);
        print(event);
        print(sourceGUID);
        print(sourceName);
        print(sourceFlags);
        print(destGUID);
        print(destName);
        print(destFlags);
        -- CraigKillCounter.OnCombatEvent(...);
    end;
end

CraigKillCounter.EventFrame = CreateFrame("Frame");
CraigKillCounter.EventFrame:Show();
CraigKillCounter.EventFrame:SetScript("OnEvent", CraigKillCounter.OnEvent);
CraigKillCounter.EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE");
CraigKillCounter.EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");