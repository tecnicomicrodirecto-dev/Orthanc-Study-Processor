------------------------------------------------------------------------------
-- OSP Orthanc Log Sink
--
-- Writes formatted log entries to the Orthanc server log.
--
-- This sink is the only logging component that depends directly on the
-- Orthanc Lua API. The remainder of the logging subsystem is intentionally
-- Orthanc-agnostic.
------------------------------------------------------------------------------

local Validation = require("osp.foundation.validation")
local Sink = require("osp.infrastructure.logging.sink")

local OrthancSink = {}
OrthancSink.__index = OrthancSink

setmetatable(OrthancSink, {
    __index = Sink
})

------------------------------------------------------------------------------
--- Creates a new Orthanc logging sink.
--
-- @return table
------------------------------------------------------------------------------
function OrthancSink.Create()

    return setmetatable(Sink.Create(), OrthancSink)

end

------------------------------------------------------------------------------
--- Writes a formatted log entry to the Orthanc log.
--
-- @param level string
-- @param message string
-- @param context table|nil
------------------------------------------------------------------------------
function OrthancSink:Write(level, message, context)

    Validation.Type(level, "level", "string")
    Validation.Type(message, "message", "string")

    if level == "ERROR" then

        Orthanc.LogError(message)

    elseif level == "WARNING" then

        Orthanc.LogWarning(message)

    else

        Orthanc.LogInfo(message)

    end

end

------------------------------------------------------------------------------
return OrthancSink