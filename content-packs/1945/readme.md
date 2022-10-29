# 1945 Content Pack

## Dependencies

- Workshops
- Barrels

## Cordite

All reactions in the production of cordite take place at an alchemist's laboratory.
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
- Fireable round (splits into casing and projectile upon being fired), this is what you want to assign to your squads

## Gun component/ammo types

- Small
- Medium
- Large
- Shotgun shell (uses large components)

## Manufacturing Ammo

This is all done at an ammo manufacturing station using the metalcraft labour.

Fuel is required to melt the metal bars.
Small produces 50 and takes 10 dimension out of a cordite bar, medium 40/20, large 30/30, and shell 25/20.

Ammo is made from two metal bars, one for the casings and one for the projectiles.
The casing bar material determines the material of the fireable round and the projecile bar's material is saved on the resultant stack.

## Manufacturing Receivers

This is all done at a gunsmith's workshop using the metalcraft labour.

Fuel is required to melt the metal bars.
Automatic receivers take two mechanisms, manual receivers take one.

## Manufacturing Guns

This is all done at a gunsmith's workshop using the mechanic labour.

Semi-automatic guns use manual receivers.
Non-manual guns require an extra mechanism in their manufacture.
Guns often need one to two plant (wood) blocks as handles.

## Guns

There are three types of fire time: add, replace, and multiply.
They each affect the firer's timer until next action accordingly.
Replace does not take skill into account.

- Magazine-fed pistol: small, semi-automatic, fire time 20 (replace)
- Revolver: small, semi-automatic, fire time 25 (replace)
- Submachine gun: small, automatic, fire time 2 (replace)
- Assault rifle: medium, automatic, fire time 2 (replace)
- Light machine gun: medium, automatic fire time 1 (replace)
- Heavy machine gun: large, automatic, fire time 1 (replace)
- Sniper rifle: large, manual, fire time 0 (add) (same fire rate as crossbow)
- Pump-action shotgun: shell, manual, fire time 0.25 (multiply)
- Double-barrel shotgun: shell, manual, fire time 6 (add)
- Sawn-off shotgun: shell, manual, fire time 3 (add)
