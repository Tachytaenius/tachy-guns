-- TODO: Record rationale for perturbations and inaccuracy quantities
-- TODO: Clean up code to make projectile/subProjectile uses consistent and disctinctions clearer

-- NOTE: Enabling piercing on projectiles will cause them to destroy trees. So I've opted to not do that.

local utils = require("utils")
local customRawTokens = require("custom-raw-tokens")

local consts = dfhack.run_script("gunMod/consts")
local exhaustionRecord = dfhack.reqscript("gunMod/exhaustionRecord")

local function getSubtypeItemDefByName(subtypeName)
	local defs = df.global.world.raws.itemdefs.all
	for i, itemDef in ipairs(defs) do
		if itemDef.id == subtypeName then
			return itemDef
		end
	end
end

local function changeSubtype(item, newSubtypeName)
	local itemDef = getSubtypeItemDefByName(newSubtypeName)
	item:setSubtype(itemDef.subtype)
	item:calculateWeight()
end

-- this is an onProjItemCheckMovement event listener
local function gunProjectileManager(projectile)
	if projectile.distance_flown > 0 then
		return
	end
	
	if projectile.flags[consts.skipProcessingProjectileFlagKey] then
		return
	end
	
	local firer = projectile.firer
	if not projectile.firer then
		return
	end
	
	local gun = df.item.find(projectile.bow_id)
	if gun and gun._type == df.item_weaponst then
		if not customRawTokens.getToken(gun.subtype, "GUN") then
			return
		end
	else
		return
	end
	
	firer.counters.think_counter = tonumber(customRawTokens.getToken(gun.subtype, "FIRE_TIME")) or firer.counters.think_counter
	
	-- Exhaustion multiplier
	local previousExhaustion = exhaustionRecord.exhaustionTable[firer.id]
	if previousExhaustion then
		local deltaExhaustion = firer.counters2.exhaustion - previousExhaustion
		print(deltaExhaustion)
		deltaExhaustion = deltaExhaustion * tonumber(customRawTokens.getToken(gun.subtype, "FIRE_EXHAUSTION_MULTIPLIER")) or 1
		print(deltaExhaustion)
		print(firer.counters2.exhaustion)
		firer.counters2.exhaustion = previousExhaustion + math.floor(deltaExhaustion)
		print(firer.counters2.exhaustion)
		print("")
	end
	
	-- Change experience gain
	local fireExperienceGain = tonumber(customRawTokens.getToken(gun.subtype, "FIRE_XP_GAIN")) or consts.defaultFireExperienceGain
	local amount = fireExperienceGain - consts.defaultFireExperienceGain
	local valueString = tostring(amount)
	if amount < 0 then
		valueString	= "\\" .. valueString
	end
	dfhack.run_script("modtools/skill-change", "-mode", "add", "-skill", "RANGED_COMBAT", "-granularity", "experience", "-unit", tostring(firer.id), "-value", valueString)
	local weaponSkill = df.job_skill[gun.subtype.skill_ranged]
	if weaponSkill then
		dfhack.run_script("modtools/skill-change", "-skill", weaponSkill, "-granularity", "experience", "-unit", tostring(firer.id), "-value", valueString)
	end
	
	if projectile.item._type == df.item_ammost then
		if not customRawTokens.getToken(projectile.item.subtype, "GUN_AMMO") then
			return
		end
	end
	
	local gunDirectionSpread = 0 -- TODO: not having a scope, maybe? but i don't see why that should make the user less accurate than a crossbow without a scope. maybe for firing on auto for too long. Scope could increase hit_rating while firing on auto or other not-in-common-with-crossbow accuracy-reducing effects are here
	local gunDirectionAngle = (math.random() - 0.5) * gunDirectionSpread
	
	local mainProjectileWear = projectile.item.wear
	
	local ammoInaccuracy = tonumber(customRawTokens.getToken(projectile.item.subtype, "INACCURACY")) or 0
	local gunInaccuracy = tonumber(customRawTokens.getToken(gun.subtype, "INACCURACY")) or 0
	local projectileInaccuracy = ammoInaccuracy + gunInaccuracy
	local gunRange = tonumber(customRawTokens.getToken(projectile.item.subtype, "RANGE") or 20)
	local ammoRange = tonumber(customRawTokens.getToken(projectile.item.subtype, "RANGE") or 20)
	local projectileRange = gunRange + ammoRange
	local mainProjectileIsShell = customRawTokens.getToken(projectile.item.subtype, "CONTAINED_PROJECTILE")
	
	if mainProjectileIsShell then
		-- Hack into old projecitles-as-contained-items behaviour and add projectiles as contained items
		local containedProjectileSubtypeName, containedProjectileCount = customRawTokens.getToken(projectile.item.subtype, "CONTAINED_PROJECTILE")
		local mat_type, mat_index = projectile.item.mat_type, projectile.item.mat_index
		-- try to find improvement representing contained projectile's material
		for i, improvement in ipairs(projectile.item.improvements) do
			if improvement._type == df.itemimprovement_itemspecificst then
				if improvement.type == consts.ammoMaterialItemSpecificImprovementType then
					mat_type, mat_index = improvement.mat_type, improvement.mat_index
					projectile.item.improvements:erase(i)
					break
				end
			end
		end
		local containedProjectile = dfhack.items.createItem(df.item_type.AMMO, getSubtypeItemDefByName(containedProjectileSubtypeName).subtype, mat_type, mat_index, firer)
		-- containedProjectile isn't actually returned from dfhack.items.createItem??
		containedProjectile = df.global.world.items.all[#df.global.world.items.all-1]
		containedProjectile.stack_size = containedProjectileCount
		containedProjectile:calculateWeight()
		containedProjectile.maker, containedProjectile.maker_race = projectile.item.maker, projectile.item.maker_race
		containedProjectile.quality, containedProjectile.skill_rating = projectile.item.quality, projectile.item.skill_rating
		containedProjectile.flags.foreign = projectile.item.flags.foreign
		containedProjectile.flags.trader = projectile.item.flags.trader
		containedProjectile.flags.trader = projectile.item.flags.trader
		containedProjectile.flags.forbid = projectile.item.flags.forbid
		containedProjectile.flags.forbid = projectile.item.flags.forbid
		containedProjectile:setSharpness(containedProjectile.quality, 0)
		assert(dfhack.items.moveToContainer(containedProjectile, projectile.item), "Failed to move projectile into shell.")
	end
	
	local function handleOutputProjectile(projectile)
		local projectileAngle = (math.random() - 0.5) * projectileInaccuracy
		local perturbationAngle = gunDirectionAngle + projectileAngle
		
		-- Perturb projectile direction
		local opos, tpos = projectile.origin_pos, projectile.target_pos
		if not (tpos.x==opos.x and tpos.y==opos.y) then -- no angle for (0,0)
			-- Get vector of length perturbedVectorLength facing in direction tpos-opos
			local x, y, z = tpos.x-opos.x, tpos.y-opos.y, tpos.z-opos.z
			local mag = math.sqrt(x^2+y^2+z^2)
			x, y, z = x * consts.perturbedVectorLength / mag, y * consts.perturbedVectorLength / mag, z * consts.perturbedVectorLength / mag
			-- Handle x y angle change
			local angle = math.atan(y, x) + perturbationAngle
			x, y = math.cos(angle) * consts.perturbedVectorLength, math.sin(angle) * consts.perturbedVectorLength
			-- Rewrite vector
			tpos.x, tpos.y, tpos.z = math.floor(x) + opos.x, math.floor(y) + opos.y, math.floor(z) + opos.z
		end
		
		local wear = mainProjectileWear
		if mainProjectileIsShell then
			wear = wear + projectile.item.wear -- else wear is wear as we're dealing with the same projectile as above
		end
		projectileRange = projectileRange / ((wear / 2) + 1) -- divison by two lessens the effect, but the addition by one is necessary because wear starts at 0
		projectile.hit_rating = projectile.hit_rating / ((wear / 4) + 1)
		projectile.fall_threshold = projectileRange
		-- if projectile.flags.parabolic then
	end
	
	if not mainProjectileIsShell then
		-- shorter one first
		handleOutputProjectile(projectile)
	else
		local subProjectileItems = {}
		local containedItems = dfhack.items.getContainedItems(projectile.item)
		
		-- Split sub-projectile stacks
		for _, containedItem in ipairs(containedItems) do
			while containedItem.stack_size > 1 do
				newStack = containedItem:splitStack(1, true)
				newStack:categorize(true)
				subProjectileItems[#subProjectileItems+1] = newStack
			end
			subProjectileItems[#subProjectileItems+1] = containedItem
		end
		
		-- Handle sub-projectiles
		for _, subProjectileItem in ipairs(subProjectileItems) do
			local subProjectile = dfhack.items.makeProjectile(subProjectileItem)
			subProjectile.flags[consts.skipProcessingProjectileFlagKey] = true
			subProjectile.firer = projectile.firer
			subProjectile.origin_pos = utils.clone(projectile.origin_pos)
			subProjectile.target_pos = utils.clone(projectile.target_pos)
			subProjectile.cur_pos = utils.clone(projectile.cur_pos)
			subProjectile.prev_pos = utils.clone(projectile.prev_pos)
			subProjectile.fall_threshold = projectile.fall_threshold
			subProjectile.fall_counter = projectile.fall_counter
			subProjectile.fall_delay = projectile.fall_delay
			subProjectile.min_hit_distance = projectile.min_hit_distance
			subProjectile.min_ground_distance = projectile.min_ground_distance
			subProjectile.bow_id = projectile.bow_id
			subProjectile.unk21 = projectile.unk21
			subProjectile.unk22 = projectile.unk22
			subProjectile.hit_rating = projectile.hit_rating
			subProjectile.unk_v40_1 = projectile.unk_v40_1
			handleOutputProjectile(subProjectile)
		end
		
		-- Handle proper spent shell behaviour
		local newSubtypeName = customRawTokens.getToken(projectile.item.subtype, "CONVERT_TO_UNFIREABLE", true)
		changeSubtype(projectile.item, newSubtypeName)
		local deltaWear = tonumber(customRawTokens.getToken(projectile.item.subtype, "FIRE_WEAR")) or consts.itemWearStep
		projectile.item:addWear(deltaWear, false, false)
		local destroyItem = projectile.item:checkWearDestroy(false, false)
		-- Cases where the following two behaviours break down have yet to be seen
		if destroyItem then
			-- Destroy the shell (no trace)
			projectile.target_pos.x = consts.invalidCoord
			projectile.origin_pos.x = consts.invalidCoord
			projectile.cur_pos.x = consts.invalidCoord
			projectile.flags.to_be_deleted = true
			projectile.item.flags.garbage_collect = true
		else
			local tpos, opos = projectile.target_pos, projectile.origin_pos
			tpos.x, tpos.y, tpos.z = opos.x, opos.y, opos.z
			projectile.unk_v40_1 = -1
			projectile.firer = nil
			projectile.bow_id = -1
			projectile.flags.no_impact_destroy = consts.dropCasingsAsItems
		end
	end
end

return gunProjectileManager
