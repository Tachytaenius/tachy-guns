local customRawTokens = require("custom-raw-tokens")

-- this is an onProjItemCheckMovement event listener
local function stuckInDamage(item, unit, wound, a, b)
	if not item._type == df.item_ammost then return end
	local extraDamage = tonumber(customRawTokens.getToken(item.subtype, "STUCKIN_DAMAGE_MULTIPLIER"))
	if not extraDamage then
		return
	end
	for _, part in ipairs(wound.parts) do
		part.bleeding = part.bleeding * extraDamage
	end
end

return stuckInDamage
