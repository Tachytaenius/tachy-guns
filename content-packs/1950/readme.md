# 1950 Content Pack

## Dependencies

Requires content pack "alchemy laboratory".

## Cordite

All reactions in the production of cordite take place at an alchemy laboratory.
They use the alchemist labour.
Sometimes reagents will be frozen at normal operating temperatures and the reaction won't be able to proceed, so consder doing work above magma.

Cordite bars are the propellant.
It is produced with a dimension of 100 and is used up by ammo manufacturing reactions.
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

All reactions currently take place at a metalsmith's forge (temporary).
They use the metalcraft labour.
They require fuel to melt the metal bars.
Small produces 9 and takes 10 dimension out of a cordite bar, medium 6/20, large 3/30, and shell 5/20.

Ammo is made from two metal bars, one for the casings and one for the projectiles.
The casing bar material determines the material of the fireable round and the projecile bar's material is saved on the resultant stack.
It is recommended to use `gui/workshop-job` or modify `df.global.world.manager_orders` using `gui/gm-editor` to set the desired materials for ammunition production.

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
