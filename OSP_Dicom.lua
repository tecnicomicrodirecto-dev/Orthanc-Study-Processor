local Rest = require("OSP_Rest")

local Dicom = {}

local function tableHasEntries(value)
    if type(value) ~= "table" then
        return false
    end

    for _ in pairs(value) do
        return true
    end

    return false
end

local function appendArray(target, source)
    if type(source) ~= "table" then
        return
    end

    for index = 1, #source do
        target[#target + 1] = source[index]
    end
end

local function mergeReplace(config)
    local replace = {}

    if type(config.presentation) == "table" and config.presentation.enabled then
        if type(config.presentation.replace) == "table" then
            for key, value in pairs(config.presentation.replace) do
                replace[key] = value
            end
        end
    end

    if type(config.modifyStudy) == "table" and type(config.modifyStudy.replace) == "table" then
        for key, value in pairs(config.modifyStudy.replace) do
            replace[key] = value
        end
    end

    return replace
end

function Dicom.getStudy(studyId)
    return Rest.getJson(Rest.studyPath(studyId, ""))
end

function Dicom.modifyStudy(studyId, config)
    local modifyConfig = config.modifyStudy or {}
    if not modifyConfig.enabled then
        return studyId
    end

    local replace = mergeReplace(config)
    local remove = {}
    local keep = {}

    appendArray(remove, modifyConfig.remove)
    appendArray(keep, modifyConfig.keep)

    if not tableHasEntries(replace) and #remove == 0 and #keep == 0 then
        return studyId
    end

    local payload = {
        Force = modifyConfig.force ~= false,
        KeepSource = modifyConfig.keepSource ~= false
    }

    if tableHasEntries(replace) then
        payload.Replace = replace
    end

    if #remove > 0 then
        payload.Remove = remove
    end

    if #keep > 0 then
        payload.Keep = keep
    end

    local response = Rest.postJson(Rest.studyPath(studyId, "/modify"), payload)

    if type(response) == "table" then
        return response.ID or response.Path or response[1] or studyId
    end

    return studyId
end

function Dicom.deleteStudy(studyId)
    Rest.delete(Rest.studyPath(studyId, ""))
end

return Dicom
