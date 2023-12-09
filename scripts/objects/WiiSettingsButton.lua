local WiiSettingsButton, super = Class("Button")

function WiiSettingsButton:init(x, y)
	super:init(self, x, y, "wii_settings")
	self.sprite:setOrigin(0.5,0.5)
	self.sprite:setPosition(x, y)
end

function WiiSettingsButton:onClick()
	super:onClick(self)
	Game.wii_menu.substate = "SETTINGS"
	self.pressed = false
end

function WiiSettingsButton:canHover() return Game.wii_menu.substate == "MAIN" end

return WiiSettingsButton