--[[
paths.lua

Copyright (C) 2016 Kano Computing Ltd.
License: http://www.gnu.org/licenses/gpl-2.0.txt GNU GPL v2

Path variables used throught the game.
]]--


local logger = require 'system.logger'


------- MODULE --------------------------------------------------------------------------

local paths = {}


local function new()
    paths.RES_DIR = 'res/'
    paths.IMAGES_DIR = paths.RES_DIR .. 'images/'
    paths.SOUNDS_DIR = paths.RES_DIR .. 'sounds/'
    paths.FONTS_DIR = paths.RES_DIR .. 'fonts/'

    logger.debug('paths.RES_DIR is', paths.RES_DIR)
    logger.debug('paths.IMAGES_DIR is', paths.IMAGES_DIR)
    logger.debug('paths.SOUNDS_DIR is', paths.SOUNDS_DIR)
    logger.debug('paths.FONTS_DIR is', paths.FONTS_DIR)

    return paths
end


return new()
