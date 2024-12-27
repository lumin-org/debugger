local Debugger = require(game.ReplicatedStorage.debugger.src)
local TestModule = require(script.Parent.testmodule)

Debugger.SetMetadata({
    Good = "hi can you please say hi",
    Bad = "OH NO - %s",
}, {
    URL = "https://lumin-org.github.io/framework/",
    Name = "Framework",
})

Debugger.Warn("Good")

local result, message: Debugger.ParsedError = xpcall(function()
    TestModule()
end, Debugger.Parse)

if not result then
    local error_message = message
    Debugger.Warn("Bad", error_message.Message)
end
