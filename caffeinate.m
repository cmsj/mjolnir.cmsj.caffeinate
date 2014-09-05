#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <IOKit/pwr_mgt/IOPMLib.h>
#import <lauxlib.h>

#define kIOPMAssertionAppliesToLimitedPowerKey  CFSTR("AppliesToLimitedPower")

static IOPMAssertionID noIdleDisplaySleep = 0;
static IOPMAssertionID noIdleSystemSleep = 0;
static IOPMAssertionID noSystemSleep = 0;

// Debug/error output helper, prints to Mjolnir's console
static void caffeinate_print(lua_State *L, char *msg) {
    lua_getglobal(L, "print");
    lua_pushstring(L, msg);
    lua_call(L, 1, 0);
}

// Create an IOPM Assertion of specified type and store its ID in the specified variable
static void caffeinate_create_assertion(lua_State *L, CFStringRef assertionType, IOPMAssertionID *assertionID) {
    IOReturn result = 1;

    if (*assertionID) return;

    result = IOPMAssertionCreateWithDescription(assertionType,
                                                CFSTR("mjolnir.cmsj.caffeinate"),
                                                NULL,
                                                NULL,
                                                NULL,
                                                0,
                                                NULL,
                                                assertionID);

    if (result != kIOReturnSuccess) {
        caffeinate_print(L, "caffeinate_create_assertion: failed");
    }
}

// Release a previously stored assertion
static void caffeinate_release_assertion(lua_State *L, IOPMAssertionID *assertionID) {
    IOReturn result = 1;

    if (!*assertionID) return;

    result = IOPMAssertionRelease(*assertionID);

    if (result != kIOReturnSuccess) {
        caffeinate_print(L, "caffeinate_release_assertion: failed");
    }

    *assertionID = 0;
}

// ----------------------- Functions for display sleep when user is idle ----------------------------

// Prevent display sleep if the user goes idle (and by implication, system sleep)
static int caffeinate_prevent_idle_display_sleep(lua_State *L) {
    caffeinate_create_assertion(L, kIOPMAssertionTypePreventUserIdleDisplaySleep, &noIdleDisplaySleep);
    return 0;
}

// Allow display sleep if the user goes idle
static int caffeinate_allow_idle_display_sleep(lua_State *L) {
    caffeinate_release_assertion(L, &noIdleDisplaySleep);
    return 0;
}

// Determine if idle display sleep is currently prevented
static int caffeinate_is_idle_display_sleep_prevented(lua_State *L) {
    lua_pushboolean(L, noIdleDisplaySleep);
    return 1;
}

// ----------------------- Functions for system sleep when user is idle ----------------------------

// Prevent system sleep if the user goes idle (display may still sleep)
static int caffeinate_prevent_idle_system_sleep(lua_State *L) {
    caffeinate_create_assertion(L, kIOPMAssertionTypePreventUserIdleSystemSleep, &noIdleSystemSleep);
    return 0;
}

// Allow system sleep if the user goes idle
static int caffeinate_allow_idle_system_sleep(lua_State *L) {
    caffeinate_release_assertion(L, &noIdleSystemSleep);
    return 0;
}

// Determine if idle system sleep is currently prevented
static int caffeinate_is_idle_system_sleep_prevented(lua_State *L) {
    lua_pushboolean(L, noIdleSystemSleep);
    return 1;
}

// ----------------------- Functions for system sleep ----------------------------

// Prevent system sleep
static int caffeinate_prevent_system_sleep(lua_State *L) {
    IOReturn result = 1;
    BOOL ac_and_battery = false;

    if lua_isboolean(L, 1)
        ac_and_battery = lua_toboolean(L, 1);
    lua_settop(L, 1);

    caffeinate_create_assertion(L, kIOPMAssertionTypePreventSystemSleep, &noSystemSleep);

    if (noSystemSleep) {
        CFBooleanRef value;
        if (ac_and_battery) {
            value = kCFBooleanTrue;
        } else {
            value = kCFBooleanFalse;
        }
        result = IOPMAssertionSetProperty(noSystemSleep,
                                          kIOPMAssertionAppliesToLimitedPowerKey,
                                          (CFBooleanRef)value);
    }

    return 0;
}

// Allow system sleep
static int caffeinate_allow_system_sleep(lua_State *L) {
    caffeinate_release_assertion(L, &noSystemSleep);
    return 0;
}

// Determine if system sleep is currently prevented
static int caffeinate_is_system_sleep_prevented(lua_State *L) {
    lua_pushboolean(L, noSystemSleep);
    return 1;
}

// ----------------------- Lua/Mjolnir glue GAR ---------------------

static int caffeinate_gc(lua_State *L) {
    // TODO: We should register which of the assertions we have active, somewhere that persists a reload()
    caffeinate_allow_idle_display_sleep(L);
    caffeinate_allow_idle_system_sleep(L);
    caffeinate_allow_system_sleep(L);

    return 0;
}

static const luaL_Reg caffeinatelib[] = {
    {"prevent_idle_display_sleep", caffeinate_prevent_idle_display_sleep},
    {"allow_idle_display_sleep", caffeinate_allow_idle_display_sleep},
    {"is_idle_display_sleep_prevented", caffeinate_is_idle_display_sleep_prevented},

    {"prevent_idle_system_sleep", caffeinate_prevent_idle_system_sleep},
    {"allow_idle_system_sleep", caffeinate_allow_idle_system_sleep},
    {"is_idle_system_sleep_prevented", caffeinate_is_idle_system_sleep_prevented},

    {"_prevent_system_sleep", caffeinate_prevent_system_sleep},
    {"allow_system_sleep", caffeinate_allow_system_sleep},
    {"is_system_sleep_prevented", caffeinate_is_system_sleep_prevented},

    {}
};

static const luaL_Reg metalib[] = {
    {"__gc", caffeinate_gc},

    {}
};

/* NOTE: The substring "mjolnir_cmsj_caffeinate_internal" in the following function's name
         must match the require-path of this file, i.e. "mjolnir.cmsj.caffeinate.internal". */

int luaopen_mjolnir_cmsj_caffeinate_internal(lua_State *L) {
    luaL_newlib(L, caffeinatelib);
    luaL_newlib(L, metalib);
    lua_setmetatable(L, -2);

    return 1;
}
