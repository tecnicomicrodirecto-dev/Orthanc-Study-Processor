------------------------------------------------------------------------------
-- OSP Revision
--
-- Tracks workflow state transitions for diagnostics.
------------------------------------------------------------------------------

local Validation = require("osp.foundation.validation")

local Revision = {}

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Creates a revision event.
--
-- @param state string
-- @param message string|nil
-- @return table
------------------------------------------------------------------------------
function Revision.Create(state, message)

    Validation.NotEmpty(state, "state")

    return {
        State = state,
        Message = message,
        Time = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }

end

return Revision
