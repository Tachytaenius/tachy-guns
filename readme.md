# Tachy Guns

***GRAPHICS ARE TODO! You'll have to use Dwarf Fortress classic mode for now.***
***RELEASES ARE TODO! There has not been a Steam Workshop release or an install-it-yourself zip file release yet.*** 

Tachy Guns is a set of mods, or perhaps a modular mod, for adding DFHack-improved guns to Dwarf Fortress.
It has a core mod containing the DFHack scripts (the `core/` directory in this repository) and various content packs containing DF raws (with custom raw tokens to interact with the scripts) (each subfolder in `content-packs/` is a mod).

You can make your own content packs that rely on the core mod through custom raw tokens, if, say the 1945 content pack's "magazine-fed pistols" etc. are too general for you and you want something more specific.

The current version subject to development is 0.0.0, for Dwarf Fortress version 0.50.07 (that format is what is returned from DFHack's version getting function).

Information about how to handle versions, releases, and the changelog is at the end of this file.

## Installation/Uninstallation

Either use Steam Workshop or the zip files in releases.

## Content Packs

### Root Packs

These are the packs you actually want to choose from.
They don't conflict, you can install them all if you want.

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
- Muzzle-Loaded Ammo: Adds round projectiles and projectile + gunpowder charges for muzzle-loading guns as ammo.

## Notes

- Behaviour around the content added by the mod may break if the main script is not enabled.
	It will leave a message in the console ("Tachy Guns enabled") when activated.
- Lead doesn't work very well for projectiles (mostly bruising, though it is lethal) due to DF's own internal mechanics.
- Projectiles all have edged attacks due to DF's internal mechanics making blunt not effective.
- The reason dependency content packs exist is because their content is used by multiple content packs.
- It is recommended to use `gui/workshop-job` to set the desired materials for production.
- Guns use the crossbow skill for ranged and the hammer skill for melee.
- Don't mix incompatible guns and ammo in the same squad!
	It can lead to, for example, units holding large handgonnes and small handgonne charges.

## Versioning, Releasing, and Changelogging

You don't need to read this unless you're the maintainer.

The version for the next release (i.e. the version being developed) is stored in the `main` branch of the GitHub repository in `core/scripts_modactive/internal/tachy-guns/consts.lua` and the top of this file, which is then packaged into releases.
It is also stored in every mod `info.txt` file.
The only change in a content pack may sometimes just be the displayed version and numeric version in the `info.txt` file being incremented, if that's the case, package it in the releases but don't update it on Steam Workshop.
The numeric version in `info.txt` files is just incremented as a single number.
The version is incremented after release for use in the next release.

The version numbers are major, minor, and patch.
Patch is incremented for small non-breaking changes such as bugfixes.
Minor is the main version that is incremented, including not-so-small non-breaking changes.
Major is incremented whenever a really large or fundamental change is made or an important milestone is reached.
The version is incremented according to the largest change in the release, so if there is both a patch-type and minor-type change, the minor number is incremented and patch is set to 0.

Changes between releases are added to the changelog under the future section.
Every release, the future section is moved to a section labelled with the current version in code, before the version increment.
If the changelog is packaged with anything, it should be packaged with the future -> current version change.

The Dwarf Fortress version this mod is for is stored at the top of this file and in `core/scripts_modactive/internal/tachy-guns/consts.lua`.
