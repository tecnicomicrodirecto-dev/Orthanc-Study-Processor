local Filesystem = require("OSP_Filesystem")

local Workspace = {}

local function timestamp()
    return os.date("!%Y%m%dT%H%M%SZ")
end

function Workspace.create(root, studyId)
    Filesystem.ensureDirectory(root)

    local name = timestamp() .. "_" .. Filesystem.safeName(studyId)
    local path = Filesystem.join(root, name)
    Filesystem.ensureDirectory(path)

    return {
        root = root,
        path = path,
        studyId = studyId,
        createdAt = timestamp()
    }
end

function Workspace.file(workspace, name)
    return Filesystem.join(workspace.path, name)
end

function Workspace.remove(workspace)
    if workspace ~= nil and workspace.path ~= nil then
        Filesystem.rmdir(workspace.path)
    end
end

return Workspace
