------------------------------------------------------------------------------
-- OSP Formatter
--
-- Applies optional presentation formatting.
------------------------------------------------------------------------------

local Constants = require("osp.foundation.constants")
local Result = require("osp.foundation.result")

local Formatter = {}

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Executes the formatting step.
--
-- @param processing table
-- @return table
------------------------------------------------------------------------------
function Formatter.Execute(processing)

    processing:SetState(Constants.Workflow.Formatting)

    local configuration = processing.Configuration.Formatting

    if not configuration.Enabled then
        return Result.Success()
    end

    local formatter = rawget(_G, configuration.Script or "OSP_FORMATTER")

    if type(formatter) ~= "function" then
        return Result.Failure(
            "FORMATTER_UNAVAILABLE",
            "Formatting is enabled but no formatter function is available."
        )
    end

    local ok, message = pcall(formatter, processing)

    if not ok then
        return Result.Failure("FORMATTER_FAILED", tostring(message))
    end

    return Result.Success()

end

return Formatter
