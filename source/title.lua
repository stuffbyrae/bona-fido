import 'game'
import 'howtoplay'
import 'options'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText

class('title').extends(gfx.sprite) -- Create the scene's class
function title:init(...)
	title.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here

	function pd.gameWillPause() -- When the game's paused...
		local menu = pd.getSystemMenu()
		menu:removeAllMenuItems()
	end

	assets = { -- All assets go here. Images, sounds, fonts, etc.
		title = gfx.image.new('images/title'),
		newsleak = gfx.font.new('fonts/newsleak')
	}

	vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
		selection = 1,
		selections = {'game', 'howtoplay', 'options'},
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
			if vars.selections[vars.selection] == 'game' then
				scenemanager:switchscene(game)
			elseif vars.selections[vars.selection] == 'howtoplay' then
				scenemanager:switchscene(howtoplay)
			elseif vars.selections[vars.selection] == 'options' then
				scenemanager:switchscene(options)
			end
		end
	}
	pd.inputHandlers.push(vars.titleHandlers)

	gfx.sprite.setBackgroundDrawingCallback(function(width, height, x, y)
		assets.title:draw(0, 0)
		gfx.setImageDrawMode(gfx.kDrawModeNXOR)
		assets.newsleak:drawTextAligned('made by rae', 390, 10, kTextAlignment.right)
		assets.newsleak:drawTextAligned('for playjam 5', 390, 30, kTextAlignment.right)
		assets.newsleak:drawTextAligned('Let\'s play a round!', 390, 170, kTextAlignment.right)
		assets.newsleak:drawTextAligned('Wait... how do I play?', 390, 190, kTextAlignment.right)
		assets.newsleak:drawTextAligned('Let\'s change some options.', 390, 210, kTextAlignment.right)
		assets.newsleak:drawText('Press Ⓐ to do this.', 10, 150 + (20 * vars.selection))
		gfx.setColor(gfx.kColorXOR)
		gfx.fillRect(0, 150 + (20 * vars.selection), 400, 20)
		gfx.setColor(gfx.kColorBlack)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end)
	self:add()
end