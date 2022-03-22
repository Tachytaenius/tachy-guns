-- TODO: come up with name for mod (and change prefix for event listeners)

-- NOTE: Currently projectileManager and shellFiller change item subtypes of ammo casings according to the [CONVERT_TO_(UN)FIREABLE:...] tag. If projectiles and non-fireable casings change item type from ammo to tool, that code will have to change
-- NOTE: Adding the reactions doesn't seem to add anything undesirable like the shell filling dummy products to the civilisation's resources, which is good, but is all this certain?

local eventful = require("plugins.eventful")

local args = {...}
if args[1] == "enable" then
	eventful.onProjItemCheckMovement.gunModProjectileManager = dfhack.run_script("gunMod/projectileManager")
	eventful.onReactionComplete.gunModShellFiller = dfhack.run_script("gunMod/shellFiller")
	eventful.onItemCreated.gunModItemCreationManager = dfhack.run_script("gunMod/itemCreationManager")
	eventful.onItemContaminateWound.gunModStuckInDamage = dfhack.run_script("gunMod/stuckInDamage")
	print("Gun mod started!")
elseif args[1] == "disable" then
	eventful.onProjItemCheckMovement.gunModProjectileManager = nil
	eventful.onReactionComplete.gunModShellFiller = nil
	eventful.onItemCreated.gunModItemCreationManager = nil
	eventful.onItemContaminateWound.gunModStuckInDamage = nil
	print("Gun mod stopped. Behaviour may break.")
else
	dfhack.printerr("Unknown argument \"" .. arg[1] .. "\" to gunMod/main")
end
