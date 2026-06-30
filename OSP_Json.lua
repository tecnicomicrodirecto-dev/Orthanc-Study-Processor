local Json = {}

function Json.encode(value)
    if DumpJson == nil then
        error("DumpJson is not available in this Orthanc Lua runtime")
    end

    return DumpJson(value)
end

function Json.decode(value)
    if ParseJson == nil then
        error("ParseJson is not available in this Orthanc Lua runtime")
    end

    if value == nil or value == "" then
        return nil
    end

    return ParseJson(value)
end

return Json
