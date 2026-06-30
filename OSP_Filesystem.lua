local Filesystem = {}

local isWindows = package.config:sub(1, 1) == "\\"
local separator = isWindows and "\\" or "/"

local function quote(path)
    return '"' .. tostring(path):gsub('"', '\\"') .. '"'
end

local function commandMkdir(path)
    if isWindows then
        return 'if not exist ' .. quote(path) .. ' mkdir ' .. quote(path)
    end

    return 'mkdir -p ' .. quote(path)
end

local function commandRmdir(path)
    if isWindows then
        return 'if exist ' .. quote(path) .. ' rmdir /s /q ' .. quote(path)
    end

    return 'rm -rf ' .. quote(path)
end

function Filesystem.join(...)
    local parts = {...}
    local result = nil

    for index = 1, #parts do
        local part = parts[index]
        if part ~= nil and part ~= "" then
            part = tostring(part)
            if result == nil then
                result = part
            else
                result = result:gsub("[/\\]+$", "") .. separator .. part:gsub("^[/\\]+", "")
            end
        end
    end

    return result or ""
end

function Filesystem.safeName(value)
    local text = tostring(value or "unknown")
    text = text:gsub("[^A-Za-z0-9_.%-]+", "_")
    text = text:gsub("^_+", "")
    text = text:gsub("_+$", "")

    if text == "" then
        return "unknown"
    end

    return text
end

function Filesystem.exists(path)
    local handle = io.open(path, "rb")
    if handle == nil then
        return false
    end

    handle:close()
    return true
end

function Filesystem.mkdir(path)
    local ok = os.execute(commandMkdir(path))
    return ok == true or ok == 0
end

function Filesystem.rmdir(path)
    local ok = os.execute(commandRmdir(path))
    return ok == true or ok == 0
end

function Filesystem.writeBinary(path, content)
    local handle = io.open(path, "wb")
    if handle == nil then
        error("Cannot write file: " .. path)
    end

    handle:write(content or "")
    handle:close()
end

function Filesystem.ensureDirectory(path)
    if not Filesystem.mkdir(path) then
        error("Cannot create directory: " .. path)
    end
end

return Filesystem
