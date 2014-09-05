--- === mjolnir.cmsj.caffeinate ===
---
--- Prevent various kinds of sleep activities in OSX
---
--- Usage: local caffeinate = require "mjolnir.cmsj.caffeinate"
---
--- NOTE: Any sleep preventions will be removed when mjolnir.reload() is called
---       A future version of the module will save/restore state across reloads.

local caffeinate = require "mjolnir.cmsj.caffeinate.internal"

--- mjolnir.cmsj.caffeinate.set(sleepType, aValue, AC_and_battery)
--- Function
--- Configures the sleep prevention settings:
---  sleepType:
---    DisplayIdle - Prevents the screen from blanking if the user is idle (and also prevents the system from sleeping)
---    SystemIdle - Prevents the system from sleeping if the user is idle (the display may still sleep)
---    System - Prevents the system from sleeping for any reason
---  acAndBattery: (NOTE: This applies only to the "System" sleep type)
---    True - System should not sleep when on AC or battery
---    False - System should not sleep only when on AC
function caffeinate.set(aType, aValue, acAndBattery)
    if (aType == "DisplayIdle") then
        if (aValue == true) then
            caffeinate.prevent_idle_display_sleep()
        else
            caffeinate.allow_idle_display_sleep()
        end
    elseif (aType == "SystemIdle") then
        if (aValue == true) then
            caffeinate.prevent_idle_system_sleep()
        else
            caffeinate.allow_idle_system_sleep()
        end
    elseif (aType == "System") then
        if (aValue == true) then
            caffeinate.prevent_system_sleep(acAndBattery)
        else
            caffeinate.allow_system_sleep()
        end
    else
        print("Unknown type: " .. aType)
    end
end

--- mjolnir.cmsj.caffeinate.get(sleepType) -> bool
--- Function
--- Queries whether a particular sleep type is being prevented by Mjolnir
function caffeinate.get(aType)
    if (aType == "DisplayIdle") then
        return caffeinate.is_idle_display_sleep_prevented()
    elseif (aType == "SystemIdle") then
        return caffeinate.is_idle_system_sleep_prevented()
    elseif (aType == "System") then
        return caffeinate.is_system_sleep_prevented()
    else
        print("Unknown type: " .. aType)
    end

    return false
end

function caffeinate.prevent_system_sleep(ac_and_battery)
    ac_and_battery = ac_and_battery or false

    caffeinate._prevent_system_sleep(ac_and_battery)
end

return caffeinate
