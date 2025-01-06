-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText

class('credits').extends(gfx.sprite) -- Create the scene's class
function credits:init(...)
	credits.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here

	function pd.gameWillPause() -- When the game's paused...
		local menu = pd.getSystemMenu()
		menu:removeAllMenuItems()
	end

	assets = { -- All assets go here. Images, sounds, fonts, etc.
		newsleak = gfx.font.new('fonts/newsleak'),
	}
	if ribbit then
		assets.bark = smp.new('audio/sfx/croak')
	else
		assets.bark = smp.new('audio/sfx/bark')
	end

	vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
	}
	vars.creditsHandlers = {
		BButtonDown = function()
			if save.sfx then assets.bark:play(1, 1 + (0.01 * math.random(-10, 10))) end
			scenemanager:switchscene(title)
		end,

		AButtonDown = function()
			if save.sfx then assets.bark:play(1, 1 + (0.01 * math.random(-10, 10))) end
			scenemanager:switchscene(title)
		end
	}
	pd.inputHandlers.push(vars.creditsHandlers)

	gfx.sprite.setBackgroundDrawingCallback(function(width, height, x, y)
		gfx.setImageDrawMode(gfx.kDrawModeNXOR)
		assets.newsleak:drawText(text("creditsme"), 10, 10)
		assets.newsleak:drawText(text("creditsmusic_" .. tostring(save.music)), 10, 30)
		assets.newsleak:drawText(text("creditssfx_" .. tostring(save.sfx)), 10, 50)
		assets.newsleak:drawText(text("creditsfont"), 10, 70)
		assets.newsleak:drawText(text("creditstanuk"), 10, 90)
		assets.newsleak:drawText(text("creditsthanks"), 10, 110)
		assets.newsleak:drawText(text("creditswandering"), 10, 140)
		assets.newsleak:drawTextAligned(text("creditsleave"), 390, 210, kTextAlignment.right)
		assets.newsleak:drawText(text("pressA"), 10, 210)
		gfx.setColor(gfx.kColorXOR)
		gfx.fillRect(0, 210, 400, 20)
		gfx.setColor(gfx.kColorBlack)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end)
	self:add()
end