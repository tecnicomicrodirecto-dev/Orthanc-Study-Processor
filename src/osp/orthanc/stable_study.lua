------------------------------------------------------------------------------
-- OSP Orthanc Stable Study
--
-- Stable-study callback entry point.
------------------------------------------------------------------------------

local Initialize = require("osp.orthanc.initialize")
local Logger = require("osp.infrastructure.logging.logger")
local Orchestrator = require("osp.application.orchestrator")
local Processing = require("osp.domain.processing")

local StableStudy = {}

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Processes an Orthanc stable-study callback.
--
-- @param studyId string
-- @param tags table|nil
-- @param metadata table|nil
-- @return table
------------------------------------------------------------------------------
function StableStudy.OnStableStudy(studyId, tags, metadata)

    local state = Initialize.Execute()
    local processing = Processing.Create(state.Configuration, studyId, tags, metadata)
    local result = Orchestrator.Execute(processing)

    if result:IsFailure() then
        Logger.Error(result:ToString())
    else
        Logger.Info("Completed processing for study " .. tostring(studyId) .. ".")
    end

    return result

end

return StableStudy
