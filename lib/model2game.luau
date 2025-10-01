-- converts a model with a workspace into a .rbxl file
local roblox = require("@lune/roblox")
local types = require("./types")

export type Model2Game = {
    convert: (model: types.model) -> string | false
}

local model2game = {} :: Model2Game

function model2game.convert(model: types.model): string | false
    for _, instance: Instance in pairs(model) do
        if instance:IsA("Workspace") then
            print("Found workspace, converting to game...")
            local gameModel = roblox.Instance.new("DataModel")
            print("Created DataModel")
            instance.Parent = gameModel
            print("Serializing game model...")
            return roblox.serializePlace(gameModel, true)
        end
    end
    return false
end

return model2game