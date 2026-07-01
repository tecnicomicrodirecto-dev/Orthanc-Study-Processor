------------------------------------------------------------------------------
-- OSP Manifest
--
-- Domain manifest for a processing run.
------------------------------------------------------------------------------

local Constants = require("osp.foundation.constants")
local Validation = require("osp.foundation.validation")

local Manifest = {}

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Creates a new manifest table.
--
-- @param processing table
-- @return table
------------------------------------------------------------------------------
function Manifest.Create(processing)

    Validation.NotNil(processing, "processing")

    return {
        Application = Constants.Application.ShortName,
        Version = Constants.Application.Version,
        ProcessingId = processing.Id,
        StudyId = processing.Study:GetId(),
        State = processing.State,
        CreatedAt = processing.CreatedAt,
        UpdatedAt = processing.UpdatedAt,
        OriginalStudyUID = processing.Study:GetTag(Constants.Dicom.StudyInstanceUID),
        ArchivePath = processing.ArchivePath,
        ExportPath = processing.ExportPath,
        Failure = processing.Failure
    }

end

return Manifest
