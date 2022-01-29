-- NOTE/TODO: prefix event listener names? or maybe table keys to keep them unique and keep the keys in global to reuse them to replace the old listeners

local eventful = require("plugins.eventful")
eventful.onProjItemCheckMovement.gunProjectileManager = dofile("hack/scripts/gunMod/projectileManager.lua")
eventful.onReactionComplete.shellFiller = dofile("hack/scripts/gunMod/shellFiller.lua")
