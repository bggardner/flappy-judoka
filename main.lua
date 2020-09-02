--[[
main.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

This is the entry point into the game code.

The main() method does only the following:
  * checks to see if another instance of the game is already running (RPI ONLY!)
  * parses the cmdline arguments to set the display resolution
  * starts the gameloop
]]--


local GamestateManager = require 'core.GamestateManager'
local DisplayManager = require 'graphics.DisplayManager'
local SoundManager = require 'graphics.SoundManager'
local ResourceManager = require 'graphics.ResourceManager'

local logger = require 'system.logger'
local utils = require 'system.utils'

local CommonUtils = require 'common.system.utils'

local love = love


------- LOCALS --------------------------------------------------------------------------

local gamestateManager
local displayManager
local soundManager
local drawables

------- GLOBALS -------------------------------------------------------------------------

g_ResManager = nil

-----------------------------------------------------------------------------------------


function love.load(args)
    CommonUtils.trackAction('lua-flappy-judoka-start')
    CommonUtils.trackSessionStart('lua-flappy-judoka')

    args = utils.parseArgs(args)
    local isDebuggingEnabled = (args['-d'] or args['--debug'])
    logger.setDebug(isDebuggingEnabled)

    logger.info('main: love.load: Game launched and loading.')

    g_ResManager = ResourceManager()

    gamestateManager = GamestateManager()
    displayManager = DisplayManager()
    soundManager = SoundManager()

    displayManager:setup(gamestateManager)  -- TODO: fix this ouch
    soundManager:setup(gamestateManager)  -- TODO: fix this ouch
    gamestateManager:load()

    drawables = {}
end

function love.update(dt_sec)
    drawables = gamestateManager:update(dt_sec)
end

function love.draw()
    displayManager:draw(drawables)
end

function love.keypressed(key, scancode, isrepeat)
    gamestateManager:keypressed(key)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    gamestateManager:touchpressed(id, x, y)
end

function love.gamepadpressed(joystick, button)
    gamestateManager:gamepadpressed(joystick, button)
end

function love.quit()
    logger.info('main: love.quit: Exiting game. Thanks for playing!')
    g_ResManager:save()
    CommonUtils.trackSessionEnd('lua-flappy-judoka')
    CommonUtils.profileSaveAppStateVariable(
        'flappy_judoka_best_score', g_ResManager:getSaveData().bestScore
    )
end
