--[[
IntroState.lua

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
local PipeManager = require 'actors.PipeManager'
local GroundManager = require 'actors.GroundManager'
local logger = require 'system.logger'

local love = love


------- CLASS ---------------------------------------------------------------------------

local IntroState = {}
IntroState.__index = IntroState

setmetatable(IntroState, {
    -- this is what makes the inheritance work
    __index = StateTemplate,

    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, IntroState)
        self:new(...)
        return self
    end,
})

-- controls
local START_KEYS = {'up', 'space'}        -- keyboard controls
local START_BUTTONS = {'x', 'y', 'dpup'}  -- gamepad controls


------- PUBLIC METHODS ------------------------------------------------------------------

function IntroState:new(gamestateManager)
    StateTemplate.new(self, gamestateManager)

    self.flappy = Flappy(0.5, 0.65)  -- passing X, Y to Flappy
    self.ground = GroundManager()

    -- create the pipes here to avoid generation (stutter) in FlappyFlyingState
    self.pipes = PipeManager()
end

function IntroState:update(dt)
    self.flappy:idleAnimation(dt)
    self.ground:update(dt)

    -- returning what we actually want to draw
    return {self.flappy, self.ground}
end

function IntroState:controls(keypress, touchpress, joystick)
    if keypress and love.keyboard.isDown(unpack(START_KEYS)) or
       joystick and joystick:isGamepadDown(unpack(START_BUTTONS)) or
       touchpress then

        logger.debug('IntroState: controls: Pressed a START key')
        self.gamestateManager:setCurrentState(
            self.gamestateManager.NEW_GAME_STATE_ID,
            self.gamestateManager, self.pipes
        )
        return true  -- state has changed, do not call updateState
    end
    return false
end


return IntroState
