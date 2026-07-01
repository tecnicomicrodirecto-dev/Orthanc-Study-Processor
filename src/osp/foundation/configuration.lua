------------------------------------------------------------------------------
-- OSP Configuration
--
-- Creates and normalizes the application configuration.
--
-- Configuration is created in three stages:
--
--   1. Build default values.
--   2. Merge user overrides.
--   3. Normalize derived values.
--
-- Derived values (workspace, archive, export, log...) are always rebuilt
-- from the effective RootDirectory unless explicitly overridden.
------------------------------------------------------------------------------

local Constants  = require("osp.foundation.constants")
local Path       = require("osp.foundation.path")
local Validation = require("osp.foundation.validation")

local Configuration = {}

------------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------------

local DEFAULT_ROOT_DIRECTORY = "OSP"

------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------

local function clone(source)

    local destination = {}

    for key, value in pairs(source) do

        if type(value) == "table" then
            destination[key] = clone(value)
        else
            destination[key] = value
        end

    end

    return destination

end

------------------------------------------------------------------------------

local function merge(destination, source)

    if source == nil then
        return destination
    end

    for key, value in pairs(source) do

        if type(value) == "table"
        and type(destination[key]) == "table" then

            merge(destination[key], value)

        else

            destination[key] = value

        end

    end

    return destination

end

------------------------------------------------------------------------------

local function buildDefaults()

    return {

        RootDirectory = DEFAULT_ROOT_DIRECTORY,

        WorkspaceDirectory = nil,
        ArchiveDirectory   = nil,
        ExportDirectory    = nil,
        LogDirectory       = nil,

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

local function normalize(configuration)

    local root = configuration.RootDirectory

    configuration.WorkspaceDirectory =
        configuration.WorkspaceDirectory
        or Path.Join(root, "workspace")

    configuration.ArchiveDirectory =
        configuration.ArchiveDirectory
        or Path.Join(root, "archive")

    configuration.ExportDirectory =
        configuration.ExportDirectory
        or Path.Join(root, "export")

    configuration.LogDirectory =
        configuration.LogDirectory
        or Path.Join(root, "logs")

end

------------------------------------------------------------------------------
-- Public API
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Creates a normalized configuration table.
--
-- @param overrides table|nil
-- @return table
------------------------------------------------------------------------------
function Configuration.Create(overrides)

    if overrides ~= nil then
        Validation.Type(overrides, "overrides", "table")
    end

    local configuration = clone(buildDefaults())

    merge(configuration, overrides)

    normalize(configuration)

    Validation.NotEmpty(configuration.RootDirectory, "RootDirectory")
    Validation.NotEmpty(configuration.WorkspaceDirectory, "WorkspaceDirectory")
    Validation.NotEmpty(configuration.ArchiveDirectory, "ArchiveDirectory")
    Validation.NotEmpty(configuration.ExportDirectory, "ExportDirectory")
    Validation.NotEmpty(configuration.LogDirectory, "LogDirectory")

    return configuration

end

------------------------------------------------------------------------------
--- Loads configuration from the optional global OSP_CONFIGURATION table.
--
-- @return table
------------------------------------------------------------------------------
function Configuration.Load()

    return Configuration.Create(rawget(_G, "OSP_CONFIGURATION"))

end

------------------------------------------------------------------------------
return Configuration
