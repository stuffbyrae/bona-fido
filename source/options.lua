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
		newsleak = gfx.font.new('fonts/newsleak'),
		tick = smp.new('audio/sfx/tick'),
		bark = smp.new('audio/sfx/bark'),
		die = smp.new('audio/sfx/die'),
	}

	vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
		selection = 1,
		selections = {'music', 'sfx', 'reset', 'back'},
		reset = 1,
	}
	vars.optionsHandlers = {
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
			if vars.selections[vars.selection] == 'music' then
				save.music = not save.music
				if save.music then
					newmusic('audio/music/basementfloor', true)
				else
					stopmusic()
				end
				if save.sfx then assets.bark:play(1, 1 + (0.01 * math.random(-10, 10))) end
			elseif vars.selections[vars.selection] == 'sfx' then
				save.sfx = not save.sfx
				if save.sfx then assets.bark:play(1, 1 + (0.01 * math.random(-10, 10))) end
			elseif vars.selections[vars.selection] == 'reset' and vars.reset < 4 then
				if save.sfx then assets.bark:play(1, 0.85 + (0.15 * vars.reset)) end
				vars.reset += 1
				if vars.reset == 4 then
					save.score = 0
					if save.sfx then assets.die:play(1, 1 + (0.01 * math.random(-10, 10))) end
					shakies()
					shakies_y()
				end
			elseif vars.selections[vars.selection] == 'back' then
				if save.sfx then assets.bark:play(1, 1 + (0.01 * math.random(-10, 10))) end
				scenemanager:switchscene(title)
			end
			gfx.sprite.redrawBackground()
		end
	}
	pd.inputHandlers.push(vars.optionsHandlers)

	gfx.sprite.setBackgroundDrawingCallback(function(width, height, x, y)
		gfx.setImageDrawMode(gfx.kDrawModeNXOR)
		assets.newsleak:drawText('This game was made by Rae; she did art and programming.', 10, 10)
		if save.music then
			assets.newsleak:drawText('Kevin MacLeod did the music, which you\'re hearing now.', 10, 30)
		else
			assets.newsleak:drawText('Kevin MacLeod did the music, which you\'re not hearing.', 10, 30)
		end
		if save.sfx then
			assets.newsleak:drawText('Pixabay handled the SFX, which you\'re hearing now.', 10, 50)
		else
			assets.newsleak:drawText('Pixabay handled the SFX, which you\'re not hearing.', 10, 50)
		end
		assets.newsleak:drawText('Panic provided the nice Newsleak Serif font in the SDK.', 10, 70)
		assets.newsleak:drawText('Mag, Toad, Kirk, Henry, John n\' bumble were big helps, too.', 10, 90)
		assets.newsleak:drawText('Sorry, my mind\'s wandering... Oh, here are the options:', 10, 120)
		if save.music then
			assets.newsleak:drawTextAligned('The music\'s currently on.', 390, 150, kTextAlignment.right)
		else
			assets.newsleak:drawTextAligned('The music\'s currently off.', 390, 150, kTextAlignment.right)
		end
		if save.sfx then
			assets.newsleak:drawTextAligned('The SFX are currently on.', 390, 170, kTextAlignment.right)
		else
			assets.newsleak:drawTextAligned('The SFX are currently off.', 390, 170, kTextAlignment.right)
		end
		if vars.reset == 1 then
			assets.newsleak:drawTextAligned('I\'d like to reset my local scores.', 390, 190, kTextAlignment.right)
		elseif vars.reset == 2 then
			assets.newsleak:drawTextAligned('Oh, I have to press again to confirm.', 390, 190, kTextAlignment.right)
		elseif vars.reset == 3 then
			assets.newsleak:drawTextAligned('One more time, to reset local scores?', 390, 190, kTextAlignment.right)
		elseif vars.reset == 4 then
			assets.newsleak:drawTextAligned('Oh, there we go! Local scores reset.', 390, 190, kTextAlignment.right)
		end
		assets.newsleak:drawTextAligned('I\'m done changing stuff.', 390, 210, kTextAlignment.right)
		if not (vars.selection == 3 and vars.reset == 4) then
			assets.newsleak:drawText('Press Ⓐ to do this.', 10, 130 + (20 * vars.selection))
		end
		gfx.setColor(gfx.kColorXOR)
		gfx.fillRect(0, 130 + (20 * vars.selection), 400, 20)
		gfx.setColor(gfx.kColorBlack)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end)
	self:add()
end