-- custom type definitions

local types = {}

export type opts = {
    outputFile:                   string?,
    directoryMode:                boolean,
    directoryPath:                string?,
    forceBinaryRead:              boolean,
    printInstanceNames:           boolean,
    zlibDecompressFiles:          boolean,
    zlibDecompressFilesRecursive: boolean,
    filesToProcess:               {string?}
}

export type model = {Instance}

export type callbackFunction = (file: string, opts: opts) -> string | boolean

return types