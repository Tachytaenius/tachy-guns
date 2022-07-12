local consts = {}

consts.ammoMaterialItemSpecificImprovementType = 2
consts.dropCasingsAsItems = false -- (damaged) items or broken projectiles? TODO: settings manager
consts.perturbedVectorLength = 5000 -- Due to integer-only target locations
consts.skipProcessingProjectileFlagKey = 31

-- game's own values
consts.gravity = 4900
-- consts.defaultFireExhaustion = 20 -- depends on attributes
consts.defaultFireExperienceGain = 30
consts.itemWearStep = 806400
consts.invalidCoord = -30000

return consts
