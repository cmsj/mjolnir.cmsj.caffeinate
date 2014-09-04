#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <IOKit/pwr_mgt/IOPMLib.h>
#import <lauxlib.h>

static int caffeinate_addnumbers(lua_State* L) {
    int a = luaL_checknumber(L, 1);
    int b = luaL_checknumber(L, 2);
    lua_pushnumber(L, a + b);
    return 1;
}

static const luaL_Reg caffeinatelib[] = {
    {"addnumbers", caffeinate_addnumbers},
    
    {} // necessary sentinel
};


/* NOTE: The substring "mjolnir_cmsj_caffeinate_internal" in the following function's name
         must match the require-path of this file, i.e. "mjolnir.cmsj.caffeinate.internal". */

int luaopen_mjolnir_cmsj_caffeinate_internal(lua_State* L) {
    luaL_newlib(L, caffeinatelib);
    return 1;
}
