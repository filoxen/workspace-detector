-- custom type definitions

local types = {}

--[[
    Options table type definition.

    Will contain these values:
    * `outputFile` - The path to the output file, if specified
    * `directoryMode` - Whether to operate in directory mode
    * `directoryPath` - The path to the directory to scan, if in directory mode
    * `forceBinaryRead` - Whether to force reading files even if they lack file extensions
    * `printInstanceNames` - Whether to print the names of all instances in the models scanned
    * `zlibDecompressFiles` - Whether to decompress zlib-compressed files
    * `zlibDecompressFilesRecursive` - Whether to recursively decompress zlib-compressed files
    * `filesToProcess` - A list of file paths to process
    ]]--
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

--[[
    Callback function type definition.

    A function that takes a file path and options table, and returns either a string (e.g. processed data) or false on failure.

    @param file The path to the file to process.
    @param opts Options table of type `types.opts`
    @return A string containing processed data, or false if processing fails.
]]--
export type callbackFunction = (file: string, opts: opts) -> string | boolean

return types