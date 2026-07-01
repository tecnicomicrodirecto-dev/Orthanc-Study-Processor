------------------------------------------------------------------------------
-- OSP Archive Store
--
-- Adapter for persistent archive storage.
------------------------------------------------------------------------------

local Filesystem = require("osp.infrastructure.filesystem.filesystem")
local Path = require("osp.foundation.path")
local Result = require("osp.foundation.result")
local Validation = require("osp.foundation.validation")

local Store = {}

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Copies an exported archive into long-term archive storage.
--
-- @param sourcePath string
-- @param archiveDirectory string
-- @param filename string
-- @return table
------------------------------------------------------------------------------
function Store.Save(sourcePath, archiveDirectory, filename)

    Validation.NotEmpty(sourcePath, "sourcePath")
    Validation.NotEmpty(archiveDirectory, "archiveDirectory")
    Validation.NotEmpty(filename, "filename")

    local directoryResult = Filesystem.CreateDirectory(archiveDirectory)

    if directoryResult:IsFailure() then
        return directoryResult
    end

    local targetPath = Path.Join(archiveDirectory, filename)
    local copyResult = Filesystem.CopyFile(sourcePath, targetPath)

    if copyResult:IsFailure() then
        return copyResult
    end

    return Result.Success(targetPath)

end

return Store
