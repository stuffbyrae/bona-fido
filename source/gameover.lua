import 'howtoplaytoo'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText

class('gameover').extends(gfx.sprite) -- Create the scene's class
function gameover:init(...)
	gameover.super.init(self)
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
		level = args[1],
		score = args[2],
		selection = 1,
		selections = {'game', 'title'},
	}
	vars.gameoverHandlers = {
		upButtonDown = function()
			if vars.selection == 1 then
				vars.selection = #vars.selections
			else
				vars.selection -= 1
			end
			if save.sfx then assets.tick:play() end
			gfx.sprite.redrawBackground()
		end,

		downButtonDown = function()
			if vars.selection == #vars.selections then
				vars.selection = 1
			else
				vars.selection += 1
			end
			if save.sfx then assets.tick:play() end
			gfx.sprite.redrawBackground()
		end,

		AButtonDown = function()
			if save.sfx then assets.bark:play() end
			if vars.selections[vars.selection] == "game" then
				scenemanager:switchscene(game)
			elseif vars.selections[vars.selection] == "title" then
				scenemanager:switchscene(title)
			end
		end
	}
	pd.inputHandlers.push(vars.gameoverHandlers)

	gfx.sprite.setBackgroundDrawingCallback(function(width, height, x, y)
		gfx.setImageDrawMode(gfx.kDrawModeNXOR)
		assets.newsleak:drawText('game over!! you got score ' .. vars.score .. ', at lv ' .. vars.level, 10, 10)
		assets.newsleak:drawTextAligned('Let\'s play another round, why not?', 390, 190, kTextAlignment.right)
		assets.newsleak:drawTextAligned('I think I\'ll head back to the title menu.', 390, 210, kTextAlignment.right)
		assets.newsleak:drawText('Press Ⓐ to do this.', 10, 170 + (20 * vars.selection))
		gfx.setColor(gfx.kColorXOR)
		gfx.fillRect(0, 170 + (20 * vars.selection), 400, 20)
		gfx.setColor(gfx.kColorBlack)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end)
	self:add()
end