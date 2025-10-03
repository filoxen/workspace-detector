-- handles core detection logic for workspace in models
local roblox = require("@lune/roblox")
local stdio = require("@lune/stdio")
local types = require("./types")
local compression = require("./compression")

export type Core = {
    scanForWorkspace:      (model: types.model, printInstanceNames: boolean) -> boolean,
    isValidModelFile:      (fileName: string) -> boolean,
    fileContainsWorkspace: (fileContents: string, opts: types.opts) -> boolean,
    formatResult:          (result: boolean, fileName: string) -> string
}

local core = {} :: Core

--[[
    Recursively scans a model (table of Instances) for a Workspace instance.

    ### Example usage

    ```lua
    local roblox = require("@lune/roblox")
    local core = require("./core")

    local model = roblox.deserializeModel(fileContents)
    if core.scanForWorkspace(model) then
        print("This model contains a Workspace instance.")
    else
        print("This model does not contain a Workspace instance.")
    end
    ```

    @param model The deserialized Roblox model to scan.
    @param printInstanceNames If true, prints the full names of all instances in the model during the scan.
    @return True if a Workspace instance is found, false otherwise.
]]--
function core.scanForWorkspace(model: types.model, printInstanceNames: boolean): boolean
    assert(typeof(model) == "table", "Expected model to be of type 'table'")
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

--[[
	Returns true if the file has a .rbxm or .rbxmx extension, false otherwise.

	### Example usage

	```lua
	local fs = require("@lune/fs")

	local modelFile = fs.readFile("filePath.rbxm")
    if core.isValidModelFile("filePath.rbxm") then
        print("This is a valid Roblox model file.")
    else
        print("This is not a valid Roblox model file.")
    end
	```

	@param contents The filename of the model file to check.
    @return True if the file has a valid model extension, false otherwise.
]]--
function core.isValidModelFile(fileName: string): boolean
    assert(typeof(fileName) == "string", "Expected fileName to be of type 'string'")
    local ext = string.match(fileName, "%.([^%.]+)$")
    return ext == "rbxm" or ext == "rbxmx"
end


--[[
    Checks if the given file contents contain a Workspace instance.

    If the file is a valid Roblox model file, attempts to deserialize it and scan for a Workspace instance.
    If deserialization fails, falls back to a simple string search for the Workspace tag.

    If zlib decompression options are enabled in opts, attempts to decompress the file contents before scanning.

    ### Example usage

    ```lua
    local fs = require("@lune/fs")
    local core = require("./core")

    local fileContents = fs.readFile("model.rbxm")
    local opts = {
        printInstanceNames = true,
        zlibDecompressFiles = true,
        zlibDecompressFilesRecursive = false
        -- other options...
    }
    if core.fileContainsWorkspace(fileContents, opts) then
        print("The file contains a Workspace instance.")
    else
        print("The file does not contain a Workspace instance.")
    end
    ```
    @param fileContents The contents of the file to check.
    @param opts Options table of type `types.opts`
    @return True if a Workspace instance is found, false otherwise.
]]
function core.fileContainsWorkspace(fileContents: string, opts: types.opts): boolean
    assert(typeof(fileContents) == "string", "Expected fileContents to be of type 'string'")
    assert(typeof(opts) == "table", "Expected opts to be of type 'table'")
    if opts.zlibDecompressFiles or opts.zlibDecompressFilesRecursive then
        local success = pcall(function() fileContents = compression.zlibDecompress(fileContents, opts) end)
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


--[[
    Formats the workspace detection result as a colored string.

    @param result The boolean result of the workspace detection.
    @param fileName The name of the file that was checked.
    @return A formatted string indicating whether the file contains a Workspace instance, colored green for true and yellow for false.
]]--
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
