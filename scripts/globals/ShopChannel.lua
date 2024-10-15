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

    self.state = "MAIN" -- MAIN, SEARCH, GAME 

    self.current_page = 1

    local code, pages = https.request("https://gamebanana.com/apiv8/Mod/ByCategory?_csvProperties=@gbprofile&_aCategoryRowIds[]=16803")

    self.request_code = code

    if self.request_code == 200 then
        pages = JSON.decode(pages)
        pages = math.ceil(#pages / 2)
        self.pages = pages
    else
        self.error = true
    end

    self.mod = 1

    self.is_loading = false

    self.preview_list = {}

    Kristal.showCursor()

    --self:pageButton()

    --self:changeMod()
end

function ShopChannel:enter()
	Game.wii_menu = self

    self.substate = "FALSE" -- TEST, FALSE
	
	if not Game.musicplay then
		Game.musicplay = Music("shop_intro")
        Game.musicplay:setLooping(false)
	end
	
	Kristal.showCursor()
    
    --self:drawButton()
	
	self.cooldown = 0

    self.btn_cooldown = 0
	
	self.clickable = true

    if self.error then
        self.popUp = popUp("Could not load Mods\n \n \nError code: "..self.request_code, {"OK"}, function(clicked) 
            if Game.musicplay then
                Game.musicplay:remove()
                Game.musicplay = nil
            end
            Game.wii_menu.popUp:remove()
            Mod:setState("MainMenu", false)
        end)
		self.screen_helper_upper:addChild(self.popUp)
    end

    self.access_btn = Button(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, "wii_settings", function ()
        self:changePage()
        self:setPreview()
        self:drawButton()
        self:removeMainButton()
        self.offset = 0
        Game.wii_menu.state = "SEARCH"
    end)
    self.screen_helper:addChild(self.access_btn)

    self.back_button = TextButtonInApp(140, 440, "Wii Menu", function ()
        if Game.wii_menu.state == "MAIN" then
            if Game.musicplay then
                Game.musicplay:remove()
                Game.musicplay = nil
            end
            Mod:setState("MainMenu", false)
        elseif Game.wii_menu.state == "SEARCH" then
            Game.wii_menu.state = "MAIN"
            self:removeButton()
            self:removePageButton()
            self:drawMainButton()
        else
            self.state = "SEARCH"
            self:drawButton()
            self:changePage()
        end
    end)
    print(Game.wii_menu.back_button.pressed)
    self.screen_helper:addChild(self.back_button)
end

function ShopChannel:update()
    self.screen_helper:update()
    self.screen_helper_upper:update()

    if Game.wii_menu.cooldown and Game.wii_menu.cooldown > 0 then Game.wii_menu.cooldown = Game.wii_menu.cooldown - DT end
    if Game.wii_menu.btn_cooldown and Game.wii_menu.btn_cooldown > 0 then Game.wii_menu.btn_cooldown = Game.wii_menu.btn_cooldown - DT end

    if not Game.musicplay:isPlaying() then
        Game.musicplay = Music("shop")
        Game.musicplay:setLooping(true)
    end

    if self.state == "MAIN" then
        self.back_button.text = "Wii Menu"
        if Input.pressed("confirm") then
            self:changePage()
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
        self.back_button.text = "Back"
        if Input.pressed("cancel") then self.state = "MAIN" self:removeButton() self:removePageButton() end
        if Input.pressed("confirm") then self.state = "GAME" self:changeMod() self:removeButton() self:removePageButton() end

        if Input.keyDown("down") then self.offset = self.offset + DT * 90 end
        if Input.keyDown("up") then self.offset = self.offset - DT * 90 end
        self.offset = Utils.clamp(self.offset, 0, 101 * #self.mod_list)

        if Input.keyDown("left") then self:changePage(-1) self:removeButton() self:drawButton() end
        if Input.keyDown("right") then self:changePage(1) self:removeButton() self:drawButton() end

    elseif self.state == "GAME" then
        if Input.pressed("left") then self:changeMod(-1) end
        if Input.pressed("right") then self:changeMod(1) end
        if Input.pressed("cancel") then self.state = "SEARCH" self:drawButton() self:changePage() end
    end

    Kristal.showCursor()
end

function ShopChannel:onWheelMoved(x, y)
    self.offset = Utils.clamp(self.offset - y * 10, 0, 101 * #self.mod_list)
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

    self.current_page = self.current_page + (page_num or 0)

    self.current_page = Utils.clamp(self.current_page, 1, self.pages)

    local code, body, _ = https.request("https://gamebanana.com/apiv8/Mod/ByCategory?_csvProperties=@gbprofile&_aCategoryRowIds[]=16803&_nPerpage=10&_nPage="..self.current_page)

    self.request_code = code

    body = JSON.decode(body)

    self.mod_list = body

    self:setPreview()

    self:removePageButton()

    self:pageButton() 
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

function ShopChannel:removePageButton()
    if self.left_button then self.left_button:remove() end
    if self.right_button then self.right_button:remove() end
end

function ShopChannel:pageButton()
    if self.current_page ~= 1 then
        self.left_button = Button(SCREEN_WIDTH/2 + 87, SCREEN_HEIGHT - 45, "left", function() Game.wii_menu:changePage(-1) self:removeButton() self:drawButton() end)
        self.left_button.sprite:setScale(40/self.left_button.sprite.width, 40/self.left_button.sprite.height)
        self.screen_helper:addChild(self.left_button)
    end

    if self.current_page ~= self.pages then
        self.right_button = Button(SCREEN_WIDTH/2 + 185, SCREEN_HEIGHT - 45, "right", function() Game.wii_menu:changePage(1) self:removeButton() self:drawButton() end)
        self.right_button.sprite:setScale(40/self.right_button.sprite.width, 40/self.right_button.sprite.height)
        --self.right_button.sprite:setScale(80/self.right_button.sprite.width, 80/self.right_button.sprite.height)
        self.screen_helper:addChild(self.right_button)
    end
end

function ShopChannel:removeMainButton()
    if self.access_btn then self.access_btn:remove() end
end

function ShopChannel:drawMainButton()
    self.access_btn = Button(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, "wii_settings", function ()
        self:changePage()
        self:setPreview()
        self:drawButton()
        self:removeMainButton()
        self.offset = 0
        Game.wii_menu.state = "SEARCH"
    end)
    self.screen_helper:addChild(self.access_btn)
end

function ShopChannel:changeMod(mod_num)
    self.mod = self.mod + (mod_num or 0)
    self.mod = Utils.clamp(self.mod, 1, 10)

    self.mod_name = self.mod_list[self.mod]["_sName"]

    local _, preview = https.request(self.mod_list[self.mod]["_aPreviewMedia"]["_aImages"][1]["_sBaseUrl"].."/"..self.mod_list[self.mod]["_aPreviewMedia"]["_aImages"][1]["_sFile"])
    preview = love.filesystem.newFileData(preview, "preview.png")
    preview = love.graphics.newImage(preview)

    local date = self.mod_list[self.mod]["_tsDateAdded"]
    self.date = os.date("%m/%d/%Y", date)

    self.dev_name = self.mod_list[self.mod]["_aSubmitter"]["_sName"]

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

        love.graphics.print(self.current_page.."/"..self.pages, SCREEN_WIDTH/2 + 125, SCREEN_HEIGHT - 75)
        
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

            local x_scale = 1
            if Assets.getFont("main"):getWidth(obj["mod_name"]) > 230 then
                x_scale = 230/Assets.getFont("main"):getWidth(obj["mod_name"])
            end

            if self.buttons[index] then
                self.buttons[index].y = Utils.round((115 + ((index - 1) * 130) - Utils.round(self.offset)))
            end
            -- Mod Info
            love.graphics.print(obj["mod_name"], SCREEN_WIDTH/2 - 80, 115 + ((index - 1) * 130) - Utils.round(self.offset), 0, x_scale, 1)
            love.graphics.print(obj["dev_name"], SCREEN_WIDTH/2 - 80, 170 + ((index - 1) * 130) - Utils.round(self.offset), 0, 0.75, 0.75)
            love.graphics.print(love.system.getOS(), SCREEN_WIDTH/2 - 80, 195 + ((index - 1) * 130) - Utils.round(self.offset), 0, 0.5, 0.5)
            Draw.setColor(1, 1, 1)
            Draw.draw(obj["preview"], 115, 120 + ((index - 1) * 130) - Utils.round(self.offset), 0, 120/obj["preview"]:getWidth(), 90/obj["preview"]:getHeight())
        end
        
        Draw.popScissor()
    elseif self.state == "GAME" then
        Draw.setColor(1, 1, 1)
        Draw.draw(self.preview, SCREEN_WIDTH/2 - 450/2 + 6, 110 + 8, 0, 160/self.preview:getWidth(), 120/self.preview:getHeight())
        Draw.setColor(0, 0, 0)
        Draw.rectangle("fill", SCREEN_WIDTH/2 - 450/2 - 1, 82, 200, 28)
        Draw.rectangle("line", SCREEN_WIDTH/2 - 450/2, 110, 450, 220)
        love.graphics.line(SCREEN_WIDTH/2 - 450/2 + 16, 250, 540 - 16, 250)
        Draw.setColor(1, 1, 1)
        love.graphics.print(love.system.getOS(), SCREEN_WIDTH/2 - 450/2 + 3, 84, 0, 0.5, 0.75)
        Draw.setColor(0, 0, 0)
        love.graphics.print("Released "..self.date, 264, 184, 0, 0.5, 0.75)
        love.graphics.print("For 1 player", 444, 185, 0, 0.5, 0.75)
        love.graphics.print(self.dev_name, 264, 184 + 18, 0, 0.5, 0.75)
        love.graphics.print("Fangame", 264, 184 + 18 + 20, 0, 0.5, 0.75)
        Draw.setColor(0, 0, 1)
        local mod_name_x = (SCREEN_WIDTH - Assets.getFont("main"):getWidth(self.mod_name)*0.75)/2
        love.graphics.print(self.mod_name, mod_name_x, 259, 0, 0.75, 0.75)
    end

    self.screen_helper:draw()
    self.screen_helper_upper:draw()

    love.graphics.pop()

    love.graphics.push()
    Kristal.callEvent("postDraw")
    love.graphics.pop()
end

return ShopChannel