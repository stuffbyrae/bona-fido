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
		newsleak = gfx.font.new('fonts/newsleak'),
		tick = smp.new('audio/sfx/tick'),
		bark = smp.new('audio/sfx/bark'),
	}

	vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
		selection = 1,
		page = 1,
		selections = {'more', 'title'},
	}
	vars.howtoplayHandlers = {
		upButtonDown = function()
			if vars.selection == 1 then
				vars.selection = #vars.selections
			else
				vars.selection -= 1
			end
			if save.sfx then assets.tick:play(1, 1 + (0.01 * math.random(-10, 10))) end
			gfx.sprite.redrawBackground()
		end,

		downButtonDown = function()
			if vars.selection == #vars.selections then
				vars.selection = 1
			else
				vars.selection += 1
			end
			if save.sfx then assets.tick:play(1, 1 + (0.01 * math.random(-10, 10))) end
			gfx.sprite.redrawBackground()
		end,

		AButtonDown = function()
			if save.sfx then assets.bark:play(1, 1 + (0.01 * math.random(-10, 10))) end
			if vars.selections[vars.selection] == "more" then
				if vars.page < 4 then
					vars.page += 1
				elseif vars.page == 4 then
					vars.page = 1
				end
				gfx.sprite.redrawBackground()
			elseif vars.selections[vars.selection] == "title" then
				scenemanager:switchscene(title)
			end
		end
	}
	pd.inputHandlers.push(vars.howtoplayHandlers)

	gfx.sprite.setBackgroundDrawingCallback(function(width, height, x, y)
		gfx.setImageDrawMode(gfx.kDrawModeNXOR)
		if vars.page == 1 then -- Backstory
			assets.newsleak:drawText('Okay, let me run through this in my head one more time:\n\nI\'m Fido. I\'m a dog, and I\'m also a pretty small bag of bones.\nThe afterlife\'s pretty easy; just jump around and eat candy.\nOf course, there\'s no such thing as a free lunch, so I\'ve gotta\nwatch out for these other folks, too - they\'re REAL meanies.\nSuch as the nature of the afterlife, I\'ve just gotta keep doing\nthis over and over, forever. Maybe I can get a high score?', 10, 10)
			assets.newsleak:drawTextAligned('...I still don\'t understand.', 390, 190, kTextAlignment.right)
		elseif vars.page == 2 then -- Basic controls
			assets.newsleak:drawTextAligned('Abstract! What about those enemies?', 390, 190, kTextAlignment.right)
		elseif vars.page == 3 then -- Enemy types
			assets.newsleak:drawTextAligned('And the stuff in the ground sometimes?', 390, 190, kTextAlignment.right)
		elseif vars.page == 4 then -- Dig-ups types
			assets.newsleak:drawTextAligned('Wait...I lost my train of thought.', 390, 190, kTextAlignment.right)
		end
		assets.newsleak:drawTextAligned('Okay, I think I\'ve got it now.', 390, 210, kTextAlignment.right)
		assets.newsleak:drawText('Press Ⓐ to do this.', 10, 170 + (20 * vars.selection))
		gfx.setColor(gfx.kColorXOR)
		gfx.fillRect(0, 170 + (20 * vars.selection), 400, 20)
		gfx.setColor(gfx.kColorBlack)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end)
	self:add()
end