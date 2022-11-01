# Tachy Guns

The current version is 0.0.0.

Information about how to handle versions, releases, and the changelog is at the end of this file.

## Installation

- Download a root content pack pre-packaged with its dependencies from the releases page, and merge its `raw/` with your DF(Hack) installation's `raw`/.

Or

- Download the repository.
- Merge `raw/` with your DF(Hack) installation's `raw/`.
	This contains the scripts that actually give functionality to the content.
- Pick a content pack from below, find it in `content-packs/` and merge its `raw/` with your DF(Hack) installation's `raw/`.
- In the content pack's directory, `add-to-entity.txt` contains raw text that you paste into the entity definition for the entity you want to be able to use guns, so don't forget that.
- Check for any dependency content packs in the content pack's `readme.md` and install those too if not installed already, recursively.

## Uninstallation

- Search for "tachy_guns" in your DF(Hack) installation's `raw/objects/` and delete the text files in there.
- Delete `raw/init.d/init-tachy-guns.lua`.
- Delete `raw/scripts/tachy-guns.lua`.
- Delete `raw/scripts/tachy-guns/`.
- Delete the lines from the `add-to-entity.txt` files from your entity definitions.

## Content Packs

### Root Packs

These are pack you actually want to choose from and install.
They don't conflict, you can install them all if you want.
Make sure to read the readme(s) for the one(s) you choose.

- 1400: Recommended as it adheres to Dwarf Fortress' 1400 technology cutoff.
	Adds some very old-timey weapons (handgonnes, little more than barrels on sticks).
- 1800: Good if you want some (perhaps) more familiar weaponry to play with, while still being something classical.
- 1945: A collection of modern-ish guns.
	Uses a different propellant to 1800 and 1400.

### Dependency-Only Packs

These are packs that only exist to give functionality to other packs that use them.

- Black Gunpowder: Adds a classical gunpowder made from sulphur, saltpetre, and coke/charcoal.
- Workshops: Adds the workshops used to make guns.
- Barrels: Adds the barrels of various sizes used to make guns.
	Its `add-to-entity.txt` is optional, check its readme.
- Muzzle-Loaded Ammo: Adds round projectiles and projectile + gunpowder charges for muzzle-loading guns as ammo.

## Notes

- Behaviour around the content added by the mod may break if the script is not on.
	It will leave a message in the console ("Tachy Guns enabled!") when activated.
- Lead doesn't work very well for projectiles (mostly bruising, though it is lethal) due to DF's own internal mechanics.
- Projectiles all have edged attacks due to DF's internal mechanics making blunt not effective.
- The reason dependency content packs exist is because their content is used by multiple content packs.
- It is recommended to use `gui/workshop-job` to set the desired materials for production.
- Guns use the crossbow skill for ranged and the hammer skill for melee.

## Versioning, Releasing, and Changelogging

The version for the next release is stored in the `main` branch of the GitHub repository in `raw/scripts/consts.lua` and the top of this file, which is then packaged into releases.
The version is incremented after release for use in the next release.

The version numbers are major, minor, and patch.
Patch is incremented for non-breaking (i.e. does not remove/rename any entries from raws or other changes that could be considered breaking) changes.
Minor is the main version that is incremented.
Major is incremented whenever a really large or fundamental change is made or an important milestone is reached.
The version is incremented according to the largest change in the release, so if there is both a patch-type and minor-type change, the minor number is incremented and patch is set to 0.

For every release, all root content packs are packaged with their dependencies as a ready-to-install single `raw/` directory, and added to the releases page along with a copy of the repository.

Changes between releases are added to the changelog under the future section.
Every release, the future section is moved to a section labelled with the current version in code.
