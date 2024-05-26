--[[

    NanaSettings - Project "NanaOS"
    The NanaOS Built-in File Manager
    Copyright 2023 K-Nana
    License: MIT License https://opensource.org/license/mit/

]]

local hash = require("sha2")
settings.load("os/users/"..nanaUsr.."/user.nana")
if nanaPass ~= settings.get("password") then
    error("Wrong Password")
end
local admin = settings.get("admin", false)

function write(text, x, y, tcol, bgcol)
    if x and y then term.setCursorPos(x, y) end
    if tcol then term.setTextColor(tcol) end
    if bgcol then term.setBackgroundColor(bgcol) end
    term.write(text)
end

function find(list, fvalue)
    for key,value in ipairs(list) do
        if value == fvalue then return key end
    end
end

function menu(ty, user)
    local sizeX, sizeY = term.getSize()
    term.setBackgroundColor(colors.white)
    term.clear()
    write("Settings", 1, 1, colors.black)
    write("X", sizeX, 1, colors.red)
    paintutils.drawBox(1, 2, sizeX, sizeY, colors.yellow)
    paintutils.drawLine(3, 3, sizeX-1, 3, colors.lightGray)
    if ty == "your_account" then
        write("\27", 2, 3, colors.black, colors.orange)
        write("Your Account", 4, 3, colors.black, colors.lightGray)
        write("Logined account: "..nanaUsr, 2, 4, colors.gray, colors.white)
        write("Rename", 2, 5, colors.black, colors.white)
        write("Change Password", 2, 6, colors.black, colors.white)
        write("Delete", 2, 7, colors.red, colors.white)
    elseif ty == "computer" then
        write("\27", 2, 3, colors.black, colors.orange)
        write("Computer", 4, 3, colors.black, colors.lightGray)
        write("Type", 2, 4, colors.black, colors.white)
        write("Peripherals", 2, 5, colors.black, colors.white)
        if turtle then
            write("Turtle", 7, 4, colors.green, colors.white)
        elseif pocket then
            write("Pocket Computer", 7, 4, colors.green, colors.white)
        else
            write("Computer", 7, 4, colors.green, colors.white)
        end
        local peri = peripheral.getNames()
        term.setCursorPos(2, 6)
        if peri[1] ~= nil then
            for i, name in ipairs(peri) do
                term.setTextColor(colors.blue)
                term.write(peripheral.getType(name))
                term.setTextColor(colors.lightBlue)
                print(" "..name)
            end
        else
            print("Nothing")
        end
    elseif ty == "accounts" then
        write("\27", 2, 3, colors.black, colors.orange)
        write("Accounts", 4, 3, colors.black, colors.lightGray)
        write("Create New Account", 2, 4, colors.black, colors.white)
        for i, usr in ipairs(fs.list("os/users")) do
            write(usr, 2, i+4, colors.gray)
        end
    elseif ty == "create_account_select" then
        write("\27", 2, 3, colors.black, colors.orange)
        write("Accounts/Create New Account", 4, 3, colors.black, colors.lightGray)
        write("Create Admin Account", 2, 4, colors.black, colors.white)
        write("Create Normal Account", 2, 5, colors.black, colors.white)
    elseif ty == "your_account_rename" then
        write("\27", 2, 3, colors.black, colors.orange)
        write("Your Account/Rename", 4, 3, colors.black, colors.lightGray)
        write("Enter new Name", 2, 4, colors.black, colors.white)
        write("Reboot after making changes.", 2, 5, colors.lightGray, colors.white)
        paintutils.drawLine(3, 6, sizeX-2, 6, colors.lightGray)
    elseif ty == "your_account_change_pass_1" then
        write("\27", 2, 3, colors.black, colors.orange)
        write("Your Account/Change Password", 4, 3, colors.black, colors.lightGray)
        write("Enter new Password (1/2)", 2, 4, colors.black, colors.white)
        write("must be re-entered.", 2, 5, colors.lightGray, colors.white)
        write("To disable the password,", 2, 6, colors.lightGray, colors.white)
        write("press Enter without entering anything.", 2, 7, colors.lightGray, colors.white)
        paintutils.drawLine(3, 8, sizeX-2, 8, colors.lightGray)
    elseif ty == "your_account_change_pass_2" then
        write("\27", 2, 3, colors.black, colors.orange)
        write("Your Account/Change Password", 4, 3, colors.black, colors.lightGray)
        write("Retype new Password (2/2)", 2, 4, colors.black, colors.white)
        write("Reboot after making changes.", 2, 5, colors.lightGray, colors.white)
        paintutils.drawLine(3, 8, sizeX-2, 8, colors.lightGray)
    elseif ty == "your_account_delete" then
        local aCnt = 0
        if admin then
            for i, usr in ipairs(fs.list("os/users")) do
                settings.load("os/users/"..usr.."/user.nana")
                if settings.get("admin") then
                    aCnt = aCnt+1
                end
            end
        end
        write("\27", 2, 3, colors.black, colors.orange)
        write("Your Account/Delete", 4, 3, colors.black, colors.lightGray)
        if aCnt < 2 and admin then
            write("You can't delete the account because", 2, 4, colors.black, colors.white)
            write("all Admin accounts will be gone.", 2, 5, colors.black, colors.white)
        else
            write("All data related to that account", 2, 4, colors.black, colors.white)
            write("will be deleted. Do you want to run it?", 2, 5, colors.black, colors.white)
            write("This operation can never be undone.", 2, 6, colors.black, colors.white)
            write("If you really want to, click on the text below.", 2, 7, colors.blue, colors.white)
            write("Delete Your Account", 2, 9, colors.red, colors.white)
        end
    elseif ty == "create_account_name" then
        write("\27", 2, 3, colors.black, colors.orange)
        write("Accounts/Create New Account", 4, 3, colors.black, colors.lightGray)
        write("Enter the Name (1/3)", 2, 4, colors.black, colors.white)
        write("Reboot after making changes.", 2, 5, colors.lightGray, colors.white)
        paintutils.drawLine(3, 8, sizeX-2, 8, colors.lightGray)
    elseif ty == "create_account_1" then
        write("\27", 2, 3, colors.black, colors.orange)
        write("Accounts/Create New Account", 4, 3, colors.black, colors.lightGray)
        write("Enter the Password (2/3)", 2, 4, colors.black, colors.white)
        write("Reboot after making changes.", 2, 5, colors.lightGray, colors.white)
        paintutils.drawLine(3, 8, sizeX-2, 8, colors.lightGray)
    elseif ty == "create_account_2" then
        write("\27", 2, 3, colors.black, colors.orange)
        write("Accounts/Create New Account", 4, 3, colors.black, colors.lightGray)
        write("Retype the Password (3/3)", 2, 4, colors.black, colors.white)
        write("Reboot after making changes.", 2, 5, colors.lightGray, colors.white)
        paintutils.drawLine(3, 8, sizeX-2, 8, colors.lightGray)
    elseif ty == "uninstall" then
        write("\27", 2, 3, colors.black, colors.orange)
        write("Uninstall", 4, 3, colors.black, colors.lightGray)
        write("----------------------------------------", (sizeX/2)-20, 4, colors.gray, colors.white)
        write("CRITICAL WARNING!", (sizeX/2)-8, 5, colors.red, colors.white)
        write("Are you sure you want to uninstall it?", (sizeX/2)-19, 6, colors.orange, colors.white)
        write("----------------------------------------", (sizeX/2)-20, 7, colors.gray, colors.white)
        write("All data on your computer will be deleted.", 2, 8, colors.black, colors.white)
        write("Backup any files you don't want to lose.", 2, 9, colors.black, colors.white)
        write("This operation can never be undone.", 2, 10, colors.black, colors.white)
        write("We recommend checking with other users before.", 2, 11, colors.black, colors.white)
        write("If you really want to, click on the text below.", 2, 12, colors.blue, colors.white)
        write("Uninstall NanaOS (All data will be deleted!)", 2, 14, colors.red, colors.white)
    else
        write("\27", 2, 3, colors.black, colors.gray)
        write("Settings", 4, 3, colors.black, colors.lightGray)
        write("General", 2, 4, colors.black, colors.orange)
        write("Your Account", 2, 5, colors.black, colors.white)
        write("Computer", 2, 6, colors.black, colors.white)
        if admin then
            write("Admin", 2, 8, colors.black, colors.red)
            write("Accounts...", 2, 9, colors.black, colors.white)
            write("Uninstall the OS", 2, 10, colors.red, colors.white)
        end
    end
end

function clicks(ty, user)
    local sizeX, sizeY = term.getSize()
    while true do
        local e, b, x, y = os.pullEvent("mouse_click")
        if x == sizeX and y == 1 then
            exit()
        elseif ty == "computer" then
            if x == 2 and y == 3 then
                menu()
                clicks()
            end
        elseif ty == "accounts" then
            if x == 2 and y == 3 then
                menu()
                clicks()
            elseif y == 4 and not (x == 1 or x == sizeX) then
                menu("create_account_select")
                clicks("create_account_select")
            end
        elseif ty == "create_account_select" then
            if x == 2 and y == 3 then
                menu("accounts")
                clicks("accounts")
            elseif y == 4 and not (x == 1 or x == sizeX) then
                menu("create_account_name")
                term.setCursorBlink(true)
                local pResult = {}
                local nResult
                parallel.waitForAny(
                    function() clicks("back") end,
                    function() term.setCursorPos(3, 8) term.setTextColor(colors.black)
                        term.setCursorBlink(true) nResult = read() end
                )
                if (not nResult) or find(fs.list("os/users"), nResult) then
                    menu("accounts")
                    clicks("accounts")
                end
                for i=1, 2 do
                    menu("create_account_"..i)
                    parallel.waitForAny(
                        function() clicks("back") end,
                        function() term.setCursorPos(3, 8) term.setTextColor(colors.black)
                            term.setCursorBlink(true) pResult[i] = read("*") end
                    )
                    if not pResult[i] then
                        break
                    end
                end
                if pResult[1] == pResult[2] and pResult[1] then
                    settings.clear()
                    settings.set("admin", true)
                    settings.set("password", hash.sha256(pResult[1]))
                    fs.makeDir("os/users/"..nResult)
                    fs.makeDir("os/users/"..nResult.."/apps")
                    settings.save("os/users/"..nResult.."/user.nana")
                    os.reboot()
                else
                    menu("accounts")
                    clicks("accounts")
                end
            elseif y == 5 and not (x == 1 or x == sizeX) then
                menu("create_account_name")
                term.setCursorBlink(true)
                local pResult = {}
                local nResult
                parallel.waitForAny(
                    function() clicks("back") end,
                    function() term.setCursorPos(3, 8) term.setTextColor(colors.black)
                        term.setCursorBlink(true) nResult = read() end
                )
                if (not nResult) or find(fs.list("os/users"), nResult) then
                    menu("accounts")
                    clicks("accounts")
                end
                for i=1, 2 do
                    menu("create_account_"..i)
                    parallel.waitForAny(
                        function() clicks("back") end,
                        function() term.setCursorPos(3, 8) term.setTextColor(colors.black)
                            term.setCursorBlink(true) pResult[i] = read("*") end
                    )
                    if not pResult[i] then
                        break
                    end
                end
                if pResult[1] == pResult[2] and pResult[1] then
                    settings.clear()
                    settings.set("admin", false)
                    settings.set("password", hash.sha256(pResult[1]))
                    fs.makeDir("os/users/"..nResult)
                    fs.makeDir("os/users/"..nResult.."/apps")
                    settings.save("os/users/"..nResult.."/user.nana")
                    os.reboot()
                else
                    menu("accounts")
                    clicks("accounts")
                end
            end
        elseif ty == "uninstall" then
            if x == 2 and y == 3 then
                menu()
                clicks()
            elseif y == 14 and not (x == 1 or x == sizeX) then
                fs.delete("os")
                fs.delete("startup.lua")
                os.reboot()
            end
        elseif ty == "your_account" then
            if x == 2 and y == 3 then
                menu()
                clicks()
            elseif y == 5 and not (x == 1 or x == sizeX) then
                term.setCursorBlink(true)
                menu("your_account_rename")
                local result
                parallel.waitForAny(
                    function() clicks("back") end,
                    function() term.setCursorPos(3, 6) term.setTextColor(colors.black)
                        term.setCursorBlink(true) result = read() end
                )
                if result == "" or result == nil or result == nanaUsr then
                    menu("your_account")
                    clicks("your_account")
                else
                    fs.copy("os/users/"..nanaUsr, "os/users/"..result)
                    fs.delete("os/users/"..nanaUsr)
                    os.reboot()
                end
            elseif y == 6 and not (x == 1 or x == sizeX) then
                local result = {}
                for i = 1, 2 do
                    menu("your_account_change_pass_"..i)
                    parallel.waitForAny(
                        function() clicks("back") end,
                        function() term.setCursorPos(3, 8) term.setTextColor(colors.black)
                            term.setCursorBlink(true) result[i] = read("*") end
                    )
                    if not result[i] then
                        break
                    end
                end
                if result[1] == result[2] and result[1] then
                    passHash = hash.sha256(result[1])
                    if nanaPass == passHash then
                        menu("your_account")
                        clicks("your_account")
                    else
                        settings.clear()
                        settings.set("password", passHash)
                        settings.save("os/users/"..nanaUsr.."/user.nana")
                        os.reboot()
                    end
                else
                    menu("your_account")
                    clicks("your_account")
                end
            elseif y == 7 and not (x == 1 or x == sizeX) then
                menu("your_account_delete")
                clicks("your_account_delete")
            end
        elseif ty == "your_account_delete" then
            if x == 2 and y == 3 then
                menu("your_account")
                clicks("your_account")
            elseif y == 9 and not (x == 1 or x == sizeX) then
                local aCnt = 0
                if admin then
                    for i, usr in ipairs(fs.list("os/users")) do
                        settings.load("os/users/"..usr.."/user.nana")
                        if settings.get("admin") then
                            aCnt = aCnt+1
                        end
                    end
                end
                if aCnt > 1 or (not admin) then
                    fs.delete("os/users/"..nanaUsr)
                    os.reboot()
                end
            end
        elseif ty == "back" then
            if x == 2 and y == 3 then
                term.setCursorBlink(false)
                return
            end
        else
            if y == 5 and not (x == 1 or x == sizeX) then
                menu("your_account")
                clicks("your_account")
            elseif y == 6 and not (x == 1 or x == sizeX) then
                menu("computer")
                clicks("computer")
            elseif y == 9 and not (x == 1 or x == sizeX) and admin then
                menu("accounts")
                clicks("accounts")
            elseif y == 10 and not (x == 1 or x == sizeX) and admin then
                menu("uninstall")
                clicks("uninstall")
            end
        end
    end
end

menu()
clicks()
