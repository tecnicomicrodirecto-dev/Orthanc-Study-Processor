------------------------------------------------------------------------------
-- OSP Orchestrator
--
-- Coordinates the application workflow.
------------------------------------------------------------------------------

local Archive = require("osp.application.archive")
local Cleanup = require("osp.application.cleanup")
local Compatibility = require("osp.foundation.compatibility")
local Constants = require("osp.foundation.constants")
local Exporter = require("osp.application.exporter")
local Filesystem = require("osp.infrastructure.filesystem.filesystem")
local Formatter = require("osp.application.formatter")
local Manifest = require("osp.domain.manifest")
local Metadata = require("osp.application.metadata")
local Pacs = require("osp.application.pacs")
local Path = require("osp.foundation.path")
local Result = require("osp.foundation.result")
local Studies = require("osp.infrastructure.orthanc.studies")
local Zip = require("osp.infrastructure.zip.zip")

local Orchestrator = {}

------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------

local function writeManifest(processing)

    local ok, json = pcall(Compatibility.EncodeJson, Manifest.Create(processing))

    if not ok then
        return Result.Failure("MANIFEST_ENCODE_FAILED", tostring(json))
    end

    return Filesystem.WriteFile(
        Path.Join(processing.Workspace.Paths.Root, "manifest.json"),
        json,
        false
    )

end

local function runStep(processing, step)

    local result = step.Execute(processing)

    if result:IsFailure() then
        processing:Fail(result)
        writeManifest(processing)
        return result
    end

    local manifestResult = writeManifest(processing)

    if manifestResult:IsFailure() then
        processing:Fail(manifestResult)
        return manifestResult
    end

    return result

end

local function reimportIfConfigured(processing)

    if not processing.Configuration.ReimportProcessedStudy then
        return Result.Success()
    end

    processing:SetState(Constants.Workflow.Reimporting)

    local readResult = Zip.Read(processing.ExportPath)

    if readResult:IsFailure() then
        return readResult
    end

    return Studies.ImportArchive(readResult:GetData())

end

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Executes the full OSP processing workflow.
--
-- @param processing table
-- @return table
------------------------------------------------------------------------------
function Orchestrator.Execute(processing)

    processing:SetState(Constants.Workflow.Loading)

    local workspaceResult = Filesystem.CreateDirectories(
        processing.Workspace:GetDirectories()
    )

    if workspaceResult:IsFailure() then
        processing:Fail(workspaceResult)
        return workspaceResult
    end

    local manifestResult = writeManifest(processing)

    if manifestResult:IsFailure() then
        processing:Fail(manifestResult)
        return manifestResult
    end

    local steps = {
        Formatter,
        Metadata,
        Exporter,
        Archive,
        Pacs
    }

    for _, step in ipairs(steps) do
        local result = runStep(processing, step)

        if result:IsFailure() then
            return result
        end
    end

    local reimportResult = reimportIfConfigured(processing)

    if reimportResult:IsFailure() then
        processing:Fail(reimportResult)
        writeManifest(processing)
        return reimportResult
    end

    processing:SetState(Constants.Workflow.Completed)
    writeManifest(processing)

    return Cleanup.Execute(processing)

end

return Orchestrator
