--[[

    NanaLauncher - Project "NanaOS"
    The Updater(WIP) and something
    Copyright 2023 K-Nana
    License: MIT License https://opensource.org/license/mit/

]]

assert(term.isColour(), "NanaOS cannot be used on monochrome computers because it uses features such as color, click detection, and multishell that are only available on advanced computers.")

local nana = true

function drawText(x,y,text,tcl,bgcl)
    if tcl then term.setTextColor(tcl) end
    if bgcl then term.setBackgroundColor(bgcl) end
    term.setCursorPos(x,y)
    term.write(text)
end

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
    if http then
        print("Checking Updates...")
        local newUpdate = assert(load("return "..http.get("https://raw.githubusercontent.com/k-7iro/NanaOS/main/update.nana").readAll()))()
        local newVerdata = newUpdate["Files"]
        local newName = newUpdate["VersionName"]
        settings.load("update.nana")
        local oldVerdata = settings.get("Files")
        for file, hash in pairs(newVerdata) do
            if hash ~= oldVerdata[file] then
                print("Updating "..file.." ...")
                local fh = fs.open(file, "w")
                fh.write(http.get("https://raw.githubusercontent.com/k-7iro/NanaOS/main/"..file).readAll())
                fh.close()
            end
        end
        if newVerdata ~= oldVerdata then
            settings.set("Files", newVerdata)
            settings.set("VersionName", newName)
            settings.save("update.nana")
        end
    end
    shell.run("os/login.lua")
end
