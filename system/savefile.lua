--[[
savefile.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPLv2

This is the Savefile manager which handles the file operations.
]]--


local Tserial = require 'libs.Tserial'
local logger = require 'system.logger'

local love = love


local Savefile = {}
Savefile.__index = Savefile

-- local function forward declaration
local containsKey, validateSaveFile


function Savefile.create()
    local self = setmetatable({}, Savefile)

    return self
end

function Savefile:load()
    self.saveFile = 'savefile-data.lua'
    local defaultsPath = 'system/savefile-data.lua'
    local defaultData = love.filesystem.load(defaultsPath)()

    if love.filesystem.exists(self.saveFile) then
        -- there is a savefile, so use that instead
        local serialisedData = love.filesystem.read(self.saveFile)
        logger.debug(
            'Savefile: load: found', self.saveFile, 'serialisedData is', serialisedData
        )
        self.saveData = Tserial.unpack(serialisedData)

        -- Check that saveData has the same values as the default one
        validateSaveFile(self.saveData, defaultData)

    else
        -- loading defaults
        logger.debug('Savefile: load: loading defaults..')
        self.saveData = defaultData
    end

    logger.debug('Savefile: load: saveData is', Tserial.pack(self.saveData))
end

function Savefile:save()
    local serialisedData = Tserial.pack(self.saveData)
    logger.debug('Savefile: save: serialisedData is', serialisedData, 'to', self.saveFile)
    local success = love.filesystem.write(self.saveFile, serialisedData)
    logger.debug('Savefile: save: operation success = ', success)
end

function Savefile:getData()
    return self.saveData
end


function containsKey(table, _key)
    for k, _ in pairs(table) do
        if k == _key then
            return true
        end
    end
    return false
end

function validateSaveFile(data, default)
    for k, value in pairs(default) do
        if type(value) == 'table' then
            if not containsKey(data, k) then
                data[k]={}
            end
            validateSaveFile(data[k], default[k])

        elseif not containsKey(data, k) then
            data[k] = value
        end
    end
end


return Savefile
