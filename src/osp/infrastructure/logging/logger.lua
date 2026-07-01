------------------------------------------------------------------------------
-- OSP Logger
--
-- Orthanc-aware logging adapter.
------------------------------------------------------------------------------

local Constants = require("osp.foundation.constants")

local Logger = {}

------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------

local function emit(level, message)

    local line = string.format(
        "[%s] %s",
        Constants.Application.ShortName,
        tostring(message)
    )

    if level == Constants.Logging.Error and type(PrintError) == "function" then
        PrintError(line)
    elseif level == Constants.Logging.Warning and type(PrintWarning) == "function" then
        PrintWarning(line)
    elseif type(PrintInfo) == "function" then
        PrintInfo(line)
    else
        print(line)
    end

end

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Logs a debug message.
--
-- @param message string
------------------------------------------------------------------------------
function Logger.Debug(message)

    emit(Constants.Logging.Debug, message)

end

------------------------------------------------------------------------------
--- Logs an informational message.
--
-- @param message string
------------------------------------------------------------------------------
function Logger.Info(message)

    emit(Constants.Logging.Info, message)

end

------------------------------------------------------------------------------
--- Logs a warning.
--
-- @param message string
------------------------------------------------------------------------------
function Logger.Warning(message)

    emit(Constants.Logging.Warning, message)

end

------------------------------------------------------------------------------
--- Logs an error.
--
-- @param message string
------------------------------------------------------------------------------
function Logger.Error(message)

    emit(Constants.Logging.Error, message)

end

return Logger
