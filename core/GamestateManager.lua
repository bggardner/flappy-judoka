--[[
GamestateManager.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

This is the manager for the Gamestates. It updates the game logic and returns
what needs to be drawn on the Display. It also handles changing gamestates and
calling the appropriate interfaces.
]]--


local IntroState = require 'core.gamestates.IntroState'
local NewGameState = require 'core.gamestates.NewGameState'
local FlappyFlyingState = require 'core.gamestates.FlappyFlyingState'
local GameOverState = require 'core.gamestates.GameOverState'
local logger = require 'system.logger'


------- CLASS ---------------------------------------------------------------------------

local GamestateManager = {['GamestateChangeListener'] = {}}
GamestateManager.__index = GamestateManager

-- local function forward declaration
local callGamestateChangeListenersOnIntro, callGamestateChangeListenersOnNewGame
local callGamestateChangeListenersOnFlappyFlying, callGamestateChangeListenersOnGameOver

setmetatable(GamestateManager, {
    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, GamestateManager)
        self:new(...)
        return self
    end,
})


------- INTERFACE -----------------------------------------------------------------------

local GamestateChangeListener = {}
GamestateChangeListener.__index = GamestateChangeListener

GamestateManager['GamestateChangeListener'] = GamestateChangeListener

setmetatable(GamestateChangeListener, {
    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, GamestateChangeListener)
        return self
    end,
})

function GamestateChangeListener:onIntro(gamestate)
    -- implement me!
end

function GamestateChangeListener:onNewGame(gamestate)
    -- implement me!
end

function GamestateChangeListener:onFlappyFlying(gamestate)
    -- implement me!
end

function GamestateChangeListener:onGameOver(gamestate)
    -- implement me!
end


------- PUBLIC METHODS --------------------------------------------------------

function GamestateManager:new()
    self.INTRO_STATE_ID = 1
    self.NEW_GAME_STATE_ID = 2
    self.FLAPPY_FLYING_STATE_ID = 3
    self.GAME_OVER_STATE_ID = 4

    self.gamestateChangeNotifiers = {
        [self.INTRO_STATE_ID] = callGamestateChangeListenersOnIntro,
        [self.NEW_GAME_STATE_ID] = callGamestateChangeListenersOnNewGame,
        [self.FLAPPY_FLYING_STATE_ID] = callGamestateChangeListenersOnFlappyFlying,
        [self.GAME_OVER_STATE_ID] = callGamestateChangeListenersOnGameOver
    }

    self.gamestateChangeListeners = {}
end

function GamestateManager:load()
    self.gamestates = {
        [self.INTRO_STATE_ID] = IntroState,
        [self.NEW_GAME_STATE_ID] = NewGameState,
        [self.FLAPPY_FLYING_STATE_ID] = FlappyFlyingState,
        [self.GAME_OVER_STATE_ID] = GameOverState
    }

    self:setCurrentState(self.INTRO_STATE_ID, self)
end

function GamestateManager:update(dt)
    local drawables = self.currentState:update(dt)
    return drawables
end

function GamestateManager:keypressed(key)
    self.currentState:keypressed(key)
end

function GamestateManager:touchpressed(id, x, y)
    self.currentState:touchpressed()
end

function GamestateManager:gamepadpressed(joystick, button)
   self.currentState:gamepadpressed(joystick, button)
end

function GamestateManager:getCurrentState()
    return self.currentState
end

function GamestateManager:setCurrentState(stateId, ...)
    logger.debug('GamestateManager: setCurrentState: stateId is', stateId)
    self.currentState = self.gamestates[stateId](...)

    -- calling the appropriate state change notifier on the listeners
    self.gamestateChangeNotifiers[stateId](self)
end

function GamestateManager:addGamestateChangeListener(listener)
    -- if not utils.instanceOf(listener, self.GamestateChangeListener) then  -- TODO: enable and fix this
    --     logger.error(
    --         'GamestateManager: addGamestateChangeListenerq: Given',
    --         'listener is not an instance of GamestateChangeListener!'
    --     )
    --     return false
    -- end
    table.insert(self.gamestateChangeListeners, listener)
end


------- PRIVATE METHODS -------------------------------------------------------

function callGamestateChangeListenersOnIntro(self)
    for _, listener in ipairs(self.gamestateChangeListeners) do
        listener:onIntro(self.currentState)
    end
end

function callGamestateChangeListenersOnNewGame(self)
    for _, listener in ipairs(self.gamestateChangeListeners) do
        listener:onNewGame(self.currentState)
    end
end

function callGamestateChangeListenersOnFlappyFlying(self)
    for _, listener in ipairs(self.gamestateChangeListeners) do
        listener:onFlappyFlying(self.currentState)
    end
end

function callGamestateChangeListenersOnGameOver(self)
    for _, listener in ipairs(self.gamestateChangeListeners) do
        listener:onGameOver(self.currentState)
    end
end


return GamestateManager
