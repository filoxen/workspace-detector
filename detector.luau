local process = require("@lune/process")
local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local stdio = require("@lune/stdio")

local args = process.args

if #args < 1 then
    stdio.write(stdio.color("red"))
    stdio.write("Error: Please provide file path(s) or use --directory flag.\n")
    stdio.write("Usage: lune run detector file1.rbxm file2.rbxm file3.rbxmx\n")
    stdio.write("       lune run detector --directory path/to/folder\n")
    stdio.write("       lune run detector --d path/to/folder\n")
    stdio.write("       lune run detector --o output.txt file1.rbxm file2.rbxm\n")
    stdio.write("       lune run detector --output output.txt file1.rbxm file2.rbxm\n")
    stdio.write("       lune run detector --directory path/to/folder --o output.txt\n")
    stdio.write(stdio.color("reset"))
    process.exit(1)
end

-- takes in a model as defined by lune (a table of children)
-- returns a boolean if that model contains a workspace or not
-- recursively searches entire model
function scanForWorkspace(model: {Instance}): boolean
    for _, child in pairs(model) do
        if child:IsA("Workspace") or scanForWorkspace(child:GetChildren()) then
            return true
        end
    end
    return false
end

-- takes in fileContents as a string and deserializes them returning the results of scanForWorkspace() on the deserialized model
function fileContainsWorkspace(fileContents: string): boolean
    local instances = roblox.deserializeModel(fileContents)
    return scanForWorkspace(instances)
end 

function formatResult(result: boolean, fileName: string): string
    if result then
        return stdio.color("green") .. `File {fileName} contains a Workspace instance.` .. stdio.color("reset")
    else
        return stdio.color("yellow") .. `File {fileName} does not contain a Workspace instance.` .. stdio.color("reset")
    end
end

-- checks if file has valid extension
function isValidModelFile(fileName: string): boolean
    local ext = string.match(fileName, "%.([^%.]+)$")
    return ext == "rbxm" or ext == "rbxmx"
end

-- parse arguments for flags
local outputFile = nil
local directoryMode = false
local directoryPath = nil
local filesToProcess = {}

local i = 1
while i <= #args do
    local arg = args[i]
    
    if arg == "--o" or arg == "--output" then
        if i + 1 > #args then
            stdio.write(stdio.color("red"))
            stdio.write("Error: --o or --output flag requires an output filename.\n")
            stdio.write(stdio.color("reset"))
            process.exit(1)
        end
        outputFile = args[i + 1]
        i = i + 2
    elseif arg == "--directory" or arg == "--d" then
        if i + 1 > #args then
            stdio.write(stdio.color("red"))
            stdio.write("Error: --directory (or --d) flag requires a directory path.\n")
            stdio.write(stdio.color("reset"))
            process.exit(1)
        end
        directoryMode = true
        directoryPath = args[i + 1]
        i = i + 2
    else
        -- regular file argument
        if not directoryMode then
            table.insert(filesToProcess, arg)
        end
        i = i + 1
    end
end

-- check if output file already exists
if outputFile then
    if fs.isFile(outputFile) then
        stdio.write(stdio.color("red"))
        stdio.write(`Error: Output file {outputFile} already exists. Will not overwrite.\n`)
        stdio.write(stdio.color("reset"))
        process.exit(1)
    end
end

if directoryMode then
    -- check if directory exists
    if not fs.isDir(directoryPath) then
        stdio.write(stdio.color("red"))
        stdio.write(`Error: Directory {directoryPath} does not exist.\n`)
        stdio.write(stdio.color("reset"))
        process.exit(1)
    end
    
    -- read directory and collect .rbxm and .rbxmx files
    for _, file in pairs(fs.readDir(directoryPath)) do
        local fullPath = directoryPath .. "/" .. file
        if fs.isFile(fullPath) and isValidModelFile(file) then
            table.insert(filesToProcess, fullPath)
        end
    end
    
    if #filesToProcess == 0 then
        stdio.write(stdio.color("yellow"))
        stdio.write(`Warning: No .rbxm or .rbxmx files found in directory {directoryPath}.\n`)
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

local totalFiles = #filesToProcess
local filesWithWorkspace = {}
local processedFiles = 0

stdio.write(`Processing {totalFiles} file(s)...\n\n`)

for _, filePath in pairs(filesToProcess) do
    processedFiles = processedFiles + 1
    
    if fs.isFile(filePath) then
        if directoryMode or isValidModelFile(filePath) then
            local success, result = pcall(function()
                local fileContents = fs.readFile(filePath)
                return fileContainsWorkspace(fileContents)
            end)
            
            if success then
                if result then
                    table.insert(filesWithWorkspace, filePath)
                end
                print(formatResult(result, filePath))
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

-- write to output file
if outputFile then
    local outputContent = table.concat(filesWithWorkspace, "\n") .. "\n"
    fs.writeFile(outputFile, outputContent)
    stdio.write(`Output written to {outputFile}\n`)
end

-- print summary
stdio.write("\nFiles containing a Workspace instance:\n")
for _, file in pairs(filesWithWorkspace) do
    stdio.write(stdio.color("green"))
    stdio.write(`  {file}\n`)
    stdio.write(stdio.color("reset"))
end