-- Meteor Blaster - Bullet Entity
-- Small, fast-moving projectile with a limited lifetime.
-- Travels in a straight line, wraps around screen edges.

local utils = require("utils")

local bullet = {}

local BULLET_SPEED = 500
local BULLET_LIFETIME = 1.5    -- seconds before auto-destruction
local BULLET_RADIUS = 3

--- Create a new bullet
-- @param x, y   Spawn position
-- @param angle  Direction of travel (radians)
function bullet.new(x, y, angle)
    local self = {
        x = x or 0,
        y = y or 0,
        vx = math.cos(angle) * BULLET_SPEED,
        vy = math.sin(angle) * BULLET_SPEED,
        radius = BULLET_RADIUS,
        lifetime = BULLET_LIFETIME,
        dead = false,
    }
    setmetatable(self, { __index = bullet })
    return self
end

function bullet:update(dt)
    if self.dead then return end

    -- Move
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    -- Screen wrapping
    self.x, self.y = utils.wrapPosition(self.x, self.y)

    -- Lifetime countdown
    self.lifetime = self.lifetime - dt
    if self.lifetime <= 0 then
        self.dead = true
    end
end

function bullet:draw()
    if self.dead then return end

    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

-- Check if bullet has expired or been destroyed
function bullet:isDead()
    return self.dead
end

return bullet
