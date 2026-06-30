------------------------------------------------------------------------------
-- OSP - Orthanc Study Processor
--
-- Module:
--     osp.foundation.compatibility
--
-- Purpose:
--     Provides compatibility helpers for Lua and Orthanc.
--
-- Responsibilities:
--     - Detect runtime capabilities
--     - Wrap JSON encode/decode
--     - Detect Orthanc version (when available)
--     - Expose feature flags
--
-- This module contains no business logic.
--
------------------------------------------------------------------------------

local M = {}

------------------------------------------------------------------------------
-- Private State
------------------------------------------------------------------------------

local _runtime = {
    luaVersion = _VERSION or "Unknown",
    orthancVersion = "Unknown",
    initialized = false
}

local _features = {
    json = false,
    restApi = false,
    modifyInstance = false,
    deleteResource = false
}

------------------------------------------------------------------------------
-- Private Helpers
------------------------------------------------------------------------------

local function functionExists(name)

    return type(_G[name]) == "function"

end

------------------------------------------------------------------------------
-- Initialization
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Detects runtime capabilities.
--
-- Safe to call multiple times.
------------------------------------------------------------------------------

function M.Initialize()

    if _runtime.initialized then
        return
    end

    --------------------------------------------------------------------------
    -- Feature Detection
    --------------------------------------------------------------------------

    _features.json =
        functionExists("ParseJson") and
        functionExists("DumpJson")

    _features.restApi =
        functionExists("RestApiGet") and
        functionExists("RestApiPost") and
        functionExists("RestApiPut") and
        functionExists("RestApiDelete")

    _features.modifyInstance =
        functionExists("ModifyInstance")

    _features.deleteResource =
        functionExists("Delete")

    --------------------------------------------------------------------------
    -- Orthanc Version
    --------------------------------------------------------------------------

    if functionExists("GetOrthancVersion") then

        local ok, version = pcall(GetOrthancVersion)

        if ok and version then
            _runtime.orthancVersion = tostring(version)
        end

    end

    _runtime.initialized = true

end

------------------------------------------------------------------------------
--- Returns the Lua version.
--
-- @return string
------------------------------------------------------------------------------

function M.GetLuaVersion()

    return _runtime.luaVersion

end

------------------------------------------------------------------------------
--- Returns the Orthanc version.
--
-- @return string
------------------------------------------------------------------------------

function M.GetOrthancVersion()

    return _runtime.orthancVersion

end

------------------------------------------------------------------------------
--- Returns true if JSON support is available.
--
-- @return boolean
------------------------------------------------------------------------------

function M.HasJson()

    return _features.json

end

------------------------------------------------------------------------------
--- Returns true if REST API helpers are available.
--
-- @return boolean
------------------------------------------------------------------------------

function M.HasRestApi()

    return _features.restApi

end

------------------------------------------------------------------------------
--- Returns true if ModifyInstance() exists.
--
-- @return boolean
------------------------------------------------------------------------------

function M.HasModifyInstance()

    return _features.modifyInstance

end

------------------------------------------------------------------------------
--- Returns true if Delete() exists.
--
-- @return boolean
------------------------------------------------------------------------------

function M.HasDelete()

    return _features.deleteResource

end

------------------------------------------------------------------------------
-- Module
------------------------------------------------------------------------------

return M

------------------------------------------------------------------------------
-- JSON Compatibility
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Safely decodes a JSON document.
--
-- @param json string
--      JSON document.
--
-- @return table
--
-- @raise
--      Error if JSON support is unavailable or the document is invalid.
------------------------------------------------------------------------------
function M.DecodeJson(json)

    if not _runtime.initialized then
        M.Initialize()
    end

    if not _features.json then
        error("JSON support is unavailable.")
    end

    if type(json) ~= "string" then
        error("DecodeJson() expects a JSON string.")
    end

    local success, result =
        pcall(ParseJson, json)

    if not success then
        error(
            string.format(
                "Invalid JSON document: %s",
                tostring(result)
            )
        )
    end

    return result

end

------------------------------------------------------------------------------
--- Safely encodes a Lua table as JSON.
--
-- @param value table
--
-- @return string
------------------------------------------------------------------------------
function M.EncodeJson(value)

    if not _runtime.initialized then
        M.Initialize()
    end

    if not _features.json then
        error("JSON support is unavailable.")
    end

    local success, result =
        pcall(DumpJson, value)

    if not success then
        error(
            string.format(
                "Unable to encode JSON: %s",
                tostring(result)
            )
        )
    end

    return result

end

------------------------------------------------------------------------------
-- Runtime Information
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Returns an immutable snapshot of the detected runtime.
--
-- @return table
------------------------------------------------------------------------------
function M.GetRuntime()

    if not _runtime.initialized then
        M.Initialize()
    end

    return {

        LuaVersion = _runtime.luaVersion,

        OrthancVersion = _runtime.orthancVersion,

        Features = {

            Json = _features.json,

            RestApi = _features.restApi,

            ModifyInstance = _features.modifyInstance

        }

    }

end

------------------------------------------------------------------------------
--- Returns true when running inside Orthanc.
--
-- @return boolean
------------------------------------------------------------------------------
function M.IsOrthanc()

    if not _runtime.initialized then
        M.Initialize()
    end

    return _features.restApi

end

------------------------------------------------------------------------------
--- Returns true if the current Lua runtime is Lua 5.1.
--
-- OSP officially targets Lua 5.1.
--
-- @return boolean
------------------------------------------------------------------------------
function M.IsLua51()

    return _runtime.luaVersion == "Lua 5.1"

end

------------------------------------------------------------------------------
-- Diagnostics
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Returns a diagnostic report describing the current runtime.
--
-- @return table
------------------------------------------------------------------------------
function M.GetDiagnostics()

    if not _runtime.initialized then
        M.Initialize()
    end

    return {

        Compatible =
            _features.json and
            _features.restApi,

        Runtime = M.GetRuntime()

    }

end

------------------------------------------------------------------------------
--- Performs a runtime compatibility check.
--
-- @return boolean
--      True if the current runtime satisfies the minimum OSP requirements.
------------------------------------------------------------------------------
function M.Validate()

    if not _runtime.initialized then
        M.Initialize()
    end

    if not M.IsLua51() then
        return false
    end

    if not _features.json then
        return false
    end

    if not _features.restApi then
        return false
    end

    return true

end

------------------------------------------------------------------------------
--- Produces a formatted compatibility report.
--
-- @return string
------------------------------------------------------------------------------
function M.GetReport()

    local runtime = M.GetRuntime()

    local lines = {

        "OSP Compatibility Report",
        "------------------------",

        string.format(
            "Lua Version      : %s",
            runtime.LuaVersion
        ),

        string.format(
            "Orthanc Version  : %s",
            runtime.OrthancVersion
        ),

        "",

        string.format(
            "JSON             : %s",
            runtime.Features.Json and "OK" or "Unavailable"
        ),

        string.format(
            "REST API         : %s",
            runtime.Features.RestApi and "OK" or "Unavailable"
        ),

        string.format(
            "ModifyInstance   : %s",
            runtime.Features.ModifyInstance and
            "Available" or
            "Unavailable"
        ),

        "",

        string.format(
            "Status           : %s",
            M.Validate() and
            "Compatible" or
            "Unsupported"
        )

    }

    return table.concat(lines, "\n")

end
	