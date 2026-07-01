------------------------------------------------------------------------------
-- OSP PACS
--
-- Adapter for forwarding studies to Orthanc peers/modalities.
------------------------------------------------------------------------------

local Client = require("osp.infrastructure.orthanc.client")
local Result = require("osp.foundation.result")
local Validation = require("osp.foundation.validation")

local Pacs = {}

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Sends a study to a configured Orthanc peer.
--
-- @param peer string
-- @param studyId string
-- @return table
------------------------------------------------------------------------------
function Pacs.SendToPeer(peer, studyId)

    Validation.NotEmpty(peer, "peer")
    Validation.NotEmpty(studyId, "studyId")

    return Client.Post("/peers/" .. peer .. "/store", studyId)

end

------------------------------------------------------------------------------
--- Sends when PACS forwarding is enabled.
--
-- @param configuration table
-- @param studyId string
-- @return table
------------------------------------------------------------------------------
function Pacs.SendIfEnabled(configuration, studyId)

    Validation.Type(configuration, "configuration", "table")
    Validation.NotEmpty(studyId, "studyId")

    if not configuration.Pacs.Enabled then
        return Result.Success()
    end

    return Pacs.SendToPeer(configuration.Pacs.Peer, studyId)

end

return Pacs
