-- handles cli argument parsing and usage printing
local process = require("@lune/process")
local stdio = require("@lune/stdio")
local fs = require("@lune/fs")
local types = require("./types")

export type CLI = {
    parseArgs: () -> types.opts,
    printUsage: () -> (),
    checkOutputFile: (outputFile: string?) -> ()
}

local cli = {} :: CLI

-- parses command line arguments into options
function cli.parseArgs(): types.opts    
    local args = process.args
    local opts = {
        outputFile = nil,
        directoryMode = false,
        directoryPath = nil,
        forceBinaryRead = false,
        printInstanceNames = false,
        zlibDecompressFiles = false,
        filesToProcess = {}
    }
    if #args < 1 then
        cli.printUsage()
        process.exit(1)
    end
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
            opts.outputFile = args[i + 1]
            i = i + 2
        elseif arg == "--directory" or arg == "--d" then
            if i + 1 > #args then
                stdio.write(stdio.color("red"))
                stdio.write("Error: --directory (or --d) flag requires a directory path.\n")
                stdio.write(stdio.color("reset"))
                process.exit(1)
            end
            opts.directoryMode = true
            opts.directoryPath = args[i + 1]
            i = i + 2
        elseif arg == "--force-binary-read" then
            opts.forceBinaryRead = true
            i = i + 1
        elseif arg == "--print-instance-names" then
            opts.printInstanceNames = true
            i = i + 1
        elseif arg == "--zlib-decompress" then
            opts.zlibDecompressFiles = true
            i = i + 1
        else
            if not opts.directoryMode then
                table.insert(opts.filesToProcess, arg)
            end
            i = i + 1
        end
    end
    return opts
end

-- prints usage instructions for the command line tool
function cli.printUsage()
    stdio.write(stdio.color("red"))
    stdio.write("Error: Please provide file path(s) or use --directory flag.\n")
    stdio.write("Usage: lune run detector file1.rbxm file2.rbxm file3.rbxmx\n")
    stdio.write("       lune run detector --directory path/to/folder\n")
    stdio.write("       lune run detector --d path/to/folder\n")
    stdio.write("       lune run detector --o output.txt file1.rbxm file2.rbxm\n")
    stdio.write("       lune run detector --output output.txt file1.rbxm file2.rbxm\n")
    stdio.write("       lune run detector --directory path/to/folder --o output.txt\n")
    stdio.write("       lune run detector --force-binary-read file1 file2.bin file3.robloxmodelfile\n")
    stdio.write("       lune run detector --print-instance-names file1.rbxm\n")
    stdio.write("       lune run detector --zlib-decompress file1.rbxm\n")
    stdio.write(stdio.color("reset"))
end

-- checks if output file exists to prevent overwriting
function cli.checkOutputFile(outputFile: string?)
    if outputFile and fs.isFile(outputFile) then
        stdio.write(stdio.color("red"))
        stdio.write(`Error: Output file {outputFile} already exists. Will not overwrite.\n`)
        stdio.write(stdio.color("reset"))
        process.exit(1)
    end
end

return cli
