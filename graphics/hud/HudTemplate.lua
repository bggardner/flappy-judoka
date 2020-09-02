--[[
HudTemplate.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

A collection of HUDs specific to each individual Gamestate.
]]--


local paths = require 'system.paths'

local love = love


------- CLASS ---------------------------------------------------------------------------

local HudTemplate = {}
HudTemplate.__index = HudTemplate

setmetatable(HudTemplate, {
    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, HudTemplate)
        self:new(...)
        return self
    end,
})


------- PUBLIC METHODS ------------------------------------------------------------------

function HudTemplate:new()
    -- font size parameters  -- TODO: scale these based on display resolution
    self.BANNER_FONT_SIZE = 90
    self.SCORE_FONT_SIZE = 80
    self.TITLE_FONT_SIZE = 60
    self.HINT_FONT_SIZE = 30

    -- defining colors
    self.WHITE = {1, 1, 1}
    self.BLACK = {0, 0, 0}
    self.GRAY = {150 / 255, 150 / 255, 150 / 255}
    self.ORANGE = {255 / 255, 132 / 255, 42 / 255}

    -- parameters defining the Y position of the texts
    self.CONTROLS_HINT_X = 0.03
    self.CONTROLS_HINT_Y = 0.9

    -- setting up the font objects
    self.BANNER_FONT = love.graphics.newFont(
        paths.FONTS_DIR .. 'zx_spectrum-7_bold.ttf', self.BANNER_FONT_SIZE
    )
    self.SCORE_FONT = love.graphics.newFont(
        paths.FONTS_DIR .. 'zx_spectrum-7_bold.ttf', self.SCORE_FONT_SIZE
    )
    self.TITLE_FONT = love.graphics.newFont(
        paths.FONTS_DIR .. 'zx_spectrum-7_bold.ttf', self.TITLE_FONT_SIZE
    )
    self.HINT_FONT = love.graphics.newFont(
        paths.FONTS_DIR .. 'zx_spectrum-7_bold.ttf', self.HINT_FONT_SIZE
    )

    self.displayWidth = love.graphics.getWidth()
    self.displayHeight = love.graphics.getHeight()

    self.controlsHintText = '[SPACE] or [UP] to Jump'
    self.controlsHintTextX = self.displayWidth * self.CONTROLS_HINT_X
    self.controlsHintTextY = self.displayHeight * self.CONTROLS_HINT_Y

    self.quitHintText = '[ESC] or [Q] to Quit'
    self.quitHintTextX = self.displayWidth * self.CONTROLS_HINT_X
    self.quitHintTextY = self.displayHeight * self.CONTROLS_HINT_Y + 20
end

function HudTemplate:draw()
    -- on every frame, all subclasses will draw the controls + quit hints
    self:drawText(
        self.controlsHintText, self.HINT_FONT, self.WHITE, 'left',
        self.controlsHintTextX, self.controlsHintTextY
    )
    self:drawText(
        self.quitHintText, self.HINT_FONT, self.WHITE, 'left',
        self.quitHintTextX, self.quitHintTextY
    )

    love.graphics.draw(g_ResManager.ESC_IMAGE, 45, 45)
end

function HudTemplate:drawText(text, font, color, alignment, x, y)
    love.graphics.setFont(font)
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(color)
    love.graphics.printf(text, x, y, love.graphics.getWidth(), alignment)
    love.graphics.setColor(r, g, b, a)
end


return HudTemplate
