This is a sample project to demonstrate writing a Mjolnir plugin.

### Picking a name for your module

Our sample module is called "mjolnir.ext.foobar". This is both the
name of the module, and its require-path. This is a good practice and
I recommend you stick to it.

In general, I recommend you prefix your module's name with
"mjolnir.ext." for a few reasons. It's consistent, clear, and lets
people write tools in the future that easily find all existing Mjolnir
plugins easily.

### Installing prerequisites

Before you begin, you'll need to install Lua 5.2, LuaRocks, and
MoonRocks. If you have Mjolnir installed, you've probably already done
this:

~~~bash
$ brew install homebrew/versions/lua52
$ brew install luarocks --with-lua52
$ luarocks install --server=http://rocks.moonscript.org moonrocks
~~~

### Optionally create an Xcode project

If you're writing a module that has some C or Objective-C, you may
want to create a little Xcode project for it. That way, you get
autocompletion and other helpful Xcode features.

1. New Xcode Project -> Framework & Library -> C/C++ Library
2. Add `/usr/local/include` to "Header Search Paths"
3. Add `/usr/local/lib` to "Library Search Paths"
4. Add `-llua` to Other Linker Flags
5. Add your `.m` file to the Xcode project
6. Add `#import <lauxlib.h>` to the top of your `.m` file

### Building and testing your module

LuaRocks has a helpful command to build and install the LuaRocks
module in the current directory:

~~~bash
$ luarocks make
~~~

Then, just launch Mjolnir, require your module, and test it out:

~~~lua
local foobar = require "mjolnir.ext.foobar"
print(foobar.addnumbers(1, 2))
~~~

You can repeat this process any number of times, since I'm pretty sure
`luarocks make` will overwrite any pre-existing locally installed
module with the same name.

### Publishing your module

~~~bash
$ luarocks make
~~~

Now test it thoroughly. Make sure it actually works. Automated tests
are not enough, actually load it up in Mjolnir and use it. Preferrably
for a few days.

~~~bash
$ luarocks pack mjolnir.ext.foobar
$ moonrocks upload --skip-pack mjolnir.ext.foobar-0.1-1.rockspec
$ moonrocks upload mjolnir.ext.foobar-0.1-1.macosx-x86_64.rock
~~~

Congratulations, it's now available for everyone!
