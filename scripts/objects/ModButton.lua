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
	Game.wii_menu:changeMod(0)
	Game.wii_menu.state = "GAME"
end

function ModButton:update()
	super:update(self)
	
	local mx, my = love.mouse.getPosition()
	local screen_x, screen_y = self:getScreenPos()
	screen_x, screen_y = screen_x-self.width/2, screen_y-self.height/2
	if not self.pressed then
		if (mx / Kristal.getGameScale() > screen_x) and (mx / Kristal.getGameScale() < (screen_x + self.width)) and (my / Kristal.getGameScale() > screen_y) and (my / Kristal.getGameScale() < (screen_y + self.height)) and self:canHover() then
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
	if self.hover then
		Draw.setColor(0, 0, 1)
	else
		Draw.setColor(0, 0, 0)
	end

	Draw.rectangle("line", 0, 0, self.width, self.height)
end

function ModButton:canClick() return not Mod.popup_on end
function ModButton:canHover() return true end

return ModButton