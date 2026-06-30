local Config = {}

Config.defaults = {
    logLevel = "info",
    workspaceRoot = "C:\\OSP\\workspace",
    archiveRoot = "C:\\OSP\\archive",
    keepWorkspace = false,
    archiveProcessedStudy = true,
    deleteProcessedStudy = false,
    modifyStudy = {
        enabled = true,
        keepSource = true,
        force = true,
        replace = {},
        remove = {},
        keep = {}
    },
    presentation = {
        enabled = false,
        replace = {}
    }
}

local function clone(value)
    if type(value) ~= "table" then
        return value
    end

    local result = {}
    for key, item in pairs(value) do
        result[key] = clone(item)
    end
    return result
end

local function merge(target, source)
    if type(source) ~= "table" then
        return target
    end

    for key, value in pairs(source) do
        if type(value) == "table" and type(target[key]) == "table" then
            merge(target[key], value)
        else
            target[key] = clone(value)
        end
    end

    return target
end

local function readJsonFile(path)
    local handle = io.open(path, "rb")
    if handle == nil then
        return nil
    end

    local content = handle:read("*a")
    handle:close()

    if content == nil or content == "" then
        return nil
    end

    if ParseJson == nil then
        error("ParseJson is not available; cannot read " .. path)
    end

    return ParseJson(content)
end

function Config.load(path)
    local config = clone(Config.defaults)

    if path ~= nil and path ~= "" then
        local fileConfig = readJsonFile(path)
        if fileConfig ~= nil then
            merge(config, fileConfig)
        end
    end

    return config
end

return Config
