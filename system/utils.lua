--[[
utils.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

Various utilities used throught the game.
]]--


local logger = require 'system.logger'
local paths = require 'system.paths'

local love = love


------- MODULE --------------------------------------------------------------------------

local utils = {}


------- PUBLIC METHODS ------------------------------------------------------------------

function utils.parseArgs(args)
    local argsTable = {}
    for _, arg in ipairs(args) do
        argsTable[arg] = true  -- TODO: support --opt=value
    end
    return argsTable
end

function utils.loadImage(name)  -- TODO: handle errors
    local path = paths.IMAGES_DIR .. name .. '.png'
    local successful, image = pcall(love.graphics.newImage, path)
    if not successful then
        successful, image = pcall(love.graphics.newImage, 'common/'..path)
        if not successful then
           logger.error('utils: loadImage: Could not load', path, image)
           return nil
        end
    end
    return image
end

function utils.loadSound(name)  -- TODO: handle errors
    local path = paths.SOUNDS_DIR .. name .. '.wav'
    local successful, sound = pcall(love.audio.newSource, path, 'static')
    if not successful then
        logger.error('utils: loadSound: Could not load', path, sound)
        return nil
    end
    return sound
end

function utils.round(num, idp)
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function utils.degreesToRadians(degrees)
    return degrees * math.pi / 180
end

function utils.instanceOf(subject, super)  -- TODO: fix this for interfaces
    super = tostring(super)
    local mt = getmetatable(subject)

    while true do
        if mt == nil then return false end
        if tostring(mt) == super then return true end
        mt = getmetatable(mt)
    end
end

function utils.fileExists(path)
    local file = io.open(path, 'r')
    if file then
        io.close(file)
        return true
    end
    return false
end

function utils.checkCollision(firstRect, secondRect)
    return (
        firstRect.x < secondRect.x + secondRect.image:getWidth() and
        firstRect.x + firstRect.image:getWidth() > secondRect.x and
        firstRect.y - firstRect.oy < secondRect.y + secondRect.image:getHeight()
            - secondRect.oy and
        firstRect.y + firstRect.image:getHeight() - firstRect.oy > secondRect.y
            - secondRect.oy
    )
end


return utils
