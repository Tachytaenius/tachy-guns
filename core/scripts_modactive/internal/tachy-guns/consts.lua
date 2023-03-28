--@ module = true

version = "0.0.0"
DFVersion = "0.50.07"

ammoMaterialItemSpecificImprovementType = 100
dropCasingsAsItems = true -- (damaged) items or broken projectiles? Edit: broken projectiles appear to have been removed from the game, so when this is false the casings are just deleted
perturbedVectorLength = 5000 -- Due to integer-only target locations
skipProcessingProjectileFlagKey = 31
smokeEffectDistanceFromFirer = 1

-- game's own values
gravity = 4900
defaultFireExperienceGain = 30
itemWearStep = 806400
invalidCoord = -30000
