local process = require("@lune/process")
local fs = require("@lune/fs")
local roblox = require("@lune/roblox")

local args = process.args()

local fileFromArgs: string = fs.readFile(args[1])


function scanForWorkspace(model: Model): boolean
    for _index, child in model:GetDescendants() do
        if child:IsA("Workspace") then
            return true
        end
    end
    return false
end

function containsWorkspace(fileContents: string): boolean
    local instances = roblox.deserializeModel(fileContents)
    return scanForWorkspace(instances)
end 

containsWorkspace(fileFromArgs)