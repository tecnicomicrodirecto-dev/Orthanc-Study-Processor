------------------------------------------------------------------------------
-- OSP Cleanup
--
-- Performs deterministic cleanup after processing.
------------------------------------------------------------------------------

local Constants = require("osp.foundation.constants")
local Filesystem = require("osp.infrastructure.filesystem.filesystem")
local Result = require("osp.foundation.result")
local Studies = require("osp.infrastructure.orthanc.studies")

local Cleanup = {}

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Executes cleanup.
--
-- @param processing table
-- @return table
------------------------------------------------------------------------------
function Cleanup.Execute(processing)

    processing:SetState(Constants.Workflow.Cleaning)

    if processing.Configuration.DeleteSourceStudy then
        local deleteResult = Studies.Delete(processing.Study:GetId())

        if deleteResult:IsFailure() then
            return deleteResult
        end
    end

    local cleanupResult = Filesystem.Remove(processing.Workspace.Paths.Root)

    if cleanupResult:IsFailure() then
        return cleanupResult
    end

    return Result.Success()

end

return Cleanup
