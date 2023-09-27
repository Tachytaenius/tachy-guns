--@module = true
--@enable = true

--[====[
tachy-guns
===========

Tags: gameplay | military

Contains modules for handling behaviour in Tachy Guns content packs.

Usage
-----

    enable tachy-guns
    disable tachy-guns
]====]

local repeatUtil = require("repeat-util")
local eventful = require("plugins.eventful")
local dialogs = require("gui.dialogs")

local consts = dfhack.reqscript("internal/tachy-guns/consts") -- Used here to get the mod's DF version for a check

local projectileManager = dfhack.reqscript("internal/tachy-guns/projectile-manager") -- Proper casing firing behaviour
local typeTransform = dfhack.reqscript("internal/tachy-guns/type-transform") -- Making sawn-off shotguns
local handleMaterialTransfer = dfhack.reqscript("internal/tachy-guns/handle-material-transfer") -- Code for applying handle material to guns
local storeProjectileMaterial = dfhack.reqscript("internal/tachy-guns/store-projectile-material") -- Storing projectile material from projectile bar in ammo product as an improvement
local stuckInDamage = dfhack.reqscript("internal/tachy-guns/stuck-in-damage") -- Cause extra havoc when a bullet is lodged firmly in a wound
local exhaustionRecord = dfhack.reqscript("internal/tachy-guns/exhaustion-record") -- Record unit exhaustion from previous tick to roll back for exhaustion multiplier

local GLOBAL_KEY = "tachy-guns"

enabled = enabled or false

function isEnabled()
	return enabled
end

dfhack.onStateChange[GLOBAL_KEY] = function(stateChange)
	if stateChange == SC_MAP_UNLOADED then
		dfhack.run_command("disable", "tachy-guns")
		dfhack.onStateChange[GLOBAL_KEY] = nil
		return
	end
	if stateChange ~= SC_MAP_LOADED or df.global.gamemode ~= df.game_mode.DWARF then
		return
	end
	dfhack.run_command("enable", "tachy-guns")
end

if dfhack_flags.module then
	return
end

if not dfhack_flags.enable then
	print(dfhack.script_help())
	print()
	print(("Tachy Guns is currently %s"):format(enabled and "enabled" or "disabled"))
	return
end

local function disable() -- Used in two places
	eventful.onProjItemCheckMovement[GLOBAL_KEY] = nil
	eventful.onJobCompleted[GLOBAL_KEY] = nil
	eventful.onReactionComplete[GLOBAL_KEY] = nil
	eventful.onItemContaminateWound[GLOBAL_KEY] = nil

	print("Tachy Guns disabled")
	enabled = false
end

if dfhack_flags.enable_state then
	local currentDFVersion = dfhack.getDFVersion():sub(2, -1):gsub("[ -].+$", "") -- Remove v and extra info, leaving only the numbers
	if consts.DFVersion ~= currentDFVersion then
		dialogs.showMessage("Error",
			"This version of Tachy Guns is for DF version " .. consts.DFVersion .. ",\n" ..
			"current DF version is " .. currentDFVersion .. ". The script will now disable.\n" ..
			"Behaviour may break."
		)
		disable()
		return
	end

	exhaustionRecord.onLoad()

	eventful.onProjItemCheckMovement[GLOBAL_KEY] = function(...)
		projectileManager.onProjItemCheckMovement(...)
	end

	eventful.onJobCompleted[GLOBAL_KEY] = function(...)
		typeTransform.onJobCompleted(...)
	end
	eventful.enableEvent(eventful.eventType.JOB_COMPLETED, 0)

	eventful.onReactionComplete[GLOBAL_KEY] = function(...)
		handleMaterialTransfer.onReactionComplete(...)
		storeProjectileMaterial.onReactionComplete(...)
	end

	eventful.onItemContaminateWound[GLOBAL_KEY] = function(...)
		stuckInDamage.onItemContaminateWound(...)
	end

	repeatUtil.scheduleEvery(GLOBAL_KEY .. " every tick", 1, "ticks", function()
		exhaustionRecord.every1Tick()
	end)

	print("Tachy Guns enabled")
	enabled = true
else
	disable()
end
