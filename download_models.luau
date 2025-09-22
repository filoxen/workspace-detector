local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")

-- should be an open cloud api key with assetdelivery scope
local OPEN_CLOUD_API_KEY = process.env.OPEN_CLOUD_API_KEY
local BASE_API_URL = "https://apis.roblox.com/asset-delivery-api/v1/assetId/"

local download_models = {}

function download_models.downloadModel(assetId: number, fileName: string?): string?
    local response = net.request({
        url = BASE_API_URL .. assetId,
        method = "GET",
        headers = {["x-api-key"] = OPEN_CLOUD_API_KEY}
    })
    if response.ok then
        return response.body
    else
        return nil
    end
end

return download_models