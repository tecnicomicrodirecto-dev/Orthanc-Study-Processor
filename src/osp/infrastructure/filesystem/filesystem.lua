------------------------------------------------------------------------------
-- OSP Filesystem
--
-- Filesystem adapter returning Result objects for operational failures.
------------------------------------------------------------------------------

local Platform = require("osp.foundation.platform")
local Result = require("osp.foundation.result")
local Validation = require("osp.foundation.validation")

local Filesystem = {}

------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------

local function tryOpen(path, mode)

    local handle, message = io.open(path, mode)

    if handle == nil then
        return nil, Result.Failure("FILE_OPEN_FAILED", tostring(message))
            :WithContext({ Path = path, Mode = mode })
    end

    return handle, nil

end

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Creates a directory.
--
-- @param path string
-- @return table
------------------------------------------------------------------------------
function Filesystem.CreateDirectory(path)

    Validation.NotEmpty(path, "path")

    return Platform.MakeDirectory(path)

end

------------------------------------------------------------------------------
--- Creates multiple directories.
--
-- @param directories table
-- @return table
------------------------------------------------------------------------------
function Filesystem.CreateDirectories(directories)

    Validation.Type(directories, "directories", "table")

    for _, directory in ipairs(directories) do
        local result = Filesystem.CreateDirectory(directory)

        if result:IsFailure() then
            return result
        end
    end

    return Result.Success()

end

------------------------------------------------------------------------------
--- Writes text or binary content to a file.
--
-- @param path string
-- @param content string
-- @param binary boolean|nil
-- @return table
------------------------------------------------------------------------------
function Filesystem.WriteFile(path, content, binary)

    Validation.NotEmpty(path, "path")
    Validation.Type(content, "content", "string")

    local handle, failure = tryOpen(path, binary and "wb" or "w")

    if failure ~= nil then
        return failure
    end

    local ok, message = handle:write(content)
    handle:close()

    if not ok then
        return Result.Failure("FILE_WRITE_FAILED", tostring(message))
            :WithContext({ Path = path })
    end

    return Result.Success(path)

end

------------------------------------------------------------------------------
--- Reads a file.
--
-- @param path string
-- @param binary boolean|nil
-- @return table
------------------------------------------------------------------------------
function Filesystem.ReadFile(path, binary)

    Validation.NotEmpty(path, "path")

    local handle, failure = tryOpen(path, binary and "rb" or "r")

    if failure ~= nil then
        return failure
    end

    local content = handle:read("*a")
    handle:close()

    return Result.Success(content or "")

end

------------------------------------------------------------------------------
--- Copies a file.
--
-- @param source string
-- @param target string
-- @return table
------------------------------------------------------------------------------
function Filesystem.CopyFile(source, target)

    Validation.NotEmpty(source, "source")
    Validation.NotEmpty(target, "target")

    return Platform.CopyFile(source, target)

end

------------------------------------------------------------------------------
--- Removes a file or directory.
--
-- @param path string
-- @return table
------------------------------------------------------------------------------
function Filesystem.Remove(path)

    Validation.NotEmpty(path, "path")

    return Platform.Remove(path)

end

return Filesystem
