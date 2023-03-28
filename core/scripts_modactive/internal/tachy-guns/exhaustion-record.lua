--@ module = true

function onLoad()
	exhaustionTable = {}
	previousExhaustionTable = {}
end

function every1Tick()
	for _, unit in ipairs(df.global.world.units.active) do
		previousExhaustionTable[unit.id] = exhaustionTable[unit.id]
		exhaustionTable[unit.id] = unit.counters2.exhaustion
	end
end
