------------------------------------------------------------------------------
-- OSP Logging Sink
--
-- Defines the contract implemented by every logging sink.
--
-- A sink is responsible for delivering an already formatted log message to a
-- destination (Orthanc log, file, console, etc.).
--
-- Sinks do not perform formatting or severity filtering. Those concerns belong
-- to the logger and formatter respectively.
------------------------------------------------------------------------------

local Validation = require("osp.foundation.validation")

local Sink = {}
Sink.__index = Sink

------------------------------------------------------------------------------
--- Creates a new sink instance.
--
-- Concrete sinks should call this constructor and override Write().
--
-- @return table
------------------------------------------------------------------------------
function Sink.Create()

    return setmetatable({}, Sink)

end

------------------------------------------------------------------------------
--- Writes a formatted log entry.
--
-- This method must be overridden by concrete sinks.
--
-- @param level string
-- @param message string
-- @param context table|nil
------------------------------------------------------------------------------
function Sink:Write(level, message, context)

    Validation.Type(level, "level", "string")
    Validation.Type(message, "message", "string")

    error(
        "Logging sink does not implement Write().",
        2
    )

end

------------------------------------------------------------------------------
return Sink