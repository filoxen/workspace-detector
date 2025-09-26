local fs = require("@lune/fs")
local process = require("@lune/process")
local core = require("../lib/core")
local compression = require("../lib/compression")
local types = require("../lib/types")


function testFolder(callback: (file: string, opts: types.opts) -> string | boolean, opts: types.opts, folderPath: string): {boolean}
    local results = {}
    local folder = fs.readDir(folderPath)
    for _, file in pairs(folder) do
        local filePath = `./{folderPath}/{file}`
        local fileContents = fs.readFile(filePath)
        local result = callback(fileContents, opts)
        results[file] = result
    end
    return results
end

local containsWorkspaceTest = testFolder(core.fileContainsWorkspace, {outputFile = nil, directoryMode = false, directoryPath = nil, forceBinaryRead = false, printInstanceNames = false, zlibDecompressFiles = false, zlibDecompressFilesRecursive = false, filesToProcess = nil} , "containsworkspace")

for fileName, result in pairs(containsWorkspaceTest) do
    if not result then
        print(`Test failed: {fileName} should contain a workspace instance.`)
        process.exit(1)
    end
end
print("All tests passed for files in containsworkspace.")

local doesntContainWorkspaceTest = testFolder(core.fileContainsWorkspace, {outputFile = nil, directoryMode = false, directoryPath = nil, forceBinaryRead = false, printInstanceNames = false, zlibDecompressFiles = false, zlibDecompressFilesRecursive = false, filesToProcess = nil}, "doesntcontainworkspace")
for fileName, result in pairs(doesntContainWorkspaceTest) do
    if result then
        print(`Test failed: {fileName} shouldn't contain a workspace instance.`)
        process.exit(1)
    end
end
print("All tests passed for files in doesntcontainworkspace.")

local zlibDecompressedTest = testFolder(compression.zlibDecompress, {outputFile = nil, directoryMode = false, directoryPath = nil, forceBinaryRead = false, printInstanceNames = false, zlibDecompressFiles = false, zlibDecompressFilesRecursive = true, filesToProcess = nil}, "zlibCompressed")

for fileName, result in pairs(zlibDecompressedTest) do
    if not result then
        print(`Test failed: {fileName} should be zlib decompressed successfully.`)
        process.exit(1)
    end
end
print("All tests passed for zlib decompression.")
print("All tests passed.")