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
		newsleakbold = gfx.font.new('fonts/newsleak-bold'),
		howtoplay3 = gfx.image.new('images/howtoplay3'),
		howtoplay4 = gfx.image.new('images/howtoplay4'),
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
		if vars.page == 3 then assets.howtoplay3:draw(0, 0) end
		if vars.page == 4 then assets.howtoplay4:draw(0, 0) end
		gfx.setImageDrawMode(gfx.kDrawModeNXOR)
		if vars.page == 1 then -- Backstory
			assets.newsleak:drawText('Okay, let me run through this in my head one more time:\nMy name\'s Fido. I\'m a dog, but really I\'m nothing but a bag\nof bones. The afterlife\'s pretty nice; it\'s a bit repetitive, but\nI can get used to it. It\'s pretty chill! ...Well, aside from all the\nunmentionable horrors that are out to kill me again.\n\nMaybe if I keep running around, I can find a way outta\nthis place? Or at least set some new high scores.', 10, 10)
			assets.newsleak:drawTextAligned('...I still don\'t understand.', 390, 190, kTextAlignment.right)
		elseif vars.page == 2 then -- Basic controls
			assets.newsleak:drawText('Let\'s take a different approach to this:\nThe d-pad runs around. A button jumps, B button barks.\nThe Crank helps you dig up opportune stuff in the ground.\n\nRun around and dodge the enemies; bark to kill \'em and\nmove up to a harder (but higher-scoring) level.\n\nYou\'ve got three "lives" (hah) - run out, and it\'s game over.', 10, 10)
			assets.newsleak:drawTextAligned('Abstract! What about those enemies?', 390, 190, kTextAlignment.right)
		elseif vars.page == 3 then -- Enemy types
			assets.newsleak:drawText('So, enemies, obviously,\nare bad. If you run into them\nthey\'ll kill ya (...again), as\nquick as can be. Luckily,\nmy bark seems to shut \'em\nup and make \'em go away.\nPress B to use that, if you\nfind yourself in a pinch.', 10, 10)
			assets.newsleakbold:drawText('Cap\'n Slow', 260, 15)
			assets.newsleak:drawText('walks/turns/is slow', 260, 30)
			assets.newsleak:drawTextAligned('+100', 235, 45, kTextAlignment.center)
			assets.newsleakbold:drawText('King Confuzzle', 260, 75)
			assets.newsleak:drawText('turns on a dime', 260, 90)
			assets.newsleak:drawTextAligned('+300', 235, 105, kTextAlignment.center)
			assets.newsleakbold:drawText('Quack Reaper', 260, 135)
			assets.newsleak:drawText('out for blood', 260, 150)
			assets.newsleak:drawTextAligned('+500', 235, 165, kTextAlignment.center)
			assets.newsleak:drawTextAligned('And the stuff in the ground sometimes?', 390, 190, kTextAlignment.right)
		elseif vars.page == 4 then -- Dig-ups types
			assets.newsleak:drawText('Those are Dig-ups. Some are\ngood, some are bad, but you\ndon\'t know what\'s what until\nyou go fish it out. If you see\nsomething buried in the\nground, use the Crank to dig\nit up before it disappears.\nTrick or treat!', 10, 10)
			assets.newsleak:drawTextAligned('+100    +300    +500    +1 life', 300, 55, kTextAlignment.center)
			assets.newsleak:drawTextAligned('-100       -250       -1 life', 300, 145, kTextAlignment.center)
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