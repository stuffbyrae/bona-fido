import 'gameover'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local text <const> = gfx.getLocalizedText

class('game').extends(gfx.sprite) -- Create the scene's class
function game:init(...)
	game.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here

	function pd.gameWillPause() -- When the game's paused...
		local menu = pd.getSystemMenu()
		menu:removeAllMenuItems()
		if sprites.fido.control then
			menu:addMenuItem(text('endgame'), function()
				vars.lives = 1
				sprites.fido:die(0)
			end)
		end
	end

	assets = { -- All assets go here. Images, sounds, fonts, etc.
		newsleak = gfx.font.new('fonts/newsleak-bold'),
		collision = gfx.image.new('images/gameplay'),
		jump = smp.new('audio/sfx/jump'),
		run = smp.new('audio/sfx/run'),
		bonk = smp.new('audio/sfx/bonk'),
		ground = smp.new('audio/sfx/ground'),
		skid = smp.new('audio/sfx/skid'),
		die = smp.new('audio/sfx/die'),
		win = smp.new('audio/sfx/win'),
		bark_img = gfx.imagetable.new('images/bark'),
		enemy1 = gfx.imagetable.new('images/enemy1'),
		enemy2 = gfx.imagetable.new('images/enemy2'),
		enemy3 = gfx.imagetable.new('images/enemy3'),
		digup = smp.new('audio/sfx/digup'),
		digging = smp.new('audio/sfx/digging'),
		digup_img = gfx.imagetable.new('images/digup'),
		digup1 = gfx.image.new('images/digup1'),
		digup2 = gfx.image.new('images/digup2'),
		digup3 = gfx.image.new('images/digup3'),
		digup4 = gfx.image.new('images/digup4'),
		digup5 = gfx.image.new('images/digup5'),
		digupbark = gfx.image.new('images/digupbark'),
	}
	if ribbit then
		assets.bark = smp.new('audio/sfx/croak')
		assets.fido = gfx.imagetable.new('images/ribbit')
		assets.life = gfx.image.new('images/life_ribbit')
	else
		assets.bark = smp.new('audio/sfx/bark')
		assets.fido = gfx.imagetable.new('images/fido')
		assets.life = gfx.image.new('images/life')
	end

	function draw_block(x, y, width, height, num)
		if num == 2 then -- Normal platform drawing
			gfx.setColor(gfx.kColorWhite)
			gfx.setDitherPattern(0.5, gfx.image.kDitherTypeDiagonalLine)
			gfx.fillRect(x, y, width, height)
			gfx.setColor(gfx.kColorWhite)
			gfx.fillRect(x+2, y+2, width-4, height-4)
		elseif num == 3 then -- Mud platform drawing
			gfx.setColor(gfx.kColorWhite)
			gfx.setDitherPattern(0.75, gfx.image.kDitherTypeDiagonalLine)
			gfx.fillRect(x, y, width, height)
			gfx.setColor(gfx.kColorBlack)
			gfx.fillRect(x+2, y+2, width-4, height-4)
		elseif num == 4 then -- Ice platform drawing
			gfx.setColor(gfx.kColorWhite)
			gfx.setDitherPattern(0.5, gfx.image.kDitherTypeDiagonalLine)
			gfx.fillRect(x, y, width, height)
			gfx.setColor(gfx.kColorWhite)
		end

	end

	vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
		level = args[1] or 1,
		score = args[2] or 0,
		lives = args[3] or 3,
		show_level = true,
		tags = {
			fido = 1,
			platform = 2,
			platform_mud = 3,
			platform_ice = 4,
			digup = 5,
			enemy = 6,
			bark = 7,
		},
		won = false,
		ground = gfx.sprite.addEmptyCollisionSprite(0, 210, 400, 30),
		walk_timer = pd.timer.new(300, 1, 6.99),
		death_timer = pd.timer.new(0, 17, 17),
		bark_timer = pd.timer.new(200, 1, 4.99),
		enemy_timer = pd.timer.new(700, 1, 2.99),
		dig_timer = pd.timer.new(350, 22, 25.99),
		counter = 0,
		enemies = {},
		barks = 3,
	}
	vars.gameHandlers = {
		leftButtonDown = function()
			if sprites.fido.control then
				sprites.fido.left = true
				sprites.fido.direction = "left"
			end
		end,

		leftButtonUp = function()
			if sprites.fido.control then
				sprites.fido.left = false
			end
		end,

		rightButtonDown = function()
			if sprites.fido.control then
				sprites.fido.right = true
				sprites.fido.direction = "right"
			end
		end,

		rightButtonUp = function()
			if sprites.fido.control then
				sprites.fido.right = false
			end
		end,

		AButtonDown = function()
			sprites.fido:jump()
		end,

		BButtonDown = function()
			sprites.fido:bark()
		end
	}

	vars.walk_timer.repeats = true
	vars.bark_timer.repeats = true
	vars.enemy_timer.repeats = true
	vars.death_timer.discardOnCompletion = false
	vars.dig_timer.repeats = true

	vars.ground:setTag(vars.tags.platform)

	if not (vars.level % 20 > 5 or vars.level % 20 == 0) then
		vars.platform4 = gfx.sprite.addEmptyCollisionSprite(0, 90, 95, 10)
		if vars.level % 5 == 0 then
			vars.platform4:setTag(vars.tags.platform_ice)
		elseif vars.level % 8 == 0 then
			vars.platform4:setTag(vars.tags.platform_ice)
		else
			vars.platform4:setTag(vars.tags.platform)
		end
	end
	if not (vars.level % 20 > 10 or vars.level % 20 == 0) then
		vars.platform3 = gfx.sprite.addEmptyCollisionSprite(305, 90, 95, 10)
		if vars.level % 6 == 0 then
			vars.platform3:setTag(vars.tags.platform_ice)
		elseif vars.level % 11 == 0 then
			vars.platform3:setTag(vars.tags.platform_mud)
		else
			vars.platform3:setTag(vars.tags.platform)
		end
	end
	if not (vars.level % 20 > 15 or vars.level % 20 == 0) then
		vars.platform2 = gfx.sprite.addEmptyCollisionSprite(0, 155, 135, 10)
		if vars.level % 3 == 0 then
			vars.platform2:setTag(vars.tags.platform_ice)
		elseif vars.level % 9 == 0 then
			vars.platform2:setTag(vars.tags.platform_mud)
		else
			vars.platform2:setTag(vars.tags.platform)
		end
	end
	vars.platform1 = gfx.sprite.addEmptyCollisionSprite(265, 155, 135, 10)
	if vars.level % 7 == 0 then
		vars.platform1:setTag(vars.tags.platform_ice)
	elseif vars.level % 10 == 0 then
		vars.platform1:setTag(vars.tags.platform_mud)
	else
		vars.platform1:setTag(vars.tags.platform)
	end

	for i = 1, 4 + ((vars.level - 1) % 5) + math.floor((vars.level - 1) / 5) do
		if vars.level < 5 then
			table.insert(vars.enemies, 1)
		elseif vars.level < 10 then
			local random = math.random(1, 5)
			if random == 1 or random == 2 or random == 3 then
				table.insert(vars.enemies, 1)
			else
				table.insert(vars.enemies, 2)
			end
		else
			local random = math.random(1, 15)
			if random == 1 or random == 2 or random == 3 or random == 4 or random == 5 or random == 6 then
				table.insert(vars.enemies, 1)
			elseif random == 7 or random == 8 or random == 9 or random == 10 or random == 11 then
				table.insert(vars.enemies, 2)
			else
				table.insert(vars.enemies, 3)
			end
		end
	end

	gfx.pushContext(assets.collision)
		gfx.setColor(gfx.kColorWhite)
		draw_block(0, 210, 400, 30, 2)
		if vars.platform1 ~= nil then
			draw_block(265, 155, 135, 10, vars.platform1:getTag())
		end
		if vars.platform2 ~= nil then
			draw_block(0, 155, 135, 10, vars.platform2:getTag())
		end
		if vars.platform3 ~= nil then
			draw_block(305, 90, 95, 10, vars.platform3:getTag())
		end
		if vars.platform4 ~= nil then
			draw_block(0, 90, 95, 10, vars.platform4:getTag())
		end
	gfx.popContext()

	gfx.sprite.setBackgroundDrawingCallback(function(width, height, x, y)
		assets.collision:draw(0, 0) -- Draw the stage
		-- Draw the life counter
		for i = 1, vars.lives do
			assets.life:draw(-15 + (25 * i), 10)
		end
		-- Draw the score & level indicator
		if vars.show_level then
			gfx.fillRect(150, 85, 100, 45)
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			if sprites.fido.control then
				if vars.show_level then assets.newsleak:drawTextAligned(text("ready"), 200, 105, kTextAlignment.center) end
			end
			if vars.show_level then assets.newsleak:drawTextAligned(text("level") .. commalize(vars.level), 200, 85, kTextAlignment.center) end
			gfx.setImageDrawMode(gfx.kDrawModeCopy)
		end
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		assets.newsleak:drawTextAligned(commalize(vars.score), 390, 10, kTextAlignment.right)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
		assets.newsleak:drawText(text('barks') .. vars.barks, 10, 216)
	end)

	class('game_fido', _, classes).extends(gfx.sprite)
	function classes.game_fido:init()
		classes.game_fido.super.init(self)
		self:setCenter(0.5, 1)
		self:setImage(assets.fido[1])
		self:setCollideRect(6, 6, 20, 26)
		self:setZIndex(4)
		self:moveTo(200, 200)
		self:setTag(vars.tags.fido)
		self.control = false
		self.invincible = false
		self.barking = false
		self.digging = false
		self.landing = false
		self.left = false
		self.right = false
		self.deathspeed = 0
		self.direction = "left"
		self.horispeed = 0
		self.velocity = 0
		self.movemax = 5
		self.speedup = 0.75
		self.slowdown = 1
		self.jumping = false
		self:add()
	end
	function classes.game_fido:update()
		local x = self.x
		local y = self.y

		-- Governing run SFX
		if save.sfx and (self.left or self.right) and not ribbit and not self.digging then -- If the player's running, then
			if assets.run:isPlaying() then -- Make sure the SFX isn't playing already.
				if self.velocity ~= 0 then -- If the player's not on the ground,
					assets.run:stop() -- stop it!
				end
			else -- If the sound isn't already playing,
				if self.velocity == 0 then -- and the player's on the ground,
					assets.run:play(0, 1 + (0.01 * math.random(-10, 10))) -- then start playing the run noise.
				end
			end
		else -- If the player's not running,
			if save.sfx and assets.run:isPlaying() then assets.run:stop() end -- then stop the SFX.
		end

		-- Falling sprite
		if self.velocity < 0 then
			self:setImage(assets.fido[8])
		elseif self.velocity > 0 then
			self:setImage(assets.fido[9])
		end

		-- Jump height change — so holding A down during a jump will make you jump higher.
		if self.jumping and self.velocity < 0 and pd.buttonIsPressed('a') then
			self.velocity += 1.8 -- "Holding A during the jump" velocity
		else
			self.velocity += 2.5 -- Regular velocity, which gets added every frame.
		end

		-- Move the dog! And check for collisions.
		local actualx
		local actualy
		local collisions
		local length

		if self.control then
			actualx, actualy, collisions, length = self:moveWithCollisions(x + self.horispeed, y + self.velocity)
		else
			self:moveBy(self.deathspeed, -math.abs(self.deathspeed) / 2)
			if self.deathspeed >= 0 then
				self.deathspeed -= 0.25
				self.deathspeed = math.max(self.deathspeed, 0)
			elseif self.deathspeed <= 0 then
				self.deathspeed += 0.25
				self.deathspeed = math.min(self.deathspeed, 0)
			end
		end

		if length ~= nil and length > 0 then -- If there are any collisions...
			for i = 1, #collisions do
				local tag = collisions[i].other:getTag() -- Store the tag.
				local collx, colly = collisions[i].normal:unpack() -- Collision normal to determine hit directions
				if tag == 2 or tag == 3 or tag == 4 then -- 2, 3, and 4 indicate the three platform types.
					-- Horizontal movement speeds
					if ribbit then
						self.movemax = 7 -- The max speed
						self.speedup = 1.25 -- The rate at which the player speeds up (per frame)
						self.slowdown = 4 -- The rate at which the player comes to a stop.
					else
						self.movemax = 5 -- The max speed
						self.speedup = 0.75 -- The rate at which the player speeds up (per frame)
						self.slowdown = 1 -- The rate at which the player comes to a stop.
					end
					if tag == 3 then -- For muddy platforms,
						self.movemax /= 2 -- make the player slower.
					elseif tag == 4 then -- For icy platforms,
						self.slowdown /= 3 -- make the player more slippery.
					end

					if colly ~= 0 then -- If the player is hitting their head or feet...
						if colly == 1 and save.sfx then -- If they're hitting their head,
							assets.bonk:play(1, 1 + (0.01 * math.random(-10, 10))) -- BONK!
						end
						if colly == -1 then -- If they're landing on their feet,
							if self.jumping then self.jumping = false end -- end any jumps.
							if self.velocity > 10 then
								if save.sfx then assets.ground:play(1, 1 + (0.01 * math.random(-10, 10))) end
								self.landing = true
								pd.timer.performAfterDelay(50, function()
									self.landing = false
								end)
							end
						end
						self.velocity = 0 -- Reset the player velocity,
						self:setImage(assets.fido[1]) -- reset their player sprite,
						if save.sfx then assets.jump:stop() end -- and stop any jumping noise.
					end
				elseif tag == 6 and not collisions[i].other.dead and not self.invincible then
					self:die(collx)
				end
			end
		end

		if pd.buttonIsPressed('up') and self.control then self:setImage(assets.fido[20]) end
		if pd.buttonIsPressed('down') and self.control then self:setImage(assets.fido[21]) end

		if not self.jumping and self.velocity == 0 then -- If the player's not jumping or falling,
			if (self.left or self.right) and not ribbit then -- If they're walking,
				self:setImage(assets.fido[math.floor(vars.walk_timer.value)]) -- display the walking sprite.
			end
			if (self.left and self.horispeed > 0) or (self.right and self.horispeed < 0) and not ribbit then -- If they're skidding (pressing one way, walking another);
				self:setImage(assets.fido[7]) -- show the skid sprite,
				if save.sfx then assets.skid:play(1, 1 + (0.01 * math.random(-10, 10))) end -- and play the skid SFX.
			end
		end

		local crank = pd.getCrankChange()
		if #playdate.inputHandlers > 1 and self.control then
			if crank < 1.5 and crank > -1.5 then
				if save.sfx then assets.digging:stop() end
				self.digging = false
			else
				self.digging = true
				if save.sfx and not assets.digging:isPlaying() then assets.digging:play(0) end
			end
		else
			if save.sfx then assets.digging:stop() end
			self.digging = false
		end

		-- Movement code
		if self.left and ((ribbit and self.jumping) or not ribbit) and not self.digging then
			if self.horispeed > -self.movemax then -- If the player's not at the movement speed yet,
				if self.horispeed > 0 then -- If they're turning around,
					self.horispeed -= 0 -- do nothing, let the slowdown code handle it.
				else
					self.horispeed -= self.speedup -- Otherwise, speed 'em up!'
				end
			elseif self.horispeed < -self.movemax then -- If they're *above* the movement speed,
				self.horispeed = -self.movemax -- lock them back down.
			end
		else
			if self.horispeed < 0 then -- If they're not touching this button,
				self.horispeed += self.slowdown -- slow them down,
				self.horispeed = math.min(self.horispeed, 0) -- and eventually lock 'em down at 0.
			end
		end

		-- Movement code, this time to the right. Follow the comments above.
		if self.right and ((ribbit and self.jumping) or not ribbit) and not self.digging then
			if self.horispeed < self.movemax then
				if self.horispeed < 0 then
					self.horispeed += 0
				else
					self.horispeed += self.speedup
				end
			elseif self.horispeed > self.movemax then
				self.horispeed = self.movemax
			end
		else
			if self.horispeed > 0 then
				self.horispeed -= self.slowdown
				self.horispeed = math.max(self.horispeed, 0)
			end
		end

		if not self.control then
			if vars.death_timer.timeLeft ~= 0 then
				self:setImage(assets.fido[math.floor(vars.death_timer.value)])
			else
				self:setImage(assets.fido[17])
			end
		end

		-- Screen wrapping code
		if x < 0 then self:moveTo(400, y) end
		if x > 400 then self:moveTo(0, y) end

		if self.digging then self:setImage(assets.fido[math.floor(vars.dig_timer.value)]) end

		if self.barking then self:setImage(assets.fido[18]) end
		if self.landing then self:setImage(assets.fido[10]) end

		-- Sprite flipping code
		if self.direction == "left" then self:setImageFlip('unflipped') end
		if self.direction == "right" then self:setImageFlip('flipX') end

		if pd.getReduceFlashing() then
			if math.floor(vars.counter / 4) % 2 == 0 and self.invincible then self:setImage(assets.fido[17]) end
		else
			if vars.counter % 2 == 0 and self.invincible then self:setImage(assets.fido[17]) end
		end

		-- SFX stereo panning
		assets.run:setVolume(map(self.x, 0, 400, 0.8, 0.2), map(self.x, 0, 400, 0.2, 0.8))
		assets.jump:setVolume(map(self.x, 0, 400, 0.8, 0.2), map(self.x, 0, 400, 0.2, 0.8))
		assets.skid:setVolume(map(self.x, 0, 400, 0.8, 0.2), map(self.x, 0, 400, 0.2, 0.8))
		assets.bonk:setVolume(map(self.x, 0, 400, 0.8, 0.2), map(self.x, 0, 400, 0.2, 0.8))
		assets.bark:setVolume(map(self.x, 0, 400, 0.8, 0.2), map(self.x, 0, 400, 0.2, 0.8))
		assets.ground:setVolume(map(self.x, 0, 400, 0.8, 0.2), map(self.x, 0, 400, 0.2, 0.8))
		assets.die:setVolume(map(self.x, 0, 400, 0.8, 0.2), map(self.x, 0, 400, 0.2, 0.8))
	end
	function classes.game_fido:jump()
		if not self.jumping and self.velocity == 0 and not self.digging and self.control then
			self.velocity = -19
			self.jumping = true
			self.horispeed /= 1.1
			if save.sfx then assets.jump:play(1, 1 + (0.01 * math.random(-10, 10))) end
		end
	end
	function classes.game_fido:bark()
		if self.control and not self.barking and not self.digging and vars.barks > 0 then
			if save.sfx then assets.bark:play(1, 1 + (0.01 * math.random(-10, 10))) end
			self.barking = true
			pd.timer.performAfterDelay(50, function()
				self.barking = false
			end)
			vars.barks -= 1
			gfx.sprite.redrawBackground()
		end
	end
	function classes.game_fido:die(normal)
		if self.control then
			shakies()
			shakies_y()
			self.control = false
			self.left = false
			self.right = false
			self.jumping = false
			local horideathspeed
			self.deathspeed = normal * 2
			vars.death_timer:resetnew(500, 12, 17.99)
			if save.sfx then assets.die:play() end
			vars.lives -= 1
			if vars.lives <= 0 then
				fademusic(700)
			end
			gfx.sprite.redrawBackground()
			pd.timer.performAfterDelay(2000, function()
				if vars.lives <= 0 then
					scenemanager:switchscene(gameover, vars.level, vars.score)
				elseif not vars.won then
					vars.barks = 3
					gfx.sprite.redrawBackground()
					if save.sfx then assets.bark:play(1, 1 + (0.01 * math.random(-10, 10))) end
					self.invincible = true
					pd.timer.performAfterDelay(2000, function()
						self.invincible = false
					end)
					self:moveTo(200, 220)
					self.control = true
				end
			end)
		end
	end
	function classes.game_fido:collisionResponse(other)
		if other:getTag() == 5 or other:getTag() == 6 or other:getTag() == 7 then
			return gfx.sprite.kCollisionTypeOverlap
		else
			return gfx.sprite.kCollisionTypeSlide
		end
	end

	class('game_bark', _, classes).extends(gfx.sprite)
	function classes.game_bark:init()
		classes.game_bark.super.init(self)
		self:setSize(60, 40)
		self:setCollideRect(0, 0, 60, 40)
		self:setTag(vars.tags.bark)
		self.blank = gfx.image.new(60, 40)
		self:add()
	end
	function classes.game_bark:update()
		if sprites.fido.direction == "left" then
			self:moveTo((sprites.fido.x - 20) % 400, sprites.fido.y - 15)
		elseif sprites.fido.direction == "right" then
			self:moveTo((sprites.fido.x + 20) % 400, sprites.fido.y - 15)
		end

		if sprites.fido.barking then
			self:setImage(assets.bark_img[math.floor(vars.bark_timer.value)])
		else
			self:setImage(self.blank)
		end

		-- Sprite flipping code
		if sprites.fido.direction == "left" then self:setImageFlip('unflipped') end
		if sprites.fido.direction == "right" then self:setImageFlip('flipX') end
	end

	class('game_digup', _, classes).extends(gfx.sprite)
	function classes.game_digup:init(x, y, type)
		classes.game_digup.super.init(self)
		self:moveTo(x, y)
		self:setSize(34, 50)
		self:setCollideRect(0, 0, 34, 50)
		self:setTag(vars.tags.digup)
		self.progress = 0
		self.dug = false
		self.dug_timer = pd.timer.new(0, 18, 18)
		self.dug_timer.discardOnCompletion = false
		if save.sfx then assets.digup:play() end
		self.anim_timer = pd.timer.new(500, 1, 6)
		self:setCenter(0.5, 1)
		self.barkless = false
		self.type = type
		self:add()
	end
	function classes.game_digup:update()
		local actualx, actualy, collisions, length = self:moveWithCollisions(self.x, self.y)

		local fido_hit = false

		if length > 0 then
			for i = 1, length do
				local tag = collisions[i].other:getTag()
				if tag == 1 then
					fido_hit = true
				end
			end
		end

		if not sprites.fido.control then fido_hit = false end
		if self.dug then fido_hit = false end

		if fido_hit and sprites.fido.digging then
			local crank = pd.getCrankChange()
			if crank == 0 then
				self.progress -= 100
				if self.progress < 0 then self.progress = 0 end
			else
				self.progress += crank
				if self.progress >= 1800 then
					self:dig()
				end
			end
		else
			self.progress = 0
		end

		-- SFX stereo panning
		assets.win:setVolume(map(self.x, 0, 400, 0.8, 0.2), map(self.x, 0, 400, 0.2, 0.8))
		assets.digging:setVolume(map(self.x, 0, 400, 0.8, 0.2), map(self.x, 0, 400, 0.2, 0.8))
		assets.digup:setVolume(map(self.x, 0, 400, 0.8, 0.2), map(self.x, 0, 400, 0.2, 0.8))
		self:markDirty()
	end
	function classes.game_digup:draw()
		if self.dug then
			if self.barkless then
				assets['digupbark']:draw(0, self.dug_timer.value)
			else
				assets['digup' .. self.type]:draw(0, self.dug_timer.value)
			end
		else
			assets.digup_img[math.floor(self.anim_timer.value)]:draw(0, 18)
		end
	end
	function classes.game_digup:dig()
		if not self.dug then
			self.dug = true
			self:setZIndex(5)
			self.dug_timer:resetnew(1000, 32, 0, pd.easingFunctions.outSine)
			if vars.barks == 0 then
				self.barkless = true
				vars.barks = 3
				if save.sfx then assets.bark:play() end
				gfx.sprite.redrawBackground()
			else
				if self.type == 1 then
					game:changescore(100)
					if save.sfx then assets.win:play(1, 2) end
				elseif self.type == 2 then
					game:changescore(300)
					if save.sfx then assets.win:play(1, 2) end
				elseif self.type == 3 then
					game:changescore(500)
					if save.sfx then assets.win:play(1, 2) end
				elseif self.type == 4 then
					game:changescore(-250)
					if save.sfx then assets.die:play() end
				elseif self.type == 5 then
					game:changescore(-500)
					if save.sfx then assets.die:play() end
				end
			end
			gfx.sprite.redrawBackground()
			if save.sfx then assets.digging:stop() end
			pd.timer.performAfterDelay(1000, function()
				pd.timer.performAfterDelay(math.random(10000, 15000), function()
					game:new_digup()
				end)
				self:remove()
			end)
		end
	end
	function classes.game_digup:collisionResponse()
		return gfx.sprite.kCollisionTypeOverlap
	end

	class('game_enemy', _, classes).extends(gfx.sprite)
	function classes.game_enemy:init(type, x, y, direction, slot)
		classes.game_enemy.super.init(self)
		self:setCenter(0.5, 1)
		self:setCollideRect(0, 0, 34, 34)
		self:moveTo(x, y)
		self:setTag(vars.tags.enemy)
		self.dead = false
		self.slot = slot
		self.queuedfordeletion = false
		self.type = type -- 1, 2, or 3.
		self.direction = direction
		self.left = false
		self.right = false
		if self.direction == "left" then
			self.left = true
		elseif self.direction == "right" then
			self.right = true
		end
		self.jumping = false
		self.horispeed = 0
		self.velocity = 0
		if self.type == 1 then
			self.movemax = 3
		elseif self.type == 2 then
			self.movemax = 4
		elseif self.type == 3 then
			self.movemax = 4.5
		end
		self.speedup = 0.75
		self.slowdown = 0.5
		-- self:add()
	end
	function classes.game_enemy:update()
		local x = self.x
		local y = self.y

		if not self.dead then -- If the CPU's not dead...
			self.velocity += 2.5

			local random
			if self.type == 1 then
				random = math.random(1, 100)
			elseif self.type == 2 then
				random = math.random(1, 45)
			elseif self.type == 3 then
				random = math.random(1, 75)
			end
			if random == 1 and not self.jumping then
				self.right = false
				self.left = true
				self.direction = "left"
			elseif random == 2 and not self.jumping then
				self.left = false
				self.right = true
				self.direction = "right"
			end

			local actualx, actualy, collisions, length = self:moveWithCollisions(x + self.horispeed, y + self.velocity)

			if length > 0 then
				for i = 1, length do
					local tag = collisions[i].other:getTag() -- Store the tag.
					local collx, colly = collisions[i].normal:unpack() -- Collision normal to determine hit directions
					if tag == 2 or tag == 3 or tag == 4 then -- 2, 3, and 4 indicate the three platform types.
						-- Horizontal movement speeds
						if self.type == 1 then
							self.movemax = 2
						elseif self.type == 2 then
							self.movemax = 1.75
						elseif self.type == 3 then
							self.movemax = 3
						end
						self.speedup = 0.75 -- The rate at which the player speeds up (per frame)
						self.slowdown = 1 -- The rate at which the player comes to a stop.
						if tag == 3 then -- For muddy platforms,
							self.movemax /= 2 -- make the player slower.
						elseif tag == 4 then -- For icy platforms,
							self.slowdown /= 3 -- make the player more slippery.
						end

						if colly ~= 0 then -- If the player is hitting their head or feet...
							if colly == -1 then -- If they're landing on their feet,
								if self.jumping then self.jumping = false end -- end any jumps.
							end
							self.velocity = 0 -- Reset the player velocity,
						end
					elseif tag == 7 and sprites.fido.barking then
						self:die(collx)
					end
				end
			end

			-- Movement code. Refer to Fido about this.
			if self.left then
				if self.horispeed > -self.movemax then
					if self.horispeed > 0 then
						self.horispeed -= 0
					else
						self.horispeed -= self.speedup
					end
				elseif self.horispeed < -self.movemax then
					self.horispeed = -self.movemax
				end
			else
				if self.horispeed < 0 then
					self.horispeed += self.slowdown
					self.horispeed = math.min(self.horispeed, 0)
				end
			end

			if self.right then
				if self.horispeed < self.movemax then
					if self.horispeed < 0 then
						self.horispeed += 0
					else
						self.horispeed += self.speedup
					end
				elseif self.horispeed > self.movemax then
					self.horispeed = self.movemax
				end
			else
				if self.horispeed > 0 then
					self.horispeed -= self.slowdown
					self.horispeed = math.max(self.horispeed, 0)
				end
			end

			if self.type == 1 then
				-- Jumps — platform level 1
				if x >= 160 and x <= 200 then
					if math.random(1, 20) == 1 and self.direction == "left" then
						self:jump()
					end
				end
				if x >= 200 and x <= 240 then
					if math.random(1, 20) == 1 and self.direction == "right" then
						self:jump()
					end
				end
			elseif self.type == 2 then
				-- Jumps — platform level 1
				if x >= 160 and x <= 200 then
					if math.random(1, 10) == 1 and self.direction == "left" then
						self:jump()
					end
				end
				if x >= 200 and x <= 240 then
					if math.random(1, 10) == 1 and self.direction == "right" then
						self:jump()
					end
				end

				-- Jumps — platform level 2
				if x >= 100 and x <= 140 then
					if math.random(1, 20) == 1 and self.direction == "left" then
						self:jump()
					end
				end
				if x >= 260 and x <= 300 then
					if math.random(1, 20) == 1 and self.direction == "right" then
						self:jump()
					end
				end
			elseif self.type == 3 then
				-- Jumps — platform level 1
				if x >= 170 and x <= 200 then
					if math.random(1, 5) == 1 and self.direction == "left" then
						self:jump()
					end
				end
				if x >= 200 and x <= 230 then
					if math.random(1, 5) == 1 and self.direction == "right" then
						self:jump()
					end
				end

				-- Jumps — platform level 2
				if x >= 110 and x <= 140 then
					if math.random(1, 8) == 1 and self.direction == "left" then
						self:jump()
					end
				end
				if x >= 260 and x <= 290 then
					if math.random(1, 8) == 1 and self.direction == "right" then
						self:jump()
					end
				end
			end

			self:setImage(assets['enemy' .. self.type][math.floor(vars.enemy_timer.value)])

			-- Screen wrapping code
			if x < 0 then self:moveTo(400, y) end
			if x > 400 then self:moveTo(0, y) end

			-- Sprite flipping code
			if self.direction == "left" then
				if self.dead then
					self:setImageFlip('flipY')
				else
					self:setImageFlip('unflipped')
				end
			end
			if self.direction == "right" then
				if self.dead then
					self:setImageFlip('flipXY')
				else
					self:setImageFlip('flipX')
				end
			end
		else -- Oh, the CPU's dead.
			self.velocity += 2 -- Make him a bit floatier.
			self:moveBy(self.deathspeed, self.velocity)
			if self.deathspeed >= 0 then
				self.deathspeed -= 0.25
				self.deathspeed = math.max(self.deathspeed, 0)
			elseif self.deathspeed <= 0 then
				self.deathspeed += 0.25
				self.deathspeed = math.min(self.deathspeed, 0)
			end
			if self.y >= 240 and not self.queuedfordeletion then
				self.queuedfordeletion = true
				self:remove()
				pd.timer.performAfterDelay(1000, function()
					game:new_enemy(self.slot)
				end)
			end
		end
	end
	function classes.game_enemy:jump()
		if not self.jumping and self.velocity == 0 then
			self.velocity = -21
			self.jumping = true
			self.horispeed /= 1.1
		end
	end
	function classes.game_enemy:die(normal)
		if not self.dead then
			if save.sfx then assets.die:play() end
			normal = normal or 0
			self.dead = true
			self.deathspeed = normal * 3
			pd.timer.performAfterDelay(1, function()
				self.velocity = -10
			end)
			if self.type == 1 then
				game:changescore(100)
			elseif self.type == 2 then
				game:changescore(300)
			elseif self.type == 3 then
				game:changescore(500)
			end
			gfx.sprite.redrawBackground()
		end
	end
	function classes.game_enemy:collisionResponse(other)
		if self.dead then
			return gfx.sprite.kCollisionTypeOverlap
		end
		if other:getTag() == 1 or other:getTag() == 5 or other:getTag() == 6 or other:getTag() == 7 then
			return gfx.sprite.kCollisionTypeOverlap
		else
			return gfx.sprite.kCollisionTypeSlide
		end
	end

	-- Set the sprites
	sprites.fido = classes.game_fido()
	sprites.bark = classes.game_bark()
	sprites.enemy1 = classes.game_enemy(1, -200, -200, "right", 1)
	sprites.enemy2 = classes.game_enemy(1, -200, -200, "right", 2)
	sprites.enemy3 = classes.game_enemy(1, -200, -200, "right", 3)
	sprites.enemy4 = classes.game_enemy(1, -200, -200, "right", 4)
	self:add()

	pd.timer.performAfterDelay(2500, function()
		gfx.sprite.redrawBackground()
		sprites.fido.control = true
	end)

	newmusic('audio/music/roundstart')

	pd.timer.performAfterDelay(4500, function()
		stopmusic()
		if ribbit then
			newmusic('audio/music/gameplay_ribbit', true, 1.555)
		else
			newmusic('audio/music/gameplay', true, 1.555)
		end
		if sprites.fido.control then
			pd.timer.performAfterDelay(1500, function()
				self:new_enemy(1)
			end)
			pd.timer.performAfterDelay(3000, function()
				self:new_enemy(2)
			end)
			if vars.level > 15 then
				pd.timer.performAfterDelay(4500, function()
					self:new_enemy(3)
				end)
			else
				sprites.enemy3.queuedfordeletion = true
			end
			if vars.level > 30 then
				pd.timer.performAfterDelay(6000, function()
					self:new_enemy(4)
				end)
			else
				sprites.enemy4.queuedfordeletion = true
			end
			vars.show_level = false
			pd.inputHandlers.push(vars.gameHandlers)
			gfx.sprite.redrawBackground()
			pd.timer.performAfterDelay(math.random(4000, 12500), function()
				self:new_digup()
			end)
		end
	end)
end

function game:new_enemy(slot)
	if #vars.enemies == 0 then
		if sprites.enemy1.queuedfordeletion and sprites.enemy2.queuedfordeletion and sprites.enemy3.queuedfordeletion and sprites.enemy4.queuedfordeletion and not vars.won and vars.lives > 0 then
			self:win()
		end
		return
	else
		local random = math.random(1, #vars.enemies)
		if slot == 1 then
			sprites.enemy1:init(vars.enemies[random], 30, -32, "right", 1)
			sprites.enemy1:add()
		elseif slot == 2 then
			sprites.enemy2:init(vars.enemies[random], 370, -32, "left", 2)
			sprites.enemy2:add()
		elseif slot == 3 then
			sprites.enemy3:init(vars.enemies[random], 30, -32, "right", 3)
			sprites.enemy3:add()
		elseif slot == 4 then
			sprites.enemy4:init(vars.enemies[random], 370, -32, "left", 4)
			sprites.enemy4:add()
		end
		table.remove(vars.enemies, random)
	end
end

function game:new_digup()
	if not sprites.fido.control then return end
	local level
	if vars.platform2 == nil and vars.platform1 == nil then
		level = 1
	elseif vars.platform4 == nil and vars.platform3 == nil then
		level = math.random(1, 2)
	else
		level = math.random(1, 3)
	end
	local platform
	local x = 0
	local y = 0
	local type = 1
	local typerand = math.random(1, 22)
	if level == 1 then
		y = 210
		x = math.random(16, 384)
	elseif level == 2 then
		y = 155
		platform = math.random(1, 2)
		if platform == 1 and vars.platform2 ~= nil then
			x = math.random(16, 116)
		else
			x = math.random(284, 384)
		end
	elseif level == 3 then
		y = 90
		platform = math.random(1, 2)
		if platform == 1 and vars.platform4 ~= nil then
			x = math.random(16, 76)
		else
			x = math.random(317, 384)
		end
	end
	if typerand == 1 or typerand == 2 or typerand == 3 or typerand == 4 or typerand == 5 or typerand == 6 or typerand == 7 then
		type = 1
	elseif typerand == 8 or typerand == 9 or typerand == 10 or typerand == 11 or typerand == 12 then
		type = 2
	elseif typerand == 13 or typerand == 14 or typerand == 15 then
		type = 3
	elseif typerand == 16 or typerand == 17 or typerand == 18 or typerand == 19 or typerand == 20 then
		type = 4
	elseif typerand == 21 or typerand == 22 then
		type = 5
	end
	if sprites.digup == nil then
		sprites.digup = classes.game_digup(x, y, type)
	else
		sprites.digup:init(x, y, type)
	end
end

function game:win()
	vars.won = true
	sprites.fido.control = false
	stopmusic()
	gfx.sprite.redrawBackground()
	assets.win:setVolume(0.8, 0.8)
	if save.sfx then assets.win:play() end
	pd.timer.performAfterDelay(2500, function()
		scenemanager:switchscene(game, vars.level + 1, vars.score, vars.lives)
	end)
end

function game:changescore(new)
	local oldscore = vars.score
	vars.score += new
	if vars.score < 0 then vars.score = 0 end
	if vars.lives <= 6 then
		if vars.score > oldscore then
			for i = 1, 100 do
				if oldscore < (i * 10000) and vars.score >= (i * 10000) then
					vars.lives += 1
					if save.sfx then assets.win:play() end
					gfx.sprite.redrawBackground()
				end
			end
		end
	end
end

function game:update()
	vars.counter += 1
end