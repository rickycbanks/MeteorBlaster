-- Meteor Blaster - Ship Entity
-- Player-controlled spaceship: rotates, thrusts, shoots, wraps around screen

local utils = require("utils")

local ship = {}

-- Ship constants
local ROTATION_SPEED = 5        -- radians per second
local THRUST_POWER = 300        -- acceleration in px/s²
local MAX_SPEED = 300           -- max speed in px/s
local DRAG = 0.99               -- per-frame velocity damping
local SHOOT_COOLDOWN = 0.25     -- seconds between shots
local INVINCIBLE_DURATION = 2.0 -- seconds after respawn
local BULLET_OFFSET = 18        -- distance from ship center to bullet spawn

function ship.new(x, y)
    local self = {
        x = x or 400,
        y = y or 300,
        vx = 0,
        vy = 0,
        angle = -math.pi / 2,   -- point upward (-Y in LÖVE)
        radius = 15,            -- collision circle radius
        lives = 3,
        invincible = false,
        invincTimer = 0,
        shootCooldown = 0,
        thrusting = false,
        dead = false,
    }
    setmetatable(self, { __index = ship })
    return self
end

-- Place ship at screen center with zero velocity, brief invincibility
function ship:reset()
    self.x = 400
    self.y = 300
    self.vx = 0
    self.vy = 0
    self.angle = -math.pi / 2
    self.invincible = true
    self.invincTimer = INVINCIBLE_DURATION
    self.shootCooldown = 0
    self.dead = false
end

function ship:update(dt)
    if self.dead then return end

    -- Rotation input
    if love.keyboard.isDown("left") then
        self.angle = self.angle - ROTATION_SPEED * dt
    end
    if love.keyboard.isDown("right") then
        self.angle = self.angle + ROTATION_SPEED * dt
    end

    -- Thrust input
    self.thrusting = love.keyboard.isDown("up")
    if self.thrusting then
        self.vx = self.vx + math.cos(self.angle) * THRUST_POWER * dt
        self.vy = self.vy + math.sin(self.angle) * THRUST_POWER * dt
    end

    -- Apply drag (friction-like deceleration)
    self.vx = self.vx * DRAG
    self.vy = self.vy * DRAG

    -- Cap speed
    local speed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
    if speed > MAX_SPEED then
        self.vx = (self.vx / speed) * MAX_SPEED
        self.vy = (self.vy / speed) * MAX_SPEED
    end

    -- Update position
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    -- Screen wrapping
    self.x, self.y = utils.wrapPosition(self.x, self.y)

    -- Update timers
    if self.invincible then
        self.invincTimer = self.invincTimer - dt
        if self.invincTimer <= 0 then
            self.invincible = false
        end
    end

    if self.shootCooldown > 0 then
        self.shootCooldown = self.shootCooldown - dt
    end
end

function ship:draw()
    if self.dead then return end

    -- Blink effect during invincibility: skip every other blink phase
    if self.invincible then
        local blinkPhase = math.floor(self.invincTimer * 10) % 2
        if blinkPhase == 0 then
            return
        end
    end

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)

    -- Draw ship as a triangle — tip points to angle 0 (right)
    love.graphics.setColor(1, 1, 1)
    love.graphics.polygon("line", 15, 0, -10, -10, -10, 10)

    -- Draw thrust flame when accelerating (flickering, shoots out the back at x=-10)
    if self.thrusting then
        local flameLen = 8 + love.math.random() * 8
        local flameWidth = 3 + love.math.random() * 3
        love.graphics.setColor(1, 0.5 + love.math.random() * 0.5, 0)
        love.graphics.polygon("fill",
            -10, -flameWidth,
            -10 - flameLen, 0,
            -10, flameWidth
        )
    end

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1)   -- restore default color
end

-- Attempt to fire a bullet. Returns {x, y, angle} if successful, nil otherwise.
function ship:shoot()
    if self.dead then return nil end
    if self.shootCooldown > 0 then return nil end

    self.shootCooldown = SHOOT_COOLDOWN

    return {
        x = self.x + math.cos(self.angle) * BULLET_OFFSET,
        y = self.y + math.sin(self.angle) * BULLET_OFFSET,
        angle = self.angle,
    }
end

-- Handle ship being hit. Returns true if the ship loses a life (player should check for game over).
function ship:hit()
    if self.invincible then return false end

    self.lives = self.lives - 1
    if self.lives <= 0 then
        self.dead = true
        return true   -- game over
    end

    self:reset()
    return false  -- just lost a life, still alive
end

return ship
