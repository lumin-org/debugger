-- Variables

local RunService = game:GetService("RunService")
local PackageLinksAllowed = RunService:IsStudio()

local Types = require(script.types)

local LogList = nil
local Metadata = {
	URL = "",
	Name = "Package",
    TraceLevel = 3,
}

-- Functions

--[=[
	Sets specific metadata for formatting; such as a custom web link or package name.

	[Open Documentation](https://lumin-org.github.io/debugger/api/#setmetadata)
]=]
local function SetMetadata(metadata: { [string]: any })
	for key, value in metadata do
		if key == "URL" and not PackageLinksAllowed then
			continue
		end
		Metadata[key] = value
	end
end

--[=[
	Sets a list of logs to be referenced within formatters.

	[Open Documentation](https://lumin-org.github.io/debugger/api/#setlogs)
]=]
local function SetLogs(logList: { [string]: string })
	LogList = logList
end

--[=[
	Base formatter for all debug functions, returns a formatted string with extra info.

	[Open Documentation](https://lumin-org.github.io/debugger/api/#format)
]=]
local function Format(logId: string, trace: string, ...: any): string
	assert(LogList[logId], "Invalid log ID")
    local FormattedLog = string.format(LogList[logId] or "Unknown", ...)
	return (string.gsub(
		`[{Metadata.Name}] {FormattedLog}{if Metadata.URL ~= ""
			then `\nLearn: {Metadata.URL}`
			else ""}\nTrace: {(string.gsub(trace, "\n", ""))}`,
		"\n",
		"\n\t\t\t\t"
	))
end

--[=[
	Formats a fatal error of a log ID with provided parameters.

	[Open Documentation](https://lumin-org.github.io/debugger/api/#fatal)
]=]
local function Fatal(logId: string, ...: any): never
	error(Format(logId,	debug.traceback(nil, Metadata.TraceLevel), ...), 0)
end

--[=[
	Formats a warning of a log ID with provided parameters.

	[Open Documentation](https://lumin-org.github.io/debugger/api/#warn)
]=]
local function Warn(logId: string, ...: any)
	warn(Format(logId, debug.traceback(nil, Metadata.TraceLevel), ...))
end

--[=[
	Returns the provided condition if it is true, behaves as the regular assert.

	[Open Documentation](https://lumin-org.github.io/debugger/api/#assert)
]=]
local function Assert<T>(condition: T, logId: string, ...: any): T
	if not condition then
		return Fatal(logId, ...)
	end
	return condition
end

--[=[
	Extracts info from xpcall errors to beautify it.

	[Open Documentation](https://lumin-org.github.io/debugger/api/#parse)
]=]
local function Parse(error: string): Types.ParsedError
	return {
		Raw = error,
		Message = string.gsub(error, "^.+:%d+:%s*", ""),
		Trace = debug.traceback(nil, Metadata.TraceLevel),
	}
end

-- Types

export type ParsedError = Types.ParsedError

-- Module

return table.freeze({
	SetMetadata = SetMetadata,
	SetLogs = SetLogs,
	Format = Format,
	Fatal = Fatal,
	Warn = Warn,
	Assert = Assert,
	Parse = Parse,
})
