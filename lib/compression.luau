local serde = require("@lune/serde")
local types = require("./types")

type CompressionModule = {
    zlibDecompress: (contents: string, recursive: boolean?) -> string | boolean
}

local compressionModule = {} :: CompressionModule


-- take in file contents and zlib decompress them
-- if recursive param is true repeatedly zlib decompress the file until it fails
-- (modelscrape files are often double/triple zlib decompressed)
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