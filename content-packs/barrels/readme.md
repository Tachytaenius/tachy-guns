# Barrels Content Pack

## Installation

This pack's `add-to-entity.txt` is optional, as the content packs that depend on this one have `TOOL` tokens for the barrels that they use while not including unused barrels, which would make caravans cleaner.
It is recommended to not install it and use the first of the techniques listed below.

## Manufacturing

There are 9 different barrel types, and they are all added to entity as tools, so you can forge them in "other objects" at a metalsmith's forge.
They suffer from the same problem as high/low boots do in vanilla, which is that item subtype adjectives are not shown by the item creation jobs they generate, but that means they have the same solutions.
You could either use `gui/gm-editor` to poke around and see if your job or manager order (see `df.global.world.manager_orders`) is on the right item subtype, or, if you used this pack's `add-to-entity.txt`, refer to the order that they appear in in-game:

- Short small barrel
- Medium-length small barrel
- Long small barrel
- Short medium barrel
- Medium-length medium barrel
- Long medium barrel
- Short large barrel
- Medium-length large barrel
- Long large barrel
