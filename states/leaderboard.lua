-- Meteor Blaster - Leaderboard State
-- Displays the top 10 high scores, loaded from persistent storage.

local utils = require("utils")

local leaderboard = {}

-- ── State ───────────────────────────────────────────────────────
local scores
local highlightName  -- name to highlight (from just-submitted score)
local titleFont
local entryFont
local smallFont
local defaultFont

-- ── Callbacks ───────────────────────────────────────────────────

function leaderboard.enter(recentName)
    scores = utils.loadScores()
    highlightName = recentName

    titleFont  = love.graphics.newFont(32)
    entryFont  = love.graphics.newFont(14)
    smallFont  = love.graphics.newFont(12)
    defaultFont = love.graphics.getFont()
end

function leaderboard.leave()
    scores = nil
    highlightName = nil
    titleFont = nil
    entryFont = nil
    smallFont = nil
end

function leaderboard.update(dt)
    -- nothing to update
end

function leaderboard.draw()
    -- Background
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    -- Title
    love.graphics.setFont(titleFont)
    love.graphics.setColor(1, 1, 1)
    local titleText = "LEADERBOARD"
    love.graphics.print(titleText, 400 - titleFont:getWidth(titleText) / 2, 40)

    -- Column headers
    love.graphics.setFont(entryFont)
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.print("RANK", 160, 110)
    love.graphics.print("NAME", 240, 110)
    love.graphics.print("SCORE", 420, 110)
    love.graphics.print("LEVEL", 540, 110)

    -- Separator line
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.line(150, 130, 650, 130)

    -- Score entries
    local startY = 145
    local rowHeight = 30

    if #scores == 0 then
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.print("No scores yet — go play!", 280, startY + 40)
    else
        for i, entry in ipairs(scores) do
            local y = startY + (i - 1) * rowHeight

            -- Highlight the just-submitted score
            if highlightName and entry.name == highlightName then
                love.graphics.setColor(1, 0.8, 0)   -- gold
            elseif i <= 3 then
                love.graphics.setColor(0.8, 0.8, 0.8)   -- top 3 slightly brighter
            else
                love.graphics.setColor(0.6, 0.6, 0.6)
            end

            -- Rank with ordinal decoration for top 3
            local rankText
            if i == 1 then rankText = "1st"
            elseif i == 2 then rankText = "2nd"
            elseif i == 3 then rankText = "3rd"
            else rankText = tostring(i) .. "th"
            end
            love.graphics.print(rankText, 160, y)
            love.graphics.print(entry.name, 240, y)
            love.graphics.print(tostring(entry.score), 420, y)
            love.graphics.print(tostring(entry.level), 540, y)
        end
    end

    -- Footer
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(smallFont)
    love.graphics.print("Press Enter or Space to return to menu", 260, 560)

    -- Restore
    love.graphics.setFont(defaultFont)
    love.graphics.setColor(1, 1, 1)
end

function leaderboard.keypressed(key)
    if key == "return" or key == "kpenter" or key == "space" or key == "escape" then
        switchState("menu")
    end
end

return leaderboard
