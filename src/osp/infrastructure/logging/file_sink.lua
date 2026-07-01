------------------------------------------------------------------------------
-- OSP File Log Sink
--
-- Writes formatted log entries to a text file.
--
-- This sink owns all filesystem interaction required for persistent logging.
-- The logger and formatter remain completely independent from the filesystem.
------------------------------------------------------------------------------

local Validation = require("osp.foundation.validation")
local Sink = require("osp.infrastructure.logging.sink")

local FileSink = {}
FileSink.__index = FileSink

setmetatable(FileSink, {
    __index = Sink
})

------------------------------------------------------------------------------
--- Creates a file logging sink.
--
-- @param path string
--
-- @return table
------------------------------------------------------------------------------
function FileSink.Create(path)

    Validation.Type(path, "path", "string")
    Validation.NotEmpty(path, "path")

    local self = Sink.Create()

    self.Path = path

    return setmetatable(self, FileSink)

end

------------------------------------------------------------------------------
--- Writes a formatted log entry.
--
-- @param level string
-- @param message string
-- @param context table|nil
------------------------------------------------------------------------------
function FileSink:Write(level, message, context)

    Validation.Type(level, "level", "string")
    Validation.Type(message, "message", "string")

    local file, reason = io.open(self.Path, "a")

    if file == nil then

        error(
            string.format(
                "Unable to open log file '%s': %s",
                self.Path,
                tostring(reason)
            ),
            2
        )

    end

    file:write(message)
    file:write("\n")
    file:close()

end

------------------------------------------------------------------------------
return FileSink