local caffeinate = require "mjolnir.cmsj.caffeinate.internal"

function caffeinate.prevent_system_sleep(ac_and_battery)
    ac_and_battery = ac_and_battery or false

    caffeinate._prevent_system_sleep(ac_and_battery)
end

return caffeinate
