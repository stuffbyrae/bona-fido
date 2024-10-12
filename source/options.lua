-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText

class('options').extends(gfx.sprite) -- Create the scene's class
function options:init(...)
	options.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here

	function pd.gameWillPause() -- When the game's paused...
		local menu = pd.getSystemMenu()
		menu:removeAllMenuItems()
	end

	assets = { -- All assets go here. Images, sounds, fonts, etc.
	}

	vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
	}
	vars.optionsHandlers = {
		upButtonDown = function()
		end,

		downButtonDown = function()
		end,

		AButtonDown = function()
		end
	}
	pd.inputHandlers.push(vars.optionsHandlers)

	gfx.sprite.setBackgroundDrawingCallback(function(width, height, x, y)
	end)
	self:add()
end

function options:update()
end