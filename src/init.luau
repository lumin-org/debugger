-- Variables

local RunService = game:GetService("RunService")
local LinksAllowed = RunService:IsStudio()

local Types = require(script.types)

local LogList = nil
local LogBase = "[%s] %s%s%s"
local Metadata = {
	Name = "Package",
	Trace = true,
}

-- Functions

--[=[
	Sets logger metadata that is referenced within each log, along with the setting the
    logs themselves.

	[Open Documentation](https://lumin-org.github.io/debugger/api/#setmetadata)
]=]
local function SetMetadata(logs: { [string]: string }, metadata: { [string]: any })
	LogList = logs
	for key, value in metadata do
		if key == "URL" and not LinksAllowed then
			continue
		end
		Metadata[key] = value
	end
end

--[=[
	Base formatter for all debug functions, returns a formatted string with extra info.

	[Open Documentation](https://lumin-org.github.io/debugger/api/#format)
]=]
local function Format(logId: string, trace: string, ...: any): string
	assert(LogList[logId], "Invalid log ID")
	local Formatted = LogBase:format(
		Metadata.Name, -- Package name
		LogList[logId]:format(...), -- Formatted log details
		if Metadata.URL then `\nLearn: {Metadata.URL}{logId}` else "", -- Learn URL
		if Metadata.Trace then `\nTrace: {trace}` else "" -- Traceback
	):gsub("\n", "\n\t\t\t\t")
	return Formatted
end

--[=[
	Formats a fatal error of a log ID with provided parameters.

	[Open Documentation](https://lumin-org.github.io/debugger/api/#fatal)
]=]
local function Fatal(logId: string, ...: any): never
	error(Format(logId, debug.traceback(nil, 2), ...), 0)
end

--[=[
	Formats a warning of a log ID with provided parameters.

	[Open Documentation](https://lumin-org.github.io/debugger/api/#warn)
]=]
local function Warn(logId: string, ...: any)
	warn(Format(logId, debug.traceback(nil, 2), ...))
end

--[=[
	Returns the provided condition if it is true, behaves as the regular assert.

	[Open Documentation](https://lumin-org.github.io/debugger/api/#assert)
]=]
local function Assert<T>(condition: T, logId: string, ...: any): T
	if not condition then
		Fatal(logId, ...)
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
		Message = error:gsub("^.+:%d+:%s*", ""),
		Trace = debug.traceback(nil, 2),
	}
end

-- Types

export type ParsedError = Types.ParsedError

-- Module

return table.freeze({
	SetMetadata = SetMetadata,
	Format = Format,
	Fatal = Fatal,
	Warn = Warn,
	Assert = Assert,
	Parse = Parse,
})
