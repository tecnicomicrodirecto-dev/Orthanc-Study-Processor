------------------------------------------------------------------------------
-- OSP Platform
--
-- Small platform primitives used by infrastructure adapters.
------------------------------------------------------------------------------

local Result = require("osp.foundation.result")

local Platform = {}

------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------

local function run(command)

    local ok, reason, code = os.execute(command)

    if ok == true or ok == 0 then
        return Result.Success()
    end

    return Result.Failure(
        "PLATFORM_COMMAND_FAILED",
        "Command failed: " .. command
    ):WithContext({
        Reason = reason,
        Code = code
    })

end

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Returns true when the runtime appears to be Windows.
--
-- @return boolean
------------------------------------------------------------------------------
function Platform.IsWindows()

    return package.config ~= nil and string.sub(package.config, 1, 1) == "\\"

end

------------------------------------------------------------------------------
--- Quotes a command argument.
--
-- @param value string
-- @return string
------------------------------------------------------------------------------
function Platform.Quote(value)

    value = tostring(value)

    if Platform.IsWindows() then
        return '"' .. string.gsub(value, '"', '\\"') .. '"'
    end

    return "'" .. string.gsub(value, "'", "'\\''") .. "'"

end

------------------------------------------------------------------------------
--- Creates a directory and any missing parents.
--
-- @param path string
-- @return table
------------------------------------------------------------------------------
function Platform.MakeDirectory(path)

    if Platform.IsWindows() then
        local quoted = Platform.Quote(path)

        return run("if not exist " .. quoted .. " mkdir " .. quoted)
    end

    return run("mkdir -p " .. Platform.Quote(path))

end

------------------------------------------------------------------------------
--- Removes a file or directory recursively.
--
-- @param path string
-- @return table
------------------------------------------------------------------------------
function Platform.Remove(path)

    if Platform.IsWindows() then
        local quoted = Platform.Quote(path)

        return run("if exist " .. quoted .. " rmdir /S /Q " .. quoted)
    end

    return run("rm -rf " .. Platform.Quote(path))

end

------------------------------------------------------------------------------
--- Copies a file.
--
-- @param source string
-- @param target string
-- @return table
------------------------------------------------------------------------------
function Platform.CopyFile(source, target)

    if Platform.IsWindows() then
        return run("copy /Y " .. Platform.Quote(source) .. " " .. Platform.Quote(target) .. " >nul")
    end

    return run("cp " .. Platform.Quote(source) .. " " .. Platform.Quote(target))

end

return Platform
