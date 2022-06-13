--@ module = true

function onLoad()
	exhaustionTable = {}
end

function onTick()
	for _, unit in ipairs(df.global.world.units.active) do
		exhaustionTable[unit.id] = unit.counters2.exhaustion
	end
end

-- function onUnitNewActive(id)
-- 	-- TODO: when onUnitNewActive is fixed, see whether onProjItemCheckMovement or onUnitNewActive is called first
-- end
