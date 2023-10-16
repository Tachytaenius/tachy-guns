# Tachy Guns

***GRAPHICS ARE TODO! You'll have to use Dwarf Fortress classic mode for now.***

***ENTITY VARIATION IS TODO! Currently it just adds content to MOUNTAIN (dwarves), but a system to add to entities of any name is planned.***

***THERE IS CURRENTLY NO WAY TO SELECT AMMO FOR SQUADS IN DF! This mod is (currently!) useless because of that.***

This project relies on DFHack!

Tachy Guns is a set of mods, or perhaps a modular mod, for adding DFHack-improved guns to Dwarf Fortress.
It has a core mod containing the DFHack scripts (the `core/` directory in this repository) and various content packs containing DF raws (with custom raw tokens to interact with the scripts) (each subfolder in `content-packs/` is a mod).

You can make your own content packs that rely on the core mod through custom raw tokens, if, say the 1945 content pack's "magazine-fed pistols" etc. are too general for you and you want something more specific.

The version that was last released is 0.0.0.
The Dwarf Fortress version this mod is currently for is 0.50.10 (as seen with the numbers extracted from DFHack's version-getting function).

Information about how to handle versions, releases, and the changelog is at the end of this file.
When developing, be wary of DF not incorporating your changes due to versions and it thinking your mod is already installed as it should be; delete from installed_mods when making changes and not bumping versions.

## Installation/Uninstallation

Either use Steam Workshop (Dwarf Fortress File Depot is planned) or the zip files in releases.

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
- Cordite: adds a more modern gun propellant made from guncotton (which is made frmo nitric acid, sulphuric acid, and cotton) and nitroglycerin (which is made from nitric acid, sulphuric acid, and glycerol).

## Notes

- Behaviour around the content added by the mod may break if the main script is not enabled.
	It will leave a message in the console ("Tachy Guns enabled") when activated.
- Lead doesn't work very well for projectiles (mostly bruising, though it is lethal) due to DF's own internal mechanics.
- Projectiles all have edged attacks due to DF's internal mechanics making blunt not effective.
- The reason dependency content packs exist is because their content is used by multiple content packs, or intended for use in custom content packs.
- It is recommended to use `gui/workshop-job` to set the desired materials for production.
- Guns use the crossbow skill for ranged and the hammer skill for melee.
- There is currently no way to select ammo for squads, it all doesn't work, it's all broken.
	(For the old ammo system, I said: don't mix incompatible guns and ammo in the same squad!
	It can lead to, for example, units holding large handgonnes and small handgonne charges.)
- You'll need to run `enable tachy-guns` to get it working in arena mode.
- In the case of bullets and shotgun shells, you can only fire ammo that says "fireable"-- other ammo is just shells or projectiles.
	In the case of muzzle-loaded ammo, charges are what you fire and balls are the projectiles (there are no casings).

## Versioning, Releasing, and Changelogging

You don't need to read this unless you're the maintainer.

The version from the previous release is stored in the `main` branch of the GitHub repository in `core/scripts_modactive/internal/tachy-guns/consts.lua` and near the top of this file.
It is also stored in every mod `info.txt` file.
Just before a release, it is incremented according to the changes in the changelog (along with the versions in the `info.txt` files), and then packaged into the release.
The only change in a content pack may sometimes just be the displayed version and numeric version in the `info.txt` file being incremented, if that's the case, package it in the releases but don't update it on Steam Workshop.
The numeric version in `info.txt` files is just incremented as a single number.
The version is incremented before release for use in the upcoming release.

The version numbers are major, minor, and patch.
Patch is incremented for small non-breaking changes such as non-breaking bugfixes.
Minor is the main version that is incremented, including not-so-small non-breaking changes.
Major is incremented whenever a really large or fundamental change is made or an important milestone is reached.
The version is incremented according to the largest change in the upcoming release, so if there is both a patch-type and minor-type change, the minor number is incremented and patch is set to 0.

Changes between releases are added to the changelog under the future section.
Every release, the future section is moved to a section labelled with the current version in code, after the version increment.
If the changelog is packaged with anything, it should be packaged with the future -> current version change.

The Dwarf Fortress version this mod is for is stored near the top of this file and in `core/scripts_modactive/internal/tachy-guns/consts.lua`.

Use `zip-releases.sh` with the version number (with hyphens instead of dots) as an argument to get zip files for releases in the (`.gitignore`d) `release-zips/` folder.
Every released zip is prefixed with "tachy-guns-[version-using-hyphens]-".
The readmes stay in the released mods.
