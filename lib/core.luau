-- handles core detection logic for workspace in models
local roblox = require("@lune/roblox")
local stdio = require("@lune/stdio")
local serde = require("@lune/serde")

local core = {}

-- recursively searches a model for a workspace instance
function core.scanForWorkspace(model, printInstanceNames)
    for _, child in pairs(model) do
        if printInstanceNames then
            print(child:GetFullName())
        end
        if child:IsA("Workspace") or core.scanForWorkspace(child:GetChildren(), printInstanceNames) then
            return true
        end
    end
    return false
end

-- checks if file has valid extension
function core.isValidModelFile(fileName)
    local ext = string.match(fileName, "%.([^%.]+)$")
    return ext == "rbxm" or ext == "rbxmx"
end

-- takes in fileContents as a string and deserializes them returning the results of scanForWorkspace() on the deserialized model. if it can't be deserialized, it will return the results of a naive search through the xml
function core.fileContainsWorkspace(fileContents, opts)
    if opts.zlibDecompressFiles then
        local success = pcall(function() fileContents = serde.decompress("zlib", fileContents) end)
        if not success then
            stdio.write(stdio.color("yellow"))
            stdio.write("Warning: Failed to decompress file with zlib. Proceeding with original contents.\n")
            stdio.write(stdio.color("reset"))
        end
    end
    local success, instances = pcall(function() return roblox.deserializeModel(fileContents) end)
    if not success then
        return string.find(fileContents, "Item class=\"Workspace\"") and true or false
    end
    return core.scanForWorkspace(instances, opts.printInstanceNames)
end

function core.formatResult(result, fileName)
    if result then
        return stdio.color("green") .. `File {fileName} contains a Workspace instance.` .. stdio.color("reset")
    else
        return stdio.color("yellow") .. `File {fileName} does not contain a Workspace instance.` .. stdio.color("reset")
    end
end

return core
