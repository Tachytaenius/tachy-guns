--@ module = true

local customRawTokens = require("custom-raw-tokens")

function onReactionComplete(reaction, reactionProduct, unit, inputItems, inputReagents, outputItems)
	if not customRawTokens.getToken(reaction, "TACHY_GUNS_TRANSFER_HANDLE_MATERIAL_TO_PRODUCT_IMPROVEMENT") then return end

	local product = tonumber(customRawTokens.getToken(reaction, "TACHY_GUNS_TRANSFER_HANDLE_MATERIAL_TO_PRODUCT_IMPROVEMENT")) or 1

	for i, reagent in ipairs(inputReagents) do
		if reagent.code:sub(1, #"handle") == "handle" then
			-- Found handle reagent
			local item = inputItems[i] -- hopefully found handle item
			local new = df.itemimprovement_itemspecificst:new()
			new.mat_type, new.mat_index = item.mat_type, item.mat_index
			-- new.maker = outputItems[0].maker -- not a typical improvement
			new.type = df.itemimprovement_specific_type.HANDLE
			outputItems[product - 1].improvements:insert("#", new)
			-- break -- multiple handles, multiple "the handle is made from"s
		end
	end
end
