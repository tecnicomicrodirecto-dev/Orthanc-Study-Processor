local Filesystem = require("OSP_Filesystem")
local Rest = require("OSP_Rest")

local Archive = {}

function Archive.exportStudy(studyId, workspace, config)
    local archiveRoot = config.archiveRoot
    Filesystem.ensureDirectory(archiveRoot)

    local archiveName = Filesystem.safeName(studyId) .. ".zip"
    local workspaceArchive = Filesystem.join(workspace.path, archiveName)
    local finalArchive = Filesystem.join(archiveRoot, archiveName)

    local content = Rest.get(Rest.studyPath(studyId, "/archive"))
    Filesystem.writeBinary(workspaceArchive, content)
    Filesystem.writeBinary(finalArchive, content)

    return finalArchive
end

return Archive
