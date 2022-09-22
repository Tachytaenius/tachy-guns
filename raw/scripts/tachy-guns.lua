--@ enable = true

local usage = [[
Usage
-----

enable tachy-guns
disable tachy-guns
]]

local eventful = require("plugins.eventful")

local projectileManager = dfhack.reqscript("tachy-guns/projectile-manager") -- Proper casing firing behaviour
local typeTransform = dfhack.reqscript("tachy-guns/type-transform") -- Making sawn-off shotguns
local handleMaterialTransfer = dfhack.reqscript("tachy-guns/handle-material-transfer") -- Code for applying handle material to guns
local storeProjectileMaterial = dfhack.reqscript("tachy-guns/store-projectile-material") -- Storing projectile material from projectile bar in ammo product as an improvement
local stuckInDamage = dfhack.reqscript("tachy-guns/stuck-in-damage") -- Cause extra havoc when a bullet is lodged firmly in a wound

enabled = enabled or false
local modId = "tachy-guns"

if not dfhack_flags.enable then
	print(usage)
	print()
	print(("Tachy guns is currently "):format(enabled and "enabled" or "disabled"))
	return
end

if dfhack_flags.enable_state then
	eventful.onProjItemCheckMovement[modId] = function(...)
		projectileManager.onProjItemCheckMovement(...)
	end
	
	eventful.onJobCompleted[modId] = function(...)
		typeTransform.onJobCompleted(...)
	end
	eventful.enableEvent(eventful.eventType.JOB_COMPLETED, 0)
	
	eventful.onReactionComplete[modId] = function(...)
		handleMaterialTransfer.onReactionComplete(...)
		storeProjectileMaterial.onReactionComplete(...)
	end
	
	eventful.onItemContaminateWound[modId] = function(...)
		stuckInDamage.onItemContaminateWound(...)
	end
	
	print("Tachy Guns enabled!")
	enabled = true
else
	eventful.onProjItemCheckMovement[modId] = nil
	eventful.onJobCompleted[modId] = nil
	eventful.onReactionComplete[modId] = nil
	eventful.onItemContaminateWound[modId] = nil
	
	print("Tachy Guns disabled. Behaviour may break.")
	enabled = false
end
