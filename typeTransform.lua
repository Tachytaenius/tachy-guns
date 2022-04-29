local customRawTokens = require("custom-raw-tokens")

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
	
	local reagent, transformTo = customRawTokens.getToken(reaction, "ITEM_SUBTYPE_TRANSFORM")
	if not transformTo then return end
	
	-- TODO: item type change
	-- TODO: specify which reagent
	-- TODO: this at all
end
