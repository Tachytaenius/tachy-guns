-- TODO: come up with name for mod (and change key for event listeners)

local eventful = require("plugins.eventful")

local modId = "gunMod"
local args = {...}

if args[1] == "enable" then
	-- Proper casing firing behaviour
	local projectileManager = dfhack.run_script("gunMod/projectileManager")
	eventful.onProjItemCheckMovement[modId] = function(...)
		projectileManager(...)
	end
	
	-- Making sawn-off shotguns
	local typeTransform = dfhack.run_script("gunMod/typeTransform")
	eventful.onJobCompleted[modId] = function(...)
		typeTransform(...)
	end
	eventful.enableEvent(eventful.eventType.JOB_COMPLETED, 0)
	
	-- Code for applying handle material to guns
	local handleMaterialTransfer = dfhack.run_script("gunMod/handleMaterialTransfer")
	-- Storing projectile material from projectile bar in ammo product as an improvement
	local storeProjectileMaterial = dfhack.run_script("gunMod/storeProjectileMaterial")
	eventful.onReactionComplete[modId] = function(...)
		handleMaterialTransfer(...)
		storeProjectileMaterial(...)
	end
	
	-- Cause extra havoc when a bullet is lodged firmly in a wound
	local stuckInDamage = dfhack.run_script("gunMod/stuckInDamage")
	eventful.onItemContaminateWound[modId] = function(...)
		stuckInDamage(...)
	end
	
	print("Gun mod enabled!")
elseif args[1] == "disable" then
	eventful.onProjItemCheckMovement[modId] = nil
	eventful.onJobCompleted[modId] = nil
	eventful.onReactionComplete[modId] = nil
	eventful.onItemContaminateWound[modId] = nil
	print("Gun mod disabled. Behaviour may break.")
elseif not args[1] then
	dfhack.printerr("No argument given to gunMod/main")
else
	dfhack.printerr("Unknown argument \"" .. args[1] .. "\" to gunMod/main")
end