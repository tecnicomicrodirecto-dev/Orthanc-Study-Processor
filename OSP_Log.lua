local Log = {}

Log.levels = {
    debug = 10,
    info = 20,
    warn = 30,
    error = 40
}

Log.currentLevel = Log.levels.info

local function write(level, message)
    local text = "[OSP] [" .. string.upper(level) .. "] " .. tostring(message)

    if level == "error" and PrintError ~= nil then
        PrintError(text)
        return
    end

    if Print ~= nil then
        Print(text)
        return
    end

    print(text)
end

function Log.setLevel(level)
    if level == nil then
        return
    end

    local normalized = string.lower(tostring(level))
    if Log.levels[normalized] ~= nil then
        Log.currentLevel = Log.levels[normalized]
    end
end

function Log.debug(message)
    if Log.currentLevel <= Log.levels.debug then
        write("debug", message)
    end
end

function Log.info(message)
    if Log.currentLevel <= Log.levels.info then
        write("info", message)
    end
end

function Log.warn(message)
    if Log.currentLevel <= Log.levels.warn then
        write("warn", message)
    end
end

function Log.error(message)
    if Log.currentLevel <= Log.levels.error then
        write("error", message)
    end
end

return Log
