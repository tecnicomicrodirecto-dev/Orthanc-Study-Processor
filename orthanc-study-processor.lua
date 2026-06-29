------------------------------------------------------------------------------
--
--  ORTHANC STUDY PROCESSOR
--
------------------------------------------------------------------------------
--
--  Project
--
--      Orthanc Study Processor
--
--      OSP
--
------------------------------------------------------------------------------
--
--  Description
--
--      Automated DICOM processing pipeline for Orthanc.
--
--      OSP receives stable studies, creates a transaction workspace,
--      applies presentation formatting and metadata modifications,
--      exports the processed study, archives it, and performs
--      deterministic cleanup.
--
------------------------------------------------------------------------------
--
--  Target Platform
--
--      Orthanc
--
--      Lua 5.1
--
--      Windows
--
------------------------------------------------------------------------------
--
--  Architecture
--
--      Foundation
--
--      Models
--
--      Presentation
--
--      Services
--
--      Infrastructure
--
--      Application
--
--      Orthanc Entry Points
--
------------------------------------------------------------------------------
--
--  Engineering Principles
--
--      Deterministic
--
--      Transaction Based
--
--      Single Responsibility
--
--      Platform Abstraction
--
--      Structured Logging
--
--      Defensive Programming
--
------------------------------------------------------------------------------
--
--  Status
--
--      Development
--

------------------------------------------------------------------------------
--ENGINEERING RULES
------------------------------------------------------------------------------

--Foundation never depends on Models.
--Models never depend on Services.
--Services never depend on Application.
--Entry Points never contain business logic.
--Every workflow is represented by exactly one Processing object.
--Every service receives Processing.
--Every service returns Processing.
--Only Archive may delete studies.
--Every exported file is deterministic.
--Every error is logged.

------------------------------------------------------------------------------


------------------------------------------------------------------------------
--
-- FOUNDATION
--
-- Compatibility
--
-- Normalizes differences between Lua versions, Orthanc runtime behaviour
-- and the host operating system.
--
-- No other module should inspect the runtime directly.
--
------------------------------------------------------------------------------

Compat = {}

------------------------------------------------------------------------------
-- Runtime
------------------------------------------------------------------------------

Compat.Version = _VERSION

Compat.IsLua51 = (_VERSION == "Lua 5.1")

------------------------------------------------------------------------------
-- Table Compatibility
------------------------------------------------------------------------------

Compat.TableUnpack = table.unpack or unpack

------------------------------------------------------------------------------
-- Platform Detection
------------------------------------------------------------------------------

Compat.IsWindows =
    package.config:sub(1,1) == "\\"

Compat.DirectorySeparator =
    Compat.IsWindows and "\\" or "/"

Compat.PathSeparator =
    Compat.DirectorySeparator

Compat.NewLine =
    Compat.IsWindows and "\r\n" or "\n"
	
OSP = {}

OSP.Name = "Orthanc Study Processor"

OSP.Version = "2.0.0-alpha"

OSP.Build = "2026.06.29.001"

OSP.Target = "Lua 5.1"

OSP.Platform = "Windows"

OSP.Architecture = 1

------------------------------------------------------------------------------
--
-- FOUNDATION
--
-- Utils
--
-- Generic utility functions.
--
-- This module contains reusable functionality that is completely independent
-- from Orthanc, DICOM and the workflow engine.
--
-- Nothing inside this module should know that OSP exists.
--
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Type Helpers
------------------------------------------------------------------------------

function Utils.IsNil(value)
    return value == nil
end

function Utils.IsString(value)
    return type(value) == "string"
end

function Utils.IsNumber(value)
    return type(value) == "number"
end

function Utils.IsTable(value)
    return type(value) == "table"
end

function Utils.IsFunction(value)
    return type(value) == "function"
end

function Utils.IsBoolean(value)
    return type(value) == "boolean"
end

------------------------------------------------------------------------------
-- Default Values
------------------------------------------------------------------------------

function Utils.Default(value, defaultValue)

    if value == nil then
        return defaultValue
    end

    return value

end

------------------------------------------------------------------------------
-- String Helpers
------------------------------------------------------------------------------

function Utils.Trim(value)

    if value == nil then
        return ""
    end

    return (value:gsub("^%s*(.-)%s*$", "%1"))

end

function Utils.IsEmpty(value)

    return Utils.Trim(value) == ""

end

function Utils.StartsWith(text, prefix)

    return text:sub(1, #prefix) == prefix

end

function Utils.EndsWith(text, suffix)

    return suffix == ""
        or text:sub(-#suffix) == suffix

end

------------------------------------------------------------------------------
-- Table Helpers
------------------------------------------------------------------------------

function Utils.TableCount(tableValue)

    local count = 0

    for _ in pairs(tableValue) do
        count = count + 1
    end

    return count

end

function Utils.TableIsEmpty(tableValue)

    return next(tableValue) == nil

end

function Utils.ShallowCopy(source)

    local destination = {}

    for key, value in pairs(source) do
        destination[key] = value
    end

    return destination

end

------------------------------------------------------------------------------
-- Time
------------------------------------------------------------------------------

function Utils.Timestamp()

    return os.date("%Y-%m-%d %H:%M:%S")

end

function Utils.GenerateProcessingID()

    local now = os.date("%Y%m%d%H%M%S")

    local random = math.random(100000,999999)

    return string.format(

        "OSP-%s-%06d",

        now,

        random

    )

end

------------------------------------------------------------------------------
-- Protected Execution
------------------------------------------------------------------------------

function Utils.Try(callback)

    return pcall(callback)

end

local function Write(level,
                     processing,
                     module,
                     message)

    local timestamp =
        Utils.Timestamp()

    local processingId = "-"

    local revision = "-"

    local state = "-"

    if processing then

        processingId =
            processing.ID or "-"

        revision =
            processing.Revision or "-"

        state =
            processing.State or "-"

    end

    print(string.format(

        "[%s] %-7s %-12s PID=%s REV=%s STATE=%s %s",

        timestamp,

        level,

        module,

        processingId,

        revision,

        state,

        message

    ))

end

function Log.Info(processing,
                  module,
                  message)

    Write(

        Log.Level.INFO,

        processing,

        module,

        message

    )

end

function Validate.NotNil(value, name)

    if value == nil then

        error(string.format(

            "'%s' cannot be nil.",

            name

        ))

    end

    return true

end

function Validate.NotEmpty(value, name)

    Validate.NotNil(value, name)

    if Utils.Trim(value) == "" then

        error(string.format(

            "'%s' cannot be empty.",

            name

        ))

    end

    return true

end

function Validate.Table(value, name)

    if not Utils.IsTable(value) then

        error(string.format(

            "'%s' must be a table.",

            name

        ))

    end

    return true

end

function Validate.Function(value, name)

    if not Utils.IsFunction(value) then

        error(string.format(

            "'%s' must be a function.",

            name

        ))

    end

    return true

end

function Validate.Processing(processing)

    Validate.Table(

        processing,

        "Processing"

    )

    Validate.NotNil(

        processing.ID,

        "Processing.ID"

    )

    return true

end
	