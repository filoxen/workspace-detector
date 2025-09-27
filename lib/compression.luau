local serde = require("@lune/serde")
local types = require("./types")

type CompressionModule = {
    zlibDecompress: (contents: string, recursive: boolean?) -> string | boolean
}

local compressionModule = {} :: CompressionModule


--[[
    Decompresses zlib-compressed data. If recursive is true, continues to decompress until data is no longer zlib-compressed.

    ### Example usage

    ```lua
    local fs = require("@lune/fs")
    local compression = require("./compression")

    local compressedData = fs.readFile("compressedFile.bin")
    local decompressedData = compression.zlibDecompress(compressedData, true)
    if decompressedData then
        print("Decompression successful.")
    else
        print("Decompression failed.")
    end
    ```

    @param contents The zlib-compressed data as a string.
    @param opts Options table of type `types.opts`
    @return The decompressed data as a string, or false if decompression fails.
]]--
function compressionModule.zlibDecompress(contents: string,  opts: types.opts): string | boolean
    assert(typeof(contents) == "string", "Expected contents to be of type 'string'")
    assert(typeof(opts) == "table", "Expected opts to be of type 'table'")
    local success, decompressed: string = pcall(function() return serde.decompress("zlib", contents) end)
    if not success then
        return false
    end
    if opts.zlibDecompressFilesRecursive then
        local nextDecompressed = compressionModule.zlibDecompress(decompressed, opts)
        while nextDecompressed do
            decompressed = nextDecompressed
            nextDecompressed = compressionModule.zlibDecompress(decompressed, opts)
        end
    end
    return decompressed
end

return compressionModule