--[[

    NanaLogin - Project "NanaOS"
    GUI-Based Easy to Use ComputerCraft OS
    Copyright 2023 K-Nana
    License : MIT License https://opensource.org/license/mit/

]]

local sizeX, sizeY = term.getSize()

if sizeX < 21 or sizeY < 10 then
    error("Terminal is too small! It must be at least 24x10 in size.")
end

local hash = require("sha2")
local darkToLight = {colors.black, colors.gray, colors.lightGray, colors.white}
local menu = false
local pages = 1
local page = 1
local userclick = {}
local dShell = multishell.getCurrent()
local nanaUsr
local nanaPass
userclick[1] = {}

function drawText(x,y,text,tcl,bgcl)
    if tcl then term.setTextColor(tcl) end
    if bgcl then term.setBackgroundColor(bgcl) end
    term.setCursorPos(x,y)
    term.write(text)
end

function clock()
    while true do
        while dShell == multishell.getCurrent() do
            time = textutils.formatTime(os.time(), true).." Day "..os.day()
            paintutils.drawLine(#time+1,sizeY,sizeX-10,sizeY,colors.lightGray)
            term.setCursorPos(sizeX-1,sizeY)
            term.write("  ")
            drawText(sizeX-9,sizeY,"Menu ...",colors.white,colors.gray)
            drawText(1,sizeY,time,colors.white,colors.lightGray)
            os.sleep()
        end
    end
end

function loadPass(user)
    settings.load("os/users/"..user.."/user.nana")
    return settings.get("password")
end

function usrList()
    sizeX, sizeY = term.getSize()
    term.setBackgroundColor(colors.white)
    term.clear()
    paintutils.drawLine(1,sizeY-1,sizeX,sizeY-1,colors.lightBlue)
    local x = 2
    local y = 2
    local p = 1
    for _, file in ipairs(fs.list("os/users")) do
        if fs.exists("os/users/"..file.."/user.nana") then
            if x+9 > sizeX then
                x = 2
                y = y+7
            end
            if y+7 > sizeY then
                p = p+1
                pages = p
                userclick[p] = {}
                x = 2
                y = 2
            end
            userclick[p][file] = {}
            userclick[p][file]["x"] = x
            userclick[p][file]["y"] = y
            if p == page then
                local icon
                if fs.exists("os/users/"..file.."/icon.nfp") then
                    icon = paintutils.loadImage("os/users/"..file.."/icon.nfp")
                else
                    icon = paintutils.loadImage("os/icons/user.nfp")
                end
                paintutils.drawImage(icon, x+1, y)
                drawText(x+math.floor((9-#file)/2), y+5, file, colors.black, colors.white)
            end
            x = x+10
        end
    end
    drawText(math.floor(sizeX/2)-4, sizeY-1, "Page "..page.."/"..pages, colors.black, colors.lightBlue)
    if page ~= 1 then drawText(1, sizeY-1, "<-", colors.white, colors.blue) end
    if page ~= pages then drawText(sizeX-1, sizeY-1, "->", colors.white, colors.blue) end
    if menu then
        drawText(sizeX-9,sizeY-2,"Reboot  ",colors.white,colors.lightGray)
        drawText(sizeX-9,sizeY-1,"Shutdown",colors.white,colors.lightGray)
    end
end

function login(user)
    local pass = loadPass(user)
    if pass == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" then
        nanaUsr = user
        nanaPass = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        return true
    else
        local result = true
        sizeX, sizeY = term.getSize()
        term.setBackgroundColor(colors.white)
        term.clear()
        paintutils.drawLine(1,sizeY,sizeX,sizeY,colors.lightGray)
        drawText(2,2,"\27"..user, colors.blue, colors.lightGray)
        drawText(3,2," Login by "..user, nil, colors.white)
        drawText(2,4,"Enter Password...", colors.gray)
        paintutils.drawLine(2,5,sizeX-1,5, colors.lightGray)
        paintutils.drawLine(1,sizeY-1,sizeX,sizeY-1,colors.lightBlue)
        local function click()
            while true do
                local e,b,x,y = os.pullEvent("mouse_click")
                if x == 2 and y == 2 then
                    term.setCursorBlink(false)
                    result = false
                    return
                end
            end
        end
        local function passCheck()
            local rd
            repeat
                term.setCursorPos(2,5)
                term.setBackgroundColor(colors.lightGray)
                term.setTextColor(colors.black)
                rd = hash.sha256(read("*"))
                if pass ~= rd then
                    paintutils.drawLine(2,5,sizeX-1,5, colors.lightGray)
                    paintutils.drawLine(1,sizeY-1,sizeX,sizeY-1,colors.red)
                    drawText(1,sizeY-1,"Wrong Password",colors.white)
                end
            until pass == rd
            nanaUsr = user
            nanaPass = rd
            result = true
        end
        parallel.waitForAny(click, passCheck)
        return result
    end
end

function inrange(x,a,b)
    if a > b then return x <= a and x >= b end
    if a < b then return x >= a and x <= b end
end

function listEvents()
    while true do
        local e,b,x,y = os.pullEvent()
        if e == "mouse_click" then
            if y == sizeY then
                if inrange(x,sizeX-1,sizeX-9) then
                    menu = not menu
                    usrList()
                end
            elseif menu and inrange(x,sizeX-1,sizeX-9) and inrange(y,sizeY-1,sizeY-2) then
                if y == sizeY-1 then
                    term.redirect(term.native())
                    drawText(sizeX-9,sizeY-1,"Shutdown",colors.white,colors.white)
                    os.sleep(0.1)
                    drawText(sizeX-9,sizeY-1,"Shutdown",colors.white,colors.lightGray)
                    os.sleep(0.2)
                    os.shutdown()
                elseif y == sizeY-2 then
                    term.redirect(term.native())
                    drawText(sizeX-9,sizeY-2,"Reboot  ",colors.white,colors.white)
                    os.sleep(0.1)
                    drawText(sizeX-9,sizeY-2,"Reboot  ",colors.white,colors.lightGray)
                    os.sleep(0.2)
                    os.reboot()
                end
            elseif y == sizeY-1 then
                if inrange(x,1,2) and page ~= 1 then
                    page = page-1
                    usrList()
                elseif inrange(x,sizeX-1,sizeX) and page ~= pages then
                    page = page+1
                    usrList()
                end
            else
                for usr, pos in pairs(userclick[page]) do
                    if inrange(x,pos["x"],pos["x"]+6) and inrange(y,pos["y"],pos["y"]+5) then
                        return usr
                    end
                end
            end
        elseif e == "term_resize" then
            usrList(euser)
        end
    end
end

for i, c in ipairs(darkToLight) do
    term.setBackgroundColor(c)
    term.clear()
    os.sleep(0.05)
end
drawText(math.floor(sizeX/2)-4, math.floor(sizeY/2), "Welcome.", colors.black)
os.sleep(1.6)
for i, c in ipairs(darkToLight) do
    os.sleep(0.1)
    drawText(math.floor(sizeX/2)-4, math.floor(sizeY/2), "Welcome.", c)
end
local euser
local erun
while true do
    repeat
        usrList()
        parallel.waitForAny(clock,function() euser = listEvents() end)
        erun = login(euser)
    until erun
    os.run({shell=shell, multishell=multishell, require=require, nanaUsr=nanaUsr, nanaPass=nanaPass}, "os/desktop.lua")
    menu = false
end
