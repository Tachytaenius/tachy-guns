-- TODO: come up with name for mod (and change key for event listeners)

-- NOTE: Currently projectileManager and shellFiller change item subtypes of ammo casings according to the [CONVERT_TO_(UN)FIREABLE:...] token. If projectiles and non-fireable casings change item type from ammo to tool, that code will have to change
-- NOTE: Adding the reactions doesn't seem to add anything undesirable like the shell filling dummy products to the civilisation's resources, which is good, but is all this certain?

local eventful = require("plugins.eventful")
local eventfulKey = "gunMod"
local args = {...}
if args[1] == "enable" then
	local projectileManager = dfhack.run_script("gunMod/projectileManager")
	eventful.onProjItemCheckMovement[eventfulKey] = function(...)
		projectileManager(...)
	end
	local shellFiller = dfhack.run_script("gunMod/shellFiller")
	eventful.onReactionComplete[eventfulKey] = function(...)
		-- shellFiller(...)
	end
	local itemCreationManager = dfhack.run_script("gunMod/itemCreationManager")
	eventful.onItemCreated[eventfulKey] = function(...)
		itemCreationManager(...)
	end
	local stuckInDamage = dfhack.run_script("gunMod/stuckInDamage")
	eventful.onItemContaminateWound[eventfulKey] = function(...)
		stuckInDamage(...)
	end
	print("Gun mod started!")
elseif args[1] == "disable" then
	eventful.onProjItemCheckMovement[eventfulKey] = nil
	eventful.onReactionComplete[eventfulKey] = nil
	eventful.onItemCreated[eventfulKey] = nil
	eventful.onItemContaminateWound[eventfulKey] = nil
	print("Gun mod stopped. Behaviour may break.")
else
	dfhack.printerr("Unknown argument \"" .. args[1] .. "\" to gunMod/main")
end
