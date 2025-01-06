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
		die = smp.new('audio/sfx/die'),
	}
	if ribbit then
		assets.bark = smp.new('audio/sfx/croak')
		assets.options = gfx.image.new('images/options_ribbit')
	else
		assets.bark = smp.new('audio/sfx/bark')
		assets.options = gfx.image.new('images/options')
	end

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
			if vars.reset ~= 4 then vars.reset = 1 end
			if save.sfx then assets.tick:play(1, 1 + (0.01 * math.random(-10, 10))) end
			gfx.sprite.redrawBackground()
		end,

		downButtonDown = function()
			if vars.selection == #vars.selections then
				vars.selection = 1
			else
				vars.selection += 1
			end
			if vars.reset ~= 4 then vars.reset = 1 end
			if save.sfx then assets.tick:play(1, 1 + (0.01 * math.random(-10, 10))) end
			gfx.sprite.redrawBackground()
		end,

		BButtonDown = function()
			if save.sfx then assets.bark:play(1, 1 + (0.01 * math.random(-10, 10))) end
			scenemanager:switchscene(title)
		end,

		AButtonDown = function()
			if vars.selections[vars.selection] == 'music' then
				save.music = not save.music
				if save.music then
					newmusic('audio/music/title', true)
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
					if ribbit then assets.bark = smp.new('audio/sfx/bark') end
					ribbit = false
					save.ribbitfound = false
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
		assets.options:draw(0, 0)
		gfx.setImageDrawMode(gfx.kDrawModeNXOR)
		assets.newsleak:drawText(text("options"), 10, 10)
		assets.newsleak:drawTextAligned(text("optionsmusic_" .. tostring(save.music)), 390, 150, kTextAlignment.right)
		assets.newsleak:drawTextAligned(text("optionssfx_" .. tostring(save.sfx)), 390, 170, kTextAlignment.right)
		assets.newsleak:drawTextAligned(text("optionsreset_" .. tostring(vars.reset)), 390, 190, kTextAlignment.right)
		assets.newsleak:drawTextAligned(text("optionsdone"), 390, 210, kTextAlignment.right)
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

function options:update()
	local ticks = pd.getCrankTicks(5)
	if ticks ~= 0 and vars.selection > 0 then
		if save.sfx then assets.tick:play(1, 1 + (0.01 * math.random(-10, 10))) end
		vars.selection += ticks
		if vars.reset ~= 4 then vars.reset = 1 end
		if vars.selection < 1 then
			vars.selection = #vars.selections
		elseif vars.selection > #vars.selections then
			vars.selection = 1
		end
		gfx.sprite.redrawBackground()
	end
end