#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <IOKit/pwr_mgt/IOPMLib.h>
#import <lauxlib.h>

static IOPMAssertionID noDisplaySleep = 0;

static void caffeinate_print(lua_State *L, char *msg) {
    lua_getglobal(L, "print");
    lua_pushstring(L, msg);
    lua_call(L, 1, 0);
}

static int caffeinate_prevent_display_sleep(lua_State *L) {
    IOReturn result = 1;

    if (noDisplaySleep) return 0;

    result = IOPMAssertionCreateWithDescription(kIOPMAssertionTypePreventUserIdleDisplaySleep,
                                                CFSTR("mjolnir.cmsj.caffeinate"),
                                                NULL,
                                                NULL,
                                                NULL,
                                                0,
                                                NULL,
                                                &noDisplaySleep);
    if (result != kIOReturnSuccess) {
        caffeinate_print(L, "prevent_display_sleep: assertion failed");
        // WAT DO
    }

    caffeinate_print(L, "prevent_display_sleep: success");

    return 0;
}

static int caffeinate_allow_display_sleep(lua_State *L) {
    IOReturn result = 1;

    if (!noDisplaySleep) return 0;

    result = IOPMAssertionRelease(noDisplaySleep);
    if (result != kIOReturnSuccess) {
        caffeinate_print(L, "allow_display_sleep: release failed");
        // WAT DO
    }

    noDisplaySleep = 0;
    caffeinate_print(L, "allow_display_sleep: success");

    return 0;
}

static int caffeinate_gc(lua_State *L) {
    if (noDisplaySleep) caffeinate_allow_display_sleep(L);

    return 0;
}

static const luaL_Reg caffeinatelib[] = {
    {"prevent_display_sleep", caffeinate_prevent_display_sleep},
    {"allow_display_sleep", caffeinate_allow_display_sleep},
    {"__gc", caffeinate_gc},
    
    {} // necessary sentinel
};


/* NOTE: The substring "mjolnir_cmsj_caffeinate_internal" in the following function's name
         must match the require-path of this file, i.e. "mjolnir.cmsj.caffeinate.internal". */

int luaopen_mjolnir_cmsj_caffeinate_internal(lua_State *L) {
    luaL_newlib(L, caffeinatelib);
    caffeinate_print(L, "Initialised caffeinate.");
    return 1;
}
