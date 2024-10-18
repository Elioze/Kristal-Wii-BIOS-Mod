local ShopButton, super = Class(Object)

function ShopButton:init(x, y, image, callback, width, height)
	super:init(self, x, y)

	self.can_hover = true

	if image then
		self.path = "shop/" .. image
		if love.filesystem.getInfo(Kristal.Mods.getMod("wii_kristal").path .. "/assets/sprites/shop/" .. Game.wii_data["theme"] .. "/" .. image .. ".png") then
			self.path = "shop/" .. Game.wii_data["theme"] .. "/" ..image
		end
		
		self.sprite = Sprite(self.path)
		self:addChild(self.sprite)
		
		self:setOrigin(0.5,0.5)
		
		self.width = self.sprite.width
		self.height = self.sprite.height
	end

	if callback then
		self.callback = callback
	end

	self.width = width or self.sprite.width or 1
	self.height = height or self.sprite.height or 1

	print(self.sprite.width)

	self.sprite:setScale(self.width/self.sprite.width, self.height/self.sprite.height)

	self.played_sound = false
end

function ShopButton:update() 
	super.update(self)

	local mx, my = love.mouse.getPosition()
	local screen_x, screen_y = self:getScreenPos()
	screen_x, screen_y = screen_x-self.width/2, screen_y-self.height/2
	if not self.pressed then
		if (mx / Kristal.getGameScale() > screen_x) and (mx / Kristal.getGameScale() < (screen_x + self.width)) and (my / Kristal.getGameScale() > screen_y) and (my / Kristal.getGameScale() < (screen_y + self.height)) and self:canHover() then
			if self:canClick() then
				self.sprite:setSprite(self.path.."_hover")
				if not self.played_sound then
					self.played_sound = true
					Assets.playSound("wii/hover")
				end
				if not self.pressed and love.mouse.isDown(1) then
					self.pressed = true
					self:onClick()
				end
			end
		else
			self.sprite:setSprite(self.path)
			self.played_sound = false
		end
	else
		if self.flash and not self.flash.parent then
			self.buttonPressed = true
		end
	end
end

function ShopButton:draw() super:draw(self) end

function ShopButton:onClick()
	Assets.playSound("wii/button_pressed")
	self.flash = FlashFade(self.sprite.texture, 0, 0)
    self.flash.layer = self.layer+10 -- TODO: Unhardcode?
    self.sprite:addChild(self.flash)
	Game.wii_menu.btn_cooldown = 0.5

	if self.callback then
		self.callback()
	end
end

function ShopButton:canClick() return Game.wii_menu.btn_cooldown <= 0 end
function ShopButton:canHover() return self.can_hover end

return ShopButton
