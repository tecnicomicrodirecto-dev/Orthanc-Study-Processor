------------------------------------------------------------------------------
-- OSP PACS Workflow
--
-- Optional forwarding step.
------------------------------------------------------------------------------

local PacsAdapter = require("osp.infrastructure.orthanc.pacs")
local Result = require("osp.foundation.result")

local Pacs = {}

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Executes optional PACS forwarding.
--
-- @param processing table
-- @return table
------------------------------------------------------------------------------
function Pacs.Execute(processing)

    if not processing.Configuration.Pacs.Enabled then
        return Result.Success()
    end

    return PacsAdapter.SendIfEnabled(
        processing.Configuration,
        processing.Study:GetId()
    )

end

return Pacs
