--[[
NewGameHud.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

A collection of HUDs specific to each individual Gamestate.
]]--


local HudTemplate = require 'graphics.hud.HudTemplate'


------- CLASS ---------------------------------------------------------------------------

local NewGameHud = {}
NewGameHud.__index = NewGameHud

setmetatable(NewGameHud, {
    -- this is what makes the inheritance work
    __index = HudTemplate,

    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, NewGameHud)
        self:new(...)
        return self
    end,
})


------- PUBLIC METHODS ------------------------------------------------------------------

function NewGameHud:new()
    HudTemplate.new(self)

    -- parameters defining the Y position of the texts
    self.TITLE_Y = 0.2
    self.HINT_Y = 0.5

    self.titleText = 'New Game'
    self.hintText = 'Press [SPACE] to start!'

    self.titleTextY = self.displayHeight * self.TITLE_Y
    self.hintTextY = self.displayHeight * self.HINT_Y
end

function NewGameHud:draw()
    HudTemplate.draw(self)

    self:drawText(
        self.titleText, self.TITLE_FONT, self.WHITE, 'center', 0, self.titleTextY
    )
    self:drawText(
        self.hintText, self.HINT_FONT, self.WHITE, 'center', 0, self.hintTextY
    )
end


return NewGameHud
