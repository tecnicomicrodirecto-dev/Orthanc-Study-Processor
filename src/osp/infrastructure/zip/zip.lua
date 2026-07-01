------------------------------------------------------------------------------
-- OSP ZIP
--
-- ZIP file adapter for binary archive persistence.
------------------------------------------------------------------------------

local Filesystem = require("osp.infrastructure.filesystem.filesystem")
local Result = require("osp.foundation.result")
local Validation = require("osp.foundation.validation")

local Zip = {}

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Writes ZIP binary content to disk.
--
-- @param path string
-- @param content string
-- @return table
------------------------------------------------------------------------------
function Zip.Write(path, content)

    Validation.NotEmpty(path, "path")
    Validation.Type(content, "content", "string")

    local result = Filesystem.WriteFile(path, content, true)

    if result:IsFailure() then
        return result
    end

    return Result.Success(path)

end

------------------------------------------------------------------------------
--- Reads ZIP binary content from disk.
--
-- @param path string
-- @return table
------------------------------------------------------------------------------
function Zip.Read(path)

    Validation.NotEmpty(path, "path")

    return Filesystem.ReadFile(path, true)

end

return Zip
