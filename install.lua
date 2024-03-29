--[[

    NanaOS Installer - Project "NanaOS"
    The Installation assistance
    Copyright 2023 K-Nana
    License: MIT License https://opensource.org/license/mit/

]]

function pressKey()
    while true do
        local e, bt, h = os.pullEvent("key")
        if (bt == 28 or bt == 257) and not h then
            return
        end
    end
end

function wget(url, file)
    local response = http.get(url, nil, true)
    if not response then
        return false
    else
        local fh = fs.open(file, "w")
        fh.write(response.readAll())
        fh.close()
        return true
    end
end

term.setTextColor(colors.purple)
print("[ NanaOS Installer ]")
if not term.isColor() then
    print("[!] NanaOS cannot be used on Monochrome Computer.")
    print("- Try it on an Advanced Computer.")
    exit()
elseif not http then
    printError("It looks like the http api is unavailable.")
    print("- For singleplayer, please check the config.")
    print("- For multiplayer, please contact the server administrator.")
    print("- For multiplayer, please contact the server administrator.")
    exit()
end
term.setTextColor(colors.lightBlue)
print("Meets installation requirements.")
term.setTextColor(colors.white)
print("Welcome to NanaOS Install!")
term.setTextColor(colors.yellow)
print("Press Enter to continue. Press Ctrl and T keys at the same time to exit.")
pressKey()
term.clear()
term.setCursorPos(1,1)
term.setTextColor(colors.white)
local _, height = term.getCursorPos()
local message = [[[ (1/4) License ]
MIT License

Copyright (c) 2023 K-Nana

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]
textutils.pagedPrint(message, -2)
term.setTextColor(colors.yellow)
print("Press Enter to continue. Press Ctrl and T keys at the same time to exit.")
pressKey()
term.clear()
term.setCursorPos(1,1)
term.setTextColor(colors.white)
print("[ (2/4) Create First Account ]")
print("Enter the Name")
term.write("> ")
local name
repeat
    name = read()
until name ~= ""
local pass1
local pass2
repeat
    print("Enter the Password")
    print("Do not enter to disable (not recommended) Password")
    term.write("> ")
    pass1 = read("*")
    print("Retype the Password")
    term.write("> ")
    pass2 = read("*")
until pass1 == pass2
term.clear()
term.setCursorPos(1,1)
term.setTextColor(colors.white)
print("[ (3/4) Install ]")
print("Installing...")
print("Preparing for installation...")
local updNana = http.get("https://raw.githubusercontent.com/k-7iro/NanaOS/main/update.nana").readAll()
local fh = fs.open("update.nana", "w")
fh.write(updNana)
fh.close()
for file, _ in pairs(assert(load("return "..updNana))()["Files"]) do
    print("Downloading "..file.." ...")
    local fh = fs.open(file, "w")
    fh.write(http.get("https://raw.githubusercontent.com/k-7iro/NanaOS/main/"..file).readAll())
    fh.close()
end

local hash = require("/os/sha2")
fs.makeDir("os/users")
fs.makeDir("os/users/"..name)
fs.makeDir("os/users/"..name.."/apps")
settings.clear()
settings.set("admin", true)
settings.set("password", hash.sha256(pass1))
settings.save("os/users/"..name.."/user.nana")
print("[ (4/4) Done ]")
print("All Ready! Have Fun!")
term.setTextColor(colors.yellow)
print("Installation is complete. Press Enter to restart.")
pressKey()
fs.delete("install.lua")
os.reboot()
