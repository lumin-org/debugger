-- Variables

local RunService = game:GetService("RunService")
local LinksAllowed = RunService:IsStudio()

local Types = require(script.types)

local LogBase = "[%s] %s%s%s"
local Data = {
	URL = nil,
	Logs = nil,
	Name = "Package",
	Trace = true,
}

-- Functions

--[=[
	Sets logger metadata that is referenced within each log, along with the setting the
    logs themselves.

	[Open Documentation](https://lumin-org.github.io/debugger/api/#setmetadata)
]=]
local function set(data: { [string]: any })
	for key, value in data do
		if key == "URL" and not LinksAllowed then
			continue
		end
		Data[key] = value
	end
end

--[=[
	Base formatter for all debug functions, returns a formatted string with extra info.

	[Open Documentation](https://lumin-org.github.io/debugger/api/#format)
]=]
local function format(logId: string, trace: string, ...: any): string
	assert(Data.Logs, "Must have log list")
	assert(Data.Logs[logId], "Invalid log ID")
	local Formatted = LogBase:format(
		Data.Name, -- Package name
		(Data.Logs[logId] :: string):format(...), -- Formatted log details
		if Data.URL then `\nLearn: {Data.URL}{logId:lower()}` else "", -- Learn URL
		if Data.Trace then `\nTrace: {trace}` else "" -- Traceback
	):gsub("\n", "\n\t\t\t\t")
	return Formatted
end

--[=[
	Formats a fatal error of a log ID with provided parameters.

	[Open Documentation](https://lumin-org.github.io/debugger/api/#fatal)
]=]
local function fatal(logId: string, ...: any): never
	error(format(logId, debug.traceback(nil, 2), ...), 0)
end

--[=[
	Formats a warning of a log ID with provided parameters.

	[Open Documentation](https://lumin-org.github.io/debugger/api/#warn)
]=]
local function warn(logId: string, ...: any)
	warn(format(logId, debug.traceback(nil, 2), ...))
end

--[=[
	Returns the provided condition if it is true, behaves as the regular assert.

	[Open Documentation](https://lumin-org.github.io/debugger/api/#assert)
]=]
local function assert<T>(condition: T, logId: string, trace: string?, ...: any): T
	if not condition then
		error(format(logId, debug.traceback(nil, 3), ...), 0)
	end
	return condition
end

--[=[
	Extracts info from xpcall errors to beautify it.

	[Open Documentation](https://lumin-org.github.io/debugger/api/#parse)
]=]
local function parse(error: string): Types.ParsedError
	return {
		Raw = error,
		Message = error:gsub("^.+:%d+:%s*", ""),
		Trace = debug.traceback(nil, 2),
	}
end

-- Types

export type ParsedError = Types.ParsedError

-- Module

return table.freeze({
	set = set,
	fatal = fatal,
	warn = warn,
	assert = assert,
	parse = parse,
})
