--[[
GroundManager.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

This class is the top level manager for the "floor assembly".

It composes the ground out of as many Ground objects as needed in order to fill the
screen. Similar to PipeManager, as soon as a Ground sprite falls off the screen
to the left, it is moved at the end for continuous animation.
]]--


local Ground = require 'actors.Ground'
local logger = require 'system.logger'

local love = love


------- CLASS ---------------------------------------------------------------------------

local GroundManager = {}
GroundManager.__index = GroundManager

-- local function forward declaration
local generateGround

setmetatable(GroundManager, {
    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, GroundManager)
        self:new(...)
        return self
    end,
})

-- constants
local GROUND_Y = 0.93


------- PUBLIC METHODS ------------------------------------------------------------------

function GroundManager:new()
    self.displayWidth = love.graphics.getWidth()
    self.displayHeight = love.graphics.getHeight()

    -- scaling ground position with display resolution
    self.groundY = GROUND_Y * self.displayHeight
    logger.debug('GroundManager: new: groundY is', self.groundY)

    self.groundWidth = g_ResManager.GROUND_IMAGE:getWidth()
    logger.debug('GroundManager: new: groundWidth is', self.groundWidth)

    -- calculate the number of ground sprites needed and generate them
    self.numGrounds = math.floor(self.displayWidth / self.groundWidth + 2)
    logger.debug('GroundManager: new: numGrounds is', self.numGrounds)

    self.groundList = generateGround(self)
end

function GroundManager:update(dt)
    -- call the update function of every Ground sprite
    for _, ground in ipairs(self.groundList) do
        ground:update(dt)
    end

    -- if the first ground sprite falls off the screen completely move it to the back
    if self.groundList[1].x < -self.groundWidth / 2 then  -- TODO: fix access to instance variable
        local firstGround = table.remove(self.groundList, 1)

        local newLastGroundX = self.groundList[#self.groundList].x + self.groundWidth
        firstGround.x = newLastGroundX
        firstGround.y = firstGround.y

        table.insert(self.groundList, firstGround)
    end
end

function GroundManager:draw()
    for _, ground in ipairs(self.groundList) do
        ground:draw()
    end
end

function GroundManager:getGroundUnderFlappy()
    for _, ground in ipairs(self.groundList) do
        -- TODO: better way of using flappy's position (.. > s.d_w * 0.2)
        if ground.x + ground.image:getWidth() / 2.0 > self.displayWidth * 0.2 then
            return ground
        end
    end
    logger.error(
        'GroundManager: getGroundUnderFlappy: Did not find any ground under Flappy!'
    )
end


------- PRIVATE METHODS -----------------------------------------------------------------

function generateGround(self)
    local groundList = {}

    for i = 0, self.numGrounds - 1 do
        table.insert(groundList, Ground(i * self.groundWidth, self.groundY))
    end
    return groundList
end


return GroundManager
