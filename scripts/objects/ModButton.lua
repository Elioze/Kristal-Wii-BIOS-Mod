local ModButton, super = Class(Object)

function ModButton:init(x, y, id)
	super:init(self, x, y)

	self.width = 380
	self.height = 100

	self.hover = false

	self.id = id
end

function ModButton:onClick()
	Assets.playSound("wii/button_pressed")
	Game.wii_menu.mod = self.id
	Game.wii_menu:changeMod()
	Game.wii_menu:removeButton()
	Game.wii_menu:removePageButton()
	Game.wii_menu:drawDownloadButton()
	Game.wii_menu.btn_cooldown = 0.5
	Game.wii_menu.state = "GAME"
end

function ModButton:update()
	super:update(self)
	
	local mx, my = love.mouse.getPosition()
	local screen_x, screen_y = self:getScreenPos()
	local up_y, down_y = 0, self.height

	if screen_y + self.height > SCREEN_HEIGHT/2 + 78 + 86 then
    	down_y = 100 - ((screen_y + self.height) - (SCREEN_HEIGHT/2 + 78 + 86))
	end

	if screen_y < 86 then
    	up_y = (86 - screen_y)
	end

	if not self.pressed then
		if (mx / Kristal.getGameScale() > screen_x) and (mx / Kristal.getGameScale() < (screen_x + self.width)) 
		and (my / Kristal.getGameScale() > screen_y + up_y) and (my / Kristal.getGameScale() < (screen_y + down_y)) 
		and self:canHover() then
			self.hover = true
			if self:canClick() then
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
			self.played_sound = false
			self.hover = false
		end
	else
		if self.flash and not self.flash.parent then
			self.buttonPressed = true
		end
	end
end

function ModButton:draw()
	super:draw(self)

	local _, screen_y = self:getScreenPos()

	if screen_y + self.height > SCREEN_HEIGHT/2 + 78 + 86 then
    	Draw.scissor(-2, -1, self.width + 4, 100 - ((screen_y + self.height) - (SCREEN_HEIGHT/2 + 78 + 86)) + 2)
	end

	if screen_y < 86 then
    	Draw.scissor(-2, self.height + 1, self.width + 4, -(100 + (screen_y - 86)) - 2)
	end

	if self.hover then
		Draw.setColor(0, 0, 1)
	else
		Draw.setColor(0, 0, 0)
	end

	Draw.rectangle("line", 0, 0, self.width, self.height)
end

function ModButton:canClick() return Game.wii_menu.btn_cooldown <= 0 end
function ModButton:canHover() return true end

return ModButton