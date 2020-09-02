--[[
DisplayManager.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2


]]--


local GamestateChangeListener = require 'core.GamestateManager'['GamestateChangeListener']
local IntroHud = require 'graphics.hud.IntroHud'
local NewGameHud = require 'graphics.hud.NewGameHud'
local FlappyFlyingHud = require 'graphics.hud.FlappyFlyingHud'
local GameOverHud = require 'graphics.hud.GameOverHud'
local logger = require 'system.logger'
local overscan = require 'common.system.overscan'

local love = love


------- CLASS ---------------------------------------------------------------------------

local DisplayManager = {}
DisplayManager.__index = DisplayManager

-- interfaces this class implements
local mGamestateChangeListener

-- local function forward declaration
local randomiseBackground

setmetatable(DisplayManager, {
    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, DisplayManager)
        self:new(...)
        return self
    end,
})


------- PUBLIC METHODS ------------------------------------------------------------------

function DisplayManager:new()
    randomiseBackground(self)
end

function DisplayManager:setup(gamestate)
    self.gamestate = gamestate
    gamestate:addGamestateChangeListener(mGamestateChangeListener(self))

    love.mouse.setVisible(false)
end

function DisplayManager:draw(drawables)  -- TODO: optimise drawing pipeline?
    overscan:adjust()
    love.graphics.draw(self.background, 0, self.backgroundY)

    for _, drawable in ipairs(drawables) do
        drawable:draw()
    end

    -- draw the HUD on top of everything
    self.hud:draw()
    love.graphics.pop()
end


------- PRIVATE METHODS -----------------------------------------------------------------

function randomiseBackground(self)
    -- pick a random background from the list
    local index = math.random(#g_ResManager.BACKGROUND_IMAGES)
    local backgroundImage = g_ResManager.BACKGROUND_IMAGES[index]
    local backgroundColor = g_ResManager.BACKGROUND_COLORS[index]

    local numBackgroundImages = math.ceil(
        love.graphics.getWidth() / backgroundImage:getWidth()
    )
    self.backgroundY = love.graphics.getHeight() * 0.74 -
                       backgroundImage:getHeight() / 2.0

    logger.debug(
        'Display: randomiseBackground: numBackgroundImages is',
        numBackgroundImages, 'backgroundY is', self.backgroundY
    )

    self.background = love.graphics.newCanvas(
        love.graphics.getWidth(), backgroundImage:getHeight()
    )
    love.graphics.setCanvas(self.background)
    for i = 0, numBackgroundImages - 1 do
        local x = math.floor(i * backgroundImage:getWidth())
        love.graphics.draw(backgroundImage, x, 0)
    end
    love.graphics.setCanvas()

    love.graphics.setBackgroundColor(backgroundColor)
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
        'DisplayManager: mGamestateChangeListener: onIntro: Setting the IntroHUD'
    )
    self.parent.hud = IntroHud()
end

function mGamestateChangeListener:onNewGame(gamestate)
    logger.debug(
        'DisplayManager: mGamestateChangeListener: onNewGame: Setting the NewGameHud'
    )
    self.parent.hud = NewGameHud()
end

function mGamestateChangeListener:onFlappyFlying(gamestate)
    logger.debug(
        'DisplayManager: mGamestateChangeListener: onFlappyFlying:',
        'Setting the FlappyFlyingHud'
    )
    self.parent.hud = FlappyFlyingHud(gamestate)
end

function mGamestateChangeListener:onGameOver(gamestate)
    logger.debug(
        'DisplayManager: mGamestateChangeListener: onGameOver: Setting the GameOverHud'
    )
    self.parent.hud = GameOverHud(gamestate:getLastScore(), gamestate:getBestScore())
end


return DisplayManager
