------------------------------------------------------------------------------
-- OSP Workspace
--
-- Domain representation of a processing workspace.
------------------------------------------------------------------------------

local Constants = require("osp.foundation.constants")
local Path = require("osp.foundation.path")
local Validation = require("osp.foundation.validation")

local Workspace = {}
Workspace.__index = Workspace

------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------

local function buildPaths(root)

    return {
        Root = root,
        Raw = Path.Join(root, Constants.Workspace.Raw),
        Working = Path.Join(root, Constants.Workspace.Working),
        Export = Path.Join(root, Constants.Workspace.Export),
        Archive = Path.Join(root, Constants.Workspace.Archive),
        Temp = Path.Join(root, Constants.Workspace.Temp),
        Logs = Path.Join(root, Constants.Workspace.Logs)
    }

end

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Creates a workspace object.
--
-- @param root string
-- @return table
------------------------------------------------------------------------------
function Workspace.Create(root)

    Validation.NotEmpty(root, "root")

    return setmetatable({
        Root = root,
        Paths = buildPaths(root)
    }, Workspace)

end

------------------------------------------------------------------------------
--- Returns all workspace directories.
--
-- @return table
------------------------------------------------------------------------------
function Workspace:GetDirectories()

    return {
        self.Paths.Root,
        self.Paths.Raw,
        self.Paths.Working,
        self.Paths.Export,
        self.Paths.Archive,
        self.Paths.Temp,
        self.Paths.Logs
    }

end

return Workspace
