--[[
StateTemplate.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2


]]--


local logger = require 'system.logger'

local love = love


------- CLASS ---------------------------------------------------------------------------

local StateTemplate = {}
StateTemplate.__index = StateTemplate

setmetatable(StateTemplate, {
    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, StateTemplate)
        self:new(...)
        return self
    end,
})


------- PUBLIC METHODS ------------------------------------------------------------------

function StateTemplate:new(gamestateManager)
    self.gamestateManager = gamestateManager
end

function StateTemplate:keypressed(key)
    if love.keyboard.isDown('escape') or love.keyboard.isDown('q') then
        logger.debug('StateTemplate: keypressed: Pressed a QUIT key')
        love.event.quit()
    else
        self:controls(true, nil, nil)
    end
end

function StateTemplate:touchpressed()
    self:controls(nil, true, nil)
end

function StateTemplate:gamepadpressed(joystick, button)
    if joystick:isGamepadDown('back', 'start') then
        logger.debug('StateTemplate: gamepadpressed: Pressed a QUIT key')
        love.event.quit()
    else
        self:controls(nil, nil, joystick)
    end
end

function StateTemplate:update()
    -- implement me!
end

function StateTemplate:controls(keypress, touchpress, joystick)
    -- implement me!
end


return StateTemplate
