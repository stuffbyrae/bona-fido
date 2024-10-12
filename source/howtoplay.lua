import 'howtoplaytoo'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText

class('howtoplay').extends(gfx.sprite) -- Create the scene's class
function howtoplay:init(...)
	howtoplay.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here

	function pd.gameWillPause() -- When the game's paused...
		local menu = pd.getSystemMenu()
		menu:removeAllMenuItems()
	end

	assets = { -- All assets go here. Images, sounds, fonts, etc.
		newsleak = gfx.font.new('fonts/newsleak')
	}

	vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
		selection = 1,
		selections = {'more', 'title'},
	}
	vars.titleHandlers = {
		upButtonDown = function()
			if vars.selection == 1 then
				vars.selection = #vars.selections
			else
				vars.selection -= 1
			end
			gfx.sprite.redrawBackground()
		end,

		downButtonDown = function()
			if vars.selection == #vars.selections then
				vars.selection = 1
			else
				vars.selection += 1
			end
			gfx.sprite.redrawBackground()
		end,

		AButtonDown = function()
			if vars.selections[vars.selection] == "more" then
				scenemanager:switchscene(howtoplaytoo)
			elseif vars.selections[vars.selection] == "title" then
				scenemanager:switchscene(title)
			end
		end
	}
	pd.inputHandlers.push(vars.titleHandlers)

	gfx.sprite.setBackgroundDrawingCallback(function(width, height, x, y)
		gfx.setImageDrawMode(gfx.kDrawModeNXOR)
		assets.newsleak:drawText('Okay, so let me run through this in my head one more time:\n\nI\'m Fido. I\'m a dog, and I\'m also a pretty small bag of bones.\nThe afterlife\'s pretty easy; just jump around and eat candy.\nOf course, there\'s no such thing as a free lunch, so I\'ve gotta\nwatch out for these other folks, too - they\'re REAL meanies.\nSuch as the nature of the afterlife, I\'ve just gotta keep doing\nthis over and over, forever. Maybe I can get a high score?', 10, 10)
		assets.newsleak:drawTextAligned('...I still don\'t understand this.', 390, 190, kTextAlignment.right)
		assets.newsleak:drawTextAligned('Okay, I think I\'ve got it now.', 390, 210, kTextAlignment.right)
		assets.newsleak:drawText('Press Ⓐ to do this.', 10, 170 + (20 * vars.selection))
		gfx.setColor(gfx.kColorXOR)
		gfx.fillRect(0, 170 + (20 * vars.selection), 400, 20)
		gfx.setColor(gfx.kColorBlack)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end)
	self:add()
end