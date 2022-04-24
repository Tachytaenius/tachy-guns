-- TODO: come up with name for mod (and change key for event listeners)

-- NOTE: Currently projectileManager and shellFiller change item subtypes of ammo casings according to the [CONVERT_TO_(UN)FIREABLE:...] token and also checks against segfaults in shellFiller by checking if job_item_refs are of type AMMO. If projectiles and non-fireable casings change item type from ammo to tool, that code will have to change
-- NOTE: Adding the reactions doesn't seem to add anything undesirable like the shell filling dummy products to the civilisation's resources, which is good, but is all this certain?

local eventful = require("plugins.eventful")

local eventfulKey = "gunMod"
local args = {...}

if args[1] == "enable" then	
	-- Proper casing firing behaviour
	local projectileManager = dfhack.run_script("gunMod/projectileManager")
	eventful.onProjItemCheckMovement[eventfulKey] = function(...)
		projectileManager(...)
	end
	
	-- Code for filling casings
	local shellFiller = dfhack.run_script("gunMod/shellFiller")
	eventful.onJobCompleted[eventfulKey] = function(...)
		shellFiller(...)
	end
	eventful.enableEvent(eventful.eventType.JOB_COMPLETED, 0)
	
	-- Code for applying handle material to guns
	local handleMaterialTransfer = dfhack.run_script("gunMod/handleMaterialTransfer")
	eventful.onReactionComplete[eventfulKey] = function(...)
		handleMaterialTransfer(...)
	end
	
	-- TODO
	local itemCreationManager = dfhack.run_script("gunMod/itemCreationManager")
	eventful.onItemCreated[eventfulKey] = function(...)
		itemCreationManager(...)
	end
	
	-- Cause extra havoc when a bullet is lodged firmly in a wound
	local stuckInDamage = dfhack.run_script("gunMod/stuckInDamage")
	eventful.onItemContaminateWound[eventfulKey] = function(...)
		stuckInDamage(...)
	end
	
	print("Gun mod enabled!")
elseif args[1] == "disable" then
	eventful.onProjItemCheckMovement[eventfulKey] = nil
	eventful.onJobCompleted[eventfulKey] = nil
	eventful.onReactionComplete[eventfulKey] = nil
	eventful.onItemCreated[eventfulKey] = nil
	eventful.onItemContaminateWound[eventfulKey] = nil
	print("Gun mod disabled. Behaviour may break.")
elseif not args[1] then
	dfhack.printerr("No argument given to gunMod/main")
else
	dfhack.printerr("Unknown argument \"" .. args[1] .. "\" to gunMod/main")
end
