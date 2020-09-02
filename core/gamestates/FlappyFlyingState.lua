--[[
FlappyFlyingState.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

The heart of the game logic is in a form of a Finite State Machine.

Each individual state has its own controls and actors it updates.
Ultimately, each individual state dictates what actors the Display renders.

The FSM is: IntroState > NewGameState > FlappyFlyingState > GameOverState >
NewGameState > ...
]]--


local StateTemplate = require 'core.gamestates.StateTemplate'
local logger = require 'system.logger'
local utils = require 'system.utils'

local love = love


------- CLASS ---------------------------------------------------------------------------

local FlappyFlyingState = {['ScoreChangedListener'] = {}}
FlappyFlyingState.__index = FlappyFlyingState

-- local function forward declaration
local updateScore, callScoreChangedListeners

setmetatable(FlappyFlyingState, {
    -- this is what makes the inheritance work
    __index = StateTemplate,

    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, FlappyFlyingState)
        self:new(...)
        return self
    end,
})

-- controls
local FLAP_KEYS = {'up', 'space'}        -- keyboard controls
local FLAP_BUTTONS = {'x', 'y', 'dpup'}  -- gamepad controls


------- INTERFACE -----------------------------------------------------------------------

local ScoreChangedListener = {}
ScoreChangedListener.__index = ScoreChangedListener

FlappyFlyingState['ScoreChangedListener'] = ScoreChangedListener

setmetatable(ScoreChangedListener, {
    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, ScoreChangedListener)
        return self
    end,
})

function ScoreChangedListener:onScoreChanged(score)
    -- implement me!
end


------- PUBLIC METHODS ------------------------------------------------------------------

function FlappyFlyingState:new(gamestateManager, flappy, pipes, ground)
    StateTemplate.new(self, gamestateManager)

    self.flappy = flappy
    self.pipes = pipes
    self.ground = ground

    self.isFlappyHitPipe = false  -- flag for falling animation after pipe hit
    self.score = 0                -- the number of pipes flappy passed through
    self.countedPipe = nil        -- pipe we are currently going through

    self.scoreChangedListeners = {}
end

function FlappyFlyingState:update(dt)
    -- keep moving the pipes and ground as long as flappy did not crash
    if not self.isFlappyHitPipe then
        self.pipes:update(dt)
        self.ground:update(dt)
    end

    -- update flappy's Y position, simulating gravity
    self.flappy:update(dt)
    updateScore(self)

    -- checking if flappy smashed into the 2 pipes in front of him
    for _, pipe in ipairs(self.pipes:getFlappysNextPipes()) do
        if utils.checkCollision(self.flappy, pipe) then
            self.isFlappyHitPipe = true
            break
        end
    end

    -- checking if flappy hit the ground right underneath him
    -- switch to GameOver only when Flappy hits the ground
    if utils.checkCollision(
       self.flappy, self.ground:getGroundUnderFlappy()) then

        self.gamestateManager:setCurrentState(
            self.gamestateManager.GAME_OVER_STATE_ID,
            self.gamestateManager, self.flappy, self.pipes, self.ground, self.score
        )
    end

    -- returning what we actually want to draw
    return {self.flappy, self.pipes, self.ground}
end

function FlappyFlyingState:controls(keypress, touchpress, joystick)
    if keypress and love.keyboard.isDown(unpack(FLAP_KEYS)) or
       joystick and joystick:isGamepadDown(unpack(FLAP_BUTTONS)) or
       touchpress then

        logger.debug('FlappyFlyingState: controls: Pressed a FLAP key')
        if not self.isFlappyHitPipe then
            self.flappy:flap()
        end
    end
end

function FlappyFlyingState:addScoreChangedListener(listener)
    -- if not utils.instanceOf(listener, ScoreChangedListener) then  -- TODO: enable and fix this
    --     logger.error('FlappyFlyingState: addScoreChangedListener:',
    --         'Given listener is not an instance of ScoreChangedListener!')
    --     return false
    -- end
    table.insert(self.scoreChangedListeners, listener)
end


------- PRIVATE METHODS -----------------------------------------------------------------

function updateScore(self)
    local flappyToPipe

    for i = 1, #self.pipes.pipesList, 2 do  -- TODO: fix access to instance variable
        flappyToPipe = self.flappy.x - self.pipes.pipesList[i].x  -- TODO: fix access to instance variable

        if flappyToPipe > 0 and flappyToPipe < self.pipes.pipeWidth then
            if self.pipes.pipesList[i] ~= self.countedPipe then
                self.countedPipe = self.pipes.pipesList[i]
                self.score = self.score + 1
                callScoreChangedListeners(self)
                break
            end
        else
            break
        end
    end
end

function callScoreChangedListeners(self)
    for _, listener in ipairs(self.scoreChangedListeners) do
        listener:onScoreChanged(self.score)
    end
end


return FlappyFlyingState
