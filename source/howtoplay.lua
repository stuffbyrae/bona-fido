-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText

class('howtoplay').extends(gfx.sprite) -- Create the scene's class
function howtoplay:init(...)
	title.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here

	function pd.gameWillPause() -- When the game's paused...
		local menu = pd.getSystemMenu()
		menu:removeAllMenuItems()
	end

	assets = { -- All assets go here. Images, sounds, fonts, etc.
	}

	vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
	}
	vars.howtoplayHandlers = {
		BButtonDown = function()
		end
	}
	pd.inputHandlers.push(vars.howtoplayHandlers)

	gfx.sprite.setBackgroundDrawingCallback(function(width, height, x, y)
	end)
	self:add()
end

function howtoplay:update()
end