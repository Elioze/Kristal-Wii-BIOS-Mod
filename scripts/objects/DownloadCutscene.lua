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
            ["ball"] = {"party/kris/dark/ball", 0.1, true},
            ["fall"] = {"party/kris/dark/fall", 0.2, true},
            ["pose"] = {"party/kris/dark/pose", 0.5, true}
        },
        susie = {
            ["walk_down"] = {"party/susie/dark/walk/down", 0.5, true},
            ["walk_up"] = {"party/susie/dark/walk/up", 0.5, true},
            ["walk_left"] = {"party/susie/dark/walk/left", 0.5, true},
            ["walk_right"] = {"party/susie/dark/walk/right", 0.5, true},
            ["ball"] = {"party/susie/dark/ball", 0.1, true},
            ["fall"] = {"party/susie/dark/fall", 0.2, true},
            ["pose"] = {"party/susie/dark/pose", 0.5, true}
        },
        ralsei = {
            ["walk_down"] = {"party/ralsei/dark/walk/down", 0.5, true},
            ["walk_up"] = {"party/ralsei/dark/walk/up", 0.5, true},
            ["walk_left"] = {"party/ralsei/dark/walk/left", 0.5, true},
            ["walk_right"] = {"party/ralsei/dark/walk/right", 0.5, true},
            ["ball"] = {"party/ralsei/dark/ball", 0.1, true},
            ["fall"] = {"party/ralsei/dark/fall", 0.2, true},
            ["pose"] = {"party/ralsei/dark/pose", 0.5, true}
        },
    }

    self.characters = {}

    if id == 1 then
        self.kris = Sprite()
        self.kris:set("party/kris/dark/walk/down_1")
        self.kris.x, self.kris.y = SCREEN_WIDTH/2-self.kris.width, SCREEN_HEIGHT/2-self.kris.height + 70
        self.kris_startx, self.kris_starty = self.kris.x, self.kris.y
        self.characters["kris"] = self.kris

        self.susie = Sprite()
        self.susie:set("party/susie/dark/walk/up_1")
        self.susie.x, self.susie.y = SCREEN_WIDTH/2-self.susie.width + 44, SCREEN_HEIGHT/2-self.susie.height + 100
        self.susie_startx, self.susie_starty = self.susie.x, self.susie.y
        self.characters["susie"] = self.susie

        self.ralsei = Sprite()
        self.ralsei:set("party/ralsei/dark/walk/up_1")
        self.ralsei.x, self.ralsei.y = SCREEN_WIDTH/2-self.ralsei.width - 44, SCREEN_HEIGHT/2-self.ralsei.height + 104
        self.ralsei_startx, self.ralsei_starty = self.ralsei.x, self.ralsei.y
        self.characters["ralsei"] = self.ralsei

        local function cutscene()
            self.kris:set("party/kris/dark/walk/down_1")
            self.susie:set("party/susie/dark/walk/up_1")
            self.ralsei:set("party/ralsei/dark/walk/up_1")

            self.timer:after(1, function ()
                self.kris:set("party/kris/dark/landed_1")
                self.susie:set("party/susie/dark/landed_1")
                self.ralsei:set("party/ralsei/dark/landed_1")
                self.timer:after(0.1, function ()
                    Assets.playSound("jump")
                    self.kris:set(self.animations["kris"]["fall"])
                    self.susie:set(self.animations["susie"]["fall"])
                    self.ralsei:set(self.animations["ralsei"]["fall"])

                    self.kris:slideTo(self.kris.x, self.kris.y - 20, 0.23, "linear", function ()
                        self.kris:slideTo(self.kris.x, self.kris.y + 60, 1/3, "linear", function ()
                            self.kris:set("party/kris/dark/landed_1")
                        end)
                    end)
                    self.susie:slideTo(self.kris.x - 14, self.kris.y - 10, 0.23, "linear", function ()
                        self.susie:slideTo(self.susie.x - 70, self.susie.y + 38, 1/3, "linear", function ()
                            self.susie:set("party/susie/dark/landed_1")
                        end)
                    end)
                    self.ralsei:slideTo(self.ralsei.x - 54, self.kris.y + 8, 0.23, "linear", function ()
                        self.ralsei:slideTo(self.ralsei.x - 55, self.ralsei.y + 30, 1/3, "linear", function ()
                            self.ralsei:set("party/ralsei/dark/landed_1")
                            Assets.playSound("impact")
                            self.timer:after(0.1, function()
                                self.kris:set("party/kris/dark/walk/right_1")
                                self.susie:set("party/susie/dark/walk/right_1")
                                self.ralsei:set("party/ralsei/dark/walk/right_1")
                                self.timer:after(0.2, function ()
                                    Assets.playSound("ui_cancel")
                                    self:spin(0.05, 2, self.kris, "kris", function()
                                        self.kris:set(self.animations["kris"]["pose"])
                                    end)
                                    self:spin(0.05, 2, self.susie, "susie", function()
                                        self.susie:set(self.animations["susie"]["pose"])
                                        self.susie.x = self.susie.x + 10
                                        self.susie.y = self.susie.y + 10
                                    end)
                                    self:spin(0.05, 2, self.ralsei, "ralsei", function()
                                        self.ralsei:set(self.animations["ralsei"]["pose"])
                                        Assets.playSound("bell")
                                        self.timer:after(1, function ()
                                            self.kris:set(self.animations["kris"]["walk_up"])
                                            self.susie:set(self.animations["susie"]["walk_right"])
                                            self.ralsei:set(self.animations["ralsei"]["walk_right"])
                                            self.kris:slideTo(self.kris_startx, self.kris_starty, 1, "linear", function()
                                                cutscene()
                                            end)
                                            self.susie:slideTo(self.susie_startx, self.susie_starty, 1)
                                            self.ralsei:slideTo(self.ralsei_startx, self.ralsei_starty, 1)
                                        end)
                                    end)
                                end)
                            end)
                        end)
                    end)
                end)
            end)
        end
        cutscene()
    else
        self.wall = Sprite()
        self.wall:set(self.animations["wall"]["yapping"])
        self.wall.x, self.wall.y = SCREEN_WIDTH/2-self.wall.width, SCREEN_HEIGHT/2-self.wall.height - 60
        table.insert(self.characters, self.wall)

        self.starwalker = Sprite()
        self.starwalker:set(self.animations["starwalker"]["starwalker"])
        self.starwalker.x, self.starwalker.y = SCREEN_WIDTH/2-self.starwalker.width, SCREEN_HEIGHT/2-self.starwalker.height + 30
        table.insert(self.characters, self.starwalker)
    end
end

function DownloadCutscene:spin(speed, time, chara, index, callback)
    local done = time*4

    self.timer:every(speed, function()
        if chara.texture_path == "party/"..index.."/dark/walk/up_1" then
            chara:set("party/"..index.."/dark/walk/right_1")
        elseif chara.texture_path == "party/"..index.."/dark/walk/right_1" then
            chara:set("party/"..index.."/dark/walk/down_1")
        elseif chara.texture_path == "party/"..index.."/dark/walk/down_1" then
            chara:set("party/"..index.."/dark/walk/left_1")
        else
            chara:set("party/"..index.."/dark/walk/up_1")
        end
        done = done - 1

        if callback and done == 0 then
            callback()
        end

    end, time*4)
end

function DownloadCutscene:update(dt)
    self.timer:update(dt)

    for _, chara in pairs(self.characters) do
        chara:update()
    end

    if self.anim_done and self.callback then
        self.callback()
        self:remove()
    end
end

function DownloadCutscene:draw()
    for index, chara in pairs(self.characters) do
        if self.id == 1 then
            Draw.draw(chara:getTexture(), chara.x, chara.y, 0, 2, 2)
        else
            Draw.draw(chara:getTexture(), chara.x, chara.y, 0, 2, 2)
        end
    end
end

return DownloadCutscene