--[[
IntroHud.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

A collection of HUDs specific to each individual Gamestate.
]]--


local HudTemplate = require 'graphics.hud.HudTemplate'


------- CLASS ---------------------------------------------------------------------------

local IntroHud = {}
IntroHud.__index = IntroHud

setmetatable(IntroHud, {
    -- this is what makes the inheritance work
    __index = HudTemplate,

    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, IntroHud)
        self:new(...)
        return self
    end,
})


------- PUBLIC METHODS ------------------------------------------------------------------

function IntroHud:new()
    HudTemplate.new(self)

    -- parameters defining the Y position of the texts
    self.BANNER_Y = 0.25
    self.HINT_Y = 0.4

    self.bannerText = 'FlappyJudoka'
    self.hintText = 'Press [SPACE] to start!'

    self.bannerTextY = self.displayHeight * self.BANNER_Y
    self.hintTextY = self.displayHeight * self.HINT_Y
end

function IntroHud:draw()
    HudTemplate.draw(self)

    self:drawText(
        self.bannerText, self.BANNER_FONT, self.ORANGE, 'center',
        0, self.bannerTextY
    )
    self:drawText(
        self.hintText, self.HINT_FONT, self.WHITE, 'center', 0, self.hintTextY
    )
end


return IntroHud
