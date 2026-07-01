------------------------------------------------------------------------------
-- OSP Compatibility
--
-- Runtime capability detection and JSON wrappers.
------------------------------------------------------------------------------

local Validation = require("osp.foundation.validation")

local Compatibility = {}

------------------------------------------------------------------------------
-- Private State
------------------------------------------------------------------------------

local runtime = {
    LuaVersion = _VERSION or "Unknown",
    OrthancVersion = "Unknown",
    Initialized = false
}

local features = {
    Json = false,
    RestApi = false,
    ModifyInstance = false,
    DeleteResource = false
}

------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------

local function functionExists(name)

    return type(_G[name]) == "function"

end

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Detects runtime capabilities.
------------------------------------------------------------------------------
function Compatibility.Initialize()

    if runtime.Initialized then
        return
    end

    features.Json =
        functionExists("ParseJson") and
        functionExists("DumpJson")

    features.RestApi =
        functionExists("RestApiGet") and
        functionExists("RestApiPost") and
        functionExists("RestApiPut") and
        functionExists("RestApiDelete")

    features.ModifyInstance = functionExists("ModifyInstance")
    features.DeleteResource = functionExists("Delete")

    if functionExists("GetOrthancVersion") then
        local ok, version = pcall(GetOrthancVersion)

        if ok and version ~= nil then
            runtime.OrthancVersion = tostring(version)
        end
    end

    runtime.Initialized = true

end

------------------------------------------------------------------------------
--- Decodes JSON using Orthanc's JSON helper.
--
-- @param json string
-- @return table
------------------------------------------------------------------------------
function Compatibility.DecodeJson(json)

    Compatibility.Initialize()
    Validation.Type(json, "json", "string")

    if not features.Json then
        error("JSON support is unavailable.")
    end

    local ok, value = pcall(ParseJson, json)

    if not ok then
        error("Invalid JSON document: " .. tostring(value))
    end

    return value

end

------------------------------------------------------------------------------
--- Encodes a Lua value using Orthanc's JSON helper.
--
-- @param value any
-- @return string
------------------------------------------------------------------------------
function Compatibility.EncodeJson(value)

    Compatibility.Initialize()

    if not features.Json then
        error("JSON support is unavailable.")
    end

    local ok, json = pcall(DumpJson, value)

    if not ok then
        error("Unable to encode JSON: " .. tostring(json))
    end

    return json

end

------------------------------------------------------------------------------
--- Returns an immutable runtime snapshot.
--
-- @return table
------------------------------------------------------------------------------
function Compatibility.GetRuntime()

    Compatibility.Initialize()

    return {
        LuaVersion = runtime.LuaVersion,
        OrthancVersion = runtime.OrthancVersion,
        Features = {
            Json = features.Json,
            RestApi = features.RestApi,
            ModifyInstance = features.ModifyInstance,
            DeleteResource = features.DeleteResource
        }
    }

end

------------------------------------------------------------------------------
--- Returns true when running inside Orthanc.
--
-- @return boolean
------------------------------------------------------------------------------
function Compatibility.IsOrthanc()

    Compatibility.Initialize()

    return features.RestApi

end

------------------------------------------------------------------------------
--- Returns true when the runtime reports Lua 5.1.
--
-- @return boolean
------------------------------------------------------------------------------
function Compatibility.IsLua51()

    return runtime.LuaVersion == "Lua 5.1"

end

------------------------------------------------------------------------------
--- Returns true when the current runtime satisfies OSP requirements.
--
-- @return boolean
------------------------------------------------------------------------------
function Compatibility.Validate()

    Compatibility.Initialize()

    return Compatibility.IsLua51() and features.Json and features.RestApi

end

------------------------------------------------------------------------------
--- Returns a diagnostic report.
--
-- @return table
------------------------------------------------------------------------------
function Compatibility.GetDiagnostics()

    return {
        Compatible = Compatibility.Validate(),
        Runtime = Compatibility.GetRuntime()
    }

end

------------------------------------------------------------------------------
--- Produces a formatted compatibility report.
--
-- @return string
------------------------------------------------------------------------------
function Compatibility.GetReport()

    local detected = Compatibility.GetRuntime()

    return table.concat({
        "OSP Compatibility Report",
        "------------------------",
        "Lua Version      : " .. detected.LuaVersion,
        "Orthanc Version  : " .. detected.OrthancVersion,
        "",
        "JSON             : " .. (detected.Features.Json and "OK" or "Unavailable"),
        "REST API         : " .. (detected.Features.RestApi and "OK" or "Unavailable"),
        "ModifyInstance   : " .. (detected.Features.ModifyInstance and "Available" or "Unavailable"),
        "Delete           : " .. (detected.Features.DeleteResource and "Available" or "Unavailable"),
        "",
        "Status           : " .. (Compatibility.Validate() and "Compatible" or "Unsupported")
    }, "\n")

end

return Compatibility
