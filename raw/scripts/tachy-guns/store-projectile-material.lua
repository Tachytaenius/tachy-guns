--@ module = true

local customRawTokens = require("custom-raw-tokens")

local consts = dfhack.reqscript("tachy-guns/consts")

function onReactionComplete(reaction, reactionProduct, unit, inputItems, inputReagents, outputItems)
	if not customRawTokens.getToken(reaction, "TACHY_GUNS_STORE_PROJECTILE_MATERIAL") then return end
	
	local reagentName, productIndex = customRawTokens.getToken(reaction, "TACHY_GUNS_STORE_PROJECTILE_MATERIAL")
	productIndex = tonumber(productIndex) or 1
	
	for i, reagent in ipairs(inputReagents) do
		if reagent.code == reagentName then
			-- Found reagent
			local item = inputItems[i] -- hopefully found item
			local new = df.itemimprovement_itemspecificst:new()
			new.mat_type, new.mat_index = item.mat_type, item.mat_index
			-- new.maker = outputItems[0].maker -- not a typical improvement
			new.type = consts.ammoMaterialItemSpecificImprovementType
			outputItems[productIndex - 1].improvements:insert("#", new)
			return
		end
	end
	error("Could not find reagent " .. reagentName)
end
