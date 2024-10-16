local DownloadCutscene, super = Class(Object)

function DownloadCutscene:init(id, callback)
    super.init(self)

    self.stage = Stage()

    self.callback = callback

    self.animations = {
        kris = {
            ["spin"] = {"party/kris/dark/walk/down", 0.5, false, {{"party/kris/dark/walk/left", 0.5, false, {{"party/kris/dark/walk/up", 0.5, false, {{"party/kris/dark/walk/right", 0.5, false,{{"party/kris/dark/walk/down", 0.5, false}}}}}}}}},
            ["ball"] = {"party/kris/dark/ball", 0.5, true},
            ["pose"] = {"party/kris/dark/pose", 0.5, true}
        },
        susie = {
            ["ball"] = {"party/susie/dark/ball", 0.5, true},
            ["pose"] = {"party/susie/dark/pose", 0.5, true}
        },
        ralsei = {
            ["ball"] = {"party/ralsei/dark/ball", 0.5, true},
            ["pose"] = {"party/ralsei/dark/pose", 0.5, true}
        },
    }

    self.kris = Sprite()
    self.kris:setAnimation(self.animations["kris"]["spin"])
    --self.susie = Sprite("party/susie/dark/susie_pose", SCREEN_WIDTH/2 - self.kris.width, SCREEN_HEIGHT/2 - self.kris.height)
    --self.ralsei = Sprite("party/ralsei/dark/ralsei_pose", SCREEN_WIDTH/2 - self.kris.width, SCREEN_HEIGHT/2 - self.kris.height)
    --self.kris:play(2, true)
end

function DownloadCutscene:update()
    super.update(self)

    self.kris:update()

    if self.anim_done and self.callback then
        self.callback()
    end
end

function DownloadCutscene:draw()
    Draw.draw(self.kris:getTexture(), SCREEN_WIDTH/2 - self.kris.width, SCREEN_HEIGHT/2 - self.kris.height, 0, 2, 2)

    super.draw(self)
end

return DownloadCutscene