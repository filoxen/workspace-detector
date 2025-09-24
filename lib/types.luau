-- custom type definitions

local types = {}

export type opts = {
    outputFile:          string?,
    directoryMode:       boolean,
    directoryPath:       string?,
    forceBinaryRead:     boolean,
    printInstanceNames:  boolean,
    zlibDecompressFiles: boolean,
    filesToProcess:      {string?}
}

export type model = {Instance}

return types