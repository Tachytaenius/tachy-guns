# Tachy Guns

## Installation

- Merge `raw/` with your DF(Hack) installation's `raw/`.
	This contains the scripts that actually give functionality to the content.
- Pick a content pack from `content-packs/` and merge its `raw/` with your DF(Hack) installation's `raw/`.
- In the content pack's directory, `add-to-entity.txt` contains raw text that you paste into the entity definition for the entity you want to be able to use guns, so don't forget that.
- Check for any dependency content packs (modern and classical both requrie an alchemist's laboratory) and install those too.

## Notes

- Behaviour around the content added by the gun mod may break if the script is not on.
	It will leave a message in the console ("Tachy Guns enabled!") when activated.
- Lead doesn't work very well for bullets (mostly bruising, though it is lethal) due to DF's own internal mechanics.
