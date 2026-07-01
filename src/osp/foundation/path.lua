------------------------------------------------------------------------------
-- OSP Path
--
-- Reusable path manipulation helpers.
------------------------------------------------------------------------------

local Constants = require("osp.foundation.constants")
local Validation = require("osp.foundation.validation")

local Path = {}

------------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------------

local WINDOWS_SEPARATOR = Constants.Platform.WindowsSeparator
local UNIX_SEPARATOR = Constants.Platform.UnixSeparator

------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------

local function normalizeSeparator(separator)

    if separator == nil or separator == "" then
        return WINDOWS_SEPARATOR
    end

    return separator

end

local function trimTrailingSeparator(value)

    while #value > 1 do
        local last = string.sub(value, -1)

        if last ~= WINDOWS_SEPARATOR and last ~= UNIX_SEPARATOR then
            break
        end

        value = string.sub(value, 1, -2)
    end

    return value

end

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Returns the preferred platform separator.
--
-- @return string
------------------------------------------------------------------------------
function Path.GetSeparator()

    if package.config ~= nil then
        return string.sub(package.config, 1, 1)
    end

    return WINDOWS_SEPARATOR

end

------------------------------------------------------------------------------
--- Normalizes all separators in a path.
--
-- @param value string
-- @param separator string|nil
-- @return string
------------------------------------------------------------------------------
function Path.Normalize(value, separator)

    Validation.Type(value, "value", "string")

    local selected = normalizeSeparator(separator or Path.GetSeparator())
    local normalized = string.gsub(value, "[/\\]", selected)

    return trimTrailingSeparator(normalized)

end

------------------------------------------------------------------------------
--- Joins path segments with one separator between each segment.
--
-- @param ...
-- @return string
------------------------------------------------------------------------------
function Path.Join(...)

    local segments = { ... }
    local separator = Path.GetSeparator()
    local parts = {}

    for _, segment in ipairs(segments) do
        if segment ~= nil and tostring(segment) ~= "" then
            local value = tostring(segment)
            value = string.gsub(value, "[/\\]+$", "")
            value = string.gsub(value, "^[/\\]+", "")

            if #parts == 0 then
                value = tostring(segment)
                value = string.gsub(value, "[/\\]+$", "")
            end

            table.insert(parts, value)
        end
    end

    return Path.Normalize(table.concat(parts, separator), separator)

end

------------------------------------------------------------------------------
--- Returns the final path segment.
--
-- @param value string
-- @return string
------------------------------------------------------------------------------
function Path.Basename(value)

    Validation.Type(value, "value", "string")

    local normalized = Path.Normalize(value)
    local name = string.match(normalized, "([^/\\]+)$")

    return name or normalized

end

------------------------------------------------------------------------------
--- Returns the directory portion of a path.
--
-- @param value string
-- @return string
------------------------------------------------------------------------------
function Path.Dirname(value)

    Validation.Type(value, "value", "string")

    local normalized = Path.Normalize(value)
    local directory = string.match(normalized, "^(.*)[/\\][^/\\]+$")

    return directory or "."

end

------------------------------------------------------------------------------
--- Combines a filename and extension.
--
-- @param stem string
-- @param extension string
-- @return string
------------------------------------------------------------------------------
function Path.WithExtension(stem, extension)

    Validation.NotEmpty(stem, "stem")
    Validation.NotEmpty(extension, "extension")

    if string.sub(extension, 1, 1) ~= "." then
        extension = "." .. extension
    end

    return stem .. extension

end

return Path
