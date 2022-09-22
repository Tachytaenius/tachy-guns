--@ module = true

function onLoad()
	exhaustionTable = {}
end

function every1Tick()
	for _, unit in ipairs(df.global.world.units.active) do
		exhaustionTable[unit.id] = unit.counters2.exhaustion
	end
end
