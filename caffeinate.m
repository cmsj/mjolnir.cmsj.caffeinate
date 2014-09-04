#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <IOKit/pwr_mgt/IOPMLib.h>
#import <lauxlib.h>

static IOPMAssertionID noDisplaySleep = 0;

static int caffeinate_prevent_display_sleep(lua_State* L) {
    IOReturn result = 1;

    if (noDisplaySleep) return 1;

    result = IOPMAssertionCreateWithDescription(kIOPMAssertionTypePreventUserIdleDisplaySleep,
                                                CFSTR("mjolnir.cmsj.caffeinate"),
                                                NULL,
                                                NULL,
                                                NULL,
                                                0,
                                                NULL,
                                                &noDisplaySleep);
    if (result != kIOReturnSuccess) {
        // WAT DO
    }

    return 1;
}

static const luaL_Reg caffeinatelib[] = {
    {"prevent_display_sleep", caffeinate_prevent_display_sleep},
    
    {} // necessary sentinel
};


/* NOTE: The substring "mjolnir_cmsj_caffeinate_internal" in the following function's name
         must match the require-path of this file, i.e. "mjolnir.cmsj.caffeinate.internal". */

int luaopen_mjolnir_cmsj_caffeinate_internal(lua_State* L) {
    luaL_newlib(L, caffeinatelib);
    return 1;
}
