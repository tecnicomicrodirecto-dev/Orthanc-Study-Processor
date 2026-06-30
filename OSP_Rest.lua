local Json = require("OSP_Json")

local Rest = {}

local function encodePathPart(value)
    return tostring(value):gsub("([^A-Za-z0-9_%.%-])", function(character)
        return string.format("%%%02X", string.byte(character))
    end)
end

function Rest.studyPath(studyId, suffix)
    local path = "/studies/" .. encodePathPart(studyId)
    if suffix ~= nil and suffix ~= "" then
        path = path .. suffix
    end
    return path
end

function Rest.get(path)
    return RestApiGet(path)
end

function Rest.getJson(path)
    return Json.decode(RestApiGet(path))
end

function Rest.post(path, payload)
    if payload == nil then
        return RestApiPost(path, "")
    end

    if type(payload) == "string" then
        return RestApiPost(path, payload)
    end

    return RestApiPost(path, Json.encode(payload))
end

function Rest.postJson(path, payload)
    return Json.decode(Rest.post(path, payload))
end

function Rest.delete(path)
    if RestApiDelete == nil then
        error("RestApiDelete is not available in this Orthanc Lua runtime")
    end

    return RestApiDelete(path)
end

return Rest
