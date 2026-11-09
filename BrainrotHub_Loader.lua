-- BRAINROT HUB AUTO LOADER

local URL = "https://github.com/levi182afk/Brainrot-hub-/blob/main/Brainrothub.lua"

local success, source = pcall(function()
    return game:HttpGet(URL)
end)

if not success then
    warn("Brainrot Hub: Download failed")
    return
end

local fn, err = loadstring(source)

if not fn then
    warn("Brainrot Hub: " .. tostring(err))
    return
end

local successRun, result = pcall(fn)

if not successRun then
    warn("Brainrot Hub error: " .. tostring(result))
end
