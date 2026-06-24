-- Meteor Blaster - Shared Utilities

local utils = {}

local WINDOW_WIDTH = 800
local WINDOW_HEIGHT = 600

-- Screen wrapping: if an entity goes off one edge, it appears on the opposite edge
function utils.wrapPosition(x, y)
    if x < 0 then x = x + WINDOW_WIDTH
    elseif x > WINDOW_WIDTH then x = x - WINDOW_WIDTH end
    if y < 0 then y = y + WINDOW_HEIGHT
    elseif y > WINDOW_HEIGHT then y = y - WINDOW_HEIGHT end
    return x, y
end

-- Euclidean distance between two points
function utils.distance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end

-- Simple circle-circle collision check
function utils.circleCollision(x1, y1, r1, x2, y2, r2)
    local dx = x1 - x2
    local dy = y1 - y2
    local distSq = dx * dx + dy * dy
    local radSum = r1 + r2
    return distSq <= radSum * radSum
end

-- Generate irregular polygon vertices for an asteroid shape
-- Creates 8-12 vertices around the center, each offset randomly from the base radius
function utils.generateAsteroidVertices(radius)
    local numVertices = love.math.random(8, 12)
    local vertices = {}
    local angleStep = (2 * math.pi) / numVertices

    for i = 0, numVertices - 1 do
        local angle = i * angleStep
        -- Random offset: 70% to 130% of base radius for irregular look
        local offset = radius * (0.7 + love.math.random() * 0.6)
        local x = math.cos(angle) * offset
        local y = math.sin(angle) * offset
        table.insert(vertices, x)
        table.insert(vertices, y)
    end

    return vertices
end

-- Leaderboard file handling
local LEADERBOARD_PATH = "leaderboard.dat"

-- Load leaderboard scores from save directory
-- Returns a table of {name, score, level} entries, sorted by score descending
function utils.loadScores()
    local scores = {}

    -- Check if file exists
    local info = love.filesystem.getInfo(LEADERBOARD_PATH)
    if not info then
        return scores
    end

    local contents, size = love.filesystem.read(LEADERBOARD_PATH)
    if not contents then
        return scores
    end

    -- Parse each line: name|score|level
    for line in contents:gmatch("[^\r\n]+") do
        local name, score, level = line:match("^(.-)|(%d+)|(%d+)$")
        if name and score and level then
            table.insert(scores, {
                name = name,
                score = tonumber(score),
                level = tonumber(level)
            })
        end
    end

    -- Sort by score descending
    table.sort(scores, function(a, b) return a.score > b.score end)

    return scores
end

-- Save a new score entry to the leaderboard
function utils.saveScore(name, score, level)
    local scores = utils.loadScores()

    -- Add the new entry
    table.insert(scores, { name = name, score = score, level = level })

    -- Sort and keep only top 10
    table.sort(scores, function(a, b) return a.score > b.score end)
    if #scores > 10 then
        scores[11] = nil  -- truncate to top 10 in Lua 5.1
    end

    -- Serialize to string
    local lines = {}
    for _, entry in ipairs(scores) do
        table.insert(lines, entry.name .. "|" .. entry.score .. "|" .. entry.level)
    end

    -- Write to file
    love.filesystem.write(LEADERBOARD_PATH, table.concat(lines, "\n"))

    return scores
end

return utils
