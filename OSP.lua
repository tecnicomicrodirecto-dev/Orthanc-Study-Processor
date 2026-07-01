------------------------------------------------------------------------------
-- OSP - Orthanc Study Processor
--
-- Orthanc Lua entry script.
------------------------------------------------------------------------------

local function scriptDirectory()

    local source = debug.getinfo(1, "S").source or ""

    if string.sub(source, 1, 1) == "@" then
        source = string.sub(source, 2)
    end

    local directory = string.match(source, "^(.*)[/\\][^/\\]+$")

    return directory or "."

end

local sourceRoot = scriptDirectory() .. "/src"

if package ~= nil and package.path ~= nil then
    package.path =
        sourceRoot .. "/?.lua;" ..
        sourceRoot .. "/?/init.lua;" ..
        sourceRoot .. "\\?.lua;" ..
        sourceRoot .. "\\?\\init.lua;" ..
        package.path
end

local Initialize = require("osp.orthanc.initialize")
local StableStudy = require("osp.orthanc.stable_study")

------------------------------------------------------------------------------
--- Initializes OSP when the script is loaded by Orthanc.
------------------------------------------------------------------------------
function InitializeOSP()

    return Initialize.Execute()

end

------------------------------------------------------------------------------
--- Orthanc stable-study callback.
--
-- @param studyId string
-- @param tags table|nil
-- @param metadata table|nil
------------------------------------------------------------------------------
function OnStableStudy(studyId, tags, metadata)

    return StableStudy.OnStableStudy(studyId, tags, metadata)

end

InitializeOSP()
