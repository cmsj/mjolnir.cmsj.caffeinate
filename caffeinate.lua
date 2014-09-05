local caffeinate = require "mjolnir.cmsj.caffeinate.internal"

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
