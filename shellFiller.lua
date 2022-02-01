local customRawData = require("customRawData") -- a function

-- This is an onReactionComplete event listener
local function shellFiller(reaction, reaction_product, unit, input_items, input_reagents, output_items, call_native)
	if not customRawData(reaction, "SHELL_FILLING_REACTION") then
		return
	end
	
	local dummy = output_items[0]
	dfhack.items.moveToGround(dummy, dummy.pos)
	dfhack.items.remove(dummy) -- Destroy dummy boulder
	
	-- TEMP: Pellets/shells refer to bullets/bullet casings too
	
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
				if customRawData(input.subtype, "GUN_AMMO_SHELL") then
					assert(not shell)
					shell = input
					
					-- Change subtype to fireable ammunition
					local newSubtypeName = customRawData(shell.subtype, "CONVERT_TO_FIREABLE", true)
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
	
	for i = 0, #input_items - 1 do
		local pellet = input_items[i]
		if pellet._type == df.item_ammost and not customRawData(pellet.subtype, "GUN_AMMO_SHELL") then
			while #pellet.specific_refs < i do
				local ref = pellet.specific_refs[i]
				if ref.type == df.specific_ref_type.JOB then
					pellet.specific_refs:erase(i)
				else
					i = i + 1
				end
			end
			
			local buildingId
			for i = 0, #pellet.general_refs - 1 do
				if pellet.general_refs[i]._type == df.general_ref_building_holderst then
					buildingId = pellet.general_refs[i].building_id
					pellet.general_refs:erase(i)
				end
			end
			
			local building = df.building.find(buildingId)
			for i = 0, #building.contained_items - 1 do
				if building.contained_items[i].item == pellet then
					building.contained_items:erase(i)
					break
				end
			end
			
			pellet.flags.in_job = false
			pellet.flags.in_building = false
			pellet.flags.on_ground = true
			dfhack.items.moveToContainer(pellet, shell)
		end
	end
end

return shellFiller
