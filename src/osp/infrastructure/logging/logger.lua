------------------------------------------------------------------------------
-- OSP Logger
--
-- Logging façade.
--
-- The logger is intentionally small. Its responsibilities are limited to:
--
--   • Validating log requests.
--   • Delegating formatting.
--   • Dispatching the formatted message to one or more sinks.
--
-- The logger never writes directly to Orthanc, the console or the filesystem.
-- Those responsibilities belong to logging sinks.
------------------------------------------------------------------------------

local Validation = require("osp.foundation.validation")

local Logger = {}

------------------------------------------------------------------------------
-- Private State
------------------------------------------------------------------------------

local formatter = nil
local sinks = {}

------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------

local function dispatch(level, message, context)

    Validation.NotNil(formatter, "formatter")

    local line = formatter.Format(level, message, context)

    for _, sink in ipairs(sinks) do
        sink.Write(level, line, context)
    end

end

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Sets the formatter used by the logger.
--
-- @param instance table
------------------------------------------------------------------------------
function Logger.SetFormatter(instance)

    Validation.NotNil(instance, "instance")
    Validation.Type(instance, "instance", "table")

    Validation.NotNil(instance.Format, "instance.Format")
    Validation.Type(instance.Format, "instance.Format", "function")

    formatter = instance

end

------------------------------------------------------------------------------
--- Registers a logging sink.
--
-- Sinks are invoked in registration order.
--
-- @param sink table
------------------------------------------------------------------------------
function Logger.AddSink(sink)

    Validation.NotNil(sink, "sink")
    Validation.Type(sink, "sink", "table")

    Validation.NotNil(sink.Write, "sink.Write")
    Validation.Type(sink.Write, "sink.Write", "function")

    table.insert(sinks, sink)

end

------------------------------------------------------------------------------
--- Removes all registered sinks.
------------------------------------------------------------------------------
function Logger.ClearSinks()

    sinks = {}

end

------------------------------------------------------------------------------
--- Logs a debug message.
--
-- @param message string
-- @param context table|nil
------------------------------------------------------------------------------
function Logger.Debug(message, context)

    Validation.Type(message, "message", "string")

    dispatch("DEBUG", message, context)

end

------------------------------------------------------------------------------
--- Logs an informational message.
--
-- @param message string
-- @param context table|nil
------------------------------------------------------------------------------
function Logger.Info(message, context)

    Validation.Type(message, "message", "string")

    dispatch("INFO", message, context)

end

------------------------------------------------------------------------------
--- Logs a warning.
--
-- @param message string
-- @param context table|nil
------------------------------------------------------------------------------
function Logger.Warning(message, context)

    Validation.Type(message, "message", "string")

    dispatch("WARNING", message, context)

end

------------------------------------------------------------------------------
--- Logs an error.
--
-- @param message string
-- @param context table|nil
------------------------------------------------------------------------------
function Logger.Error(message, context)

    Validation.Type(message, "message", "string")

    dispatch("ERROR", message, context)

end

------------------------------------------------------------------------------
return Logger
