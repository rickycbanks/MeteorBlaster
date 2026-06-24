-- Meteor Blaster - Play State
-- Core gameplay: ship control, asteroid spawning/splitting, collision detection,
-- scoring, level progression, and lives management.

local shipModule = require("ship")
local asteroidModule = require("asteroid")
local bulletModule = require("bullet")
local utils = require("utils")
local sounds = require("sounds")

local play = {}

-- ── Game Constants ──────────────────────────────────────────────
local BASE_SPEED          = 50
local SPEED_INCREMENT     = 10
local BASE_COUNT          = 4
local POINTS_PER_ASTEROID = 100
local SPAWN_SAFE_DISTANCE = 150
local LEVEL_TRANSITION_TIME = 2.0

-- ── State ───────────────────────────────────────────────────────
local player
local asteroids
local bullets
local score
local level
local levelTimer
local transitioning

-- ── Helpers ─────────────────────────────────────────────────────

-- Calculate asteroid base speed for the current level.
-- Even levels (2,4,6,8,10) increase speed; after level 10, every level increases speed.
local function getCurrentSpeed()
    local speedUps
    if level <= 1 then
        speedUps = 0
    elseif level <= 10 then
        speedUps = math.floor(level / 2)
    else
        speedUps = level - 5
    end
    return BASE_SPEED + speedUps * SPEED_INCREMENT
end

-- Spawn large asteroids for the current level.
-- Count increases on odd levels (3,5,7,9), capped at level 10.
local function spawnAsteroids()
    local count = BASE_COUNT + math.floor(math.min(level - 1, 9) / 2)

    for _ = 1, count do
        local x, y
        -- Keep picking positions until we're far enough from the ship
        repeat
            x = love.math.random(0, 800)
            y = love.math.random(0, 600)
        until utils.distance(x, y, player.x, player.y) > SPAWN_SAFE_DISTANCE

        local angle = love.math.random() * 2 * math.pi
        local speed = getCurrentSpeed() * (0.5 + love.math.random())
        local vx = math.cos(angle) * speed
        local vy = math.sin(angle) * speed

        table.insert(asteroids, asteroidModule.new(x, y, "large", vx, vy))
    end
end

-- ── State Callbacks ─────────────────────────────────────────────

function play.enter()
    player = shipModule.new(400, 300)
    asteroids = {}
    bullets = {}
    score = 0
    level = 1
    levelTimer = LEVEL_TRANSITION_TIME
    transitioning = true

    spawnAsteroids()
end

function play.leave()
    sounds.stopThrust()
    player = nil
    asteroids = nil
    bullets = nil
end

function play.update(dt)
    -- Level transition countdown (pause gameplay briefly)
    if transitioning then
        levelTimer = levelTimer - dt
        if levelTimer <= 0 then
            transitioning = false
        end
        return
    end

    -- ── Update player ───────────────────────────────────────
    player:update(dt)

    -- Thruster sound: play low rumble while accelerating
    if player.thrusting then
        sounds.playThrust()
    else
        sounds.stopThrust()
    end

    -- Shooting
    if love.keyboard.isDown("space") then
        local spawnInfo = player:shoot()
        if spawnInfo then
            table.insert(bullets, bulletModule.new(spawnInfo.x, spawnInfo.y, spawnInfo.angle))
            sounds.playShoot()
        end
    end

    -- ── Update asteroids & bullets ──────────────────────────
    for _, a in ipairs(asteroids) do a:update(dt) end
    for _, b in ipairs(bullets)   do b:update(dt) end

    -- ── Bullet ↔ Asteroid collision ─────────────────────────
    for bi = #bullets, 1, -1 do
        local b = bullets[bi]
        if not b:isDead() then
            for ai = #asteroids, 1, -1 do
                local a = asteroids[ai]
                if not a.dead and a:collidesWith(b.x, b.y, b.radius) then
                    -- Hit! Destroy bullet, split asteroid, award points
                    b.dead = true
                    a.dead = true
                    score = score + POINTS_PER_ASTEROID
                    sounds.playExplosion(a.size)

                    local fragments = a:split()
                    for _, frag in ipairs(fragments) do
                        table.insert(asteroids, frag)
                    end
                    break   -- bullet can only hit one asteroid
                end
            end
        end
    end

    -- ── Clean up dead entities ──────────────────────────────
    for bi = #bullets, 1, -1 do
        if bullets[bi]:isDead() then
            table.remove(bullets, bi)
        end
    end
    for ai = #asteroids, 1, -1 do
        if asteroids[ai].dead then
            table.remove(asteroids, ai)
        end
    end

    -- ── Ship ↔ Asteroid collision ───────────────────────────
    if not player.dead then
        for _, a in ipairs(asteroids) do
            if not a.dead and a:collidesWith(player.x, player.y, player.radius) then
                -- Only play death sound when actually taking damage (not invincible)
                if not player.invincible then
                    sounds.playDeath()
                end
                local gameOver = player:hit()
                if gameOver then
                    switchState("gameover", score, level)
                    return
                end
                break   -- only lose one life per frame
            end
        end
    end

    -- ── Level clear check ───────────────────────────────────
    if #asteroids == 0 then
        level = level + 1
        bullets = {}               -- clear remaining bullets
        levelTimer = LEVEL_TRANSITION_TIME
        transitioning = true
        spawnAsteroids()
    end
end

function play.draw()
    -- Clear background
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    -- Draw entities
    for _, a in ipairs(asteroids) do a:draw() end
    for _, b in ipairs(bullets)   do b:draw() end
    player:draw()

    -- ── HUD ─────────────────────────────────────────────────
    love.graphics.setColor(1, 1, 1)

    -- Score (top-left)
    love.graphics.print("SCORE: " .. score, 10, 10)

    -- Level (top-center)
    local levelText = "LEVEL: " .. level
    local font = love.graphics.getFont()
    love.graphics.print(levelText, 400 - font:getWidth(levelText) / 2, 10)

    -- Lives (top-right) — small ship icons
    local livesLabel = "LIVES: "
    local livesLabelWidth = font:getWidth(livesLabel)
    love.graphics.print(livesLabel, 790 - livesLabelWidth - player.lives * 20, 10)
    for i = 1, player.lives do
        local x = 790 - (player.lives - i) * 20
        local y = 20
        love.graphics.push()
        love.graphics.translate(x, y)
        love.graphics.rotate(-math.pi / 2)   -- point up
        love.graphics.polygon("line", 6, 0, -4, -4, -4, 4)
        love.graphics.pop()
    end

    -- ── Level transition overlay ────────────────────────────
    if transitioning then
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", 0, 0, 800, 600)
        love.graphics.setColor(1, 1, 1)
        local text = "LEVEL " .. level
        love.graphics.print(text, 400 - font:getWidth(text) / 2, 280)
    end
end

function play.keypressed(key)
    if key == "escape" then
        switchState("menu")
    end
end

return play
