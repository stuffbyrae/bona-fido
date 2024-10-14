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
		gameover = gfx.image.new('images/gameover'),
		gameover2 = gfx.image.new('images/gameover2'),
		newsleak = gfx.font.new('fonts/newsleak'),
		tick = smp.new('audio/sfx/tick'),
		bark = smp.new('audio/sfx/bark'),
		thunder = smp.new('audio/sfx/thunder'),
	}

	vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
		level = args[1],
		score = args[2],
		selection = 1,
		selections = {'game', 'title'},
		newbest = false,
		going = false,
	}
	vars.gameoverHandlers = {
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
			if vars.selections[vars.selection] == "game" then
				pd.inputHandlers.pop()
				fademusic(700)
				vars.going = true
				gfx.sprite.redrawBackground()
				shakies()
				shakies_y()
				if not pd.getReduceFlashing() then
					pd.display.setInverted(true)
					pd.timer.performAfterDelay(150, function()
						pd.display.setInverted(false)
					end)
					pd.timer.performAfterDelay(250, function()
						pd.display.setInverted(true)
					end)
					pd.timer.performAfterDelay(350, function()
						pd.display.setInverted(false)
					end)
				end
				if save.sfx then assets.thunder:play(1, 1 + (0.01 * math.random(-10, 10))) end
				pd.timer.performAfterDelay(1500, function()
					scenemanager:switchscene(game)
				end)
			elseif vars.selections[vars.selection] == "title" then
				stopmusic()
				scenemanager:switchscene(title)
			end
		end
	}
	pd.inputHandlers.push(vars.gameoverHandlers)

	if vars.score > save.score then
		vars.newbest = true
		save.score = vars.score
	end

	gfx.sprite.setBackgroundDrawingCallback(function(width, height, x, y)
		if vars.going then
			assets.gameover2:draw(0, 0)
		else
			assets.gameover:draw(0, 0)
		end
		gfx.setImageDrawMode(gfx.kDrawModeNXOR)
		assets.newsleak:drawTextAligned('Game Over!', 300, 30, kTextAlignment.center)
		assets.newsleak:drawTextAligned('I died at level ' .. commalize(vars.level) .. ',', 300, 60, kTextAlignment.center)
		assets.newsleak:drawTextAligned('and scored ' .. commalize(vars.score) .. ' pts.', 300, 80, kTextAlignment.center)
		if vars.newbest then
			assets.newsleak:drawTextAligned('That\'s a new high score!', 300, 110, kTextAlignment.center)
			assets.newsleak:drawTextAligned('Good job!', 300, 130, kTextAlignment.center)
		else
			assets.newsleak:drawTextAligned('My current best', 300, 110, kTextAlignment.center)
			assets.newsleak:drawTextAligned('is ' .. commalize(save.score) .. ' pts.', 300, 130, kTextAlignment.center)
		end
		assets.newsleak:drawTextAligned('Let\'s play another round, why not?', 390, 190, kTextAlignment.right)
		assets.newsleak:drawTextAligned('I think I\'ll head back to the title menu.', 390, 210, kTextAlignment.right)
		if not vars.going then
			assets.newsleak:drawText('Press Ⓐ to do this.', 10, 170 + (20 * vars.selection))
		end
		gfx.setColor(gfx.kColorXOR)
		gfx.fillRect(0, 170 + (20 * vars.selection), 400, 20)
		gfx.setColor(gfx.kColorBlack)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end)
	self:add()

	newmusic('audio/music/ancientrite')
end