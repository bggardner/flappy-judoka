--[[
SoundManager.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

This is Sound effects class responsible for all sound playbacks.
]]--


local GamestateChangeListener = require 'core.GamestateManager'['GamestateChangeListener']
local ScoreChangedListener = require 'core.gamestates.FlappyFlyingState'['ScoreChangedListener']
local FlappyFlapListener = require 'actors.Flappy'['FlappyFlapListener']
local logger = require 'system.logger'

local love = love


------- CLASS ---------------------------------------------------------------------------

local SoundManager = {}
SoundManager.__index = SoundManager

-- interfaces this class implements
local mGamestateChangeListener, mScoreChangedListener, mFlappyFlapListener

setmetatable(SoundManager, {
    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, SoundManager)
        self:new(...)
        return self
    end,
})


------- PUBLIC METHODS ------------------------------------------------------------------

function SoundManager:new()
    self.startGameSound = g_ResManager.START_GAME_SOUND
    self.gameOverSound = g_ResManager.GAME_OVER_SOUND
    self.flappyFlapSound = g_ResManager.FLAPPY_FLAP_SOUND
    self.gainedPointSound = g_ResManager.GAINED_POINT_SOUND
end

function SoundManager:setup(gamestate)
    gamestate:addGamestateChangeListener(mGamestateChangeListener(self))
end


------- IMPLEMENTS ----------------------------------------------------------------------

mGamestateChangeListener = {}
mGamestateChangeListener.__index = mGamestateChangeListener

setmetatable(mGamestateChangeListener, {
    -- this is what makes the inheritance work
    __index = GamestateChangeListener,

    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, mGamestateChangeListener)
        self:new(...)
        return self
    end,
})

function mGamestateChangeListener:new(parent)
    self.parent = parent
end

function mGamestateChangeListener:onIntro(gamestate)
    logger.debug(
        'SoundManager: mGamestateChangeListener: onIntro:',
        'Playing startGameSound'
    )
    love.audio.play(self.parent.startGameSound)
end

function mGamestateChangeListener:onNewGame(gamestate)
    -- pass
end

function mGamestateChangeListener:onFlappyFlying(gamestate)
    logger.debug(
        'SoundManager: mGamestateChangeListener: onFlappyFlying:',
        'Setting ScoreChangedListener and FlappyFlapListener'
    )
    gamestate:addScoreChangedListener(mScoreChangedListener(self.parent))
    gamestate.flappy:addFlappyFlapListener(mFlappyFlapListener(self.parent))  -- TODO: fix accessing class variable
end

function mGamestateChangeListener:onGameOver(gamestate)
    logger.debug(
        'SoundManager: mGamestateChangeListener: onGameOver:',
        'Playing gameOverSound'
    )
    love.audio.play(self.parent.gameOverSound)
end


------- IMPLEMENTS ----------------------------------------------------------------------

mScoreChangedListener = {}
mScoreChangedListener.__index = mScoreChangedListener

setmetatable(mScoreChangedListener, {
    -- this is what makes the inheritance work
    __index = ScoreChangedListener,

    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, mScoreChangedListener)
        self:new(...)
        return self
    end,
})

function mScoreChangedListener:new(parent)
    self.parent = parent
end

function mScoreChangedListener:onScoreChanged(score)
    logger.debug(
        'SoundManager: mScoreChangedListener: onScoreChanged:',
        'Playing gainedPointSound'
    )
    love.audio.play(self.parent.gainedPointSound)
end


------- IMPLEMENTS ----------------------------------------------------------------------

mFlappyFlapListener = {}
mFlappyFlapListener.__index = mFlappyFlapListener

setmetatable(mFlappyFlapListener, {
    -- this is what makes the inheritance work
    __index = FlappyFlapListener,

    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, mFlappyFlapListener)
        self:new(...)
        return self
    end,
})

function mFlappyFlapListener:new(parent)
    self.parent = parent
end

function mFlappyFlapListener:onFlappyFlap()
    logger.debug(
        'SoundManager: mFlappyFlapListener: onFlappyFlap:',
        'Playing flappyFlapSound'
    )
    love.audio.play(self.parent.flappyFlapSound)
end


return SoundManager
