-- Meteor Blaster - Game Over State
-- Displays final score and level, collects player name for leaderboard entry.

local utils = require("utils")

local gameover = {}

-- ── State ───────────────────────────────────────────────────────
local finalScore
local finalLevel
local playerName
local playerNameMax = 8
local submitted
local titleFont
local infoFont
local defaultFont

-- ── Callbacks ───────────────────────────────────────────────────

function gameover.enter(score, level)
    finalScore = score or 0
    finalLevel = level or 1
    playerName = ""
    submitted = false

    titleFont  = love.graphics.newFont(36)
    infoFont   = love.graphics.newFont(14)
    defaultFont = love.graphics.getFont()
end

function gameover.leave()
    titleFont = nil
    infoFont = nil
    playerName = nil
end

function gameover.update(dt)
    -- nothing to update here — purely input-driven
end

function gameover.draw()
    -- Background
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    love.graphics.setColor(1, 0.3, 0.3)  -- reddish for game over

    -- Title
    love.graphics.setFont(titleFont)
    local titleText = "GAME OVER"
    love.graphics.print(titleText, 400 - titleFont:getWidth(titleText) / 2, 100)

    -- Score & level info
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(infoFont)
    love.graphics.print("Final Score: " .. finalScore, 320, 200)
    love.graphics.print("Level Reached: " .. finalLevel, 320, 225)

    -- Name entry prompt
    if not submitted then
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.print("Enter your name for the leaderboard:", 250, 300)
        love.graphics.setColor(1, 1, 1)

        -- Draw the name with a blinking cursor
        local displayName = playerName
        -- Blinking cursor every 0.5 seconds
        if math.floor(love.timer.getTime() * 2) % 2 == 0 then
            displayName = displayName .. "_"
        end
        love.graphics.print("[" .. displayName .. "]", 355, 330)

        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.println("Press Enter to submit, Esc to skip", 300, 370, 200)
    else
        love.graphics.setColor(0, 1, 0)
        love.graphics.print("Score saved! Press Enter to view leaderboard.", 250, 330)
    end
end

function gameover.keypressed(key)
    if not submitted then
        if key == "backspace" then
            -- Remove last character (handle UTF-8 multi-byte safely)
            if #playerName > 0 then
                -- Simple approach: remove last byte for ASCII names
                -- For safety, use string:sub with proper byte handling
                playerName = string.sub(playerName, 1, -2)
            end
        elseif key == "return" or key == "kpenter" then
            -- Submit — only save if name is not empty
            if #playerName > 0 then
                utils.saveScore(playerName, finalScore, finalLevel)
                submitted = true
            end
        elseif key == "escape" then
            -- Skip to menu without saving
            switchState("menu")
        end
    else
        -- Already submitted, any confirm key goes to leaderboard
        if key == "return" or key == "kpenter" or key == "space" then
            switchState("leaderboard", playerName)
        end
    end
end

function gameover.textinput(text)
    if submitted then return end

    -- Filter: only allow letters, digits, and basic punctuation
    -- Also limit to max length
    if #playerName < playerNameMax then
        -- Accept only printable ASCII (letters, digits, space, underscore, dash)
        if text:match("^[%w _%-]+$") then
            playerName = playerName .. text
        end
    end
end

return gameover
