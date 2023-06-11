---@class handler
local handler = {}

local io = require('io')
local os = require('os')
local math = require('math')
local table = require('table')
local string = require('string')
local base = _G

local sleep = base.sleep
local place = base.place
local punch = base.punch
local getBot = base.getBot
local getTile = base.getTile
local addHook = base.addHook
local collect = base.collect
local findItem = base.findItem
local findPath = base.findPath
local sendPacket = base.sendPacket
local getObjects = base.getObjects
local disconnect = base.disconnect
local removeHooks = base.removeHooks


function handler.warp(world,door)
    local worlds = string.upper(world)
    if door then
        worlds = worlds.."|"..door
    end
    if getBot().world ~= string.upper(world) then
        addHook("onvariant","nuked",function (var)
            if var[0] == "OnConsoleMessage" then
                if string.find(var[1],"That world is inaccessible.") then
                    handler.nuked = true
                end
            end
        end)
        sleep(100)
        while getBot().world ~= string.upper(world) and not handler.nuked do
            sendPacket("action|join_request\nname|"..worlds.."\ninvitedWorld|0",3)
            sleep(10000)
        end
        removeHooks()
        sleep(100)
    end
    if door and getBot().world == string.upper(world) then
        local try = 0
        while getTile(math.floor(getBot().x / 32),math.floor(getBot().y / 32)).fg == 6 do
            sendPacket("action|join_request\nname|"..worlds.."\ninvitedWorld|0",3)
            sleep(10000)
            if try >= 10 then
                print("Wrong door id,stopped script")
                return error()
            else
                try = try + 1
            end
        end
    end
end

function handler.take(id,limit)
    if findItem(id) < limit then
        for _,object in pairs(getObjects()) do
            if object.id == id then
                findPath(math.floor(object.x / 32),math.floor(object.y / 32))
                sleep(200)
                collect(3)
                sleep(500)
                if findItem(id) > limit then
                    sendPacket("action|drop\n|itemID|"..id,2)
                    sleep(1000)
                    sendPacket("action|dialog_return\ndialog_name|drop_item\nitemID|"..id.."|\ncount|"..(findItem(id) - limit),2)
                    sleep(250)
                end
                if findItem(id) == limit then
                    break
                end
            end
        end
    end
end

function handler.fpunch(x,y)
    while getTile(math.floor(getBot().x / 32) + x,math.floor(getBot().y / 32) + y).fg ~= 0 do
        punch(x,y)
        sleep(120)
    end
end

function handler.fplace(id,x,y)
    while getTile(math.floor(getBot().x / 32) + x,math.floor(getBot().y /32) + y).fg ~= id do
        place(id,x,y)
        sleep(120)
    end
end

function handler.getName(target)
    if string.find(target,":") then
        local tabel = {}
        for string in string.gmatch(target,"[^:]+") do
            table.insert(tabel,string)
        end
        return {
            name = tabel[1],
            name2 = tabel[2]
        }
    else
        return target
    end
end

return handler
