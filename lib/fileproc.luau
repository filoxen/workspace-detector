-- handles file and directory processing
local fs = require("@lune/fs")
local stdio = require("@lune/stdio")
local process = require("@lune/process")
local core = require("./core")
local types = require("./types")

export type FileProc = {
    collectFiles: (opts: types.opts) -> {string},
    processFiles: (filesToProcess: {string}, opts: types.opts) -> {string},
}

local fileproc = {} :: FileProc

--[[
    Collects files to process based on command line arguments or directory mode.

    ### Example usage

    ```lua
    local cli = require("./cli")
    local fileproc = require("./fileproc")

    local opts = cli.parseArgs()
    local filesToProcess = fileproc.collectFiles(opts)
    print("Files to process:", table.concat(filesToProcess, ", "))
    ```

    @param opts Options table of type `types.opts`.
    @return A list of file paths to process.
]]--
function fileproc.collectFiles(opts: types.opts): {string}
    assert(typeof(opts) == "table", "Expected opts to be of type 'table'")
    local filesWithWorkspace = {} 

    local function processDir(dirPath)
        for _, file in pairs(fs.readDir(dirPath)) do
            local fullPath = dirPath .. "/" .. file
            if fs.isDir(fullPath) then
                processDir(fullPath)
            elseif fs.isFile(fullPath) then
                if opts.forceBinaryRead or core.isValidModelFile(file) then
                    table.insert(filesWithWorkspace, fullPath)
                end
            end
        end
    end

    if opts.directoryMode then
        if not opts.directoryPath or not fs.isDir(opts.directoryPath) then
            stdio.write(stdio.color("red"))
            stdio.write(`Error: Directory {opts.directoryPath} does not exist.\n`)
            stdio.write(stdio.color("reset"))
            process.exit(1)
        end

        processDir(opts.directoryPath)

        if #filesWithWorkspace == 0 then
            stdio.write(stdio.color("yellow"))
            stdio.write(`Warning: No files found in directory {opts.directoryPath}.\n`)
            stdio.write(stdio.color("reset"))
            process.exit(0)
        end
    end

    if #filesWithWorkspace == 0 then
        stdio.write(stdio.color("red"))
        stdio.write("Error: No files to process.\n")
        stdio.write(stdio.color("reset"))
        process.exit(1)
    end

    return filesWithWorkspace
end


--[[
    Processes each file and checks for workspace instances.

    ### Example usage

    ```lua
    local cli = require("./cli")
    local fileproc = require("./fileproc")

    local opts = cli.parseArgs()
    local filesToProcess = fileproc.collectFiles(opts)
    local filesWithWorkspace = fileproc.processFiles(filesToProcess, opts)
    print("Files containing Workspace instances:", table.concat(filesWithWorkspace, ", "))
    ```

    @param filesToProcess A list of file paths to process.
    @param opts Options table of type `types.opts`.
    @return A list of file paths that contain Workspace instances.
]]--
function fileproc.processFiles(filesToProcess: {string}, opts: types.opts): {string}
    assert(typeof(filesToProcess) == "table", "Expected filesToProcess to be of type 'table'")
    assert(typeof(opts) == "table", "Expected opts to be of type 'table'")
    local filesWithWorkspace = {}
    for _, filePath in pairs(filesToProcess) do
        if fs.isFile(filePath) then
            if opts.forceBinaryRead or opts.directoryMode or core.isValidModelFile(filePath) then
                local success, result = pcall(function()
                    local fileContents = fs.readFile(filePath)
                    return core.fileContainsWorkspace(fileContents, opts)
                end)
                if success then
                    if result then
                        table.insert(filesWithWorkspace, filePath)
                    end
                    print(core.formatResult(result, filePath))
                else
                    stdio.write(stdio.color("red"))
                    stdio.write(`Error processing {filePath}: {result}\n`)
                    stdio.write(stdio.color("reset"))
                end
            else
                stdio.write(stdio.color("yellow"))
                stdio.write(`Warning: {filePath} is not a .rbxm or .rbxmx file, skipping.\n`)
                stdio.write(stdio.color("reset"))
            end
        else
            stdio.write(stdio.color("red"))
            stdio.write(`Error: File {filePath} does not exist.\n`)
            stdio.write(stdio.color("reset"))
        end
    end
    return filesWithWorkspace
end


return fileproc
