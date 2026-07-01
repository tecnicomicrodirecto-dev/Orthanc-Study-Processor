------------------------------------------------------------------------------
-- OSP Archive
--
-- Persists exported ZIP archives.
------------------------------------------------------------------------------

local ArchiveStore = require("osp.infrastructure.archive.store")
local Constants = require("osp.foundation.constants")
local Path = require("osp.foundation.path")
local Result = require("osp.foundation.result")

local Archive = {}

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Executes archive persistence.
--
-- @param processing table
-- @return table
------------------------------------------------------------------------------
function Archive.Execute(processing)

    processing:SetState(Constants.Workflow.Archiving)

    if processing.ExportPath == nil then
        return Result.Failure(
            "EXPORT_PATH_MISSING",
            "Cannot archive before export has produced a ZIP path."
        )
    end

    local filename = Path.Basename(processing.ExportPath)
    local result = ArchiveStore.Save(
        processing.ExportPath,
        processing.Configuration.ArchiveDirectory,
        filename
    )

    if result:IsFailure() then
        return result
    end

    processing.ArchivePath = result:GetData()

    return result

end

return Archive
