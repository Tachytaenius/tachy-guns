-- NOTE/TODO: prefix event listener names? or maybe table keys to keep them unique and keep the keys in global to reuse them to replace the old listeners

-- NOTE: Currently projectileManager and shellFiller change item subtypes of ammo casings according to the [CONVERT_TO_(UN)FIREABLE:...] tag. If projectiles and non-fireable casings change item type from ammo to tool, that code will have to change
-- NOTE: Adding the reactions doesn't seem to add anything undesirable like the shell filling dummy products to the civilisation's resources, which is good, but is all this certain?

local eventful = require("plugins.eventful")
eventful.onProjItemCheckMovement.gunProjectileManager = dofile("hack/scripts/gunMod/projectileManager.lua")
eventful.onReactionComplete.shellFiller = dofile("hack/scripts/gunMod/shellFiller.lua")
