local Config = require("OSP_Config")
local Log = require("OSP_Log")
local Processor = require("OSP_Processor")

local configPath = OSP_CONFIG_PATH
if (configPath == nil or configPath == "") and os.getenv ~= nil then
    configPath = os.getenv("OSP_CONFIG_PATH")
end

local config = Config.load(configPath)

Log.setLevel(config.logLevel)
Log.info("Orthanc Study Processor loaded")

function OnStableStudy(studyId, tags, metadata, origin)
    local ok, result = pcall(function()
        return Processor.run(studyId, config)
    end)

    if not ok then
        Log.error("Stable study failed: " .. tostring(result))
        return
    end

    if result.archivePath ~= nil then
        Log.info("Archived processed study to " .. result.archivePath)
    end
end
