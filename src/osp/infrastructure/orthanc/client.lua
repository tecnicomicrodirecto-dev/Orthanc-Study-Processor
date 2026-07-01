------------------------------------------------------------------------------
-- OSP Orthanc Client
--
-- Adapter around Orthanc Lua REST helpers.
------------------------------------------------------------------------------

local Compatibility = require("osp.foundation.compatibility")
local Result = require("osp.foundation.result")
local Validation = require("osp.foundation.validation")

local Client = {}

------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------

local function call(name, ...)

    local fn = rawget(_G, name)

    if type(fn) ~= "function" then
        return Result.Failure(
            "ORTHANC_API_UNAVAILABLE",
            name .. " is unavailable."
        )
    end

    local ok, value = pcall(fn, ...)

    if not ok then
        return Result.Failure(
            "ORTHANC_API_FAILED",
            tostring(value)
        ):WithContext({ Function = name })
    end

    return Result.Success(value)

end

local function encode(value)

    local ok, json = pcall(Compatibility.EncodeJson, value)

    if not ok then
        return nil, Result.Failure("JSON_ENCODE_FAILED", tostring(json))
    end

    return json, nil

end

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Performs an Orthanc REST GET.
--
-- @param path string
-- @return table
------------------------------------------------------------------------------
function Client.Get(path)

    Validation.NotEmpty(path, "path")

    return call("RestApiGet", path)

end

------------------------------------------------------------------------------
--- Performs an Orthanc REST POST.
--
-- @param path string
-- @param body string|table|nil
-- @return table
------------------------------------------------------------------------------
function Client.Post(path, body)

    Validation.NotEmpty(path, "path")

    if type(body) == "table" then
        local json, failure = encode(body)

        if failure ~= nil then
            return failure
        end

        body = json
    end

    return call("RestApiPost", path, body or "")

end

------------------------------------------------------------------------------
--- Performs an Orthanc REST PUT.
--
-- @param path string
-- @param body string|table|nil
-- @return table
------------------------------------------------------------------------------
function Client.Put(path, body)

    Validation.NotEmpty(path, "path")

    if type(body) == "table" then
        local json, failure = encode(body)

        if failure ~= nil then
            return failure
        end

        body = json
    end

    return call("RestApiPut", path, body or "")

end

------------------------------------------------------------------------------
--- Performs an Orthanc REST DELETE.
--
-- @param path string
-- @return table
------------------------------------------------------------------------------
function Client.Delete(path)

    Validation.NotEmpty(path, "path")

    return call("RestApiDelete", path)

end

------------------------------------------------------------------------------
--- Deletes an Orthanc resource by id when configured.
--
-- @param resourceId string
-- @return table
------------------------------------------------------------------------------
function Client.DeleteResource(resourceId)

    Validation.NotEmpty(resourceId, "resourceId")

    if type(Delete) == "function" then
        return call("Delete", resourceId)
    end

    return Client.Delete("/studies/" .. resourceId)

end

return Client
