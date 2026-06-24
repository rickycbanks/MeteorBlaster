-- Meteor Blaster - Main Menu State
-- Displays title, navigation options (Start, Leaderboard, Exit),
-- controls reference at the bottom, and floating background asteroids.

local asteroidModule = require("asteroid")
local utils = require("utils")

local menu = {}

-- ── Menu options ────────────────────────────────────────────────
local options = {
    { label = "Start Game",   action = function() switchState("play") end },
    { label = "Leaderboard",  action = function() switchState("leaderboard") end },
    { label = "Exit",         action = function() love.event.quit() end },
}

-- ── State ───────────────────────────────────────────────────────
local selectedIndex
local titleFont
local menuFont
local smallFont
local defaultFont
local bgAsteroids

-- ── Callbacks ───────────────────────────────────────────────────

function menu.enter()
    selectedIndex = 1

    -- Pre-create font objects
    titleFont   = love.graphics.newFont(32)
    menuFont    = love.graphics.newFont(16)
    smallFont   = love.graphics.newFont(12)
    defaultFont = love.graphics.getFont()   -- keep a reference for cleanup

    -- Spawn a few slowly drifting background asteroids for ambiance
    bgAsteroids = {}
    for _ = 1, 5 do
        local x = love.math.random(0, 800)
        local y = love.math.random(0, 600)
        local vx = (love.math.random() - 0.5) * 30
        local vy = (love.math.random() - 0.5) * 30
        table.insert(bgAsteroids, asteroidModule.new(x, y, "large", vx, vy))
    end
end

function menu.leave()
    bgAsteroids = nil
    titleFont = nil
    menuFont = nil
    smallFont = nil
end

function menu.update(dt)
    -- Gentle drift of background asteroids
    for _, a in ipairs(bgAsteroids) do
        a:update(dt)
    end
end

function menu.draw()
    -- Clear background
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    -- Draw background asteroids (dimmed slightly for depth)
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    for _, a in ipairs(bgAsteroids) do
        a:draw()
    end
    love.graphics.setColor(1, 1, 1)

    -- ── Title ───────────────────────────────────────────────
    love.graphics.setFont(titleFont)
    local titleText = "METEOR BLASTER"
    love.graphics.print(titleText, 400 - titleFont:getWidth(titleText) / 2, 80)

    -- ── Menu Options ────────────────────────────────────────
    love.graphics.setFont(menuFont)
    local startY = 220
    local spacing = 50

    for i, opt in ipairs(options) do
        local prefix = (i == selectedIndex) and "> " or "  "
        local text = prefix .. opt.label

        if i == selectedIndex then
            love.graphics.setColor(1, 0.8, 0)   -- warm gold highlight
        else
            love.graphics.setColor(1, 1, 1)
        end

        love.graphics.print(text, 300, startY + (i - 1) * spacing)
    end

    -- ── Controls ────────────────────────────────────────────
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(smallFont)

    local controlsY = 450
    local cx = 260

    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.print("--- CONTROLS ---", cx + 80, controlsY)

    love.graphics.setColor(0.45, 0.45, 0.45)
    love.graphics.print("Left / Right Arrow   Rotate Ship",    cx, controlsY + 25)
    love.graphics.print("Up Arrow             Thrust Forward", cx, controlsY + 45)
    love.graphics.print("Space                Shoot",          cx, controlsY + 65)

    -- ── Restore defaults ────────────────────────────────────
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(defaultFont)
end

function menu.keypressed(key)
    if key == "up" then
        selectedIndex = selectedIndex - 1
        if selectedIndex < 1 then selectedIndex = #options end
    elseif key == "down" then
        selectedIndex = selectedIndex + 1
        if selectedIndex > #options then selectedIndex = 1 end
    elseif key == "return" or key == "kpenter" then
        options[selectedIndex].action()
    elseif key == "1" then
        options[1].action()
    elseif key == "2" then
        options[2].action()
    elseif key == "3" or key == "escape" then
        options[3].action()
    end
end

return menu
