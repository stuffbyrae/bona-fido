-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText

class('howtoplaytoo').extends(gfx.sprite) -- Create the scene's class
function howtoplaytoo:init(...)
	howtoplaytoo.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here

	function pd.gameWillPause() -- When the game's paused...
		local menu = pd.getSystemMenu()
		menu:removeAllMenuItems()
	end

	assets = { -- All assets go here. Images, sounds, fonts, etc.
		newsleak = gfx.font.new('fonts/newsleak'),
		bark = smp.new('audio/sfx/bark'),
	}

	vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
	}
	vars.howtoplaytooHandlers = {
		AButtonDown = function()
			if save.sfx then assets.bark:play() end
			scenemanager:switchscene(title)
		end
	}
	pd.inputHandlers.push(vars.howtoplaytooHandlers)

	gfx.sprite.setBackgroundDrawingCallback(function(width, height, x, y)
		gfx.setImageDrawMode(gfx.kDrawModeNXOR)
		assets.newsleak:drawText('Let\'s make this a little bit more abstract.\n\nI can use the d-pad to run around, and the A button to jump.\nI should collect the various candies, those add to my score.\n\nI should avoid the enemies running around, they\'ll hurt me.\nIf I run out of "lives" (as it were), the game will be over.', 10, 10)
		assets.newsleak:drawTextAligned('Okay, I think I\'ve got it now.', 390, 210, kTextAlignment.right)
		assets.newsleak:drawText('Press Ⓐ to do this.', 10, 210)
		gfx.setColor(gfx.kColorXOR)
		gfx.fillRect(0, 210, 400, 20)
		gfx.setColor(gfx.kColorBlack)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end)
	self:add()
end