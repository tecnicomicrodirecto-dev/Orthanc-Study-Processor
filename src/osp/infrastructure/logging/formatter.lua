------------------------------------------------------------------------------
-- OSP Log Formatter
--
-- Produces a canonical textual representation of log entries.
--
-- The formatter is intentionally stateless. It performs no I/O and has no
-- knowledge of where log messages are written. That responsibility belongs to
-- logging sinks.
------------------------------------------------------------------------------

local Validation = require("osp.foundation.validation")

local Formatter = {}

------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------

local function formatContext(context)

    if context == nil then
        return ""
    end

    Validation.Type(context, "context", "table")

    local parts = {}

    for key, value in pairs(context) do

        table.insert(
            parts,
            string.format("%s=%s", tostring(key), tostring(value))
        )

    end

    table.sort(parts)

    return table.concat(parts, ", ")

end

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Formats a log entry.
--
-- @param level string
-- @param message string
-- @param context table|nil
--
-- @return string
------------------------------------------------------------------------------
function Formatter.Format(level, message, context)

    Validation.Type(level, "level", "string")
    Validation.Type(message, "message", "string")

    local timestamp = os.date("%Y-%m-%d %H:%M:%S")

    local line = string.format(
        "[%s] %-7s %s",
        timestamp,
        level,
        message
    )

    local formattedContext = formatContext(context)

    if formattedContext ~= "" then
        line = string.format(
            "%s (%s)",
            line,
            formattedContext
        )
    end

    return line

end

------------------------------------------------------------------------------
return Formatter