# 1945 Content Pack

## Dependencies

- Alchemy laboratory

## Cordite

All reactions in the production of cordite take place at an alchemy laboratory.
They use the alchemist labour.
Sometimes reagents will be frozen at normal operating temperatures and the reaction won't be able to proceed, so consder doing work above magma or some other temperature control method.

Cordite bars are the propellant.
Each bar is produced with a dimension of 150 and is used up like a bar of soap is by ammo manufacturing reactions.
It is made from a vial of nitroglycerin and a glob of guncotton.

Nitroglycerin is made from a vial of sulphuric acid (called oil of vitriol), a vial of nitric acid (called spirit of nitre), and a vial of glycerol.

Sulphuric acid is made from brimstone, and is put in a vial.

Nitric acid is made from sulphuric acid and either shale for alum or saltpetre.

Glycerol is extracted from plants or seeds that can be pressed, and is put in a vial.

Guncotton is made from a cotton plant, a vial of sulphuric acid, and a vial of nitric acid.

## Ammo item types

- Casing
- Projectile
- Fireable round (splits into casing and projectile upon being fired)

## Gun component/ammo types

- Small
- Medium
- Large
- Shotgun shell (uses large components)

## Manufacturing Ammo

This is all done at a metalsmith's forge (temporary) using the metalcraft labour.

They require fuel to melt the metal bars.
Small produces 9 and takes 10 dimension out of a cordite bar, medium 6/20, large 3/30, and shell 5/20.

Ammo is made from two metal bars, one for the casings and one for the projectiles.
The casing bar material determines the material of the fireable round and the projecile bar's material is saved on the resultant stack.

## Manufacturing Gun Barrels

There are 9 different barrel types, and they are all added to entity as tools, so you can forge them in "other objects" in a metalsmith's forge.
They suffer from the same problem as high/low boots do in vanilla, which is that item subtype adjectives are not shown by the item creation jobs they generate, but that means they have the same solutions.
You could either use `gui/gm-editor` to poke around and see if your job is on the right subtype, or refer to the order that they appear in in-game using the default `add-to-entity.txt`:
- Short small barrel
- Medium-length small barrel
- Long small barrel
- Short medium barrel
- Medium-length medium barrel
- Long medium barrel
- Short large barrel
- Medium-length large barrel
- Long large barrel

## Manufacturing Receivers

This is all done at a metalsmith's forge (temporary) using the metalcraft labour.

Automatic receivers take two mechanisms, manual receivers take one.

## Manufacturing Guns

This is all done at a craftsman's workshop (temporary) using the mechanic labour.

Semi-automatic guns use manual receivers.
Non-manual guns require an extra mechanism in their manufacture.
Guns often need one to two plant (wood) blocks as handles.

## Guns

- Pistol: small, semi-automatic
- Revolver: small, semi-automatic
- Submachine gun: small, automatic
- Assault rifle: medium, automatic
- Machine gun: medium, automatic
- Sniper rifle: large, manual
- Pump-action shotgun: shell, manual
- Double-barrel shotgun: shell, manual
- Sawn-off shotgun: shell, manual
