import 'game'
import 'howtoplay'
import 'options'
import 'credits'
import 'highscores'
import 'Tanuk_CodeSequence'

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
		if save.ribbitfound then
			menu:addCheckmarkMenuItem(text('ribbit'), ribbit, function(bool)
				ribbit = bool
				gfx.sprite.redrawBackground()
				if save.sfx then
					if bool then
						assets.croak:play()
					else
						assets.bark:play()
					end
				end
			end)
		end
		menu:addMenuItem(text('highscores'), function()
			if ribbit then
				if save.sfx then assets.croak:play(1, 1 + (0.01 * math.random(-10, 10))) end
			else
				if save.sfx then assets.bark:play(1, 1 + (0.01 * math.random(-10, 10))) end
			end
			scenemanager:switchscene(highscores)
		end)
		menu:addMenuItem(text('credits'), function()
			if ribbit then
				if save.sfx then assets.croak:play(1, 1 + (0.01 * math.random(-10, 10))) end
			else
				if save.sfx then assets.bark:play(1, 1 + (0.01 * math.random(-10, 10))) end
			end
			scenemanager:switchscene(credits)
		end)
	end

	assets = { -- All assets go here. Images, sounds, fonts, etc.
		title = gfx.image.new('images/title'),
		newsleak = gfx.font.new('fonts/newsleak'),
		tick = smp.new('audio/sfx/tick'),
		bark = smp.new('audio/sfx/bark'),
		win = smp.new('audio/sfx/win'),
		croak = smp.new('audio/sfx/croak'),
	}

	if not save.ribbitfound then
		local sprCode = Tanuk_CodeSequence({pd.kButtonRight, pd.kButtonUp, pd.kButtonB, pd.kButtonDown, pd.kButtonUp, pd.kButtonB, pd.kButtonDown, pd.kButtonUp, pd.kButtonB}, function()
			if save.sfx then
				assets.win:play()
				pd.timer.performAfterDelay(1000, function()
					assets.croak:play()
				end)
			end
			save.ribbitfound = true
			ribbit = true
			updatecheevos()
			gfx.sprite.redrawBackground()
		end)
	end

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
			if ribbit then
				if save.sfx then assets.croak:play(1, 1 + (0.01 * math.random(-10, 10))) end
			else
				if save.sfx then assets.bark:play(1, 1 + (0.01 * math.random(-10, 10))) end
			end
			if vars.selections[vars.selection] == 'game' then
				stopmusic()
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
		assets.newsleak:drawTextAligned("v" .. pd.metadata.version .. text("madebyrae"), 390, 10, kTextAlignment.right)
		if ribbit then
			assets.newsleak:drawTextAligned(text("ribbest") .. commalize(save.ribbit_score), 390, 30, kTextAlignment.right)
			assets.newsleak:drawTextAligned(text("letsplay2"), 390, 170, kTextAlignment.right)
		else
			assets.newsleak:drawTextAligned(text("best") .. commalize(save.score), 390, 30, kTextAlignment.right)
			assets.newsleak:drawTextAligned(text("letsplay"), 390, 170, kTextAlignment.right)
		end
		assets.newsleak:drawTextAligned(text("howtoplay"), 390, 190, kTextAlignment.right)
		assets.newsleak:drawTextAligned(text("options"), 390, 210, kTextAlignment.right)
		assets.newsleak:drawText(text("pressA"), 10, 150 + (20 * vars.selection))
		gfx.setColor(gfx.kColorXOR)
		gfx.fillRect(0, 150 + (20 * vars.selection), 400, 20)
		gfx.setColor(gfx.kColorBlack)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end)
	self:add()

	newmusic('audio/music/title', true)
end

function title:update()
	local ticks = pd.getCrankTicks(5)
	if ticks ~= 0 and vars.selection > 0 then
		if save.sfx then assets.tick:play(1, 1 + (0.01 * math.random(-10, 10))) end
		vars.selection += ticks
		if vars.selection < 1 then
			vars.selection = #vars.selections
		elseif vars.selection > #vars.selections then
			vars.selection = 1
		end
		gfx.sprite.redrawBackground()
	end
end