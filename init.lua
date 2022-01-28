-- TODO: Record rationale for perturbations and inaccuracy quantities!

-- NOTE/TODO: prefix event listener names?

local eventful = require("plugins.eventful")
local utils = require("utils")

local gravity = 4900 -- game's own value
local vectorLength = 100 -- Due to integer-only target locations

local customRaws = {}
eventful.onUnload.clearExtractedCustomRawData = function()
	customRaws = {}
end

-- The varargs is for booleans saying whether each argument should be converted to a number
local function customRawData(typeDefinition, tag, ...)
	-- TODO/if needed: more advanced raw constructs
	
	-- Have we got a table for this item subtype/reaction/whatever?
	local customRawTable = customRaws[typeDefinition]
	if not customRawTable then
		customRawTable = {}
		customRaws[typeDefinition] = customRawTable
	end
	
	-- Have we already extracted and stored this custom raw tag for this type definition?
	local tagData = customRawTable[tag]
	if tagData ~= nil then
		if tagData then
			return true, table.unpack(tagData)
		else
			return false -- which will be the value of tagData
		end
	end
	
	-- Get data anew
	local rawStrings = typeDefinition.raw_strings -- make this depend on typeDefinition._type as needed
	for _, v in ipairs(rawStrings) do
		local noBrackets = v.value:sub(2, -2)
		local iter = noBrackets:gmatch("[^:]*")
		if tag == iter() then
			local args = {}
			for arg in iter do
				local isNum = select(#args+1, ...)
				if isNum then
					arg = tonumber(arg)
				end
				args[#args+1] = arg
			end
			customRawTable[tag] = args
			return true, table.unpack(args)
		end
	end
	return false
end

eventful.onProjItemCheckMovement.gunProjectileManager = function(projectile)
	if projectile.distance_flown > 0 then
		return
	end
	
	local firer = projectile.firer
	if not projectile.firer then
		return
	end
	
	local gun = df.item.find(projectile.bow_id)
	if gun._type == df.item_weaponst then
		if not customRawData(gun.subtype, "GUN") then
			return
		end
	end
	
	firer.counters.think_counter = select(2, customRawData(gun.subtype, "FIRE_TIME", true))
	
	if projectile.item._type == df.item_ammost then
		if not customRawData(projectile.item.subtype, "GUN_AMMO") then
			return
		end
	end
	
	local function perturbDirection(spread, opos, tpos)
		if tpos.x==opos.x and tpos.y==opos.y then return end
		local dirX, dirY = tpos.x-opos.x, tpos.y-opos.y
		local angle = math.atan(dirY, dirX)
		angle = angle + math.random() * spread - spread / 2
		dirX, dirY = math.cos(angle), math.sin(angle)
		tpos.x, tpos.y = opos.x+math.floor(dirX*vectorLength), opos.y+math.floor(dirY*vectorLength)
	end
	
	local gunDirectionSpread = 0 -- not having a scope, maybe? but i don't see why that should make the user less accurate than a crossbow without a scope. maybe for firing on auto for too long
	perturbDirection(gunDirectionSpread, projectile.origin_pos, projectile.target_pos)
	
	local mainProjectileIsShell = customRawData(projectile.item.subtype, "GUN_AMMO_SHELL")
	local _, ammoInaccuracy = customRawData(projectile.item.subtype, "INACCURACY", true)
	ammoInaccuracy = ammoInaccuracy or 0
	if not mainProjectileIsShell then
		-- Make sure the INACCURACY tag works on ammo that isn't a shell
		-- perturbing twice by spreads a and b is not equivalent to perturbing once by a + b
		perturbDirection(ammoInaccuracy, projectile.origin_pos, projectile.target_pos)
	end
	
	if mainProjectileIsShell then
		local subProjectileItems = {}
		local containedItems = dfhack.items.getContainedItems(projectile.item)
		
		-- Split sub-projectile stacks
		for _, containedItem in ipairs(containedItems) do
			while containedItem.stack_size > 1 do
				subProjectileItems[#subProjectileItems+1] = containedItem:splitStack(1, true)
			end
			subProjectileItems[#subProjectileItems+1] = containedItem
		end
		
		-- Handle sub-projectiles
		for _, subProjectileItem in ipairs(subProjectileItems) do
			local subProjectile = dfhack.items.makeProjectile(subProjectileItem)
			subProjectile.firer = projectile.firer
			subProjectile.origin_pos = utils.clone(projectile.origin_pos)
			subProjectile.target_pos = utils.clone(projectile.target_pos)
			subProjectile.cur_pos = utils.clone(projectile.cur_pos)
			subProjectile.prev_pos = utils.clone(projectile.prev_pos)
			subProjectile.fall_threshold = projectile.fall_threshold
			subProjectile.min_hit_distance = projectile.min_hit_distance
			subProjectile.min_ground_distance = projectile.min_ground_distance
			subProjectile.bow_id = projectile.bow_id
			subProjectile.unk21 = projectile.unk21
			subProjectile.unk22 = projectile.unk22
			subProjectile.hit_rating = projectile.hit_rating
			subProjectile.unk_v40_1 = projectile.unk_v40_1
			
			local _, gunInaccuracy = customRawData(gun.subtype, "INACCURACY", true)
			gunInaccuracy = gunInaccuracy or 0
			perturbDirection(gunInaccuracy + ammoInaccuracy, subProjectile.origin_pos, subProjectile.target_pos)
		end
		
		--[[
		-- Destroy the shell
		projectile.target_pos.x = -30000 -- , -30000, -30000
		projectile.origin_pos.x = -30000
		projectile.cur_pos.x = -30000
		projectile.flags.to_be_deleted = true
		]]
		
		-- Handle proper spent shell behaviour (Cases where this behaviour breaks down have yet to be seen)
		-- This does not turn the shell back into an item, it turns it into a broken projectile
		local tpos, opos = projectile.target_pos, projectile.origin_pos
		tpos.x,tpos.y,tpos.z=opos.x,opos.y,opos.z
		projectile.unk_v40_1 = -1
		projectile.firer = nil
		projectile.bow_id = -1
	end
end

eventful.onReactionComplete.shellFiller = function(reaction, reaction_product, unit, input_items, input_reagents, output_items, call_native)
	if not customRawData(reaction.code, "SHELL_FILLING_REACTION") then
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
			if input._type == df.item_ammost then -- if pellet._type ~= df.item_ammost then continue end >:(
				if customRawData(input.subtype, "GUN_AMMO_SHELL") then
					assert(not shell)
					shell = input
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
			while #pellet.specific_refs > 0 do
				pellet.specific_refs:erase(0)
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
