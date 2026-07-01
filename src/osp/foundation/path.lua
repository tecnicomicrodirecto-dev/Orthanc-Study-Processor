------------------------------------------------------------------------------
-- OSP Path
--
-- Pure path manipulation helpers.
--
-- This module performs string operations only. It never touches the filesystem.
-- Every filesystem interaction belongs in the infrastructure/filesystem layer.
------------------------------------------------------------------------------

local Validation = require("osp.foundation.validation")

local Path = {}

------------------------------------------------------------------------------
-- Private Helpers
------------------------------------------------------------------------------

local DEFAULT_SEPARATOR = "/"

local function trimTrailingSeparators(path)

    while #path > 1 do

        local last = path:sub(-1)

        if last ~= "/" and last ~= "\\" then
            break
        end

        path = path:sub(1, -2)

    end

    return path

end

local function splitExtension(path)

    local filename = path:match("([^/\\]+)$") or path

    local position = filename:match("^.*()%.")
    if not position then
        return filename, ""
    end

    return filename:sub(1, position - 1), filename:sub(position)

end

------------------------------------------------------------------------------
-- Public API
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Combines path fragments.
--
-- Nil or empty fragments are ignored.
--
-- @return string
------------------------------------------------------------------------------
function Path.Combine(...)

    local parts = { ... }
    local result = {}

    for _, part in ipairs(parts) do

        if part ~= nil and part ~= "" then

            Validation.Type(part, "path", "string")

            table.insert(
                result,
                trimTrailingSeparators(part)
            )

        end

    end

    return table.concat(result, DEFAULT_SEPARATOR)

end

------------------------------------------------------------------------------
--- Normalizes directory separators.
--
-- @param path string
-- @return string
------------------------------------------------------------------------------
function Path.Normalize(path)

    Validation.Type(path, "path", "string")

    path = path:gsub("\\", DEFAULT_SEPARATOR)
    path = path:gsub("/+", DEFAULT_SEPARATOR)

    return path

end

------------------------------------------------------------------------------
--- Returns the filename.
------------------------------------------------------------------------------
function Path.FileName(path)

    Validation.Type(path, "path", "string")

    return path:match("([^/\\]+)$") or ""

end

------------------------------------------------------------------------------
--- Returns the filename without extension.
------------------------------------------------------------------------------
function Path.FileNameWithoutExtension(path)

    local filename = Path.FileName(path)

    local stem = splitExtension(filename)

    return stem

end

------------------------------------------------------------------------------
--- Returns the extension including the leading '.'.
------------------------------------------------------------------------------
function Path.Extension(path)

    Validation.Type(path, "path", "string")

    local _, extension = splitExtension(path)

    return extension

end

------------------------------------------------------------------------------
--- Returns the directory portion.
------------------------------------------------------------------------------
function Path.DirectoryName(path)

    Validation.Type(path, "path", "string")

    return path:match("^(.*)[/\\][^/\\]+$") or ""

end

------------------------------------------------------------------------------
--- Changes the file extension.
------------------------------------------------------------------------------
function Path.ChangeExtension(path, extension)

    Validation.Type(path, "path", "string")
    Validation.Type(extension, "extension", "string")

    local directory = Path.DirectoryName(path)
    local filename = Path.FileNameWithoutExtension(path)

    local result = filename

    if extension ~= "" then

        if extension:sub(1, 1) ~= "." then
            extension = "." .. extension
        end

        result = result .. extension

    end

    if directory == "" then
        return result
    end

    return Path.Combine(directory, result)

end

------------------------------------------------------------------------------
--- Returns true if the path is absolute.
------------------------------------------------------------------------------
function Path.IsAbsolute(path)

    Validation.Type(path, "path", "string")

    return
        path:match("^%a:[/\\]") ~= nil or
        path:sub(1,1) == "/" or
        path:sub(1,2) == "\\\\"

end

------------------------------------------------------------------------------
--- Ensures exactly one trailing separator.
------------------------------------------------------------------------------
function Path.EnsureTrailingSeparator(path)

    Validation.Type(path, "path", "string")

    return trimTrailingSeparators(path) .. DEFAULT_SEPARATOR

end

------------------------------------------------------------------------------
return Path
