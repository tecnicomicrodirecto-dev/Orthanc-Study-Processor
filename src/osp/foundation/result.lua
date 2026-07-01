------------------------------------------------------------------------------
-- OSP Result
--
-- Represents operational success or failure.
------------------------------------------------------------------------------

local Validation = require("osp.foundation.validation")

local Result = {}
Result.__index = Result

------------------------------------------------------------------------------
-- Private Functions
------------------------------------------------------------------------------

local function new(success, code, message, data, context)

    return setmetatable({
        _success = success,
        _code = code,
        _message = message,
        _data = data,
        _context = context
    }, Result)

end

------------------------------------------------------------------------------
-- Public Functions
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Creates a successful result.
--
-- @param data any
-- @return table
------------------------------------------------------------------------------
function Result.Success(data)

    return new(true, nil, nil, data, nil)

end

------------------------------------------------------------------------------
--- Creates a failed result.
--
-- @param code string
-- @param message string
-- @return table
------------------------------------------------------------------------------
function Result.Failure(code, message)

    Validation.NotEmpty(code, "code")
    Validation.NotEmpty(message, "message")

    return new(false, code, message, nil, nil)

end

------------------------------------------------------------------------------
--- Returns true if the operation succeeded.
--
-- @return boolean
------------------------------------------------------------------------------
function Result:IsSuccess()

    return self._success == true

end

------------------------------------------------------------------------------
--- Returns true if the operation failed.
--
-- @return boolean
------------------------------------------------------------------------------
function Result:IsFailure()

    return not self:IsSuccess()

end

------------------------------------------------------------------------------
--- Returns the result code.
--
-- @return string|nil
------------------------------------------------------------------------------
function Result:GetCode()

    return self._code

end

------------------------------------------------------------------------------
--- Returns the diagnostic message.
--
-- @return string|nil
------------------------------------------------------------------------------
function Result:GetMessage()

    return self._message

end

------------------------------------------------------------------------------
--- Returns the associated data.
--
-- @return any
------------------------------------------------------------------------------
function Result:GetData()

    return self._data

end

------------------------------------------------------------------------------
--- Returns the diagnostic context.
--
-- @return table|nil
------------------------------------------------------------------------------
function Result:GetContext()

    return self._context

end

------------------------------------------------------------------------------
--- Attaches diagnostic context and returns a new result.
--
-- @param context table
-- @return table
------------------------------------------------------------------------------
function Result:WithContext(context)

    return new(
        self._success,
        self._code,
        self._message,
        self._data,
        context
    )

end

------------------------------------------------------------------------------
--- Replaces the data value and returns a new result.
--
-- @param value any
-- @return table
------------------------------------------------------------------------------
function Result:WithData(value)

    return new(
        self._success,
        self._code,
        self._message,
        value,
        self._context
    )

end

------------------------------------------------------------------------------
--- Creates a Result from a boolean value.
--
-- @param success boolean
-- @param code string|nil
-- @param message string|nil
-- @return table
------------------------------------------------------------------------------
function Result.FromBoolean(success, code, message)

    if success then
        return Result.Success()
    end

    return Result.Failure(
        code or "UNKNOWN",
        message or "Operation failed."
    )

end

------------------------------------------------------------------------------
--- Returns true if the supplied value is a Result instance.
--
-- @param value any
-- @return boolean
------------------------------------------------------------------------------
function Result.IsResult(value)

    return getmetatable(value) == Result

end

------------------------------------------------------------------------------
--- Returns the first failed Result or a successful Result.
--
-- @param ...
-- @return table
------------------------------------------------------------------------------
function Result.Combine(...)

    local results = { ... }

    for _, result in ipairs(results) do
        Validation.Require(Result.IsResult(result), "Result object expected.")

        if result:IsFailure() then
            return result
        end
    end

    return Result.Success()

end

------------------------------------------------------------------------------
--- Returns a string representation suitable for logging.
--
-- @return string
------------------------------------------------------------------------------
function Result:ToString()

    if self:IsSuccess() then
        return "SUCCESS"
    end

    return string.format(
        "[%s] %s",
        tostring(self._code),
        tostring(self._message)
    )

end

return Result
