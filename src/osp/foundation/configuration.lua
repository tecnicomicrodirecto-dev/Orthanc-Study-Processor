------------------------------------------------------------------------------
-- OSP Configuration
--
-- Normalizes OSP runtime configuration.
------------------------------------------------------------------------------

local Constants = require("osp.foundation.constants")
local Path = require("osp.foundation.path")
local Validation = require("osp.foundation.validation")

local Configuration = {}

------------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------------

local DEFAULT_ROOT = "C:\\Orthanc\\OSP"

------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------

local function merge(defaults, overrides)

    local output = {}

    for key, value in pairs(defaults) do
        if type(value) == "table" then
            output[key] = merge(value, {})
        else
            output[key] = value
        end
    end

    if overrides ~= nil then
        for key, value in pairs(overrides) do
            if type(value) == "table" and type(output[key]) == "table" then
                output[key] = merge(output[key], value)
            else
                output[key] = value
            end
        end
    end

    return output

end

local function defaults()

    return {
        RootDirectory = DEFAULT_ROOT,
        WorkspaceDirectory = Path.Join(DEFAULT_ROOT, "workspace"),
        ArchiveDirectory = Path.Join(DEFAULT_ROOT, "archive"),
        ExportDirectory = Path.Join(DEFAULT_ROOT, "export"),
        LogDirectory = Path.Join(DEFAULT_ROOT, "logs"),
        WorkflowVersion = Constants.Application.Version,
        DeleteSourceStudy = false,
        ReimportProcessedStudy = false,
        Formatting = {
            Enabled = false,
            Script = nil
        },
        Metadata = {
            PreserveOriginalStudyUID = true
        },
        Pacs = {
            Enabled = false,
            Peer = nil
        }
    }

end

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Creates normalized configuration.
--
-- @param overrides table|nil
-- @return table
------------------------------------------------------------------------------
function Configuration.Create(overrides)

    if overrides ~= nil then
        Validation.Type(overrides, "overrides", "table")
    end

    local config = merge(defaults(), overrides or {})

    Validation.NotEmpty(config.RootDirectory, "RootDirectory")
    Validation.NotEmpty(config.WorkspaceDirectory, "WorkspaceDirectory")
    Validation.NotEmpty(config.ArchiveDirectory, "ArchiveDirectory")
    Validation.NotEmpty(config.ExportDirectory, "ExportDirectory")
    Validation.NotEmpty(config.LogDirectory, "LogDirectory")

    return config

end

------------------------------------------------------------------------------
--- Loads configuration from the optional global OSP_CONFIGURATION table.
--
-- @return table
------------------------------------------------------------------------------
function Configuration.Load()

    local overrides = rawget(_G, "OSP_CONFIGURATION")

    return Configuration.Create(overrides)

end

return Configuration
