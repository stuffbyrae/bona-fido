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
	end

	assets = { -- All assets go here. Images, sounds, fonts, etc.
		newsleak = gfx.font.new('fonts/newsleak-bold'),
		collision = gfx.image.new(400, 240, gfx.kColorClear),
		fido = gfx.imagetable.new('images/fido'),
		jump = smp.new('audio/sfx/jump'),
		run = smp.new('audio/sfx/run'),
		bark = smp.new('audio/sfx/bark'),
		bonk = smp.new('audio/sfx/bonk'),
		ground = smp.new('audio/sfx/ground'),
		skid = smp.new('audio/sfx/skid'),
		die = smp.new('audio/sfx/die'),
		win = smp.new('audio/sfx/win'),
		life = gfx.image.new('images/life'),
	}

	function draw_block(x, y, width, height, num)
		if num == 2 then -- Normal platform drawing
			gfx.setColor(gfx.kColorWhite)
			gfx.setDitherPattern(0.5, gfx.image.kDitherTypeDiagonalLine)
			gfx.fillRect(x, y, width, height)
			gfx.setColor(gfx.kColorWhite)
			gfx.fillRect(x+2, y+2, width-4, height-4)
		elseif num == 3 then -- Mud platform drawing
			gfx.setColor(gfx.kColorWhite)
			gfx.setDitherPattern(0.5, gfx.image.kDitherTypeDiagonalLine)
			gfx.fillRect(x, y, width, height)
			gfx.setColor(gfx.kColorBlack)
			gfx.setDitherPattern(0.75, gfx.image.kDitherTypeDiagonalLine)
			gfx.fillRect(x+2, y+2, width-4, height-4)
		elseif num == 4 then -- Ice platform drawing
			gfx.setColor(gfx.kColorWhite)
			gfx.setDitherPattern(0.5, gfx.image.kDitherTypeDiagonalLine)
			gfx.fillRect(x, y, width, height)
			gfx.setColor(gfx.kColorWhite)
			gfx.setDitherPattern(0.25, gfx.image.kDitherTypeDiagonalLine)
			gfx.fillRect(x+2, y+2, width-4, height-4)
		end

	end

	vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
		level = args[1] or 1,
		score = args[2] or 0,
		lives = 3,
		show_level = true,
		tags = {
			fido = 1,
			platform = 2,
			platform_mud = 3,
			platform_ice = 4,
			pickup = 5,
			enemy = 6,
		},
		ground = gfx.sprite.addEmptyCollisionSprite(0, 210, 400, 30),
		platform1 = gfx.sprite.addEmptyCollisionSprite(265, 155, 135, 10),
		platform2 = gfx.sprite.addEmptyCollisionSprite(0, 155, 135, 10),
		platform3 = gfx.sprite.addEmptyCollisionSprite(305, 90, 95, 10),
		platform4 = gfx.sprite.addEmptyCollisionSprite(0, 90, 95, 10),
		walk_timer = pd.timer.new(300, 1, 6.99),
		death_timer = pd.timer.new(0, 25, 25),
		counter = 0,
		enemies = {},
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
	pd.inputHandlers.push(vars.gameHandlers)

	vars.walk_timer.repeats = true
	vars.death_timer.discardOnCompletion = false

	-- TODO: put platform terrain "generation" here
	vars.ground:setTag(vars.tags.platform)

	if vars.level % 7 == 0 then
		vars.platform1:setTag(vars.tags.platform_ice)
	elseif vars.level % 12 == 0 then
		vars.platform1:setTag(vars.tags.platform_mud)
	else
		vars.platform1:setTag(vars.tags.platform)
	end
	if vars.level % 3 == 0 then
		vars.platform2:setTag(vars.tags.platform_ice)
	elseif vars.level % 10 == 0 then
		vars.platform2:setTag(vars.tags.platform_mud)
	else
		vars.platform2:setTag(vars.tags.platform)
	end
	if vars.level % 6 == 0 then
		vars.platform3:setTag(vars.tags.platform_ice)
	elseif vars.level % 13 == 0 then
		vars.platform3:setTag(vars.tags.platform_mud)
	else
		vars.platform3:setTag(vars.tags.platform)
	end
	if vars.level % 5 == 0 then
		vars.platform4:setTag(vars.tags.platform_ice)
	elseif vars.level % 9 == 0 then
		vars.platform4:setTag(vars.tags.platform_ice)
	else
		vars.platform4:setTag(vars.tags.platform)
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
		draw_block(265, 155, 135, 10, vars.platform1:getTag())
		draw_block(0, 155, 135, 10, vars.platform2:getTag())
		draw_block(305, 90, 95, 10, vars.platform3:getTag())
		draw_block(0, 90, 95, 10, vars.platform4:getTag())
	gfx.popContext()

	gfx.sprite.setBackgroundDrawingCallback(function(width, height, x, y)
		assets.collision:draw(0, 0) -- Draw the stage
		-- Draw the life counter
		for i = 1, vars.lives do
			assets.life:draw(-15 + (25 * i), 10)
		end
		-- Draw the score
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		if vars.show_level then assets.newsleak:drawTextAligned('Level ' .. vars.level, 200, 100, kTextAlignment.center) end
		assets.newsleak:drawTextAligned(vars.score, 390, 10, kTextAlignment.right)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end)

	class('game_fido').extends(gfx.sprite)
	function game_fido:init()
		game_fido.super.init(self)
		self:setCenter(0.5, 1)
		self:setImage(assets.fido[1])
		self:setCollideRect(0, 0, 32, 32)
		self:moveTo(200, 210)
		self:setTag(vars.tags.fido)
		self.control = false
		self.invincible = true
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
	function game_fido:update()
		local x = self.x
		local y = self.y

		-- Governing run SFX
		if save.sfx and (self.left or self.right) then -- If the player's running, then
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
			local tag = collisions[1].other:getTag() -- Store the tag.
			local collx, colly = collisions[1].normal:unpack() -- Collision normal to determine hit directions
			if tag == 2 or tag == 3 or tag == 4 then -- 2, 3, and 4 indicate the three platform types.
				-- Horizontal movement speeds
				self.movemax = 5 -- The max speed
				self.speedup = 0.75 -- The rate at which the player speeds up (per frame)
				self.slowdown = 1 -- The rate at which the player comes to a stop.
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
						if save.sfx and self.velocity > 10 then assets.ground:play(1, 1 + (0.01 * math.random(-10, 10))) end -- If you're falling far enough, play a whump sound.
					end
					self.velocity = 0 -- Reset the player velocity,
					self:setImage(assets.fido[1]) -- reset their player sprite,
					if save.sfx then assets.jump:stop() end -- and stop any jumping noise.
				end
			elseif tag == 6 and not collisions[1].other.dead and not self.invincible then
				self:die(collx)
			end
		end

		if not self.jumping and self.velocity == 0 then -- If the player's not jumping or falling,
			if (self.left or self.right) then -- If they're walking,
				self:setImage(assets.fido[math.floor(vars.walk_timer.value)]) -- display the walking sprite.
			end
			if (self.left and self.horispeed > 0) or (self.right and self.horispeed < 0) then -- If they're skidding (pressing one way, walking another);
				self:setImage(assets.fido[7]) -- show the skid sprite,
				if save.sfx then assets.skid:play(1, 1 + (0.01 * math.random(-10, 10))) end -- and play the skid SFX.
			end
		end

		-- Movement code
		if self.left then
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

		if not self.control then
			if vars.death_timer.timeLeft ~= 0 then
				self:setImage(assets.fido[math.floor(vars.death_timer.value)])
			else
				self:setImage(assets.fido[25])
			end
		end

		-- Screen wrapping code
		if x < 0 then self:moveTo(400, y) end
		if x > 400 then self:moveTo(0, y) end

		if pd.getReduceFlashing() then
			if math.floor(vars.counter / 4) % 2 == 0 and self.invincible then self:setImage(assets.fido[25]) end
		else
			if vars.counter % 2 == 0 and self.invincible then self:setImage(assets.fido[25]) end
		end

		-- Sprite flipping code
		if self.direction == "left" then self:setImageFlip('unflipped') end
		if self.direction == "right" then self:setImageFlip('flipX') end

		-- SFX stereo panning
		assets.run:setVolume(map(sprites.fido.x, 0, 400, 0.8, 0.2), map(sprites.fido.x, 0, 400, 0.2, 0.8))
		assets.jump:setVolume(map(sprites.fido.x, 0, 400, 0.8, 0.2), map(sprites.fido.x, 0, 400, 0.2, 0.8))
		assets.skid:setVolume(map(sprites.fido.x, 0, 400, 0.8, 0.2), map(sprites.fido.x, 0, 400, 0.2, 0.8))
		assets.bonk:setVolume(map(sprites.fido.x, 0, 400, 0.8, 0.2), map(sprites.fido.x, 0, 400, 0.2, 0.8))
		assets.ground:setVolume(map(sprites.fido.x, 0, 400, 0.8, 0.2), map(sprites.fido.x, 0, 400, 0.2, 0.8))
	end
	function game_fido:jump()
		if not self.jumping and self.velocity == 0 and self.control then
			self.velocity = -19
			self.jumping = true
			self.horispeed /= 1.1
			if save.sfx then assets.jump:play(1, 1 + (0.01 * math.random(-10, 10))) end
		end
	end
	function game_fido:bark()
		if self.control then
			if save.sfx then assets.bark:play(1, 1 + (0.01 * math.random(-10, 10))) end
		end
	end
	function game_fido:die(normal)
		if self.control then
			shakies()
			shakies_y()
			self.control = false
			self.left = false
			self.right = false
			self.jumping = false
			local horideathspeed
			self.deathspeed = normal * 2
			vars.death_timer:resetnew(1001, 12, 25)
			if save.sfx then assets.die:play() end
			vars.lives -= 1
			if vars.lives <= 0 then
				fademusic(700)
			end
			pd.timer.performAfterDelay(2000, function()
				if vars.lives <= 0 then
					scenemanager:switchscene(gameover, vars.level, vars.score)
				else
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
	function game_fido:collisionResponse(other)
		if other:getTag() == 6 then
			return gfx.sprite.kCollisionTypeOverlap
		else
			return gfx.sprite.kCollisionTypeSlide
		end
	end

	class('game_enemy').extends(gfx.sprite)
	function game_enemy:init(type, x, y)
		game_enemy.super.init(self)
		self:setImage(gfx.image.new(32, 32, gfx.kColorWhite))
		self:setCenter(0.5, 1)
		self:setCollideRect(0, 0, 32, 32)
		self:moveTo(x, y)
		self:setTag(vars.tags.enemy)
		self.dead = false
		self.queuedfordeletion = false
		self.type = type -- 1, 2, or 3.
		self.direction = "right"
		self.left = false
		self.right = true
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
		self:add()
	end
	function game_enemy:update()
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

			actualx, actualy, collisions, length = self:moveWithCollisions(x + self.horispeed, y + self.velocity)

			if length > 0 then
				local tag = collisions[1].other:getTag() -- Store the tag.
				local collx, colly = collisions[1].normal:unpack() -- Collision normal to determine hit directions
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

			-- Screen wrapping code
			if x < 0 then self:moveTo(400, y) end
			if x > 400 then self:moveTo(0, y) end

			-- Sprite flipping code
			if self.direction == "left" then self:setImageFlip('unflipped') end
			if self.direction == "right" then self:setImageFlip('flipX') end
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
				pd.timer.performAfterDelay(1000, function()
					game:new_enemy()
				end)
			end
		end
	end
	function game_enemy:jump()
		if not self.jumping and self.velocity == 0 then
			self.velocity = -21
			self.jumping = true
			self.horispeed /= 1.1
		end
	end
	function game_enemy:die(normal)
		normal = normal or 0
		self.dead = true
		self.velocity = -10
		self.deathspeed = normal * 2
		if self.type == 1 then
			vars.score += 100
		elseif self.type == 2 then
			vars.score += 300
		elseif self.type == 3 then
			vars.score += 500
		end
	end
	function game_enemy:collisionResponse(other)
		if self.dead then
			return gfx.sprite.kCollisionTypeOverlap
		end
		if other:getTag() == 1 or other:getTag() == 6 then
			return gfx.sprite.kCollisionTypeOverlap
		else
			return gfx.sprite.kCollisionTypeSlide
		end
	end

	-- Set the sprites
	sprites.fido = game_fido()
	self:add()

	pd.timer.performAfterDelay(2500, function()
		self:new_enemy()
		self:new_enemy()
		vars.show_level = false
		sprites.fido.control = true
		newmusic('audio/music/coolblast', true)
		pd.timer.performAfterDelay(2000, function()
			sprites.fido.invincible = false
		end)
	end)
end

function game:new_enemy()
	if #vars.enemies == 0 then
		if sprites.enemy1.queuedfordeletion and sprites.enemy2.queuedfordeletion then
			self:win()
		end
		return
	else
		local random = math.random(1, #vars.enemies)
		if sprites.enemy1 == nil then
			sprites.enemy1 = game_enemy(vars.enemies[random], 30, -32)
		elseif sprites.enemy1.queuedfordeletion then
			sprites.enemy1:remove()
			sprites.enemy1 = nil
			sprites.enemy1 = game_enemy(vars.enemies[random], 30, -32)
		elseif sprites.enemy2 == nil then
			sprites.enemy2 = game_enemy(vars.enemies[random], 370, -32)
		elseif sprites.enemy2.queuedfordeletion then
			sprites.enemy2:remove()
			sprites.enemy2 = nil
			sprites.enemy2 = game_enemy(vars.enemies[random], 370, -32)
		end
		table.remove(vars.enemies, random)
	end
end

function game:win()
	sprites.fido.control = false
	stopmusic()
	if save.sfx then assets.win:play() end
	pd.timer.performAfterDelay(2500, function()
		scenemanager:switchscene(game, vars.level + 1, vars.score)
	end)
end

function game:update()
	vars.counter += 1
	gfx.sprite.redrawBackground()
end