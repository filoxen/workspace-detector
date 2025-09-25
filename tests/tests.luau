local fs = require("@lune/fs")
local process = require("@lune/process")
local core = require("../lib/core")
local compression = require("../lib/compression")


local containsWorkspaceDir = fs.readDir("./containsworkspace")
local containsWorkspaceTestsPassed = 0

for _, filePath in containsWorkspaceDir do
    local fileContents = fs.readFile("./containsworkspace/" .. filePath)
    local result = core.fileContainsWorkspace(fileContents, {
        forceBinaryRead = false,
        directoryMode = false,
        printInstanceNames = false,
        zlibDecompressFiles = false,
        zlibDecompressFilesRecursive = false
    })
    if result then
        containsWorkspaceTestsPassed += 1
    else
        print("Test failed for file: " .. filePath)
    end
end

local doesntContainWorkspaceDir = fs.readDir("./doesntcontainworkspace")
local doesntContainWorkspaceTestsPassed = 0

for _, filePath in doesntContainWorkspaceDir do
    local fileContents = fs.readFile("./doesntcontainworkspace/" .. filePath)
    local result = core.fileContainsWorkspace(fileContents, {
        forceBinaryRead = false,
        directoryMode = false,
        printInstanceNames = false,
        zlibDecompressFiles = false,
        zlibDecompressFilesRecursive = false
    })
    if not result then
        doesntContainWorkspaceTestsPassed += 1
    else
        print("Test failed for file: " .. filePath)
    end
end

local zlibCompressedDir = fs.readDir("./zlibCompressed")
local zlibCompressedTestsPassed = 0

for _, filePath in zlibCompressedDir do
    local fileContents = fs.readFile("./zlibCompressed/" .. filePath)
    local result = compression.zlibDecompress(fileContents, true)
    if result then
        zlibCompressedTestsPassed += 1
    else
        print("Test failed for file: " .. filePath)
    end
end

print(`Passed {containsWorkspaceTestsPassed}/{#containsWorkspaceDir} "contains workspace" tests.`)
print(`Passed {doesntContainWorkspaceTestsPassed}/{#doesntContainWorkspaceDir} "doesn't contain workspace" tests.`)
print(`Passed {zlibCompressedTestsPassed}/{#zlibCompressedDir} "zlib compressed" tests.`)

if containsWorkspaceTestsPassed == #containsWorkspaceDir and doesntContainWorkspaceTestsPassed == #doesntContainWorkspaceDir and zlibCompressedTestsPassed == #zlibCompressedDir then
    print("All tests passed!")
    process.exit(0)
else
    print("Some tests failed.")
    process.exit(1)
end