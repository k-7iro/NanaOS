--[[

    NanaLauncher - Project "NanaOS"
    The Updater(WIP) and something
    Copyright 2023 K-Nana
    License: MIT License https://opensource.org/license/mit/

]]

assert(term.isColour(), "NanaOS cannot be used on monochrome computers because it uses features such as color, click detection, and multishell that are only available on advanced computers.")

local nana = true

function craftOS()
    while true do
        local e, k = os.pullEvent("key")
        if k == keys.enter then
            term.setTextColor(colors.yellow)
            print(os.version())
            nana = false
            return
        end
    end
end

term.clear()
term.setTextColor(colors.purple)
term.setCursorPos(1,1)
term.write("Nana")
term.setTextColor(colors.magenta)
print("Launcher")
term.setTextColor(colors.white)
print(os.version()..", ".._VERSION)
print("Press Enter to Go to CraftOS (Debug Shell)")
parallel.waitForAny(craftOS, function() os.sleep(2) end)
if nana then
    print("Checking Updates...")
    -- update here
    shell.run("os/login.lua")
end