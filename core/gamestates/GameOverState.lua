--[[
GameOverState.lua

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

local CommonUtils = require 'common.system.utils'

local love = love


------- CLASS ---------------------------------------------------------------------------

local GameOverState = {}
GameOverState.__index = GameOverState

setmetatable(GameOverState, {
    -- this is what makes the inheritance work
    __index = StateTemplate,

    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, GameOverState)
        self:new(...)
        return self
    end,
})

-- controls
local START_KEYS = {'up', 'space'}        -- keyboard controls
local START_BUTTONS = {'x', 'y', 'dpup'}  -- gamepad controls


------- PUBLIC METHODS ------------------------------------------------------------------

function GameOverState:new(gamestateManager, flappy, pipes, ground, score)
    StateTemplate.new(self, gamestateManager)

    self.flappy = flappy
    self.pipes = pipes
    self.ground = ground
    self.score = score

    logger.info('GameOverState: new: Score is', score)
    CommonUtils.trackData('lua-flappy-judoka-score', 'score', score)
    g_ResManager:getSaveData().lastScore = score

    self.bestScore = math.max(
        self.score,
        g_ResManager:getSaveData().bestScore,
        CommonUtils.getMinigamesVariable('flappy_judoka_best_score')
    )

    g_ResManager:getSaveData().bestScore = self.bestScore
end

function GameOverState:update()
    return {self.flappy, self.pipes, self.ground}
end

function GameOverState:controls(keypress, touchpress, joystick)
    if keypress and love.keyboard.isDown(unpack(START_KEYS)) or
       joystick and joystick:isGamepadDown(unpack(START_BUTTONS)) or
       touchpress then

        logger.debug('GameOverState: controls: Pressed a START key')
        self.gamestateManager:setCurrentState(
            self.gamestateManager.NEW_GAME_STATE_ID,
            self.gamestateManager, self.pipes
        )
    end
end

function GameOverState:getLastScore()
    return self.score
end

function GameOverState:getBestScore()
    return self.bestScore
end


return GameOverState
