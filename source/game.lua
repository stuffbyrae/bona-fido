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
		bonk = smp.new('audio/sfx/bonk'),
		ground = smp.new('audio/sfx/ground'),
		skid = smp.new('audio/sfx/skid'),
		life = gfx.image.new('images/life'),
	}

	function draw_block(x, y, width, height)
		gfx.setColor(gfx.kColorWhite)
		gfx.setDitherPattern(0.5, gfx.image.kDitherTypeDiagonalLine)
		gfx.fillRect(x, y, width, height)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(x+2, y+2, width-4, height-4)
	end

	gfx.pushContext(assets.collision)
		gfx.setColor(gfx.kColorWhite)
		draw_block(0, 210, 400, 30)
		draw_block(265, 155, 135, 10)
		draw_block(0, 155, 135, 10)
		draw_block(305, 90, 95, 10)
		draw_block(0, 90, 95, 10)
	gfx.popContext()

	vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
		level = 1,
		score = 0,
		lives = 3,
		collision1 = gfx.sprite.addEmptyCollisionSprite(0, 210, 400, 30),
		collision2 = gfx.sprite.addEmptyCollisionSprite(265, 155, 135, 10),
		collision3 = gfx.sprite.addEmptyCollisionSprite(0, 155, 135, 10),
		collision4 = gfx.sprite.addEmptyCollisionSprite(305, 90, 95, 10),
		collision5 = gfx.sprite.addEmptyCollisionSprite(0, 90, 95, 10),
		walk_timer = pd.timer.new(300, 1, 6.99),
	}
	vars.gameHandlers = {
		leftButtonDown = function()
			sprites.fido.left = true
			sprites.fido.direction = "left"
		end,

		leftButtonUp = function()
			sprites.fido.left = false
		end,

		rightButtonDown = function()
			sprites.fido.right = true
			sprites.fido.direction = "right"
		end,

		rightButtonUp = function()
			sprites.fido.right = false
		end,

		AButtonDown = function()
			if not sprites.fido.jumping and sprites.fido.velocity == 0 then
				sprites.fido.velocity = -19
				sprites.fido.jumping = true
				sprites.fido:setImage(assets.fido[8])
				if save.sfx then assets.jump:play() end
			end
		end
	}
	pd.inputHandlers.push(vars.gameHandlers)

	vars.walk_timer.repeats = true

	gfx.sprite.setBackgroundDrawingCallback(function(width, height, x, y)
		assets.collision:draw(0, 0)
		if vars.lives >= 1 then assets.life:draw(10, 10) end
		if vars.lives >= 2 then assets.life:draw(35, 10) end
		if vars.lives == 3 then assets.life:draw(60, 10) end
		assets.newsleak:drawText('Level ' .. vars.level, 10, 215)
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		assets.newsleak:drawTextAligned(vars.score, 390, 10, kTextAlignment.right)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	end)

	class('game_fido').extends(gfx.sprite)
	function game_fido:init()
		game_fido.super.init(self)
		self:setImage(gfx.image.new(32, 32, gfx.kColorBlack))
		self:setCenter(0.5, 1)
		self:setImage(assets.fido[1])
		self:setCollideRect(0, 0, 32, 32)
		self:moveTo(200, 220)
		self.left = false
		self.right = false
		self.direction = "left"
		self.horispeed = 0
		self.jumping = false
		self.velocity = 0
		self:add()
	end
	function game_fido:update()
		local x = self.x
		local y = self.y
		if self.left then
			if self.horispeed > -5 then
				self.horispeed -= 0.75
			end
		else
			if self.horispeed < 0 then
				self.horispeed += 1
				self.horispeed = math.min(self.horispeed, 0)
			end
		end
		if self.right then
			if self.horispeed < 5 then
				self.horispeed += 0.75
			end
		else
			if self.horispeed > 0 then
				self.horispeed -= 1
				self.horispeed = math.max(self.horispeed, 0)
			end
		end
		if self.left or self.right then
			if assets.run:isPlaying() then
				if self.velocity ~= 0 then
					assets.run:stop()
				end
			else
				if self.velocity == 0 then
					assets.run:play(0)
				end
			end
		else
			if save.sfx and assets.run:isPlaying() then assets.run:stop() end
		end
		if self.velocity > 0 then
			self:setImage(assets.fido[9])
		end
		if self.jumping and self.velocity < 0 and pd.buttonIsPressed('a') then
			self.velocity += 1.8
		else
			self.velocity += 2.5
		end
		if self.jumping then self.horispeed /= 1.1 end
		local actualx, actualy, collisions, length = self:moveWithCollisions(x + self.horispeed, y + self.velocity)
		if length > 0 then
			local collx, colly = collisions[1].normal:unpack()
			if colly ~= 0 then
				if colly == 1 and save.sfx then
					assets.bonk:play()
				end
				if colly == -1 then
					if self.jumping then self.jumping = false end
					if save.sfx and self.velocity > 10 then assets.ground:play() end
				end
				self.velocity = 0
				self:setImage(assets.fido[1])
				if save.sfx then assets.jump:stop() end
			end
		end
		if not self.jumping and self.velocity == 0 then
			if (self.left or self.right) then
				self:setImage(assets.fido[math.floor(vars.walk_timer.value)])
			end
			if (self.left and self.horispeed > 0) or (self.right and self.horispeed < 0) then
				self:setImage(assets.fido[7])
				if save.sfx then assets.skid:play() end
			end
		end
		if x < 0 then self:moveTo(400, y) end
		if x > 400 then self:moveTo(0, y) end
		if self.direction == "left" then self:setImageFlip('unflipped') end
		if self.direction == "right" then self:setImageFlip('flipX') end
	end
	function game_fido:collisionResponse()
		return gfx.sprite.kCollisionTypeSlide
	end

	-- Set the sprites
	sprites.fido = game_fido()
	self:add()
end

function game:update()
	assets.run:setVolume(map(sprites.fido.x, 0, 400, 0.8, 0.2), map(sprites.fido.x, 0, 400, 0.2, 0.8))
	assets.jump:setVolume(map(sprites.fido.x, 0, 400, 0.8, 0.2), map(sprites.fido.x, 0, 400, 0.2, 0.8))
	assets.skid:setVolume(map(sprites.fido.x, 0, 400, 0.8, 0.2), map(sprites.fido.x, 0, 400, 0.2, 0.8))
	assets.bonk:setVolume(map(sprites.fido.x, 0, 400, 0.8, 0.2), map(sprites.fido.x, 0, 400, 0.2, 0.8))
	assets.ground:setVolume(map(sprites.fido.x, 0, 400, 0.8, 0.2), map(sprites.fido.x, 0, 400, 0.2, 0.8))
end