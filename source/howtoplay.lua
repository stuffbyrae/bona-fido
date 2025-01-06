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
	}
	if ribbit then
		assets.bark = smp.new('audio/sfx/croak')
	else
		assets.bark = smp.new('audio/sfx/bark')
	end

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

		BButtonDown = function()
			if save.sfx then assets.bark:play(1, 1 + (0.01 * math.random(-10, 10))) end
			scenemanager:switchscene(title)
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
			assets.newsleak:drawText(text("howtoplay1"), 10, 10)
			assets.newsleak:drawTextAligned(text("howtoplay_ask1"), 390, 190, kTextAlignment.right)
		elseif vars.page == 2 then -- Basic controls
			assets.newsleak:drawText(text("howtoplay2"), 10, 10)
			assets.newsleak:drawTextAligned(text("howtoplay_ask2"), 390, 190, kTextAlignment.right)
		elseif vars.page == 3 then -- Enemy types
			assets.newsleak:drawText(text("howtoplay3"), 10, 10)
			assets.newsleakbold:drawText(text("howtoplay_enemy1_name"), 260, 15)
			assets.newsleak:drawText(text("howtoplay_enemy1_desc"), 260, 30)
			assets.newsleak:drawTextAligned(text("howtoplay_enemy1_pts"), 235, 45, kTextAlignment.center)
			assets.newsleakbold:drawText(text("howtoplay_enemy2_name"), 260, 75)
			assets.newsleak:drawText(text("howtoplay_enemy2_desc"), 260, 90)
			assets.newsleak:drawTextAligned(text("howtoplay_enemy2_pts"), 235, 105, kTextAlignment.center)
			assets.newsleakbold:drawText(text("howtoplay_enemy3_name"), 260, 135)
			assets.newsleak:drawText(text("howtoplay_enemy3_desc"), 260, 150)
			assets.newsleak:drawTextAligned(text("howtoplay_enemy3_pts"), 235, 165, kTextAlignment.center)
			assets.newsleak:drawTextAligned(text("howtoplay_ask3"), 390, 190, kTextAlignment.right)
		elseif vars.page == 4 then -- Dig-ups types
			assets.newsleak:drawText(text("howtoplay4"), 10, 10)
			assets.newsleak:drawTextAligned(text("howtoplay_digups_pts_1"), 300, 55, kTextAlignment.center)
			assets.newsleak:drawTextAligned(text("howtoplay_digups_pts_2"), 300, 145, kTextAlignment.center)
			assets.newsleak:drawTextAligned(text("howtoplay_ask4"), 390, 190, kTextAlignment.right)
		end
		assets.newsleak:drawTextAligned(text("howtoplay_igetitnow"), 390, 210, kTextAlignment.right)
		assets.newsleak:drawText(text("pressA"), 10, 170 + (20 * vars.selection))
		gfx.setColor(gfx.kColorXOR)
		gfx.fillRect(0, 170 + (20 * vars.selection), 400, 20)
		gfx.setColor(gfx.kColorBlack)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end)
	self:add()
end

function howtoplay:update()
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