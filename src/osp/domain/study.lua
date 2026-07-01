------------------------------------------------------------------------------
-- OSP Study
--
-- Domain representation of a stable Orthanc study.
------------------------------------------------------------------------------

local Validation = require("osp.foundation.validation")

local Study = {}
Study.__index = Study

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Creates a study domain object.
--
-- @param id string
-- @param tags table|nil
-- @param metadata table|nil
-- @return table
------------------------------------------------------------------------------
function Study.Create(id, tags, metadata)

    Validation.NotEmpty(id, "id")

    return setmetatable({
        Id = id,
        Tags = tags or {},
        Metadata = metadata or {}
    }, Study)

end

------------------------------------------------------------------------------
--- Returns the Orthanc study identifier.
--
-- @return string
------------------------------------------------------------------------------
function Study:GetId()

    return self.Id

end

------------------------------------------------------------------------------
--- Returns a DICOM tag value.
--
-- @param name string
-- @return any
------------------------------------------------------------------------------
function Study:GetTag(name)

    Validation.NotEmpty(name, "name")

    return self.Tags[name]

end

------------------------------------------------------------------------------
--- Returns a metadata value.
--
-- @param name string|number
-- @return any
------------------------------------------------------------------------------
function Study:GetMetadata(name)

    Validation.NotNil(name, "name")

    return self.Metadata[name] or self.Metadata[tostring(name)]

end

return Study
