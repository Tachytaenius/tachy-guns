local customRawData = require("customRawData")

-- This is an onReactionComplete event listener
local function shellFiller(reaction, reaction_product, unit, input_items, input_reagents, output_items, call_native)
	if not customRawData.getTag(reaction, "SHELL_FILLING_REACTION") then
		return
	end
	
	-- TEMP: Pellets/shells refer to bullets/bullet casings too
	
	-- Destroy dummy boulder
	local dummy = output_items[0]
	while #dummy.general_refs > 0 do
		dummy.general_refs:erase(0)
	end
	while #dummy.specific_refs > 0 do
		dummy.specific_refs:erase(0)
	end
	assert(dfhack.items.moveToGround(dummy, dummy.pos), "Could not move dummy boulder to ground!!")
	assert(dfhack.items.remove(dummy), "Could not remove dummy boulder!!")
	
	local shell
	do -- Process input items (ie limit reagents to intended amount and get shell)
		local largestStack, totalPellets, desiredPellets
		
		local pelletReagent = reaction.reagents[0]
		desiredPellets = pelletReagent.quantity
		
		totalPellets = 0
		for i = 0, #input_items - 1 do
			local input = input_items[i]
			-- NOTE: If projectiles no longer have to be ammo, then add use a custom raw tag
			if input._type == df.item_ammost then -- if pellet._type ~= df.item_ammost then continue end >:(
				if customRawData.getTag(input.subtype, "AMMO_SHELL") then
					assert(not shell)
					shell = input
					
					-- Change subtype to fireable ammunition
					local newSubtypeName = customRawData.getTag(shell.subtype, "CONVERT_TO_FIREABLE", true)
					local defs = df.global.world.raws.itemdefs.ammo
					for i = 0, #defs - 1 do
						local itemDef = defs[i]
						if itemDef.id == newSubtypeName then
							shell:setSubtype(i)
						end
					end
					shell:calculateWeight()
					
					if shell.stack_size > 1 then
						shell:splitStack(shell.stack_size - 1, true)
					end
				else -- A pellet stack, then
					largestStack = largestStack or input
					largestStack = input.stack_size > largestStack.stack_size and input or largestStack
					totalPellets = totalPellets + input.stack_size
				end
			end
		end
		
		local excessPellets = totalPellets - desiredPellets
		if excessPellets > 0 then
			local rejectedStack = largestStack:splitStack(excessPellets, true)
		end
	end
	
	-- Move projectiles into shell
	for i = 0, #input_items - 1 do
		local pellet = input_items[i]
		if pellet._type == df.item_ammost and not customRawData.getTag(pellet.subtype, "AMMO_SHELL") then
			-- No specific refs (all prevent moveToContainer)
			local j = 0
			while #pellet.specific_refs < j do
				local ref = pellet.specific_refs[j]
				if ref.type == df.specific_ref_type.JOB then
					pellet.specific_refs:erase(i)
				else
					error("Specific ref (prevents moveToContainer) found on pellet. Type: " .. df.specific_ref_type[ref.type])
					j = j + 1
				end
			end
			
			-- No general refs that prevent moveToContainer
			local j = 0
			local buildingId
			while #pellet.general_refs < j do
				local ref = pellet.general_refs[j]
				local erase = true
				if ref:getType() == df.general_ref_type.BUILDING_HELD then
					buildingId = pellet.general_refs[i].building_id
					print(buildingId)
				elseif ref:getType() == df.general_ref_type.BUILDING_CAGED then
				elseif ref:getType() == df.general_ref_type.BUILDING_TRIGGER then
				elseif ref:getType() == df.general_ref_type.BUILDING_TRIGGERTARGET then
				elseif ref:getType() == df.general_ref_type.BUILDING_CIVZONE_ASSIGNED then
				else
					erase = false
				end
				if erase then
					pellet.general_refs:erase(i)
				else
					j = j + 1
				end
			end
			
			print(buildingId)
			if buildingId then
				local building = df.building.find(buildingId)
				for i = 0, #building.contained_items - 1 do
					if building.contained_items[i].item == pellet then
						building.contained_items:erase(i)
						break
					end
				end
			end
			
			pellet.flags.in_job = false
			pellet.flags.in_building = false
			pellet.flags.on_ground = true
			assert(dfhack.items.moveToContainer(pellet, shell), "Could not move projectile into shell!!")
		end
	end
end

return shellFiller
