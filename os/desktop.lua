--[[

    NanaDesk - Project "NanaOS"
    GUI-Based Easy to Use ComputerCraft OS
    Copyright 2023 K-Nana
    License: MIT License https://opensource.org/license/mit/

]]

local sizeX, sizeY = term.getSize()

if sizeX < 21 or sizeY < 10 then
    error("Terminal is too small! It must be at least 24x10 in size.")
end

local darkToLight = {colors.black, colors.gray, colors.lightGray, colors.white}
local menu = false
local pages = 1
local page = 1
local appclick = {}
local dShell = multishell.getCurrent()
appclick[1] = {}

multishell.setTitle(dShell, "Desktop")

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

function redraw()
    sizeX, sizeY = term.getSize()
    term.setBackgroundColor(colors.lime)
    term.clear()
    paintutils.drawLine(1,sizeY-1,sizeX,sizeY-1,colors.green)
    local x = 2
    local y = 2
    local p = 1
    for _, file in ipairs(fs.list("os/apps")) do
        if fs.exists("os/apps/"..file.."/app.nana") then
            if x+9 > sizeX then
                x = 2
                y = y+7
            end
            if y+7 > sizeY then
                p = p+1
                pages = p
                appclick[p] = {}
                x = 2
                y = 2
            end
            appclick[p]["apps/"..file] = {}
            appclick[p]["apps/"..file]["x"] = x
            appclick[p]["apps/"..file]["y"] = y
            appclick[p]["apps/"..file]["name"] = file
            if p == page then
                local icon
                if fs.exists("os/apps/"..file.."/icon.nfp") then
                    icon = paintutils.loadImage("os/apps/"..file.."/icon.nfp")
                else
                    icon = paintutils.loadImage("os/icons/file.nfp")
                end
                paintutils.drawImage(icon, x+1, y)
                drawText(x+math.floor((9-#file)/2), y+5, file, colors.white, colors.lime)
            end
            x = x+10
        end
    end
    for _, file in ipairs(fs.list("os/users/"..nanaUsr.."/apps")) do
        if fs.exists("os/users/"..nanaUsr.."/apps/"..file.."/app.nana") then
            if x+9 > sizeX then
                x = 2
                y = y+7
            end
            if y+7 > sizeY then
                p = p+1
                pages = p
                appclick[p] = {}
                x = 2
                y = 2
            end
            appclick[p]["users/"..nanaUsr.."/apps/"..file] = {}
            appclick[p]["users/"..nanaUsr.."/apps/"..file]["x"] = x
            appclick[p]["users/"..nanaUsr.."/apps/"..file]["y"] = y
            appclick[p]["users/"..nanaUsr.."/apps/"..file]["name"] = file
            if p == page then
                local icon
                if fs.exists("os/users/"..nanaUsr.."/apps/"..file.."/icon.nfp") then
                    icon = paintutils.loadImage("os/users/"..nanaUsr.."/apps/"..file.."/icon.nfp")
                else
                    icon = paintutils.loadImage("os/icons/file.nfp")
                end
                paintutils.drawImage(icon, x+1, y)
                drawText(x+math.floor((9-#file)/2), y+5, file, colors.white, colors.lime)
            end
            x = x+10
        end
    end
    drawText(math.floor(sizeX/2)-4, sizeY-1, "Page "..page.."/"..pages, colors.black, colors.green)
    if page ~= 1 then drawText(1, sizeY-1, "<-", colors.white, colors.blue) end
    if page ~= pages then drawText(sizeX-1, sizeY-1, "->", colors.white, colors.blue) end
    if menu then
        drawText(sizeX-9,sizeY-3,"Logout  ",colors.white,colors.lightGray)
        drawText(sizeX-9,sizeY-2,"Reboot  ",colors.white,colors.lightGray)
        drawText(sizeX-9,sizeY-1,"Shutdown",colors.white,colors.lightGray)
    end
end

function inrange(x,a,b)
    if a > b then return x <= a and x >= b end
    if a < b then return x >= a and x <= b end
end

function events()
    while true do
        local e,b,x,y = os.pullEvent()
        if e == "mouse_click" then
            if y == sizeY then
                if inrange(x,sizeX-1,sizeX-9) then
                    menu = not menu
                    redraw()
                end
            elseif menu and inrange(x,sizeX-1,sizeX-9) and inrange(y,sizeY-1,sizeY-3) then
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
                elseif y == sizeY-3 then
                    term.redirect(term.native())
                    drawText(sizeX-9,sizeY-3,"Logout  ",colors.white,colors.white)
                    os.sleep(0.1)
                    drawText(sizeX-9,sizeY-3,"Logout  ",colors.white,colors.lightGray)
                    os.sleep(0.2)
                    exit()
                end
            elseif y == sizeY-1 then
                menu = false
                if inrange(x,1,2) and page ~= 1 then
                    page = page-1
                    redraw()
                elseif inrange(x,sizeX-1,sizeX) and page ~= pages then
                    page = page+1
                    redraw()
                end
            else
                menu = false
                for app, pos in pairs(appclick[page]) do
                    if inrange(x,pos["x"],pos["x"]+6) and inrange(y,pos["y"],pos["y"]+5) then
                        settings.load("os/"..app.."/app.nana")
                        if settings.get("shortCut", false) then
                            local function Launch()
                                local appShell = multishell.launch({shell=shell, multishell=multishell, require=require, nanaUsr=nanaUsr, nanaPass=nanaPass, nanaAPass="os/"..app}, settings.get("mainFile", "main.lua"))
                                multishell.setFocus(appShell)
                                multishell.setTitle(appShell, pos["name"])
                            end
                            parallel.waitForAll(Launch, events)
                        else
                            local function Launch()
                                local appShell = multishell.launch({shell=shell, multishell=multishell, require=require, nanaUsr=nanaUsr, nanaPass=nanaPass, nanaAPass="os/"..app}, "os/"..app.."/"..settings.get("mainFile", "main.lua"))
                                multishell.setFocus(appShell)
                                multishell.setTitle(appShell, pos["name"])
                            end
                            parallel.waitForAll(Launch, events)
                        end
                        break
                    end
                end
            end
        elseif e == "term_resize" then
            redraw()
            local checkX, checkY = term.getSize()
            if checkX < 21 or checkY < 10 then
                error("Terminal is too small! It must be at least 24x10 in size.")
            end
        end
    end
end

redraw()
parallel.waitForAny(clock,events)
