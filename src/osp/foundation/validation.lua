------------------------------------------------------------------------------
-- OSP Validation
--
-- Runtime contract validation helpers.
--
-- Validation is used exclusively to detect programmer errors.
-- Operational failures must be represented using Result objects.
------------------------------------------------------------------------------

local Validation = {}

------------------------------------------------------------------------------
-- Private Helpers
------------------------------------------------------------------------------

local function argumentName(name)

    if name == nil or name == "" then
        return "value"
    end

    return tostring(name)

end

local function fail(message, level)

    error(message, (level or 1) + 1)

end

------------------------------------------------------------------------------
-- Public API
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Ensures a value is not nil.
--
-- @param value any
-- @param name string
------------------------------------------------------------------------------
function Validation.NotNil(value, name)

    if value ~= nil then
        return
    end

    fail(string.format(
        "Argument '%s' must not be nil.",
        argumentName(name)
    ))

end

------------------------------------------------------------------------------
--- Ensures a value is nil.
--
-- @param value any
-- @param name string
------------------------------------------------------------------------------
function Validation.Nil(value, name)

    if value == nil then
        return
    end

    fail(string.format(
        "Argument '%s' must be nil.",
        argumentName(name)
    ))

end

------------------------------------------------------------------------------
--- Ensures a value has the expected Lua type.
--
-- @param value any
-- @param name string
-- @param expected string
------------------------------------------------------------------------------
function Validation.Type(value, name, expected)

    Validation.NotNil(expected, "expected")

    local actual = type(value)

    if actual == expected then
        return
    end

    fail(string.format(
        "Argument '%s' must be of type '%s' (got '%s').",
        argumentName(name),
        expected,
        actual
    ))

end

------------------------------------------------------------------------------
--- Ensures a condition evaluates to true.
--
-- @param condition boolean
-- @param message string
------------------------------------------------------------------------------
function Validation.Require(condition, message)

    if condition then
        return
    end

    fail(message or "Validation failed.")

end

------------------------------------------------------------------------------
--- Ensures a collection is not empty.
--
-- @param value table|string
-- @param name string
------------------------------------------------------------------------------
function Validation.NotEmpty(value, name)

    Validation.NotNil(value, name)

    local valueType = type(value)

    if valueType ~= "table" and valueType ~= "string" then

        fail(string.format(
            "Argument '%s' must be a table or string.",
            argumentName(name)
        ))

    end

    local count

    if valueType == "string" then
        count = #value
    else
        count = next(value) ~= nil and 1 or 0
    end

    if count > 0 then
        return
    end

    fail(string.format(
        "Argument '%s' must not be empty.",
        argumentName(name)
    ))

end

------------------------------------------------------------------------------
--- Ensures a number is positive.
--
-- @param value number
-- @param name string
------------------------------------------------------------------------------
function Validation.Positive(value, name)

    Validation.Type(value, name, "number")

    if value > 0 then
        return
    end

    fail(string.format(
        "Argument '%s' must be positive.",
        argumentName(name)
    ))

end

------------------------------------------------------------------------------
--- Ensures a number is zero or positive.
--
-- @param value number
-- @param name string
------------------------------------------------------------------------------
function Validation.NonNegative(value, name)

    Validation.Type(value, name, "number")

    if value >= 0 then
        return
    end

    fail(string.format(
        "Argument '%s' must be zero or positive.",
        argumentName(name)
    ))

end

------------------------------------------------------------------------------
--- Ensures a value belongs to an enumeration.
--
-- @param value any
-- @param allowed table
-- @param name string
------------------------------------------------------------------------------
function Validation.Enum(value, allowed, name)

    Validation.Type(allowed, "allowed", "table")

    if allowed[value] then
        return
    end

    fail(string.format(
        "Argument '%s' has an invalid value.",
        argumentName(name)
    ))

end

------------------------------------------------------------------------------
--- Ensures an object has the expected metatable.
--
-- @param value table
-- @param class table
-- @param name string
------------------------------------------------------------------------------
function Validation.Instance(value, class, name)

    Validation.NotNil(value, name)
    Validation.Type(class, "class", "table")

    if getmetatable(value) == class then
        return
    end

    fail(string.format(
        "Argument '%s' is not an instance of the expected type.",
        argumentName(name)
    ))

end

------------------------------------------------------------------------------
return Validation