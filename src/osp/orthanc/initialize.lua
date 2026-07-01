------------------------------------------------------------------------------
-- OSP Orthanc Initialize
--
-- Orthanc startup entry point.
------------------------------------------------------------------------------

local Compatibility = require("osp.foundation.compatibility")
local Configuration = require("osp.foundation.configuration")
local Logger = require("osp.infrastructure.logging.logger")

local Initialize = {}

------------------------------------------------------------------------------
-- Private State
------------------------------------------------------------------------------

local state = {
    Initialized = false,
    Configuration = nil
}

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Initializes OSP and returns runtime state.
--
-- @return table
------------------------------------------------------------------------------
function Initialize.Execute()

    if state.Initialized then
        return state
    end

    Compatibility.Initialize()

    state.Configuration = Configuration.Load()
    state.Initialized = true

    Logger.Info("Initialized Orthanc Study Processor.")

    return state

end

------------------------------------------------------------------------------
--- Returns the current initialization state.
--
-- @return table
------------------------------------------------------------------------------
function Initialize.GetState()

    return state

end

return Initialize
