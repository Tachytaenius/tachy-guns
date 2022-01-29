-- TODO: Record rationale for perturbations and inaccuracy quantities
-- TODO: Clean up code to make projectile/subProjectile uses consistent and disctinctions clearer
-- TODO: How to modify projectile speed etc? The casing's mass shouldn't impact the velocity of the projectiles
-- When fired into a wall and dropped to the floor from another z-level, projectiles leave items instead of broken projectiles. but for shotguns this is even more broken as only the first is displayed and the rest remain as phantoms on the map. TODO: fix????
-- TODO: Are there less stuck-ins than there should be? Is this just a job for tweaking the raws?

local utils = require("utils")

local customRawData = require("customRawData") -- a function

local gravity = 4900 -- game's own value
local vectorLength = 100 -- Due to integer-only target locations

-- this is an onProjItemCheckMovement event listener
local function gunProjectileManager(projectile)
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
	
	firer.counters.think_counter = customRawData(gun.subtype, "FIRE_TIME")
	
	if projectile.item._type == df.item_ammost then
		if not customRawData(projectile.item.subtype, "GUN_AMMO") then
			return
		end
	end
	
	local function perturbDirection(angle, opos, tpos)
		if tpos.x==opos.x and tpos.y==opos.y then return end
		local dirX, dirY = tpos.x-opos.x, tpos.y-opos.y
		local currentAngle = math.atan(dirY, dirX)
		local newAngle = currentAngle + angle
		dirX, dirY = math.cos(newAngle), math.sin(newAngle)
		tpos.x, tpos.y = opos.x+math.floor(dirX*vectorLength), opos.y+math.floor(dirY*vectorLength)
	end
	local function perturbDirectionRandom(spread, opos, tpos)
		 perturbDirection((math.random() - 0.5) * spread, opos, tpos)
	end
	
	local gunDirectionSpread = 0 -- not having a scope, maybe? but i don't see why that should make the user less accurate than a crossbow without a scope. maybe for firing on auto for too long
	local ammoInaccuracy = customRawData(projectile.item.subtype, "INACCURACY") or 0
	local gunInaccuracy = customRawData(gun.subtype, "INACCURACY") or 0
	local projectileInaccuracy = ammoInaccuracy + gunInaccuracy
	local mainProjectileIsShell = customRawData(projectile.item.subtype, "GUN_AMMO_SHELL")
	if mainProjectileIsShell then
		perturbDirectionRandom(gunDirectionSpread, projectile.origin_pos, projectile.target_pos)
	else -- Make sure the INACCURACY tag works on ammo that isn't a shell
		-- but also do only one perturbation for both the ammo and gunDirectionSpread
		-- but since perturbing twice by spreads a and b is not equivalent to perturbing once by a + b
		-- manually make the angle from two random calls and perturb with that
		local angle = (math.random()-0.5)*gunDirectionSpread + (math.random()-0.5)*projectileInaccuracy
		perturbDirection(angle, projectile.origin_pos, projectile.target_pos)
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
			
			perturbDirectionRandom(projectileInaccuracy, subProjectile.origin_pos, subProjectile.target_pos)
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

return gunProjectileManager
