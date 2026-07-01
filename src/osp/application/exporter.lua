------------------------------------------------------------------------------
-- OSP Exporter
--
-- Exports the source study as a ZIP archive.
------------------------------------------------------------------------------

local Constants = require("osp.foundation.constants")
local Filesystem = require("osp.infrastructure.filesystem.filesystem")
local Path = require("osp.foundation.path")
local Studies = require("osp.infrastructure.orthanc.studies")
local Zip = require("osp.infrastructure.zip.zip")

local Exporter = {}

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Executes study export.
--
-- @param processing table
-- @return table
------------------------------------------------------------------------------
function Exporter.Execute(processing)

    processing:SetState(Constants.Workflow.Exporting)

    local directoryResult = Filesystem.CreateDirectory(processing.Workspace.Paths.Export)

    if directoryResult:IsFailure() then
        return directoryResult
    end

    local archiveResult = Studies.DownloadArchive(processing.Study:GetId())

    if archiveResult:IsFailure() then
        return archiveResult
    end

    local filename = Path.WithExtension(
        processing.Id,
        Constants.Export.ZipExtension
    )
    local exportPath = Path.Join(processing.Workspace.Paths.Export, filename)
    local writeResult = Zip.Write(exportPath, archiveResult:GetData())

    if writeResult:IsFailure() then
        return writeResult
    end

    processing.ExportPath = exportPath

    return writeResult

end

return Exporter
