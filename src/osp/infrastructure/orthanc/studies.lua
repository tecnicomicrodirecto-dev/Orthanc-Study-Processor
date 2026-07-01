------------------------------------------------------------------------------
-- OSP Orthanc Studies
--
-- Study-specific Orthanc adapter.
------------------------------------------------------------------------------

local Client = require("osp.infrastructure.orthanc.client")
local Constants = require("osp.foundation.constants")
local Result = require("osp.foundation.result")
local Validation = require("osp.foundation.validation")

local Studies = {}

------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------

local function studyPath(studyId, suffix)

    local path = Constants.Rest.Studies .. "/" .. studyId

    if suffix ~= nil then
        path = path .. suffix
    end

    return path

end

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Downloads the Orthanc ZIP archive for a study.
--
-- @param studyId string
-- @return table
------------------------------------------------------------------------------
function Studies.DownloadArchive(studyId)

    Validation.NotEmpty(studyId, "studyId")

    return Client.Get(studyPath(studyId, "/archive"))

end

------------------------------------------------------------------------------
--- Stores study metadata.
--
-- @param studyId string
-- @param key string|number
-- @param value string
-- @return table
------------------------------------------------------------------------------
function Studies.SetMetadata(studyId, key, value)

    Validation.NotEmpty(studyId, "studyId")
    Validation.NotNil(key, "key")
    Validation.NotNil(value, "value")

    return Client.Put(
        studyPath(studyId, "/metadata/" .. tostring(key)),
        tostring(value)
    )

end

------------------------------------------------------------------------------
--- Deletes a study.
--
-- @param studyId string
-- @return table
------------------------------------------------------------------------------
function Studies.Delete(studyId)

    Validation.NotEmpty(studyId, "studyId")

    return Client.DeleteResource(studyId)

end

------------------------------------------------------------------------------
--- Reimports a DICOM ZIP archive into Orthanc.
--
-- @param archiveContent string
-- @return table
------------------------------------------------------------------------------
function Studies.ImportArchive(archiveContent)

    Validation.Type(archiveContent, "archiveContent", "string")

    local result = Client.Post("/instances", archiveContent)

    if result:IsFailure() then
        return result
    end

    return Result.Success(result:GetData())

end

return Studies
