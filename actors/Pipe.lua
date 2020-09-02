--[[
Pipe.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

This class encompasses the game logic for single Pipe object.

It can be defined as a top or bottom pipe in order to set the appropriate assets. Its
update method simply moves the pipe from right to left.

Notably, the moving speed here is also scaled accordingly with the display
resolution (similar to Flappy).
]]--


local logger = require 'system.logger'
local utils = require 'system.utils'

local love = love


------- CLASS ---------------------------------------------------------------------------

local Pipe = {}
Pipe.__index = Pipe

setmetatable(Pipe, {
    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, Pipe)
        self:new(...)
        return self
    end,
})

-- determines how fast the pipes move
local MOVING_SPEED = 4.5


------- PUBLIC METHODS ------------------------------------------------------------------

function Pipe:new(x, y, isTop)
    logger.debug('Pipe: new: x is', x, 'y is', y, 'isTop is', tostring(isTop))

    if isTop then
        self.image = g_ResManager.PIPE_TOP_IMAGE
    else
        self.image = g_ResManager.PIPE_BOTTOM_IMAGE
    end

    -- scaling speed with display resolution
    self.movingSpeed = MOVING_SPEED * self.image:getWidth()

    self.x = x
    self.y = y
    self.r = nil
    self.sx = nil
    self.sy = nil
    self.ox = self.image:getWidth() / 2
    self.oy = self.image:getHeight() / 2
    self.kx = nil
    self.k = nil
end

function Pipe:update(dt)
    -- moving with a distance proportional to the time between 2 frames
    self.x = self.x - dt * self.movingSpeed
    self.x = utils.round(self.x, 2)  -- normalization to 2 decimal points
end

function Pipe:draw()
    love.graphics.draw(
        self.image, self.x, self.y, self.r, self.sx, self.sy,
        self.ox, self.oy, self.kx, self.k
    )
end


return Pipe
