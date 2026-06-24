-- Meteor Blaster - Asteroid Entity
-- Three sizes: large → medium → small. Each splits into two of the next size.
-- Irregular polygon shapes, drifting movement, screen wrapping.

local utils = require("utils")

local asteroid = {}

-- Size definitions: radius and what they split into
local SIZE_CONFIG = {
    large  = { radius = 40, splitInto = "medium" },
    medium = { radius = 20, splitInto = "small"  },
    small  = { radius = 10, splitInto = nil       },
}

--- Create a new asteroid
-- @param x, y   Spawn position
-- @param size   "large", "medium", or "small"
-- @param vx, vy Initial velocity (optional, will be randomized if nil)
function asteroid.new(x, y, size, vx, vy)
    local config = SIZE_CONFIG[size] or SIZE_CONFIG.large
    local self = {
        x = x or 0,
        y = y or 0,
        size = size or "large",
        radius = config.radius,
        vx = vx or 0,
        vy = vy or 0,
        angle = love.math.random() * 2 * math.pi,
        rotationSpeed = (love.math.random() - 0.5) * 3,   -- rad/s, slight spin
        vertices = utils.generateAsteroidVertices(config.radius),
        dead = false,
    }
    setmetatable(self, { __index = asteroid })
    return self
end

function asteroid:update(dt)
    if self.dead then return end

    -- Move
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    -- Screen wrapping
    self.x, self.y = utils.wrapPosition(self.x, self.y)

    -- Spin
    self.angle = self.angle + self.rotationSpeed * dt
end

function asteroid:draw()
    if self.dead then return end

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)

    love.graphics.setColor(1, 1, 1)
    love.graphics.polygon("line", self.vertices)

    love.graphics.pop()
end

-- Split this asteroid into two smaller ones (or nil if it's a small asteroid)
-- Returns a table of new Asteroid objects
function asteroid:split()
    local nextSize = SIZE_CONFIG[self.size].splitInto
    if not nextSize then
        return {}   -- small asteroid: no split
    end

    -- Calculate two divergent velocity directions from current velocity
    local speed = math.sqrt(self.vx * self.vx + self.vy * self.vy) * 1.5
    -- Minimum speed for spawned asteroids so they don't just sit there
    if speed < 30 then speed = 30 end

    local baseAngle = math.atan2(self.vy, self.vx)
    -- If velocity is zero (shouldn't happen normally), pick a random direction
    if self.vx == 0 and self.vy == 0 then
        baseAngle = love.math.random() * 2 * math.pi
    end

    local spreadAngle = math.pi / 4   -- 45° spread

    local a1 = asteroid.new(
        self.x, self.y, nextSize,
        math.cos(baseAngle + spreadAngle) * speed,
        math.sin(baseAngle + spreadAngle) * speed
    )
    local a2 = asteroid.new(
        self.x, self.y, nextSize,
        math.cos(baseAngle - spreadAngle) * speed,
        math.sin(baseAngle - spreadAngle) * speed
    )

    return { a1, a2 }
end

-- Check if this asteroid overlaps another entity (circle collision)
function asteroid:collidesWith(x, y, radius)
    return utils.circleCollision(self.x, self.y, self.radius, x, y, radius)
end

return asteroid
