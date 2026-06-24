-- Meteor Blaster - Configuration
function love.conf(t)
    t.title = "Meteor Blaster"
    t.version = "11.5"
    t.identity = "meteor_blaster"       -- enables save directory for leaderboard
    t.console = false

    t.window.width = 800
    t.window.height = 600
    t.window.fullscreen = false
    t.window.vsync = 1
    t.window.msaa = 0
    t.window.resizable = false
    t.window.borderless = false
    t.window.centered = true
    t.window.minwidth = 800
    t.window.minheight = 600

    -- Disable modules we don't need for faster startup
    t.modules.physics = false
    t.modules.joystick = false
    t.modules.touch = false
    t.modules.video = false
    t.modules.sensor = false
end
