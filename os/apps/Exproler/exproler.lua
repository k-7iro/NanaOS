--[[

    NanaExproler - Project "NanaOS"
    The NanaOS Built-in File Manager
    Copyright 2023 K-Nana
    License: MIT License https://opensource.org/license/mit/
    
]]

-- Config

local maincol = colors.lightBlue
local subcol = colors.blue
local accentcol1 = colors.lime
local accentcol2 = colors.orange
local warncol = colors.red
local monocol1 = colors.white
local monocol2 = colors.lightGray
local monocol3 = colors.gray
local monocol4 = colors.black

local clipboard = {}
local cut = false

function write(text, x, y, tcol, bgcol)
    if x and y then term.setCursorPos(x, y) end
    if tcol then term.setTextColor(tcol) end
    if bgcol then term.setBackgroundColor(bgcol) end
    term.write(text)
end

function extension(name)
    local result = ""
    for i=1,#name do
        local char = string.sub(name, #name+1-i, #name+1-i)
        if char == "." then
            return string.upper(result)
        elseif char == "/" then
            break
        else
            result = char..result
        end
    end
end

function cutExtension(name)
    local result = ""
    for i=1,#name do
        local char = string.sub(name, i, i)
        if char == "." then
            return result
        elseif char == "/" then
            result = ""
        else
            result = result..char
        end
    end
end

function withUnit(num)
    if num == 0 then
        return "0K"
    else
        return math.ceil(num/1000).."K"
    end
end

function find(list, fvalue)
    for key,value in ipairs(list) do
        if value == fvalue then return key end
    end
end

function valueSwitch(list, svalue)
    if find(list, svalue) then
        table.remove(list, find(list, svalue))
    else
        list[#list+1] = svalue
    end
    return list
end

function loadDir(dir, selected, scroll, ctrl, property, menu)
    local Height = 6
    local sizeX,sizeY = term.getSize()
    local prefileList = fs.list(dir)
    local fileList = prefileList
    for i, file in ipairs(prefileList) do
        if extension(file) == "NANA" then
            table.remove(fileList, i)
        end
    end
    function sort(a, b)
        if fs.isDir(dir.."/"..a) and (not fs.isDir(dir.."/"..b)) then
            return true
        elseif (not fs.isDir(dir.."/"..a)) and fs.isDir(dir.."/"..b) then
            return false
        end
        return string.upper(a) < string.upper(b)
    end
    table.sort(fileList, sort)
    term.setBackgroundColor(monocol1)
    term.clear()
    paintutils.drawFilledBox(1, 2, sizeX, 4, maincol)
    paintutils.drawFilledBox(3, 3, sizeX-1, 3, monocol1)
    write("Exproler", 1, 1, monocol4, monocol1)
    if dir ~= "" or property then
        write("\24", 2, 3, subcol, monocol1)
    else
        write("\24", 2, 3, monocol2, monocol1)
    end
    write("X", sizeX, 1, warncol, monocol1)
    if property then
        write(property.."'s Property", 5, 4, subcol, maincol)
    end
    write("Menu... ", sizeX-10, 4, monocol1, accentcol1)
    if property then
        if fs.isDir(fs.getDir(dir)) then _dir = "root/"..dir.."/"..property else _dir = "root/"..property end
    elseif dir == "" then
        _dir = "root"
    else
        _dir = "root/"..dir
    end
    if #_dir > sizeX-4 then
        dispDir = "..."..string.sub(_dir,0-sizeX+8)
    else
        dispDir = _dir
    end
    write(dispDir, 4, 3, monocol4, monocol1)
    if property then
        local attribute = fs.attributes(dir.."/"..property)
        write("Basic Infomation", 1, 5, accentcol1, monocol1)
        write("Size", 1, 6, monocol4, monocol1)
        write(withUnit(attribute["size"]).."B", 14, 6, monocol2, monocol1)
        write("is Directory", 1, 7, monocol4, monocol1)
        if attribute["isDir"] then write("Yes", 14, 7, monocol2, monocol1)
        else write("No", 14, 7, monocol2, monocol1) end
        write("is Writable", 1, 8, monocol4, monocol1)
        if attribute["isReadOnly"] then write("No", 14, 8, monocol2, monocol1)
        else write("Yes", 14, 8, monocol2, monocol1) end
        if not fs.isReadOnly(dir.."/"..property) then
            write("Modify Time", 1, 9, monocol4, monocol1)
            write(os.date("%a %b %d %Y",attribute["modifed"]), 14, 9, monocol2, monocol1)
            write("Changeable (Click to Change)", 1, 11, accentcol2, monocol1)
            write("Name", 1, 12, monocol4, monocol1)
            write(property, 6, 12, monocol2, monocol1)
        end
    else
        write("Name", 3, 5, monocol3, monocol1)
        write("\149", math.floor(sizeX/2)-3, 5, monocol2, monocol1)
        write("Type", math.floor(sizeX/2)-2, 5, monocol3, monocol1)
        write("\149", sizeX-5, 5, monocol2, monocol1)
        write("Size", sizeX-4, 5, monocol3, monocol1)
        for i=Height,sizeY do
            if fileList[i+scroll-(Height-1)] then
                if (find(selected, dir.."/"..fileList[i+scroll-(Height-1)])) or (find(selected, fileList[i+scroll-(Height-1)])) then
                    paintutils.drawFilledBox(1, i, sizeX, i, accentcol1)
                else
                    paintutils.drawFilledBox(1, i, sizeX, i, monocol1)
                end
                term.setCursorPos(1,i)
                if fs.isDir(dir.."/"..fileList[i+scroll-(Height-1)]) then
                    term.setTextColor(subcol)
                    term.write("\136 ")
                    term.setTextColor(monocol4)
                    term.write(fileList[i+scroll-(Height-1)])
                    write("Folder", math.floor(sizeX/2)-2, i, monocol2, monocol)
                else
                    term.setTextColor(monocol4)
                    term.write("\136 ")
                    term.write(fileList[i+scroll-(Height-1)])
                    write(withUnit(fs.getSize(dir.."/"..fileList[i+scroll-(Height-1)])).."B", sizeX-4, i, monocol2, nil)
                    if extension(fileList[i+scroll-(Height-1)]) == "LUA" then
                        write("Lua Source", math.floor(sizeX/2)-2, i, monocol2, monocol)
                    elseif extension(fileList[i+scroll-(Height-1)]) == "TXT" then
                        write("Text File", math.floor(sizeX/2)-2, i, monocol2, monocol)
                    elseif extension(fileList[i+scroll-(Height-1)]) == "NFP" then
                        write("CC Image", math.floor(sizeX/2)-2, i, monocol2, monocol)
                    elseif extension(fileList[i+scroll-(Height-1)]) == "NIT" then
                        write("NanaImage", math.floor(sizeX/2)-2, i, monocol2, monocol)
                    elseif not extension(fileList[i+scroll-(Height-1)]) then
                        write("Unknown File", math.floor(sizeX/2)-2, i, monocol2, monocol)
                    else
                        write(string.upper(extension(fileList[i+scroll-(Height-1)])).." File", math.floor(sizeX/2)-2, i, monocol2, monocol)
                    end
                end
            else
                paintutils.drawFilledBox(1, i, sizeX, i, monocol1)
            end
        end
        if fileList[1] == nil then
            write("There are no files in",1,Height,monocol2,monocol1)
            write("this Directory ...",1,Height+1)
        end
        if menu and not property then
            if fs.isReadOnly(dir) then
                write("New File", sizeX-10, 5, monocol2, monocol3)
                write("New Dir ", sizeX-10, 6, monocol2, monocol3)
            else
                write("New File", sizeX-10, 5, monocol1, monocol3)
                write("New Dir ", sizeX-10, 6, monocol1, monocol3)
            end
            if selected and selected[1] then
                if selected[2] then
                    write("Property", sizeX-10, 7, monocol2, monocol3)
                    write("Edit    ", sizeX-10, 8, monocol2, monocol3)
                    write("Run     ", sizeX-10, 9, monocol2, monocol3)
                else
                    write("Property", sizeX-10, 7, monocol1, monocol3)
                    write("Edit    ", sizeX-10, 8, monocol1, monocol3)
                    if (not fs.isDir(selected[1])) and string.lower(extension(selected[1])) == "lua" then
                        write("Run     ", sizeX-10, 9, monocol1, monocol3)
                    else
                        write("Run     ", sizeX-10, 9, monocol2, monocol3)
                    end
                end
                write("Delete  ", sizeX-10, 10, monocol1, monocol3)
                write("Copy    ", sizeX-10, 11, monocol1, monocol3)
                write("Cut     ", sizeX-10, 12, monocol1, monocol3)
            else
                write("Property", sizeX-10, 7, monocol2, monocol3)
                write("Edit    ", sizeX-10, 8, monocol2, monocol3)
                write("Open    ", sizeX-10, 9, monocol2, monocol3)
                write("Delete  ", sizeX-10, 10, monocol2, monocol3)
                write("Copy    ", sizeX-10, 11, monocol2, monocol3)
                write("Cut     ", sizeX-10, 12, monocol2, monocol3)
            end
            if clipboard and clipboard[1] and (not fs.isReadOnly(dir)) then
                write("Paste   ", sizeX-10, 13, monocol1, monocol3)
            else
                write("Paste   ", sizeX-10, 13, monocol2, monocol3)
            end
        end
    end
    while true do
        local event, cbt, cx, cy = os.pullEvent()
        if event == "mouse_click" and (cbt == 1 or cbt == 2) then
            if cx == sizeX and cy == 1 then
                exit()
            elseif cx == 2 and cy == 3 and (fs.isDir(fs.getDir(dir)) or property) then
                if property then
                    loadDir(dir, {}, 0, ctrl, nil)
                else
                    loadDir(fs.getDir(dir), {}, 0, ctrl)
                end
            elseif cx >= sizeX-11 and cx <= sizeX-3 and cy == 4 and (not property) then
                loadDir(dir, selected, scroll, ctrl, property, not menu)
            elseif cx >= sizeX-11 and cx <= sizeX-3 and cy == 5 and (not fs.isReadOnly(dir)) and menu then
                local file = fs.open(dir.."/NewFile.txt", "w")
                file.close()
                loadDir(dir,selected,scroll,ctrl)
            elseif cx >= sizeX-11 and cx <= sizeX-3 and cy == 6 and (not fs.isReadOnly(dir)) and menu then
                fs.makeDir(dir.."/NewDirectory")
                loadDir(dir,selected,scroll,ctrl)
            elseif cx >= sizeX-11 and cx <= sizeX-3 and cy == 7 and (not fs.isReadOnly(dir)) and menu and selected[1] and (not selected[2]) then
                loadDir(dir, {}, scroll, ctrl, fs.getName(selected[1]))
            elseif cx >= sizeX-11 and cx <= sizeX-3 and cy == 8 and (not fs.isReadOnly(dir)) and menu and selected[1] and (not selected[2]) then
                if string.lower(extension(selected[1])) == "nfp" then
                    shell.switchTab(shell.openTab("rom/programs/fun/advanced/paint.lua", selected[1]))
                else
                    shell.switchTab(shell.openTab("rom/programs/edit.lua", selected[1]))
                end
                loadDir(dir,selected,scroll,ctrl)
            elseif cx >= sizeX-11 and cx <= sizeX-3 and cy == 9 and (not fs.isReadOnly(dir)) and menu and selected[1] and (not selected[2]) then
                shell.switchTab(shell.openTab(selected[1]))
                loadDir(dir,selected,scroll,ctrl)
            elseif cx >= sizeX-11 and cx <= sizeX-3 and cy == 10 and (not fs.isReadOnly(dir)) and menu and selected[1] then
                for _, i in ipairs(selected) do 
                    fs.delete(i)
                end
                loadDir(dir,selected,scroll,ctrl)
            elseif cx >= sizeX-11 and cx <= sizeX-3 and cy == 11 and menu and selected[1] then
                clipboard = selected
                cut = false
                loadDir(dir,{},scroll,ctrl)
            elseif cx >= sizeX-11 and cx <= sizeX-3 and cy == 12 and menu and selected[1] then
                clipboard = selected
                cut = true
                loadDir(dir,{},scroll,ctrl)
            elseif cx >= sizeX-11 and cx <= sizeX-3 and cy == 13 and (not fs.isReadOnly(dir)) and menu and clipboard[1] then
                if cut then
                    for key, value in ipairs(clipboard) do
                        local fName = fs.getName(value)
                        local fCnt = 0
                        while fs.exists(dir.."/"..fName) do
                            fCnt = fCnt+1
                            fName = cutExtension(fs.getName(value)).."_("..fCnt..")."..extension(fs.getName(value))
                        end
                        fs.move(value, dir.."/"..fName)
                    end
                    clipboard = {}
                else
                    for key, value in ipairs(clipboard) do
                        local fName = fs.getName(value)
                        local fCnt = 0
                        while fs.exists(dir.."/"..fName) do
                            fCnt = fCnt+1
                            fName = cutExtension(fs.getName(value)).."_("..fCnt..")."..extension(fs.getName(value))
                        end
                        fs.copy(value, dir.."/"..fName)
                    end
                end
                loadDir(dir, selected, scroll, ctrl)
            elseif cy >= Height then
                if property then
                    if cy == 12 and (not fs.isReadOnly(dir.."/"..property)) then
                        paintutils.drawLine(6,11,sizeX,11)
                        term.setCursorPos(6,11)
                        local ans = read(nil,nil,nil,property)
                        if fs.exists(dir.."/"..ans) then
                            loadDir(dir,selected,scroll,ctrl,property)
                        else
                            fs.move(dir.."/"..property, dir.."/"..ans)
                            loadDir(dir,selected,scroll,ctrl,ans)
                        end
                    end
                elseif fileList[scroll+cy-(Height-1)] then
                    if ctrl then
                        if fs.isDir(fs.getDir(dir)) then
                            loadDir(dir,valueSwitch(selected, dir.."/"..fileList[scroll+cy-(Height-1)]),scroll,ctrl)
                        else
                            loadDir(dir,valueSwitch(selected, fileList[scroll+cy-(Height-1)]),scroll,ctrl)
                        end
                    else
                        if fs.isDir(fs.getDir(dir)) then
                            if find(selected, dir.."/"..fileList[scroll+cy-(Height-1)]) then
                                if cbt == 2 then
                                    loadDir(dir, {}, scroll, ctrl, fileList[scroll+cy-(Height-1)])
                                elseif fs.isDir(dir.."/"..fileList[scroll+cy-(Height-1)]) then
                                    loadDir(dir.."/"..fileList[scroll+cy-(Height-1)], {}, scroll, ctrl)
                                else
                                    if string.lower(extension(fileList[scroll+cy-(Height-1)])) == "nfp" then
                                        shell.switchTab(shell.openTab("rom/programs/fun/advanced/paint.lua", dir.."/"..fileList[scroll+cy-(Height-1)]))
                                    else
                                        shell.switchTab(shell.openTab("rom/programs/edit.lua", dir.."/"..fileList[scroll+cy-(Height-1)]))
                                    end
                                    loadDir(dir, {}, scroll, ctrl)
                                end
                            else
                                loadDir(dir, {dir.."/"..fileList[scroll+cy-(Height-1)]}, scroll, ctrl)
                            end
                        else
                            if find(selected, fileList[scroll+cy-(Height-1)]) then
                                if cbt == 2 then
                                    loadDir("", {}, scroll, ctrl, fileList[scroll+cy-(Height-1)])
                                elseif fs.isDir(fileList[scroll+cy-(Height-1)]) then
                                    loadDir(fileList[scroll+cy-(Height-1)], {}, scroll, ctrl)
                                else
                                    if string.lower(extension(fileList[scroll+cy-(Height-1)])) == "nfp" then
                                        shell.switchTab(shell.openTab("rom/programs/fun/advanced/paint.lua", dir.."/"..fileList[scroll+cy-(Height-1)]))
                                    else
                                        shell.switchTab(shell.openTab("rom/programs/edit.lua", dir.."/"..fileList[scroll+cy-(Height-1)]))
                                    end
                                    loadDir(dir, {}, scroll, ctrl)
                                end
                            else
                                loadDir(dir, {fileList[scroll+cy-(Height-1)]}, scroll, ctrl)
                            end
                        end
                    end
                else
                    loadDir(dir, {}, scroll, ctrl)
                end
            end
        elseif event == "mouse_scroll" then
            if cbt == 1 then
                if scroll < #fileList-(sizeY-(Height-1)) then loadDir(dir, selected, scroll+1, ctrl) end
            else
                if scroll > 0 then loadDir(dir, selected, scroll-1, ctrl) end
            end
        elseif event == "key" then
            if cbt == keys.leftCtrl and not ctrl then
                loadDir(dir, selected, scroll, true, property)
            elseif cbt == keys.delete then
                for key,value in ipairs(selected) do
                    if not fs.isReadOnly(value) then
                        fs.delete(value)
                    end
                end
                loadDir(dir, {}, scroll, ctrl, property)
            elseif cbt == keys.x and ctrl then
                clipboard = selected
                cut = true
            elseif cbt == keys.c and ctrl then
                clipboard = selected
                cut = false
            elseif cbt == keys.v and ctrl and (not fs.isReadOnly(dir)) then
                if cut then
                    for key, value in ipairs(clipboard) do
                        local fName = fs.getName(value)
                        local fCnt = 0
                        while fs.exists(dir.."/"..fName) do
                            fCnt = fCnt+1
                            fName = cutExtension(fs.getName(value)).."_("..fCnt..")."..extension(fs.getName(value))
                        end
                        fs.move(value, dir.."/"..fName)
                    end
                    clipboard = {}
                else
                    for key, value in ipairs(clipboard) do
                        local fName = fs.getName(value)
                        local fCnt = 0
                        while fs.exists(dir.."/"..fName) do
                            fCnt = fCnt+1
                            fName = cutExtension(fs.getName(value)).."_("..fCnt..")."..extension(fs.getName(value))
                        end
                        fs.copy(value, dir.."/"..fName)
                    end
                end
                loadDir(dir, selected, scroll, ctrl)
            end
        elseif event == "key_up" and cbt == keys.leftCtrl and ctrl then
            loadDir(dir, selected, scroll, false, property)
        end
    end
end

nanaUsr = "K-Nana"
loadDir("os/users/"..nanaUsr, {}, 0, false, false)
