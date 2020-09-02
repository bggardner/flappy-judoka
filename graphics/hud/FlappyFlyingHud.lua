--[[
FlappyFlyingHud.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

A collection of HUDs specific to each individual Gamestate.
]]--


local HudTemplate = require 'graphics.hud.HudTemplate'
local ScoreChangedListener = require 'core.gamestates.FlappyFlyingState'['ScoreChangedListener']

local logger = require 'system.logger'


------- CLASS ---------------------------------------------------------------------------

local FlappyFlyingHud = {}
FlappyFlyingHud.__index = FlappyFlyingHud

-- interfaces this class implements
local mScoreChangedListener

setmetatable(FlappyFlyingHud, {
    -- this is what makes the inheritance work
    __index = HudTemplate,

    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, FlappyFlyingHud)
        self:new(...)
        return self
    end,
})


------- PUBLIC METHODS ------------------------------------------------------------------

function FlappyFlyingHud:new(gamestate)
    HudTemplate.new(self)

    -- parameters defining the Y position of the texts
    self.SCORE_Y = 0.1

    self.scoreText = '0'
    self.scoreTextY = self.displayHeight * self.SCORE_Y

    gamestate:addScoreChangedListener(mScoreChangedListener(self))
end

function FlappyFlyingHud:draw()
    HudTemplate.draw(self)

    self:drawText(
        self.scoreText, self.SCORE_FONT, self.WHITE, 'center', 0, self.scoreTextY
    )
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
    self.parent.scoreText = tostring(score)
    logger.debug(
        'FlappyFlyingHud: mScoreChangedListener: onScoreChanged: score is',
        self.parent.scoreText
    )
end


return FlappyFlyingHud
