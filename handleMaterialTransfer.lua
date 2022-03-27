local customRawTokens = require("custom-raw-tokens")

local disconnect_clutter

-- This is an onReactionComplete event listener
local function handleMaterialTransfer(reaction, reactionProduct, unit, inputItems, inputReagents, outputItems)
	if not customRawTokens.getToken(reaction, "TRANSFER_HANDLE_MATERIAL_TO_PRODUCT_IMPROVEMENT") then return end
	
	for i, reagent in ipairs(inputReagents) do
		if reagent.code == "handle" then
			-- Found handle reagent
			local item = inputItems[i] -- hopefully found handle item
			local new = df.itemimprovement_itemspecificst:new()
			new.mat_type, new.mat_index = item.mat_type, item.mat_index
			-- new.maker = outputItems[0].maker -- not a typical improvement
			new.type = df.itemimprovement_specific_type.HANDLE 
			outputItems[0].improvements:insert("#", new)
			-- break -- multiple handles, multiple "the handle is made from"s
		end
	end
end

function disconnect_clutter(item)
    local bld = dfhack.items.getHolderBuilding(item)
    if not bld then return true end
    -- remove from contained items list, fail if not found
    local found = false
    for i,contained_item in ipairs(bld.contained_items) do
        if contained_item.item == item then
            bld.contained_items:erase(i)
            found = true
            break
        end
    end
    if not found then
        dfhack.printerr('failed to find clutter item in expected building')
        return false
    end
    -- remove building ref from item and move item into containing map block
    -- we do this manually instead of calling dfhack.items.moveToGround()
    -- because that function will cowardly refuse to work with items with
    -- BUILDING_HOLDER references (because it could crash the game). However,
    -- we know that this particular setup is safe to work with.
    for i,ref in ipairs(item.general_refs) do
        if ref:getType() == df.general_ref_type.BUILDING_HOLDER then
            item.general_refs:erase(i)
            -- this call can return failure, but it always succeeds in setting
            -- the required item flags and adding the item to the map block,
            -- which is all we care about here. dfhack.items.moveToBuilding()
            -- will fix things up later.
            item:moveToGround(item.pos.x, item.pos.y, item.pos.z)
            return true
        end
    end
    return false
end

return handleMaterialTransfer
