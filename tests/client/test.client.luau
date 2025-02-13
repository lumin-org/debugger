local Debugger = require(game.ReplicatedStorage.debugger.src)
local TestModule = require(script.Parent.testmodule)

Debugger.set("Framework", {
    Good = "hi can you please say hi",
    Bad = "OH NO - %s",
})

Debugger.warn("Good")

local result, message: Debugger.Parsed = xpcall(function()
    TestModule()
end, Debugger.parse)

if not result then
    local error_message = message
    Debugger.warn("Bad", error_message.message)
end
