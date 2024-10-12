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
		collision = gfx.image.new(400, 240, gfx.kColorBlack),
		fido = gfx.imagetable.new('images/fido'),
	}
	gfx.pushContext(assets.collision)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 210, 400, 30)
		gfx.fillRect(265, 145, 135, 10)
		gfx.fillRect(0, 145, 135, 10)
		gfx.fillRect(135, 75, 130, 10)
	gfx.popContext()

	vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
		collision1 = gfx.sprite.addEmptyCollisionSprite(0, 210, 400, 30),
		collision2 = gfx.sprite.addEmptyCollisionSprite(265, 145, 135, 10),
		collision3 = gfx.sprite.addEmptyCollisionSprite(0, 145, 135, 10),
		collision4 = gfx.sprite.addEmptyCollisionSprite(135, 75, 130, 10),
		walk_timer = pd.timer.new(500, 1, 6.99),
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
				sprites.fido.velocity = -21
				sprites.fido.jumping = true
				sprites.fido:setImage(assets.fido[8])
			end
		end
	}
	pd.inputHandlers.push(vars.gameHandlers)

	vars.walk_timer.repeats = true

	gfx.sprite.setBackgroundDrawingCallback(function(width, height, x, y)
		assets.collision:draw(0, 0)
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

	end
	function game_fido:collisionResponse()
		return gfx.sprite.kCollisionTypeSlide
	end

	-- Set the sprites
	sprites.fido = game_fido()
	self:add()
end

function game:update()
	if sprites.fido.left then
		if sprites.fido.horispeed > -5 then
			sprites.fido.horispeed -= 0.75
		end
	else
		if sprites.fido.horispeed < 0 then
			sprites.fido.horispeed += 1
			sprites.fido.horispeed = math.min(sprites.fido.horispeed, 0)
		end
	end
	if sprites.fido.right then
		if sprites.fido.horispeed < 5 then
			sprites.fido.horispeed += 0.75
		end
	else
		if sprites.fido.horispeed > 0 then
			sprites.fido.horispeed -= 1
			sprites.fido.horispeed = math.max(sprites.fido.horispeed, 0)
		end
	end
	if sprites.fido.velocity > 0 then
		sprites.fido:setImage(assets.fido[9])
	end
	sprites.fido.velocity += 2.5
	if sprites.fido.jumping then sprites.fido.horispeed /= 1.1 end
	local x = sprites.fido.x
	local y = sprites.fido.y
	local actualx, actualy, collisions, length = sprites.fido:moveWithCollisions(x + sprites.fido.horispeed, y + sprites.fido.velocity)
	if length > 0 then
		local collx, colly = collisions[1].normal:unpack()
		if colly ~= 0 then
			sprites.fido.velocity = 0
			sprites.fido:setImage(assets.fido[1])
		end
		if colly == -1 and sprites.fido.jumping then
			sprites.fido.jumping = false
		end
	end
	if not sprites.fido.jumping and sprites.fido.velocity == 0 then
		if (sprites.fido.left or sprites.fido.right) then
			sprites.fido:setImage(assets.fido[math.floor(vars.walk_timer.value)])
		end
		if (sprites.fido.left and sprites.fido.horispeed > 0) or (sprites.fido.right and sprites.fido.horispeed < 0) then
			sprites.fido:setImage(assets.fido[7])
		end
	end
	if x < 0 then sprites.fido:moveTo(400, y) end
	if x > 400 then sprites.fido:moveTo(0, y) end
	if sprites.fido.direction == "left" then sprites.fido:setImageFlip('unflipped') end
	if sprites.fido.direction == "right" then sprites.fido:setImageFlip('flipX') end
end