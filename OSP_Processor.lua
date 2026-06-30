local Archive = require("OSP_Archive")
local Dicom = require("OSP_Dicom")
local Log = require("OSP_Log")
local Workspace = require("OSP_Workspace")

local Processor = {}

local function processStudy(studyId, config)
    local workspace = Workspace.create(config.workspaceRoot, studyId)
    local processedStudyId = studyId
    local ok = false
    local archivePath = nil

    Log.info("Processing stable study " .. tostring(studyId))

    local status, result = pcall(function()
        Dicom.getStudy(studyId)

        processedStudyId = Dicom.modifyStudy(studyId, config)

        if config.archiveProcessedStudy then
            archivePath = Archive.exportStudy(processedStudyId, workspace, config)
        end

        if config.deleteProcessedStudy and processedStudyId ~= studyId then
            Dicom.deleteStudy(processedStudyId)
        end

        return true
    end)

    ok = status and result == true

    if not config.keepWorkspace then
        Workspace.remove(workspace)
    end

    if not ok then
        error(result)
    end

    Log.info("Finished stable study " .. tostring(studyId))

    return {
        studyId = studyId,
        processedStudyId = processedStudyId,
        archivePath = archivePath
    }
end

function Processor.run(studyId, config)
    return processStudy(studyId, config)
end

return Processor
