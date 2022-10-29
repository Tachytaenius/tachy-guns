--@ module = true

-- Explanation of perturbations and inaccuracy quantities:
-- First, we get the angle perturbation of the direction of the gun itself (gunDirectionAngle) from an innacuracy value (gunDirectionSpread), which is TODO but would be based on things like firing on auto for too long.
-- Then, relative to that, we get the angle perturbation of the projectile(s) (projectileAngle) based on projectileInaccuracy, which is the sum of gunInaccuracy (wider barrels or whatever) and projectileInaccuracy (how loose the projectiles are in the casing or whatever).
-- Then we apply the sum of the two perturbations (perturbationAngle) to the target position of the fired projectile(s).

-- NOTE: Enabling piercing on projectiles will cause them to destroy trees. So I've opted to not do that.

local utils = require("utils")
local customRawTokens = require("custom-raw-tokens")

local consts = dfhack.reqscript("tachy-guns/consts")
local exhaustionRecord = dfhack.reqscript("tachy-guns/exhaustion-record")

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

function onProjItemCheckMovement(projectile)
	-- Only work on this projectile if it was just fired
	if projectile.distance_flown > 0 then
		return
	end

	-- Abort if the mod has explicitly stated not to work on this projectile
	if projectile.flags[consts.skipProcessingProjectileFlagKey] then
		return
	end

	-- Abort if there is no firer to work on
	local firer = projectile.firer
	if not projectile.firer then
		return
	end

	-- Abort if weapon is not controlled by this mod
	local gun = df.item.find(projectile.bow_id)
	if gun and gun._type == df.item_weaponst then
		if not customRawTokens.getToken(gun.subtype, "TACHY_GUNS_GUN") then
			return
		end
	else
		return
	end

	-- Set fire time
	local fireTime = tonumber(customRawTokens.getToken(gun.subtype, "TACHY_GUNS_FIRE_TIME"))
	if fireTime then
		local fireTimeType = customRawTokens.getToken(gun.subtype, "TACHY_GUNS_FIRE_TIME_TYPE") or "REPLACE"
		if fireTimeType == "ADD" then
			firer.counters.think_counter = firer.counters.think_counter + fireTime
		elseif fireTimeType == "MULTIPLY" then
			firer.counters.think_counter = math.floor(firer.counters.think_counter * fireTime)
		elseif fireTimeType == "REPLACE" then
			firer.counters.think_counter = fireTime
		else
			error("Tachy guns fire time type \"" .. fireTimeType .. "\" for gun type \"" .. gun.subtype.id .. "\" not recognised, must be \"ADD\", \"MULTIPLY\", or \"REPLACE\" (defaults to \"REPLACE\")")
		end
		-- Limit fire time to no less than 1
		firer.counters.think_counter = math.max(1, firer.counters.think_counter)
	end

	-- Modify exhaustion gain
	local previousExhaustion = exhaustionRecord.previousExhaustionTable[firer.id]
	if previousExhaustion then
		-- Please note that it uses a compromise system where the total exhaustion change per tick is multiplied down (or up), so it doesn't actually account specifically for exhaustion from firing (which depends on RNG (and attributes)) and would multiply a unit's exhaustion from running too if running while shooting
		local deltaExhaustion = firer.counters2.exhaustion - previousExhaustion
		if deltaExhaustion > 0 then
			local newDeltaExhaustion = deltaExhaustion * (tonumber(customRawTokens.getToken(gun.subtype, "TACHY_GUNS_FIRE_EXHAUSTION_MULTIPLIER")) or 1)
			firer.counters2.exhaustion = previousExhaustion + math.floor(newDeltaExhaustion)
			exhaustionRecord.exhaustionTable[firer.id] = firer.counters2.exhaustion
		end
	end

	-- Modify experience gain
	local fireExperienceGain = tonumber(customRawTokens.getToken(gun.subtype, "TACHY_GUNS_FIRE_EXPERIENCE_GAIN")) or consts.defaultFireExperienceGain
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

	-- Abort if the item fired is not Tachy Guns ammo
	if projectile.item._type == df.item_ammost then
		if not customRawTokens.getToken(projectile.item.subtype, "TACHY_GUNS_AMMO") then
			return
		end
	else
		return
	end

	-- Create smoke
	local smokeAmount = tonumber(customRawTokens.getToken(projectile.item.subtype, "TACHY_GUNS_SMOKE_AMOUNT")) or 0
	if smokeAmount > 0 then
		local flowPosition = {}
		do
			local opos, tpos = projectile.origin_pos, projectile.target_pos
			local x, y, z = tpos.x-opos.x, tpos.y-opos.y, tpos.z-opos.z
			local mag = math.sqrt(x^2+y^2+z^2)
			if mag > 0 then
				x, y, z = x * consts.smokeEffectDistanceFromFirer / mag, y * consts.smokeEffectDistanceFromFirer / mag, z * consts.smokeEffectDistanceFromFirer / mag
				flowPosition.x, flowPosition.y, flowPosition.z = math.floor(x+0.5) + opos.x, math.floor(y+0.5) + opos.y, math.floor(z+0.5) + opos.z
			else
				flowPosition.x, flowPosition.y, flowPosition.z = opos.x, opos.y, opos.z
			end
		end
		dfhack.maps.spawnFlow(flowPosition, df.flow_type.Smoke, 0, 0, smokeAmount)
	end

	-- Get various variables

	local gunDirectionSpread = 0
	local gunDirectionAngle = (math.random() - 0.5) * gunDirectionSpread

	local mainProjectileWear = projectile.item.wear

	local ammoInaccuracy = tonumber(customRawTokens.getToken(projectile.item.subtype, "TACHY_GUNS_INACCURACY")) or 0
	local gunInaccuracy = tonumber(customRawTokens.getToken(gun.subtype, "TACHY_GUNS_INACCURACY")) or 0
	local projectileInaccuracy = ammoInaccuracy + gunInaccuracy
	local gunRange = tonumber(customRawTokens.getToken(projectile.item.subtype, "TACHY_GUNS_RANGE") or 20)
	local ammoRange = tonumber(customRawTokens.getToken(projectile.item.subtype, "TACHY_GUNS_RANGE") or 20)
	local projectileRange = gunRange + ammoRange
	local mainProjectileIsShell = customRawTokens.getToken(projectile.item.subtype, "TACHY_GUNS_CONTAINED_PROJECTILE")

	if mainProjectileIsShell then
		-- Hack into old projecitles-as-contained-items behaviour and add projectiles as contained items
		local containedProjectileSubtypeName, containedProjectileCount = customRawTokens.getToken(projectile.item.subtype, "TACHY_GUNS_CONTAINED_PROJECTILE")
		local mat_type, mat_index = projectile.item.mat_type, projectile.item.mat_index -- Default material to main projectile material
		-- try to find improvement representing contained projectiles' material
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

		if perturbationAngle ~= 0 then
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
				tpos.x, tpos.y, tpos.z = math.floor(x+0.5) + opos.x, math.floor(y+0.5) + opos.y, math.floor(z+0.5) + opos.z
			end
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
		local destroyItem
		local newSubtypeName = customRawTokens.getToken(projectile.item.subtype, "TACHY_GUNS_CONVERT_TO_UNFIREABLE")
		if newSubtypeName then
			changeSubtype(projectile.item, newSubtypeName)
			local deltaWear = tonumber(customRawTokens.getToken(projectile.item.subtype, "TACHY_GUNS_FIRE_WEAR")) or consts.itemWearStep
			projectile.item:addWear(deltaWear, false, false)
			destroyItem = projectile.item:checkWearDestroy(false, false)
		else
			destroyItem = true
		end
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
