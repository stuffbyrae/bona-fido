-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText
local floor <const> = math.floor

class('highscores').extends(gfx.sprite) -- Create the scene's class
function highscores:init(...)
	highscores.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here

	function pd.gameWillPause() -- When the game's paused...
		local menu = pd.getSystemMenu()
		menu:removeAllMenuItems()
		if not vars.loading then
			menu:addMenuItem(text('refresh'), function()
				highscores:refresh()
			end)
		end
	end

	assets = { -- All assets go here. Images, sounds, fonts, etc.
		newsleak = gfx.font.new('fonts/newsleak'),
	}
	if ribbit then
		assets.bark = smp.new('audio/sfx/croak')
		assets.fido = gfx.imagetable.new('images/ribbit')
	else
		assets.bark = smp.new('audio/sfx/bark')
		assets.fido = gfx.imagetable.new('images/fido')
	end

	vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
		result = {},
		best = {},
		loading = true,
		load_timer = pd.timer.new(500, 1, 6.99),
	}
	vars.highscoresHandlers = {
		BButtonDown = function()
			if not vars.loading then
				if save.sfx then assets.bark:play(1, 1 + (0.01 * math.random(-10, 10))) end
				scenemanager:switchscene(title)
			end
		end,

		AButtonDown = function()
			if not vars.loading then
				if save.sfx then assets.bark:play(1, 1 + (0.01 * math.random(-10, 10))) end
				scenemanager:switchscene(title)
			end
		end
	}
	pd.inputHandlers.push(vars.highscoresHandlers)

	vars.load_timer.repeats = true
	vars.load_timer.discardOnCompletion = false

	gfx.sprite.setBackgroundDrawingCallback(function(width, height, x, y)
		gfx.setImageDrawMode(gfx.kDrawModeNXOR)
		if vars.loading then
			assets.newsleak:drawTextAligned(text("highscoresfetch"), 200, 90, kTextAlignment.center)
			gfx.setImageDrawMode(gfx.kDrawModeCopy)
			assets.fido[floor(vars.load_timer.value)]:drawAnchored(200, 140, 0.5, 0.5)
			gfx.setImageDrawMode(gfx.kDrawModeNXOR)
		else
			if vars.result == "fail" then
				assets.newsleak:drawTextAligned(text("highscoresfail"), 200, 90, kTextAlignment.center)
				gfx.setImageDrawMode(gfx.kDrawModeCopy)
				assets.fido[floor(vars.load_timer.value)]:drawAnchored(200, 140, 0.5, 0.5)
				gfx.setImageDrawMode(gfx.kDrawModeNXOR)
				assets.newsleak:drawTextAligned(text("highscoresleave_fail"), 390, 210, kTextAlignment.right)
			else
				if ribbit then
					if vars.result.scores ~= nil and next(vars.result.scores) ~= nil then
						assets.newsleak:drawText(text("highscores_ribbit"), 10, 10)
						for _, v in ipairs(vars.result.scores) do
							assets.newsleak:drawText(v.rank .. '. ' .. v.player, 10, 20 + (15 * v.rank))
							assets.newsleak:drawTextAligned(commalize(v.value), 390, 20 + (15 * v.rank), kTextAlignment.right)
						end
					else
						assets.newsleak:drawTextAligned(text("highscoresempty"), 200, 90, kTextAlignment.center)
					end
				else
					if vars.result.scores ~= nil and next(vars.result.scores) ~= nil then
						assets.newsleak:drawText(text("highscores_bona"), 10, 10)
						for _, v in ipairs(vars.result.scores) do
							assets.newsleak:drawText(v.rank .. '. ' .. v.player, 10, 20 + (15 * v.rank))
							assets.newsleak:drawTextAligned(commalize(v.value), 390, 20 + (15 * v.rank), kTextAlignment.right)
						end
					else
						assets.newsleak:drawTextAligned(text("highscoresempty"), 200, 90, kTextAlignment.center)
					end
				end
				assets.newsleak:drawTextAligned(text("highscoresleave"), 390, 210, kTextAlignment.right)
			end
			assets.newsleak:drawText(text("pressA"), 10, 210)
			gfx.setColor(gfx.kColorXOR)
			gfx.fillRect(0, 210, 400, 20)
		end
		gfx.setColor(gfx.kColorBlack)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end)
	self:add()
	self:refresh()
end

function highscores:refresh()
	vars.result = {}
	vars.best = {}
	vars.loading = true
	vars.load_timer = pd.timer.new(500, 1, 6.99)
	vars.load_timer.repeats = true
	gfx.sprite.redrawBackground()
	if pd.isSimulator == 1 then
		pd.scoreboards.getScoreboards(function(status, result)
			printTable(status)
			printTable(result)
		end)
	end
	pd.scoreboards.getScores(ribbit and "ribbit" or "bona", function(status, result)
		if pd.isSimulator == 1 then
			printTable(status)
			printTable(result)
		end
		if status.code == "OK" then
			vars.result = result
		else
			vars.result = "fail"
			vars.load_timer:resetnew(500, 12, 17.99)
		end
		vars.loading = false
		gfx.sprite.redrawBackground()
	end)
	pd.scoreboards.getPersonalBest(ribbit and "ribbit" or "bona", function(status, result)
		if status.code == "OK" then
			vars.best = result
			gfx.sprite.redrawBackground()
		end
	end)
end

function highscores:update()
	if vars.loading or vars.result == "fail" then
		gfx.sprite.redrawBackground()
	end
end