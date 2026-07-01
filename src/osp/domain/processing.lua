------------------------------------------------------------------------------
-- OSP Processing
--
-- Processing transaction aggregate.
------------------------------------------------------------------------------

local Constants = require("osp.foundation.constants")
local Path = require("osp.foundation.path")
local Revision = require("osp.domain.revision")
local Study = require("osp.domain.study")
local Validation = require("osp.foundation.validation")
local Workspace = require("osp.domain.workspace")

local Processing = {}
Processing.__index = Processing

------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------

local function sanitizeIdentifier(value)

    value = tostring(value)
    value = string.gsub(value, "[^%w%._%-]", "_")

    return value

end

local function makeId(studyId)

    return table.concat({
        os.date("!%Y%m%dT%H%M%SZ"),
        sanitizeIdentifier(studyId)
    }, "_")

end

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Creates a processing aggregate.
--
-- @param configuration table
-- @param studyId string
-- @param tags table|nil
-- @param metadata table|nil
-- @return table
------------------------------------------------------------------------------
function Processing.Create(configuration, studyId, tags, metadata)

    Validation.Type(configuration, "configuration", "table")
    Validation.NotEmpty(studyId, "studyId")

    local id = makeId(studyId)
    local workspaceRoot = Path.Join(configuration.WorkspaceDirectory, id)
    local now = os.date("!%Y-%m-%dT%H:%M:%SZ")

    local self = {
        Id = id,
        Configuration = configuration,
        Study = Study.Create(studyId, tags, metadata),
        Workspace = Workspace.Create(workspaceRoot),
        State = Constants.Workflow.Created,
        CreatedAt = now,
        UpdatedAt = now,
        Revisions = {},
        ExportPath = nil,
        ArchivePath = nil,
        Failure = nil
    }

    return setmetatable(self, Processing)

end

------------------------------------------------------------------------------
--- Changes the workflow state.
--
-- @param state string
-- @param message string|nil
------------------------------------------------------------------------------
function Processing:SetState(state, message)

    Validation.NotEmpty(state, "state")

    self.State = state
    self.UpdatedAt = os.date("!%Y-%m-%dT%H:%M:%SZ")
    table.insert(self.Revisions, Revision.Create(state, message))

end

------------------------------------------------------------------------------
--- Records a failure.
--
-- @param result table
------------------------------------------------------------------------------
function Processing:Fail(result)

    Validation.NotNil(result, "result")

    self.Failure = {
        Code = result:GetCode(),
        Message = result:GetMessage(),
        Context = result:GetContext()
    }

    self:SetState(Constants.Workflow.Failed, result:GetMessage())

end

return Processing
