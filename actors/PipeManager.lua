--[[
PipeManager.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

This class is the top level manager for the "system" of pipes. It is used both by the
individual gamestates and the Display for rendering.

It defines how the pipe heights are randomised, as well as how the continuous pipe
barrier effect is achieved.

The system is configurable through the class constants below, which also scale
accordingly with the Display resolution.
]]--


local Pipe = require 'actors.Pipe'
local logger = require 'system.logger'

local love = love


------- CLASS ---------------------------------------------------------------------------

local PipeManager = {}
PipeManager.__index = PipeManager

-- local function forward declaration
local generatePipes, randomisePipePositions, updateDifficulty

setmetatable(PipeManager, {
    -- this handler allows you to get an instance without calling .new
    __call = function(cls, ...)
        local self = setmetatable({}, PipeManager)
        self:new(...)
        return self
    end,
})

-- parameters to configure pipe positions the values are percentages
-- of Display resolution
local PIPE_INIT_X = 1.3         -- from which X the pipes start
local PIPE_MIN_SPACING_X = 0.28 -- highest difficulty: distance between two pipes in X
local PIPE_MIN_SPACING_Y = 0.28 -- highest dif: distance between top pipe and bottom pipe
local PIPE_MAX_SPACING_X = 0.42 -- lowest dif: distance between two pipes in X
local PIPE_MAX_SPACING_Y = 0.42 -- lowest dif: distance between top pipe and bottom pipe
local PIPE_SPACING_DECREASE = 0.02 -- how much spacing decreases with difficulty

-- range in display height percentage for the pipe spacing center
local SPACING_FROM_Y = 0.25
local SPACING_TO_Y = 0.60

-- the number of pipes needed to fall off the screen in order to increase difficulty
local DIFFICULTY_CHANGE = 10


------- PUBLIC METHODS ------------------------------------------------------------------

function PipeManager:new()
    self.displayWidth = love.graphics.getWidth()
    self.displayHeight = love.graphics.getHeight()

    -- scaling parameters with display resolution
    self.pipeInitX = math.floor(PIPE_INIT_X * self.displayWidth)
    self.pipeMinSpacingX = math.floor(PIPE_MIN_SPACING_X * self.displayHeight)
    self.pipeMinSpacingY = math.floor(PIPE_MIN_SPACING_Y * self.displayHeight)
    self.pipeMaxSpacingX = math.floor(PIPE_MAX_SPACING_X * self.displayHeight)
    self.pipeMaxSpacingY = math.floor(PIPE_MAX_SPACING_Y * self.displayHeight)
    self.pipeSpacingDecrease = math.floor(PIPE_SPACING_DECREASE * self.displayHeight)

    self.pipeSpacingX = self.pipeMaxSpacingX
    self.pipeSpacingY = self.pipeMaxSpacingY

    self.pipeWidth = g_ResManager.PIPE_BOTTOM_IMAGE:getWidth()
    self.pipeHeight = g_ResManager.PIPE_BOTTOM_IMAGE:getHeight()
    logger.debug(
        'PipeManager: new: pipeWidth is', self.pipeWidth,
        'pipeHeight is', self.pipeHeight
    )

    -- initialising parameters for randomising top/bottom pipe y positions
    self.randFrom = math.floor(self.displayHeight * SPACING_FROM_Y)
    self.randTo = math.floor(self.displayHeight * SPACING_TO_Y)
    logger.debug('PipeManager: new: randFrom =', self.randFrom, 'randTo =', self.randTo)

    -- calculate the number of pipes needed and generate them
    self.numPipes = math.floor(
       self.displayWidth / (self.pipeWidth + self.pipeMinSpacingX) + 2
    )
    logger.debug('PipeManager: new: numPipes is', self.numPipes)
    self.pipesList = generatePipes(self)

    self.difficultyCounter = self.numPipes
end

function PipeManager:update(dt)
    -- call the update function of every Pipe sprite
    for _, pipe in ipairs(self.pipesList) do
        pipe:update(dt)
    end

    -- if the first two pipes fall off the screen completely
    if self.pipesList[1].x < -self.pipeWidth / 2 then
        logger.debug('PipeManager: update: A pipe object fell off the screen')

        -- remove the first pipes (by X) top/bottom
        local firstTopPipe = table.remove(self.pipesList, 1)
        local firstBottomPipe = table.remove(self.pipesList, 1)

        -- calculate X to move first pipes to last, equally spaced when the
        -- top/bottom pipes are moved to the back, randomise Y positions
        local newLastPipeX = self.pipesList[#self.pipesList].x +  -- TODO: fix access to instance variable
                             self.pipeSpacingX + self.pipeWidth
        local newLastPipeTopY, newLastPipeBottomY = randomisePipePositions(self)

        -- first pipe (by X) becomes the last
        firstTopPipe.x = newLastPipeX
        firstTopPipe.y = newLastPipeTopY
        firstBottomPipe.x = newLastPipeX
        firstBottomPipe.y = newLastPipeBottomY

        -- add the pipes to the end of the list
        table.insert(self.pipesList, firstTopPipe)
        table.insert(self.pipesList, firstBottomPipe)

        updateDifficulty(self)
    end
end

function PipeManager:draw()
    for _, pipe in ipairs(self.pipesList) do
        pipe:draw()
    end
end

function PipeManager:resetPipes()
    --[[
    This method resets the positions of all pipes and is called
    by GameOverState when its set.

    It avoids having to create a new instance of the PipeManager
    which would generate_pipes again. For some reason, the said method
    takes a good couple of seconds!
    ]]--
    self.pipeSpacingX = self.pipeMaxSpacingX
    self.pipeSpacingY = self.pipeMaxSpacingY

    for i = 1, #self.pipesList, 2 do
        local x = self.pipeInitX + i / 2 * (self.pipeMaxSpacingX + self.pipeWidth)
        local topY, bottomY = randomisePipePositions(self)

        self.pipesList[i].x = x
        self.pipesList[i].y = topY
        self.pipesList[i + 1].x = x
        self.pipesList[i + 1].y = bottomY
    end

    self.difficultyCounter = self.numPipes
end

function PipeManager:getFlappysNextPipes()
    --[[
    This method returns the two pipes just in front of Flappy.
    It is called by FlappyFlyingState in its update_state method.
    ]]--
    for i = 1, #self.pipesList, 2 do
        -- TODO: better way of using flappy's position (.. > s.d_w * 0.1)
        if self.pipesList[i].x > self.displayWidth * 0.2 -  -- TODO: fix access to instance variable
           g_ResManager.FLAPPY_UP_IMAGE:getWidth() then
            return {self.pipesList[i], self.pipesList[i + 1]}
        end
    end
end


------- PRIVATE METHODS -----------------------------------------------------------------

function generatePipes(self)
    local pipesList = {}

    for i = 1, self.numPipes do
        local x = self.pipeInitX + i * (self.pipeMaxSpacingX + self.pipeWidth)
        local topY, bottomY = randomisePipePositions(self)

        local topPipe = Pipe(x, topY, true)
        local bottomPipe = Pipe(x, bottomY, false)

        table.insert(pipesList, topPipe)
        table.insert(pipesList, bottomPipe)
    end

    return pipesList
end

function randomisePipePositions(self)
    local spacingCenterY = math.random(self.randFrom, self.randTo)

    local topY = spacingCenterY - self.pipeSpacingY / 2 - self.pipeHeight / 2
    local bottomY = spacingCenterY + self.pipeSpacingY / 2 + self.pipeHeight / 2

    return topY, bottomY
end

function updateDifficulty(self)
    self.difficultyCounter = self.difficultyCounter + 1

    if self.difficultyCounter >= DIFFICULTY_CHANGE then
        self.difficultyCounter = 0

        -- increase the difficulty by making the spacing between the
        -- pipes smaller
        if self.pipeSpacingX > self.pipeMinSpacingX then
            self.pipeSpacingX = self.pipeSpacingX - self.pipeSpacingDecrease
            self.pipeSpacingY = self.pipeSpacingY - self.pipeSpacingDecrease
            logger.debug(
                'PipeManager: updateDifficulty: Making spacing',
                'smaller X is', self.pipeSpacingX, 'Y is', self.pipeSpacingY
            )
        else
            logger.debug(
                'PipeManager: updateDifficulty: Highest difficulty',
                'reached! WOOHOO! Keep going!'
            )
        end
    end
end


return PipeManager
