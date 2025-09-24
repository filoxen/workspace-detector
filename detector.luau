-- main entry point
local cli = require("./lib/cli")
local fileproc = require("./lib/fileproc")
local fs = require("@lune/fs")
local stdio = require("@lune/stdio")

local opts = cli.parseArgs()
cli.checkOutputFile(opts.outputFile)

local filesToProcess = fileproc.collectFiles(opts)
local totalFiles = #filesToProcess
stdio.write(`Processing {totalFiles} file(s)...\n\n`)
local filesWithWorkspace = fileproc.processFiles(filesToProcess, opts)

if opts.outputFile then
    local outputContent = table.concat(filesWithWorkspace, "\n") .. "\n"
    fs.writeFile(opts.outputFile, outputContent)
    stdio.write(`Output written to {opts.outputFile}\n`)
end

stdio.write("\nFiles containing a Workspace instance:\n")
for _, file in pairs(filesWithWorkspace) do
    stdio.write(stdio.color("green"))
    stdio.write(`  {file}\n`)
    stdio.write(stdio.color("reset"))
end