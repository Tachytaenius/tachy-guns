local customRawTokens = require("custom-raw-tokens")

local function changeSubtype(item, newSubtypeName)
	local defs = df.global.world.raws.itemdefs.all
	for i, itemDef in ipairs(defs) do
		if itemDef.id == newSubtypeName then
			item:setSubtype(itemDef.subtype)
			break
		end
	end
	item:calculateWeight()
end

-- This is an onJobCompleted event listener
local function typeTransform(job)
	if not job.reaction_name then return end
	if job.reaction_name == "" then return end
	if job.job_type ~= df.job_type.CustomReaction then return end
	local reaction, reactionNumber
	for i, reactionRaw in ipairs(df.global.world.raws.reactions.reactions) do
		if job.reaction_name == reactionRaw.code then
			reaction, reactionNumber = reactionRaw, i
			break
		end
	end
	if not reaction then return end
	
	local reagentName, transformTo = customRawTokens.getToken(reaction, "TACHY_GUNS_ITEM_SUBTYPE_TRANSFORM")
	if not reagentName then return end
	
	local reagentIndex
	for i, reagent in ipairs(reaction.reagents) do
		if reagent.code == reagentName then
			reagentIndex = i
			break
		end
	end
	assert(reagentIndex, "Could not get reagent index for reagent " .. reagentName)
	for _, jobItemRef in ipairs(job.items) do
		if job.job_items[jobItemRef.job_item_idx].reagent_index == reagentIndex then
			local itemToTransform = jobItemRef.item
			changeSubtype(itemToTransform, transformTo)
			return
		end
	end
	error("Could not find the appropriate input item for reagent " .. reagentName)
end

return typeTransform
