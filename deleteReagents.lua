local customRawTokens = require("custom-raw-tokens")

local disconnect_clutter

-- This is an onJobCompleted event listener
local function deleteReagents(job)
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
	
	local deleteAnyReagents = customRawTokens.getToken(reaction, "DELETE_REAGENTS")
	if not deleteAnyReagents then return end
	
	local function getReagentAndItsItem(reagentName)
		local reagentIndex, returnReagent
		for i, reagent in ipairs(reaction.reagents) do
			if reagent.code == reagentName then
				reagentIndex = i
				returnReagent = reagent
				break
			end
		end
		assert(reagentIndex, "Could not get reagent index for reagent " .. reagentName)
		for _, jobItemRef in ipairs(job.items) do
			if job.job_items[jobItemRef.job_item_idx].reagent_index == reagentIndex then
				return jobItemRef.item, returnReagent
			end
		end
		error("Could not find the appropriate input item for reagent " .. reagentName)
	end
	
	(function(...)
		for i = 1, select("#", ...) do
			local item, reagent = getReagentAndItsItem(select(i, ...))
			assert(item.stack_size >= reagent.quantity)
			disconnect_clutter(item)
		end
	end)(customRawTokens.getToken(reaction, "DELETE_REAGENTS"))
end

function disconnect_clutter(item)
    local bld = dfhack.items.getHolderBuilding(item)
    if not bld then return true end
    -- remove from contained items list, fail if not found
    local found = false
    for i,contained_item in ipairs(bld.contained_items) do
        if contained_item.item == item then
            bld.contained_items:erase(i)
            found = true
            break
        end
    end
    if not found then
        dfhack.printerr('failed to find clutter item in expected building')
        return false
    end
    -- remove building ref from item and move item into containing map block
    -- we do this manually instead of calling dfhack.items.moveToGround()
    -- because that function will cowardly refuse to work with items with
    -- BUILDING_HOLDER references (because it could crash the game). However,
    -- we know that this particular setup is safe to work with.
    for i,ref in ipairs(item.general_refs) do
        if ref:getType() == df.general_ref_type.BUILDING_HOLDER then
            item.general_refs:erase(i)
            -- this call can return failure, but it always succeeds in setting
            -- the required item flags and adding the item to the map block,
            -- which is all we care about here. dfhack.items.moveToBuilding()
            -- will fix things up later.
            item:moveToGround(item.pos.x, item.pos.y, item.pos.z)
            return true
        end
    end
    return false
end

return deleteReagents
