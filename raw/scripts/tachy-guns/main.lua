-- TODO: come up with name for mod (and change key for event listeners)

local eventful = require("plugins.eventful")

local modId = "tachy-guns"
local args = {...}

if args[1] == "enable" then
	-- Proper casing firing behaviour
	local projectileManager = dfhack.run_script("tachy-guns/projectile-manager")
	eventful.onProjItemCheckMovement[modId] = function(...)
		projectileManager(...)
	end
	
	-- Making sawn-off shotguns
	local typeTransform = dfhack.run_script("tachy-guns/type-transform")
	eventful.onJobCompleted[modId] = function(...)
		typeTransform(...)
	end
	eventful.enableEvent(eventful.eventType.JOB_COMPLETED, 0)
	
	-- Code for applying handle material to guns
	local handleMaterialTransfer = dfhack.run_script("tachy-guns/handle-material-transfer")
	-- Storing projectile material from projectile bar in ammo product as an improvement
	local storeProjectileMaterial = dfhack.run_script("tachy-guns/store-projectile-material")
	eventful.onReactionComplete[modId] = function(...)
		handleMaterialTransfer(...)
		storeProjectileMaterial(...)
	end
	
	-- Cause extra havoc when a bullet is lodged firmly in a wound
	local stuckInDamage = dfhack.run_script("tachy-guns/stuck-in-damage")
	eventful.onItemContaminateWound[modId] = function(...)
		stuckInDamage(...)
	end
	
	print("Tachy Guns enabled!")
elseif args[1] == "disable" then
	eventful.onProjItemCheckMovement[modId] = nil
	eventful.onJobCompleted[modId] = nil
	eventful.onReactionComplete[modId] = nil
	eventful.onItemContaminateWound[modId] = nil
	print("Tachy Guns disabled. Behaviour may break.")
elseif not args[1] then
	dfhack.printerr("No argument given to tachy-guns/main")
else
	dfhack.printerr("Unknown argument \"" .. args[1] .. "\" to tachy-guns/main")
end
