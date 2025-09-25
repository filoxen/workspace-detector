-- handles core detection logic for workspace in models
local roblox = require("@lune/roblox")
local stdio  = require("@lune/stdio")
local types  = require("./types")
local compression = require("./compression")

export type Core = {
    scanForWorkspace:      (model: types.model, printInstanceNames: boolean) -> boolean,
    isValidModelFile:      (fileName: string) -> boolean,
    fileContainsWorkspace: (fileContents: string, opts: types.opts) -> boolean,
    formatResult:          (result: boolean, fileName: string) -> string
}

local core = {} :: Core

-- recursively searches a model for a workspace instance
function core.scanForWorkspace(model: types.model, printInstanceNames: boolean): boolean
    assert(typeof(model) == "table", "Expected model to be of type 'table''")
    assert(typeof(printInstanceNames) == "boolean", "Expected printInstanceNames to be of type 'boolean'")
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
function core.isValidModelFile(fileName: string): boolean
    assert(typeof(fileName) == "string", "Expected fileName to be of type 'string'")
    local ext = string.match(fileName, "%.([^%.]+)$")
    return ext == "rbxm" or ext == "rbxmx"
end

-- takes in fileContents as a string and deserializes them returning the results of scanForWorkspace() on the deserialized model. if it can't be deserialized, it will return the results of a naive search through the xml
function core.fileContainsWorkspace(fileContents: string, opts: types.opts): boolean
    assert(typeof(fileContents) == "string", "Expected fileContents to be of type 'string'")
    assert(typeof(opts) == "table", "Expected opts to be of type 'table'")
    if opts.zlibDecompressFiles or opts.zlibDecompressFilesRecursive then
        local success = pcall(function() fileContents = compression.zlibDecompress(fileContents, opts.zlibDecompressFilesRecursive) end)
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

-- formats the workspace detection result as a colored string
function core.formatResult(result: boolean, fileName: string): string
    assert(typeof(result) == "boolean", "Expected result to be of type 'boolean'")
    assert(typeof(fileName) == "string", "Expected fileName to be of type 'string'")
    if result then
        return stdio.color("green") .. `File {fileName} contains a Workspace instance.` .. stdio.color("reset")
    else
        return stdio.color("yellow") .. `File {fileName} does not contain a Workspace instance.` .. stdio.color("reset")
    end
end

return core
