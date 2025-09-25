local serde = require("@lune/serde")

type CompressionModule = {
    zlibDecompress: (contents: string, recursive: boolean?) -> string | boolean
}

local compressionModule = {} :: CompressionModule


-- take in file contents and zlib decompress them
-- if recursive param is true repeatedly zlib decompress the file until it fails
-- (modelscrape files are often double/triple zlib decompressed)
function compressionModule.zlibDecompress(contents: string, recursive: boolean?): string | boolean
    assert(typeof(contents) == "string", "Expected contents to be of type 'string'")
    if recursive == nil then recursive = false end
    assert(typeof(recursive) == "boolean", "Expected recursive to be of type 'boolean'")
    local success, decompressed: string = pcall(function() return serde.decompress("zlib", contents) end)
    if not success then
        return false
    end
    if recursive then
        local nextDecompressed = compressionModule.zlibDecompress(decompressed, true)
        while nextDecompressed do
            decompressed = nextDecompressed
            nextDecompressed = compressionModule.zlibDecompress(decompressed, true)
        end
    end
    return decompressed
end

return compressionModule