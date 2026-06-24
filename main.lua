-- Meteor Blaster - Main Entry Point
-- Simple state machine for game flow: menu → play → gameover → leaderboard

local sounds = require("sounds")

local states = {}
local current_state = nil
local current_state_name = nil

-- Make switchState globally accessible so state modules can call it
_G.switchState = function(name, ...)
    if current_state and current_state.leave then
        current_state.leave()
    end
    current_state = states[name]
    current_state_name = name
    if current_state and current_state.enter then
        current_state.enter(...)
    end
end

function love.load(args)
    -- Load all state modules
    states.menu = require("states.menu")
    states.play = require("states.play")
    states.gameover = require("states.gameover")
    states.leaderboard = require("states.leaderboard")

    -- Initialize random seed
    love.math.setRandomSeed(love.timer.getTime())

    -- Pre-generate all sound data to avoid frame drops during gameplay
    sounds.init()

    -- Start at the main menu
    switchState("menu")
end

function love.update(dt)
    if current_state and current_state.update then
        current_state.update(dt)
    end
end

function love.draw()
    if current_state and current_state.draw then
        current_state.draw()
    end
end

function love.keypressed(key, scancode, isrepeat)
    if current_state and current_state.keypressed then
        current_state.keypressed(key, scancode, isrepeat)
    end
end

function love.keyreleased(key, scancode)
    if current_state and current_state.keyreleased then
        current_state.keyreleased(key, scancode)
    end
end

function love.textinput(text)
    if current_state and current_state.textinput then
        current_state.textinput(text)
    end
end
