--[[
logger.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

Logging tool used to facilitate debugging.
TODO: include [File] [Method] after [Level]
TODO: check for --debug arg
]]--


------- MODULE --------------------------------------------------------------------------

local logger = {}

-- local function forward declaration
local getDateString

-- parameters
local DEBUG_ENABLED = false
local RUNNING_IN_RELEASE = true


------- PUBLIC METHODS ------------------------------------------------------------------

function logger.setDebug(isEnabled)
    DEBUG_ENABLED = isEnabled
end

function logger.setRunningInRelease() -- TODO: implement this
end

function logger.debug(...)
    if DEBUG_ENABLED then
        print(getDateString() .. ' [DEBUG] ' .. table.concat({...}, ' '))
    end
end

function logger.info(...)
    if RUNNING_IN_RELEASE then do end  -- TODO: output to file
    else
        print(getDateString() .. ' [INFO] ' .. table.concat({...}, ' '))
    end
end

function logger.warn(...)
    if RUNNING_IN_RELEASE then do end  -- TODO: output to file
    else
        print(getDateString() .. ' [WARNING] ' .. table.concat({...}, ' '))
    end
end

function logger.error(...)
    if RUNNING_IN_RELEASE then do end  -- TODO: output to file
    else
        print(getDateString() .. ' [ERROR] ' .. table.concat({...}, ' '))
    end
end


------- PRIVATE METHODS -----------------------------------------------------------------

function getDateString()
    local date = os.date("*t", os.time())
    return string.format(
        "%04d-%02d-%02d %02d:%02d:%02d",
        date['year'], date['month'], date['day'],
        date['hour'], date['min'], date['sec']
    )
end


return logger

