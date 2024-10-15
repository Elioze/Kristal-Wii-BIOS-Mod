---@class ShopChannel : GamestateState
local ShopChannel = {}

function ShopChannel:init()
    print("here")

    self.buttons = {}

    self.stage = Stage()

    self.screen_helper = ScreenHelper()
	self.stage:addChild(self.screen_helper)

    self.screen_helper_upper = ScreenHelper()
	self.stage:addChild(self.screen_helper_upper)

    self.offset = 0

    self.bg = Assets.getTexture("vii_channel/bg")

    self.state = "SEARCH" -- MAIN, SEARCH, GAME 

    self.page = 1

    self.mod = 1

    self.is_loading = false

    local _, body, _ = https.request("https://gamebanana.com/apiv8/Mod/ByCategory?_csvProperties=@gbprofile&_aCategoryRowIds[]=16803&_nPerpage=10&_nPage="..self.page)

    body = JSON.decode(body)

    self.mod_list = body

    self.preview_list = {}

    Kristal.showCursor()

    self:setPreview()
end

function ShopChannel:enter()
	Game.wii_menu = self

    self.substate = "FALSE" -- TEST, FALSE
	
	if not Game.musicplay then
		Game.musicplay = Music("shop")
	end
	
	Kristal.showCursor()
    
    self:drawButton()
	
	self.cooldown = 0
	
	self.clickable = true
end

function ShopChannel:update()
    self.screen_helper:update()
    self.screen_helper_upper:update()

    if self.state == "MAIN" then
        if Input.pressed("confirm") then
            self:setPreview()
            self:drawButton()
            self.offset = 0
            self.state = "SEARCH"
        end
        if Input.pressed("cancel") then 
            if Game.musicplay then
                Game.musicplay:remove()
                Game.musicplay = nil
            end
            Mod:setState("MainMenu", false)
        end
    elseif self.state == "SEARCH" then
        if Input.pressed("cancel") then self.state = "MAIN" self:removeButton() end
        if Input.pressed("confirm") then self.state = "GAME" self:changeMod(0) self:removeButton() end

        if Input.keyDown("down") then self.offset = self.offset + DT * 90 end
        if Input.keyDown("up") then self.offset = self.offset - DT * 90 end
        self.offset = Utils.clamp(self.offset, 0, 101 * #self.mod_list)

        if Input.keyDown("left") then self:changePage(-1) self:removeButton() self:drawButton() end
        if Input.keyDown("right") then self:changePage(1) self:removeButton() self:drawButton() end


    elseif self.state == "GAME" then
        if Input.pressed("left") then self:changeMod(-1) end
        if Input.pressed("right") then self:changeMod(1) end
        if Input.pressed("cancel") then self.state = "SEARCH" self:drawButton() end
    end

    Kristal.showCursor()
end

function ShopChannel:setPreview()
    self.preview_list = {}
    for index, obj in pairs(self.mod_list) do
        self.preview_list[index] = {
            "mod_name",
            "dev_name",
            "preview"
        }

        self.preview_list[index]["mod_name"] = obj["_sName"]

        self.preview_list[index]["dev_name"] = obj["_aSubmitter"]["_sName"]

        self.is_loading = true
        local _, preview = https.request(obj["_aPreviewMedia"]["_aImages"][1]["_sBaseUrl"].."/"..obj["_aPreviewMedia"]["_aImages"][1]["_sFile"])
        self.is_loading = false
        preview = love.filesystem.newFileData(preview, "preview.png")
        preview = love.graphics.newImage(preview)

        self.preview_list[index]["preview"] = preview
    end
end

function ShopChannel:changePage(page_num)
    self.offset = 0

    self.page = self.page + (page_num or 0)

    self.page = Utils.clamp(self.page, 1, 3)

    local _, body, _ = https.request("https://gamebanana.com/apiv8/Mod/ByCategory?_csvProperties=@gbprofile&_aCategoryRowIds[]=16803&_nPerpage=10&_nPage="..self.page)

    body = JSON.decode(body)

    self.mod_list = body

    self:setPreview()
end

function ShopChannel:removeButton()
    for index, obj in pairs(self.buttons) do
        obj:remove()
    end
    self.buttons = {}
end

function ShopChannel:drawButton()
    for index, obj in pairs(self.preview_list) do
        self.buttons[index] = ModButton(110, 115 + ((index - 1) * 130) - Utils.round(self.offset), index)
        self.screen_helper:addChild(self.buttons[index])
    end
end

function ShopChannel:changeMod(mod_num)
    self.mod = self.mod + (mod_num or 0)
    self.mod = Utils.clamp(self.mod, 1, 10)

    self.mod_name = self.mod_list[self.mod]["_sName"]

    local _, preview = https.request(self.mod_list[self.mod]["_aPreviewMedia"]["_aImages"][1]["_sBaseUrl"].."/"..self.mod_list[self.mod]["_aPreviewMedia"]["_aImages"][1]["_sFile"])
    preview = love.filesystem.newFileData(preview, "preview.png")
    preview = love.graphics.newImage(preview)

    self.preview = preview
end

function ShopChannel:draw()

    love.graphics.push()

    Draw.draw(self.bg, 0, 0)

    Draw.setColor(0, 0, 0)
    if self.is_loading then
        print("State loading")
        love.graphics.print("LOADING", SCREEN_WIDTH/2 - 64, SCREEN_HEIGHT - 50)
    end
    if self.state == "MAIN" then
        love.graphics.print("You're in Main Menu", SCREEN_WIDTH/2 - 64, SCREEN_HEIGHT/2 - 10)
    elseif self.state == "SEARCH" then
        Draw.rectangle("line", 105, 85, SCREEN_WIDTH/2 + 110, SCREEN_HEIGHT/2 + 80)
        Draw.pushScissor()
        -- Mod List
        Draw.scissor(106, 86, SCREEN_WIDTH/2 + 108, SCREEN_HEIGHT/2 + 78)

        -- Mod Scroller
        Draw.rectangle("fill", 495, 121, 38, SCREEN_HEIGHT/2 + 11)
        Draw.setColor(0.75, 0.75, 0.75)
        Draw.rectangle("fill", 494, 120 + Utils.round(self.offset/#self.mod_list), 40, 152)
        Draw.setColor(0, 0, 0)

        for index, obj in pairs(self.preview_list) do
            Draw.setColor(0, 0, 0)

            if self.buttons[index] then
                self.buttons[index].y = Utils.round((115 + ((index - 1) * 130) - Utils.round(self.offset)))
            end
            -- Mod Info
            Draw.rectangle("line", 110, 115 + ((index - 1) * 130) - Utils.round(self.offset), 380, 100)
            love.graphics.print(obj["mod_name"], SCREEN_WIDTH/2 - 80, 115 + ((index - 1) * 130) - Utils.round(self.offset))
            love.graphics.print(obj["dev_name"], SCREEN_WIDTH/2 - 80, 170 + ((index - 1) * 130) - Utils.round(self.offset), 0, 0.75, 0.75)
            love.graphics.print("Kristal", SCREEN_WIDTH/2 - 80, 195 + ((index - 1) * 130) - Utils.round(self.offset), 0, 0.5, 0.5)
            Draw.setColor(1, 1, 1)
            Draw.draw(obj["preview"], 115, 120 + ((index - 1) * 130) - Utils.round(self.offset), 0, 120/obj["preview"]:getWidth(), 90/obj["preview"]:getHeight())
        end
        
        Draw.popScissor()
    elseif self.state == "GAME" then
        Draw.setColor(1, 1, 1)
        Draw.draw(self.preview, SCREEN_WIDTH/2 - self.preview:getWidth()/2, SCREEN_HEIGHT/2 - self.preview:getHeight()/2)
        love.graphics.print(self.mod_name, SCREEN_WIDTH/2 - 64, SCREEN_HEIGHT/2 - 100)
    end

    self.screen_helper:draw()
    self.screen_helper_upper:draw()

    love.graphics.pop()

    love.graphics.push()
    Kristal.callEvent("postDraw")
    love.graphics.pop()
end

return ShopChannel