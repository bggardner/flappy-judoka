--[[
Ground.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

This class encompasses the game logic for single Ground object.

Notably, the moving speed here is also scaled accordingly with the display
resolution (similar to Flappy).
]]--


local logger = require 'system.logger'
local utils = require 'system.utils'

local love = love


------- CLASS ---------------------------------------------------------------------------

local Ground = {}
Ground.__index = Ground

setmetatable(Ground, {
    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, Ground)
        self:new(...)
        return self
    end,
})

-- determines how fast the ground sprites move
-- TODO: make sure this and pipe MOVING_SPEED are the same
local MOVING_SPEED = 4.5


------- PUBLIC METHODS ------------------------------------------------------------------

function Ground:new(x, y)
    logger.debug('Ground: new: x is', x, 'y is', y)

    self.image = g_ResManager.GROUND_IMAGE

    -- scaling speed with display resolution
    self.movingSpeed = MOVING_SPEED * g_ResManager.PIPE_TOP_IMAGE:getWidth()
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

function Ground:update(dt)
    -- moving with a distance proportional to the time between 2 frames
    self.x = self.x - dt * self.movingSpeed
    self.x = utils.round(self.x, 2)  -- normalization to 2 decimal points
end

function Ground:draw()
    love.graphics.draw(
        self.image, self.x, self.y, self.r, self.sx, self.sy,
        self.ox, self.oy, self.kx, self.k
    )
end


return Ground
