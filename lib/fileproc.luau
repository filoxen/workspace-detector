-- handles file and directory processing
local fs = require("@lune/fs")
local stdio = require("@lune/stdio")
local process = require("@lune/process")
local serde = require("@lune/serde")
local core = require("./core")
local types = require("./types")

local fileproc = {}

function fileproc.collectFiles(opts: types.opts): {string}
    local filesToProcess = opts.filesToProcess or {}
    if opts.directoryMode then
        if not opts.directoryPath or not fs.isDir(opts.directoryPath) then
            stdio.write(stdio.color("red"))
            stdio.write(`Error: Directory {opts.directoryPath} does not exist.\n`)
            stdio.write(stdio.color("reset"))
            process.exit(1)
        end
        local function readDirLoop(dirPath)
            for _, file in pairs(fs.readDir(dirPath)) do
                local fullPath = dirPath .. "/" .. file
                if fs.isFile(fullPath) then
                    if opts.forceBinaryRead or core.isValidModelFile(file) then
                        table.insert(filesToProcess, fullPath)
                    end
                elseif fs.isDir(fullPath) then
                    readDirLoop(fullPath)
                end
            end
        end
        readDirLoop(opts.directoryPath)
        if #filesToProcess == 0 then
            stdio.write(stdio.color("yellow"))
            stdio.write(`Warning: No files found in directory {opts.directoryPath}.\n`)
            stdio.write(stdio.color("reset"))
            process.exit(0)
        end
    end
    if #filesToProcess == 0 then
        stdio.write(stdio.color("red"))
        stdio.write("Error: No files to process.\n")
        stdio.write(stdio.color("reset"))
        process.exit(1)
    end
    return filesToProcess
end

function fileproc.processFiles(filesToProcess: {string}, opts: types.opts): {string}
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

-- take in file contents and zlib decompress them
-- if recursive param is true repeatedly zlib decompress the file until it fails
-- (modelscrape files are often double/triple zlib decompressed)
function fileproc.zlibDecompress(contents: string, recursive: boolean?): string | boolean
    local success: boolean, decompressedContents: string = pcall(function()
        return serde.decompress("zlib", contents)
    end)
    return success and decompressedContents or success
end

return fileproc
