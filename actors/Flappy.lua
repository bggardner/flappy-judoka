--[[
Flappy.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

This class encompasses the game logic for Flappy - from physics, to animations.

It defines idle, flap, and dive animations which are used in the update method. The
animations are completely controled by the class constants below and can be tweaked
without braking anything (within reason).

Notably, the physics (jump velocity, acceleration, max velocity, etc) scale accordingly
with respect to the screen resolution
]]--


local logger = require 'system.logger'
local utils = require 'system.utils'

local love = love


------- CLASS ---------------------------------------------------------------------------

local Flappy = {['FlappyFlapListener'] = {}}
Flappy.__index = Flappy

-- local function forward declaration
local flapAnimation, diveAnimation, getCurrentFlappyImage
local callFlappyFlapListeners

setmetatable(Flappy, {
    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, Flappy)
        self:new(...)
        return self
    end,
})

-- physics constants
local ACCELERATION = 2.5     -- the gravity's strength
local MAX_VELOCITY = 0.95    -- the max speed with which Flappy can fall
local JUMP_VELOCITY = -0.75  -- the power with which Flappy jumps

-- animation constants
local JUMP_TILT_ANGLE = 20         -- degrees - think trigonometric circle
local MAX_DIVE_TILT_ANGLE = -40    -- degrees (= 320 degrees)
local IDLE_ANIMATION_MAX_Y = 0.02  -- the Y offset from the default position
local IDLE_ANIMATION_SPEED = 0.06  -- how fast the idle animation behaves
local FLAP_ANIMATION_SEC = 0.120   -- time (120 ms) for each animation frame


------- INTERFACE -----------------------------------------------------------------------

local FlappyFlapListener = {}
FlappyFlapListener.__index = FlappyFlapListener

Flappy['FlappyFlapListener'] = FlappyFlapListener

setmetatable(FlappyFlapListener, {
    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, FlappyFlapListener)
        return self
    end,
})

function FlappyFlapListener:onFlappyFlap()
    -- implement me!
end


------- PUBLIC METHODS ------------------------------------------------------------------

function Flappy:new(scalePosX, scalePosY)
    logger.debug('Flappy: new: scalePosX is', scalePosX, 'scalePosY is', scalePosY)

    self.displayWidth = love.graphics.getWidth()
    self.displayHeight = love.graphics.getHeight()

    -- scaling physics with display resolution
    self.acceleration = ACCELERATION * self.displayHeight
    self.maxVelocity = MAX_VELOCITY * self.displayHeight
    self.jumpVelocity = JUMP_VELOCITY * self.displayHeight
    self.idleAnimationMaxY = IDLE_ANIMATION_MAX_Y * self.displayHeight
    self.idleAnimationSpeed = IDLE_ANIMATION_SPEED * self.displayHeight

    -- loading flappy assets
    self.FLAPPY_UP_IMAGE = g_ResManager.FLAPPY_UP_IMAGE
    self.FLAPPY_IMAGES = g_ResManager.FLAPPY_IMAGES

    self.image = self.FLAPPY_IMAGES[1]
    self.defaultX = math.floor(scalePosX * self.displayWidth)
    self.defaultY = math.floor(scalePosY * self.displayHeight)

    -- setting Flappy's default values
    self.velocity = 0
    self.idleDirection = -1
    self.animationMs = 0
    self.x = self.defaultX
    self.y = self.defaultY
    self.r = nil
    self.sx = nil
    self.sy = nil
    self.ox = self.image:getWidth() / 2
    self.oy = self.image:getHeight() / 2
    self.kx = nil
    self.k = nil

    self.flappyFlapListeners = {}
end

function Flappy:idleAnimation(dt)
    --[[
    This is the update method used by IntroState and NewGameState.
    It simply moves Flappy up and down.
    ]]--

    -- raise or lower flappy
    self.y = self.y + self.idleDirection * dt * self.idleAnimationSpeed
    self.y = utils.round(self.y, 2)  -- normalization to 2 decimal points

    flapAnimation(self, dt)

    -- change direction to UP/DOWN
    if self.y <= self.defaultY - self.idleAnimationMaxY then
        self.idleDirection = 1   -- switch to going down on Y
    elseif self.y >= self.defaultY + self.idleAnimationMaxY then
        self.idleDirection = -1  -- switch to going up on Y
    end
end

function Flappy:update(dt)
    --[[
    This is the update method used by FlappyFlyingState.
    It simulates gravity and performs flap and dive animations.
    ]]--

    -- simplistic simulation of gravity
    self.y = self.y + dt * self.velocity  -- time based Y position update
    self.y = utils.round(self.y, 2)  -- normalization to 2 decimal points

    -- time based velocity update with truncation
    self.velocity = self.velocity + dt * self.acceleration
    self.velocity = math.min(self.velocity, self.maxVelocity)

    -- perform the flap and dive animation
    -- these can be turned OFF by simply commenting the lines below
    flapAnimation(self, dt)
    diveAnimation(self)
end

function Flappy:draw()
    love.graphics.draw(
        self.image, self.x, self.y, self.r, self.sx, self.sy,
        self.ox, self.oy, self.kx, self.k
    )
end

function Flappy:flap()
    --[[
    This method is used by FlappyFlyingState's controls and is
    called whenever the player presses the apropriate key.
    ]]--

    -- staying alive, staying alive, flap flap flap flap
    if self.y > 0 then  -- do not go above screen
        self.velocity = self.jumpVelocity
        callFlappyFlapListeners(self)
    end
end

function Flappy:addFlappyFlapListener(listener)
    -- if not utils.instanceOf(listener, FlappyFlapListener) then  -- TODO: enable and fix this
    --     logger.error(
    --         'FATAL ERROR: Flappy: addFlappyFlapListener:',
    --         'Given listener is not an instance of FlappyFlapListener'
    --     )
    --     return false
    -- end
    table.insert(self.flappyFlapListeners, listener)
end


------- PRIVATE METHODS -----------------------------------------------------------------

function flapAnimation(self, dt)
    self.animationMs = (self.animationMs + dt) %
                       (#self.FLAPPY_IMAGES * FLAP_ANIMATION_SEC)
    self.image = getCurrentFlappyImage(self)
end

function diveAnimation(self)
    -- TODO: performance optimisations
    if self.velocity <= 0 then
        -- tilt flappy to the jump angle as long as he is gaining altitude
        self.r = JUMP_TILT_ANGLE
    else
        -- as soon as flappy starts falling, calculate the tilt angle (range
        -- [jump, max_dive]) corresponding to the current velocity, i.e. half
        -- of max velocity = mid-angle between [jump, max_dive]
        self.r = (self.velocity / self.maxVelocity) *
                 (MAX_DIVE_TILT_ANGLE - JUMP_TILT_ANGLE) + JUMP_TILT_ANGLE
    end
    self.r = utils.degreesToRadians(self.r * -1)
end

function getCurrentFlappyImage(self)
    local index = math.ceil(self.animationMs / FLAP_ANIMATION_SEC)
    return self.FLAPPY_IMAGES[index]
end

function callFlappyFlapListeners(self)
    for _, listener in ipairs(self.flappyFlapListeners) do
        listener:onFlappyFlap()
    end
end


return Flappy
