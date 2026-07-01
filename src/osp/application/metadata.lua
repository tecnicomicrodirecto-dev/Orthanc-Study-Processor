------------------------------------------------------------------------------
-- OSP Metadata
--
-- Stores OSP workflow metadata on the source study.
------------------------------------------------------------------------------

local Constants = require("osp.foundation.constants")
local Result = require("osp.foundation.result")
local Studies = require("osp.infrastructure.orthanc.studies")

local Metadata = {}

------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------

local function set(processing, key, value)

    return Studies.SetMetadata(
        processing.Study:GetId(),
        key,
        tostring(value or "")
    )

end

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Executes metadata persistence.
--
-- @param processing table
-- @return table
------------------------------------------------------------------------------
function Metadata.Execute(processing)

    processing:SetState(Constants.Workflow.Metadata)

    local versionResult = set(
        processing,
        Constants.Metadata.WorkflowVersion,
        processing.Configuration.WorkflowVersion
    )

    if versionResult:IsFailure() then
        return versionResult
    end

    if processing.Configuration.Metadata.PreserveOriginalStudyUID then
        local uid = processing.Study:GetTag(Constants.Dicom.StudyInstanceUID)

        if uid ~= nil then
            local uidResult = set(
                processing,
                Constants.Metadata.OriginalStudyUID,
                uid
            )

            if uidResult:IsFailure() then
                return uidResult
            end
        end
    end

    return Result.Success()

end

return Metadata
