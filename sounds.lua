-- Meteor Blaster - Procedural Sound Effects
-- Generates all sound effects in-memory using love.sound.newSoundData.
-- No external audio files needed. Each sound is a short synthetic waveform.

local sounds = {}
local initialized = false

-- SoundData objects (generated once, reused for every play call)
local shootSD
local explosionLgSD    -- large / medium asteroids
local explosionSmSD    -- small asteroids (shorter)
local deathSD
local thrustSD         -- looping thruster rumble

-- Persistent looping source for the thruster (so we can start/stop it)
local thrustSource

local SAMPLE_RATE = 44100
local BIT_DEPTH = 16
local CHANNELS = 1

-- ── Waveform Generators ─────────────────────────────────────────

-- Simple sine wave at a given frequency
local function sineSample(t, freq)
    return math.sin(t * freq * 2 * math.pi)
end

-- White noise (flat random)
local function noiseSample()
    return love.math.random() * 2 - 1
end

-- Generate a shoot blip: short high-pitched sine with fast decay
local function generateShoot()
    local duration = 0.07
    local freq = 1200
    local samples = math.floor(SAMPLE_RATE * duration)
    local sd = love.sound.newSoundData(samples, SAMPLE_RATE, BIT_DEPTH, CHANNELS)

    for i = 0, samples - 1 do
        local t = i / SAMPLE_RATE
        -- Sharp attack + exponential decay
        local envelope = math.max(0, 1 - (i / samples)) ^ 0.5
        local sample = sineSample(t, freq) * envelope * 0.3
        sd:setSample(i, sample)
    end

    return sd
end

-- Generate an explosion: noise burst with quick decay
local function generateExplosion(duration, volume)
    local samples = math.floor(SAMPLE_RATE * duration)
    local sd = love.sound.newSoundData(samples, SAMPLE_RATE, BIT_DEPTH, CHANNELS)

    for i = 0, samples - 1 do
        -- Non-linear envelope: holds for a bit, then decays
        local progress = i / samples
        local envelope
        if progress < 0.05 then
            envelope = progress / 0.05          -- quick attack
        else
            envelope = math.max(0, 1 - (progress - 0.05) / 0.95) ^ 0.7
        end
        local sample = noiseSample() * envelope * volume
        sd:setSample(i, sample)
    end

    return sd
end

-- Generate ship death: descending tone sweep
local function generateDeath()
    local duration = 0.5
    local startFreq = 440
    local endFreq = 80
    local samples = math.floor(SAMPLE_RATE * duration)
    local sd = love.sound.newSoundData(samples, SAMPLE_RATE, BIT_DEPTH, CHANNELS)

    for i = 0, samples - 1 do
        local t = i / SAMPLE_RATE
        local progress = t / duration
        -- Exponential frequency sweep (sounds more natural than linear)
        local freq = startFreq * (endFreq / startFreq) ^ progress
        -- Envelope: sustain briefly then fade
        local envelope = math.max(0, 1 - progress) ^ 0.5
        local sample = sineSample(t, freq) * envelope * 0.3
        sd:setSample(i, sample)
    end

    return sd
end

-- Generate a looping thruster rumble: low sine tones + filtered noise
local function generateThrust()
    local duration = 0.4
    local samples = math.floor(SAMPLE_RATE * duration)
    local sd = love.sound.newSoundData(samples, SAMPLE_RATE, BIT_DEPTH, CHANNELS)

    for i = 0, samples - 1 do
        local t = i / SAMPLE_RATE
        -- Mix of low sine waves for a mechanical hum
        local tone = sineSample(t, 70)  * 0.25
                   + sineSample(t, 110) * 0.15
                   + sineSample(t, 150) * 0.10
        -- Low-pass-ish noise by averaging consecutive samples (simulated here by
        -- using a slower-changing noise: just regular noise at low amplitude)
        local noise = noiseSample() * 0.08
        local sample = (tone + noise) * 0.4
        sd:setSample(i, sample)
    end

    return sd
end

-- ── Initialization (lazy, called on first play) ─────────────────

local function ensureInit()
    if initialized then return end
    initialized = true

    shootSD        = generateShoot()
    explosionLgSD  = generateExplosion(0.25, 0.35)   -- longer, louder for big rocks
    explosionSmSD  = generateExplosion(0.12, 0.2)    -- shorter, quieter for small
    deathSD        = generateDeath()
    thrustSD       = generateThrust()

    -- Create a persistent looping source for the thruster
    thrustSource = love.audio.newSource(thrustSD, "static")
    thrustSource:setLooping(true)
    thrustSource:setVolume(0.25)   -- quiet background hum
end

-- ── Public API ──────────────────────────────────────────────────

-- Force pre-generation of all sound data (call once at startup)
function sounds.init()
    ensureInit()
end

-- Fire a short shoot sound
function sounds.playShoot()
    ensureInit()
    love.audio.newSource(shootSD, "static"):play()
end

-- Play an explosion. Size can be "large", "medium", or "small".
function sounds.playExplosion(size)
    ensureInit()
    local sd = (size == "small") and explosionSmSD or explosionLgSD
    love.audio.newSource(sd, "static"):play()
end

-- Play the ship death sound
function sounds.playDeath()
    ensureInit()
    love.audio.newSource(deathSD, "static"):play()
end

-- Start the looping thruster sound (idempotent — safe to call repeatedly)
function sounds.playThrust()
    ensureInit()
    if not thrustSource:isPlaying() then
        thrustSource:play()
    end
end

-- Stop the thruster sound
function sounds.stopThrust()
    if thrustSource and thrustSource:isPlaying() then
        thrustSource:stop()
    end
end

return sounds
