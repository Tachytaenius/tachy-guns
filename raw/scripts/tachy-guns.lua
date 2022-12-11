--@ enable = true

local usage = [[
Usage
-----

enable tachy-guns
disable tachy-guns
]]

local eventful = require("plugins.eventful")
local repeatUtil = require("repeat-util")
local dialogs = require("gui.dialogs")

local consts = dfhack.reqscript("tachy-guns/consts") -- Used here to get the mod's DF version for a check

local projectileManager = dfhack.reqscript("tachy-guns/projectile-manager") -- Proper casing firing behaviour
local typeTransform = dfhack.reqscript("tachy-guns/type-transform") -- Making sawn-off shotguns
local handleMaterialTransfer = dfhack.reqscript("tachy-guns/handle-material-transfer") -- Code for applying handle material to guns
local storeProjectileMaterial = dfhack.reqscript("tachy-guns/store-projectile-material") -- Storing projectile material from projectile bar in ammo product as an improvement
local stuckInDamage = dfhack.reqscript("tachy-guns/stuck-in-damage") -- Cause extra havoc when a bullet is lodged firmly in a wound
local exhaustionRecord = dfhack.reqscript("tachy-guns/exhaustion-record") -- Record unit exhaustion from previous tick to roll back for exhaustion multiplier

enabled = enabled or false
local modId = "tachy-guns"

if not dfhack_flags.enable then
	print(usage)
	print()
	print(("Tachy guns is currently "):format(enabled and "enabled" or "disabled"))
	return
end

local function disable()
	eventful.onProjItemCheckMovement[modId] = nil
	eventful.onJobCompleted[modId] = nil
	eventful.onReactionComplete[modId] = nil
	eventful.onItemContaminateWound[modId] = nil

	print("Tachy Guns disabled. Behaviour may break.")
	enabled = false
end

if dfhack_flags.enable_state then
	local currentDFVersion = dfhack.getDFVersion():sub(2, -1):gsub(" .+$", "") -- Remove v and OS, leaving only the numbers
	if consts.DFVersion == currentDFVersion then
		dialogs.showMessage("Error",
			"This version of Tachy Guns is for DF version " .. consts.DFVersion .. ",\n" ..
			"current DF version is " .. currentDFVersion .. ". The script will now disable.\n" ..
			"Behaviour may break."
		)
		disable()
		return
	end

	exhaustionRecord.onLoad()

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

	repeatUtil.scheduleEvery(modId .. " every tick", 1, "ticks", function()
		exhaustionRecord.every1Tick()
	end)

	print("Tachy Guns enabled!")
	enabled = true
else
	disable()
end
