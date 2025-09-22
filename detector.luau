local process = require("@lune/process")
local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local stdio = require("@lune/stdio")

local args = process.args

if #args < 1 then
    stdio.write(stdio.color("red"))
    stdio.write("Error: Please provide a file path as an argument.")
    stdio.write(stdio.color("reset"))
    process.exit(1)
end

local fileFromArgs: string = fs.readFile(args[1])


function scanForWorkspace(model: {Instance}): boolean
    for _index, child in ipairs(model) do
        if child:IsA("Workspace") then
            return true
        else
            local children = child:GetChildren()
            scanForWorkspace(children)
        end
    end
    return false
end

function containsWorkspace(fileContents: string): boolean
    local instances = roblox.deserializeModel(fileContents)
    return scanForWorkspace(instances)
end 

function formatResult(result: boolean, fileName: string): string
    if result then
        return `File {fileName} contains a Workspace instance.`
    else
        return `File {fileName} does not contain a Workspace instance.`
    end
end

local result = formatResult(containsWorkspace(fileFromArgs), args[1])

print(result)