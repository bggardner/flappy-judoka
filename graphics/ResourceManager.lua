--[[
ResourceManager.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

A static object to load all game assets after the Display initialisation.
]]--


local Savefile = require 'system.savefile'
local logger = require 'system.logger'
local utils = require 'system.utils'

local love = love


------- CLASS ---------------------------------------------------------------------------

local ResourceManager = {}
ResourceManager.__index = ResourceManager

-- local function forward declaration
local load, resize, group, aspectRatioScale

setmetatable(ResourceManager, {
    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, ResourceManager)
        self:new(...)
        return self
    end,
})


------- PUBLIC METHODS ------------------------------------------------------------------

function ResourceManager:new()
    -- % of display height
    self.FLAPPY_SCALE = 0.13
    -- the very top part of the pipe
    self.PIPE_TOP_SCALE = 0.20
    -- pipe height = 60% of display height
    self.PIPE_BODY_SCALE = 0.60
    -- background skyline = 30% of display height
    self.BACKGROUND_SCALE = 0.28
    -- animated ground = 15% of display height (with + .03 for floating point precision)
    self.GROUND_SCALE = 0.14
    -- the esc image height = 4% of display height
    self.ESC_SCALE = 0.04

    self.displayWidth = love.graphics.getWidth()
    self.displayHeight = love.graphics.getHeight()

    self.savefile = Savefile.create()
    self.savefile:load()

    load(self)
    resize(self)
    group(self)
end

function ResourceManager:save()
    self.savefile:save()
end

function ResourceManager:getSaveData()
    return self.savefile:getData()
end


------- PRIVATE METHODS -----------------------------------------------------------------

function load(self)
    self.FLAPPY_UP_IMAGE = utils.loadImage('flappy-up')
    self.FLAPPY_MIDDLE_IMAGE = utils.loadImage('flappy-middle')
    self.FLAPPY_DOWN_IMAGE = utils.loadImage('flappy-down')

    self.PIPE_TOP_IMAGE = utils.loadImage('yellow-cable-top')
    self.PIPE_TOP_IMAGE:setFilter('nearest', 'nearest')
    self.PIPE_BODY_IMAGE = utils.loadImage('yellow-cable-body')
    self.PIPE_BODY_IMAGE:setFilter('nearest', 'nearest')

    self.BACKGROUND_DAY_COLOR = {50 / 255, 195 / 255, 223 / 255}  -- r, g, b
    self.BACKGROUND_DAY_IMAGE = utils.loadImage('background')
    self.BACKGROUND_DAY_IMAGE:setFilter('nearest', 'nearest')

    self.GROUND_IMAGE = utils.loadImage('ground')
    self.GROUND_IMAGE:setFilter('nearest', 'nearest')

    self.ESC_IMAGE = utils.loadImage('esc-exit')
    self.ESC_IMAGE:setFilter('nearest', 'nearest')

    -- sounds downloaded under CCO License from http://www.freesound.org/
    -- some of these have been edited to fit the game
    self.GAME_OVER_SOUND = utils.loadSound('game-over')
    self.START_GAME_SOUND = utils.loadSound('game-start')
    self.FLAPPY_FLAP_SOUND = utils.loadSound('jump')
    self.GAINED_POINT_SOUND = utils.loadSound('point')
end

function resize(self)
    self.FLAPPY_UP_IMAGE = aspectRatioScale(self, self.FLAPPY_UP_IMAGE, self.FLAPPY_SCALE)
    self.FLAPPY_MIDDLE_IMAGE = aspectRatioScale(self, self.FLAPPY_MIDDLE_IMAGE, self.FLAPPY_SCALE)
    self.FLAPPY_DOWN_IMAGE = aspectRatioScale(self, self.FLAPPY_DOWN_IMAGE, self.FLAPPY_SCALE)

    self.PIPE_TOP_IMAGE = aspectRatioScale(self, self.PIPE_TOP_IMAGE, self.PIPE_TOP_SCALE)

    -- assembling the pipes from TOP, BODY by stretching the body
    -- the bottom pipe will be the fliped top one
    local pipeTopWidth = self.PIPE_TOP_IMAGE:getWidth()
    local pipeTopHeight = self.displayHeight * self.PIPE_BODY_SCALE
    logger.debug('ResourceManager: resize: pipeTopWidth', pipeTopWidth, 'pipeTopHeight', pipeTopHeight)
    local pipeTop = love.graphics.newCanvas(pipeTopWidth, pipeTopHeight)
    love.graphics.setCanvas(pipeTop)
    love.graphics.draw(self.PIPE_BODY_IMAGE,
        pipeTopWidth / 2 - self.PIPE_BODY_IMAGE:getWidth() / 2, 0,
        0, 1, pipeTopHeight)
    love.graphics.draw(self.PIPE_TOP_IMAGE,
        0, pipeTopHeight - self.PIPE_TOP_IMAGE:getHeight(), 0)
    love.graphics.setCanvas()
    self.PIPE_TOP_IMAGE = pipeTop

    self.PIPE_BOTTOM_IMAGE = love.graphics.newCanvas(
        self.PIPE_TOP_IMAGE:getWidth(), self.PIPE_TOP_IMAGE:getHeight()
    )
    love.graphics.setCanvas(self.PIPE_BOTTOM_IMAGE)
    love.graphics.draw(self.PIPE_TOP_IMAGE, self.PIPE_TOP_IMAGE:getWidth() / 2,
        self.PIPE_TOP_IMAGE:getHeight() / 2, utils.degreesToRadians(180), -1, 1,
        self.PIPE_TOP_IMAGE:getWidth() / 2,
        self.PIPE_TOP_IMAGE:getHeight() / 2)
    love.graphics.setCanvas()

    self.BACKGROUND_DAY_IMAGE = aspectRatioScale(self, self.BACKGROUND_DAY_IMAGE, self.BACKGROUND_SCALE)

    self.GROUND_IMAGE = aspectRatioScale(self, self.GROUND_IMAGE, self.GROUND_SCALE)

    self.ESC_IMAGE = aspectRatioScale(self, self.ESC_IMAGE, self.ESC_SCALE)
end

function group(self)
    self.FLAPPY_IMAGES = {
        self.FLAPPY_UP_IMAGE,
        self.FLAPPY_MIDDLE_IMAGE,
        self.FLAPPY_DOWN_IMAGE
    }

    self.BACKGROUND_IMAGES = {
        self.BACKGROUND_DAY_IMAGE,
        -- self.BACKGROUND_NIGHT_IMAGE
    }

    self.BACKGROUND_COLORS = {
        self.BACKGROUND_DAY_COLOR,
        -- self.BACKGROUND_NIGHT_COLOR
    }
end

function aspectRatioScale(self, image, scaleRatio)
    local height = self.displayHeight * scaleRatio
    local width = image:getWidth() * (height / image:getHeight())
    local sx = width / image:getWidth()
    local sy = height / image:getHeight()

    local canvas = love.graphics.newCanvas(width, height)
    love.graphics.setCanvas(canvas)
    love.graphics.draw(image, 0, 0, nil, sx, sy)
    love.graphics.setCanvas()

    return canvas
end

return ResourceManager
