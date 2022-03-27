local customRawTokens = require("custom-raw-tokens")
local repeatUtil = require("repeat-util")

local disconnect_clutter

-- This is an onJobCompleted event listener
local function shellFiller(job)
	assert(job.completion_timer == 0, job.completion_timer)
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
	if not customRawTokens.getToken(reaction, "SHELL_FILLING_REACTION") then return end
	
	local shellStack
	local freeProjectileStackPool = {}
	for _, jobItemRef in ipairs(job.items) do
		if jobItemRef.role == 1 then -- role 1 is reagent
			if job.job_items[jobItemRef.job_item_idx].item_type == df.item_type.AMMO then
				local itemStack = jobItemRef.item
				if customRawTokens.getToken(itemStack, "AMMO_SHELL") then
					assert(not shellStack)
					shellStack = itemStack
				elseif df.is_instance(df.item_ammost, itemStack) then
					table.insert(freeProjectileStackPool, itemStack)
				end
			end
		end
	end
	disconnect_clutter(shellStack)
	if shellStack.stack_size > 1 then
		shellStack = shellStack:splitStack(1, true)
	end
	
	local newSubtypeName = customRawTokens.getToken(shellStack, "CONVERT_TO_FIREABLE")
	local ammoItemDefs = df.global.world.raws.itemdefs.ammo
	for i = 0, #ammoItemDefs - 1 do
			local itemDef = ammoItemDefs[i]
		if itemDef.id == newSubtypeName then
			shellStack:setSubtype(i)
		end
	end
	shellStack:calculateWeight()
	
	local projectileStacksToMove = {}
	for _, reagent in ipairs(reaction.reagents) do
		if reagent.item_type == df.item_type.AMMO and not customRawTokens.getToken(ammoItemDefs[reagent.item_subtype], "AMMO_SHELL") then
			local amountRequired, amountAcquired = reagent.quantity, 0
			local i = 1
			while i <= #freeProjectileStackPool and amountAcquired < amountRequired do
				local next = true
				local stack = freeProjectileStackPool[i]
				if reagent:matchesRoot(stack, reactionNumber) then
					disconnect_clutter(stack)
					local amountToTake = math.min(stack.stack_size, amountRequired - amountAcquired)
					if amountToTake == stack.stack_size then
						assert(stack == table.remove(freeProjectileStackPool, i))
						table.insert(projectileStacksToMove, stack)
						next = false
					else
						table.insert(projectileStacksToMove, stack:splitStack(amountToTake, true))
					end
					amountAcquired = amountAcquired + amountToTake
				end
				if next then
					i = i + 1
				end
			end
			assert(amountAcquired == amountRequired, "Amount acquired, amount required: " .. amountAcquired .. ", " .. amountRequired)
		end
	end
	
	for _, projectileStack in ipairs(projectileStacksToMove) do
		disconnect_clutter(projectileStack)
		dfhack.items.moveToContainer(projectileStack, shellStack)
	end
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

return shellFiller
