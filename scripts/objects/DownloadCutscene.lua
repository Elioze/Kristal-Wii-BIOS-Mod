local DownloadCutscene, super = Class(Object)

function DownloadCutscene:init(id, callback)
    super.init(self)

    self.timer = LibTimer.new()

    self.id = id or 0

    self.callback = callback

    self.animations = {
        wall = {
            ["yapping"] = {"npcs/wall", 0.2, true}
        },
        starwalker = {
            ["starwalker"] = {"npcs/starwalker", 1, true}
        },
        kris = {
            ["walk_down"] = {"party/kris/dark/walk/down", 0.5, true},
            ["walk_up"] = {"party/kris/dark/walk/up", 0.5, true},
            ["walk_left"] = {"party/kris/dark/walk/left", 0.5, true},
            ["walk_right"] = {"party/kris/dark/walk/right", 0.5, true},
            ["ball"] = {"party/kris/dark/ball", 0.5, true},
            ["pose"] = {"party/kris/dark/pose", 0.5, true}
        },
        susie = {
            ["walk_down"] = {"party/susie/dark/walk/down", 0.5, true},
            ["walk_up"] = {"party/susie/dark/walk/up", 0.5, true},
            ["walk_left"] = {"party/susie/dark/walk/left", 0.5, true},
            ["walk_right"] = {"party/susie/dark/walk/right", 0.5, true},
            ["ball"] = {"party/susie/dark/ball", 0.5, true},
            ["pose"] = {"party/susie/dark/pose", 0.5, true}
        },
        ralsei = {
            ["walk_down"] = {"party/ralsei/dark/walk/down", 0.5, true},
            ["walk_up"] = {"party/ralsei/dark/walk/up", 0.5, true},
            ["walk_left"] = {"party/ralsei/dark/walk/left", 0.5, true},
            ["walk_right"] = {"party/ralsei/dark/walk/right", 0.5, true},
            ["ball"] = {"party/ralsei/dark/ball", 0.5, true},
            ["pose"] = {"party/ralsei/dark/pose", 0.5, true}
        },
    }

    self.characters = {}

    if id == 1 then
        self.kris = Sprite()
        self.kris:set(self.animations["kris"]["walk_down"])
        self.kris:play(0.2)
        self.kris.x = SCREEN_WIDTH/2-self.kris.width
        self.kris.y = SCREEN_HEIGHT/2-self.kris.height
        self.characters["kris"] = self.kris

        self.susie = Sprite()
        self.susie:set(self.animations["susie"]["walk_down"])
        self.susie:play(0.2)
        self.susie.x = SCREEN_WIDTH/2-self.susie.width - 80
        self.susie.y = SCREEN_HEIGHT/2-self.susie.height
        self.characters["susie"] = self.susie

        self.ralsei = Sprite()
        self.ralsei:set(self.animations["ralsei"]["walk_down"])
        self.ralsei:play(0.2)
        self.ralsei.x = SCREEN_WIDTH/2-self.ralsei.width + 80
        self.ralsei.y = SCREEN_HEIGHT/2-self.ralsei.height
        self.characters["ralsei"] = self.ralsei

        for index, chara in pairs(self.characters) do
            self.timer:after(3, function()
                self:charaSlideTo(index, chara, 50, SCREEN_HEIGHT/2-chara.height, 20, 0.1, self.animations[index]["ball"])
            end)
            --[[self.timer:every(1.5, function()
                if chara.anim_sprite == self.animations[index]["walk_down"][1] then
                    chara:set(self.animations[index]["walk_right"])
                elseif chara.anim_sprite == self.animations[index]["walk_right"][1] then
                    chara:set(self.animations[index]["walk_up"])
                elseif chara.anim_sprite == self.animations[index]["walk_up"][1] then
                    chara:set(self.animations[index]["walk_left"])
                else
                    chara:set(self.animations[index]["walk_down"])
                end
                chara:play(0.2)
            end)]]
        end
    else
        self.wall = Sprite()
        self.wall:set(self.animations["wall"]["yapping"])
        table.insert(self.characters, self.wall)

        self.starwalker = Sprite()
        self.starwalker:set(self.animations["starwalker"]["starwalker"])
        table.insert(self.characters, self.starwalker)
    end
end

function DownloadCutscene:charaSlideTo(id, chara, x, y, speed, anim_speed, anim)
    speed = speed*2
    
    if anim then
        chara:set(anim)
    else
        if chara.x > x then
            chara:set(self.animations[id]["walk_left"])
        elseif chara.x < x then
            chara:set(self.animations[id]["walk_right"])
        end

        if chara.y > y then
            chara:set(self.animations[id]["walk_up"])
        elseif chara.y < y then
            chara:set(self.animations[id]["walk_down"])
        end
    end

    if anim_speed then
        chara:play(anim_speed)
    end
    local timer_x = self.timer:every(0, function()
        --print(chara.x - (speed * DT), x)
        if (chara.x - (speed * DT) < x and chara.x > x) or (chara.x + (speed * DT) > x and chara.x < x) then
            chara.x = x
        elseif chara.x > x then
            chara.x = chara.x - (speed * DT)
        elseif chara.x < x then
            chara.x = chara.x + (speed * DT)
        end
    end)

    local timer_y = self.timer:every(0, function()
        if (chara.y - (speed * DT) < y and chara.y > y) or (chara.y + (speed * DT) > y and chara.y < y) then
            chara.y = y
        elseif chara.y > y then
            chara.y = chara.y - (speed * DT)
        elseif chara.y < y then
            chara.y = chara.y + (speed * DT)
        end
    end)

    if chara.x == x then
        self.timer:cancel(timer_x)
    end

    if chara.y == y then
        self.timer:cancel(timer_y)
    end
end

--[[function DownloadCutscene:charaSlideFor(id, chara, x, y, speed, anim)
    speed = speed*2
    
    if anim then
        chara:set(anim)
    else
        if 0 > x then
            chara:set(self.animations[id]["walk_left"])
        elseif 0 > x then
            chara:set(self.animations[id]["walk_right"])
        end

        if 0 < y then
            chara:set(self.animations[id]["walk_down"])
        elseif 0 > y then
            chara:set(self.animations[id]["walk_up"])
        end
    end
    self.timer:every(0, function()
        chara.x = chara.x + (speed * DT)
    end, math.abs((chara.x - x)/(speed * DT)))

    self.timer:every(0, function()
        chara.y = chara.y + (speed * DT)
    end, math.abs((chara.y - y)/(speed * DT)))
end]]

function DownloadCutscene:update(dt)
    self.timer:update(dt)

    for _, chara in pairs(self.characters) do
        chara:update()

        --print(chara.anim_sprite)
    end

    if self.anim_done and self.callback then
        self.callback()
    end
end

function DownloadCutscene:draw()
    for index, chara in pairs(self.characters) do
        print(chara.x, chara.y)
        if self.id == 1 then
            Draw.draw(chara:getTexture(), chara.x, chara.y, 0, 2, 2)
        else
            if index == 1 then
                Draw.draw(chara:getTexture(), SCREEN_WIDTH/2-chara.width, (SCREEN_HEIGHT/2-chara.height) - 80, 0, 2, 2)
            else
                Draw.draw(chara:getTexture(), SCREEN_WIDTH/2-chara.width, SCREEN_HEIGHT/2-chara.height + 80, 0, 2, 2)
            end
        end
    end
end

return DownloadCutscene