local Debugger = require(game.ReplicatedStorage.debugger.src)
local TestModule = require(script.Parent.testmodule)

Debugger.SetMetadata({
    PackageURL = "https://lumin-org.github.io/framework/",
    PackageName = "Framework",
    TraceLevel = 2,
})

Debugger.SetLogs({
    Good = "hi can you please say hi",
    Bad = "OH NO - %s",
})

Debugger.Warn("Good")

local result, message = xpcall(function()
    TestModule()
end, Debugger.Parse)

if not result then
    local error_message = message :: Debugger.ParsedError
    Debugger.Warn("Bad", error_message.Message)
end
