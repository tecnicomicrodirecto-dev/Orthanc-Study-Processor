local Result = {}

Result.__index = Result

local function new(success)

    local self = {

        Success = success,

        Code = nil,

        Message = nil,

        Data = nil,

        Context = nil

    }

    return setmetatable(self, Result)

end

function Result.Success(data)

    local result = new(true)

    result.Data = data

    return result

end

function Result.Failure(code, message)

    local result = new(false)

    result.Code = code

    result.Message = message

    return result

end

------------------------------------------------------------------------------
-- Result Methods
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--- Returns true if the operation succeeded.
--
-- @return boolean
------------------------------------------------------------------------------
function Result:IsSuccess()

    return self._success

end

------------------------------------------------------------------------------
--- Returns true if the operation failed.
--
-- @return boolean
------------------------------------------------------------------------------
function Result:IsFailure()

    return not self._success

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
--- Attaches diagnostic context.
--
-- This method returns a new Result object.
--
-- @param context table
--
-- @return Result
------------------------------------------------------------------------------
function Result:WithContext(context)

    local copy = new(self._success)

    copy._code = self._code
    copy._message = self._message
    copy._data = self._data
    copy._context = context

    return copy

end

------------------------------------------------------------------------------
--- Returns a new successful result with different data.
--
-- @param value any
--
-- @return Result
------------------------------------------------------------------------------
function Result:WithData(value)

    local copy = new(self._success)

    copy._code = self._code
    copy._message = self._message
    copy._data = value
    copy._context = self._context

    return copy

end

------------------------------------------------------------------------------
--- Creates a Result from a boolean value.
--
-- @param success boolean
-- @param code string|nil
-- @param message string|nil
--
-- @return Result
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
--
-- @return boolean
------------------------------------------------------------------------------
function Result.IsResult(value)

    return getmetatable(value) == Result

end

------------------------------------------------------------------------------
--- Combines multiple Results.
--
-- Returns the first failure encountered.
-- If every Result succeeds, returns a new successful Result.
--
-- @param ...
--
-- @return Result
------------------------------------------------------------------------------
function Result.Combine(...)

    local results = { ... }

    for _, result in ipairs(results) do

        assert(
            Result.IsResult(result),
            "Result.Combine() expects Result objects."
        )

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
        tostring(self:GetCode()),
        tostring(self:GetMessage())
    )

end

------------------------------------------------------------------------------
return Result