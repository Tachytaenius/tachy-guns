local customRawTokens = require("custom-raw-tokens")
local persistTable = require("persist-table")

-- This is an onJobCompleted event listener
local function storeProjectileMaterial(job)
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
	
	local projectileReagentName, casingReagentName = customRawTokens.getToken(reaction, "STORE_PROJECTILE_MATERIAL")
	if not projectileReagentName or not casingReagentName then return end
	
	local function getReagentItem(reagentName)
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
				return jobItemRef.item
			end
		end
		error("Could not find the appropriate input item for reagent " .. reagentName)
	end
	
	local projectile = getReagentItem(projectileReagentName)
	local casing = getReagentItem(casingReagentName)
	casing.improvements:insert("#", {
		new = true,
		mat_type = projectile.mat_type,
		mat_index = projectile.mat_index
	})
end

return storeProjectileMaterial
