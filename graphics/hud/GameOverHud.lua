--[[
GameOverHud.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

A collection of HUDs specific to each individual Gamestate.
]]--


local HudTemplate = require 'graphics.hud.HudTemplate'


------- CLASS ---------------------------------------------------------------------------

local GameOverHud = {}
GameOverHud.__index = GameOverHud

setmetatable(GameOverHud, {
    -- this is what makes the inheritance work
    __index = HudTemplate,

    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, GameOverHud)
        self:new(...)
        return self
    end,
})

------- PUBLIC METHODS ------------------------------------------------------------------

function GameOverHud:new(lastScore, bestScore)
    HudTemplate.new(self)

    -- parameters defining the Y position of the texts
    self.TITLE_Y = 0.2
    self.SCORE_Y = 0.35
    self.BEST_SCORE_Y = 0.45
    self.HINT_Y = 0.65

    self.titleText = 'Game Over'
    self.scoreText = 'Score ' .. tostring(lastScore)
    self.bestScoreText = 'Best Score ' .. tostring(bestScore)
    self.hintText = 'Press [SPACE] to play again!'

    self.titleTextY = self.displayHeight * self.TITLE_Y
    self.scoreTextY = self.displayHeight * self.SCORE_Y
    self.bestScoreTextY = self.displayHeight * self.BEST_SCORE_Y
    self.hintTextY = self.displayHeight * self.HINT_Y
end

function GameOverHud:draw()
    HudTemplate.draw(self)

    self:drawText(
        self.titleText, self.TITLE_FONT, self.ORANGE, 'center', 0, self.titleTextY
    )
    self:drawText(
        self.scoreText, self.SCORE_FONT, self.WHITE, 'center', 0, self.scoreTextY
    )
    self:drawText(
        self.bestScoreText, self.SCORE_FONT, self.WHITE, 'center', 0, self.bestScoreTextY
    )
    self:drawText(
        self.hintText, self.HINT_FONT, self.WHITE, 'center', 0, self.hintTextY
    )
end


return GameOverHud
