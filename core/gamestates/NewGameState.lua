--[[
NewGameState.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

The heart of the game logic is in a form of a Finite State Machine.

Each individual state has its own controls and actors it updates.
Ultimately, each individual state dictates what actors the Display renders.

The FSM is: IntroState > NewGameState > FlappyFlyingState > GameOverState >
NewGameState > ...
]]--


local StateTemplate = require 'core.gamestates.StateTemplate'
local Flappy = require 'actors.Flappy'
local GroundManager = require 'actors.GroundManager'
local logger = require 'system.logger'

local love = love


------- CLASS ---------------------------------------------------------------------------

local NewGameState = {}
NewGameState.__index = NewGameState

setmetatable(NewGameState, {
    -- this is what makes the inheritance work
    __index = StateTemplate,

    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, NewGameState)
        self:new(...)
        return self
    end,
})

-- controls
local START_KEYS = {'up', 'space'}        -- keyboard controls
local START_BUTTONS = {'x', 'y', 'dpup'}  -- gamepad controls


------- PUBLIC METHODS ------------------------------------------------------------------

function NewGameState:new(gamestateManager, pipes)
    StateTemplate.new(self, gamestateManager)

    self.pipes = pipes

    self.flappy = Flappy(0.2, 0.4)  -- passing X,Y to Flappy
    self.ground = GroundManager()
    self.pipes:resetPipes()
end

function NewGameState:update(dt)
    self.flappy:idleAnimation(dt)
    self.ground:update(dt)

    -- returning what we actually want to draw
    return {self.flappy, self.ground}
end

function NewGameState:controls(keypress, touchpress, joystick)
    if keypress and love.keyboard.isDown(unpack(START_KEYS)) or
       joystick and joystick:isGamepadDown(unpack(START_BUTTONS)) or
       touchpress then

        logger.debug('NewGameState: controls: Pressed a START key')
        self.gamestateManager:setCurrentState(
            self.gamestateManager.FLAPPY_FLYING_STATE_ID,
            self.gamestateManager, self.flappy, self.pipes, self.ground
        )
        return true  -- state has changed, do not call updateState
    end
    return false
end


return NewGameState
