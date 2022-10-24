# Tachy Guns

## Installation

- Merge `raw/` with your DF(Hack) installation's `raw/`.
	This contains the scripts that actually give functionality to the content.
- Pick a content pack from below, find it in `content-packs/` and merge its `raw/` with your DF(Hack) installation's `raw/`.
- In the content pack's directory, `add-to-entity.txt` contains raw text that you paste into the entity definition for the entity you want to be able to use guns, so don't forget that.
- Check for any dependency content packs in the content pack's `readme.md` and install those too, recursively.

## Content Packs

### Root Packs

These are pack you actually want to choose from and install.
They don't conflict, you can install them all if you want.
Make sure to read the readme for the one you choose.

- 1400: Recommended as it adheres to Dwarf Fortress' 1400 technology cutoff.
	Adds some very old-timey weapons.
- 1800: Good if you want some (perhaps) more familiar weaponry to play with, while still being something classical.
- 1945: A collection of modern-ish guns.
	Uses a different propellant to 1800 and 1400.

### Dependency-Only Packs

These are packs that only exist to give functionality to other packs that use them.

- Black Gunpowder: Adds a classical gunpowder made from sulphur, saltpetre, and coke/charcoal.
- Alchemy Laboratory: Adds a laboratory used to create propellants.
- Barrels: Adds the barrels of various sizes used to make guns.

## Notes

- Behaviour around the content added by the mod may break if the script is not on.
	It will leave a message in the console ("Tachy Guns enabled!") when activated.
- Lead doesn't work very well for projectiles (mostly bruising, though it is lethal) due to DF's own internal mechanics.
- Black gunpowder is in its own content pack because it is used by both the 1400 and 1800 content packs.
- It is recommended to use `gui/workshop-job` to set the desired materials for production.
- Guns use the crossbow skill.
