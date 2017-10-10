
-- Returns one of hTable's key depending on the weight defined for each key.
-- Example: { "key1" = 0.5, "key2" = 0.25, "key3" = 0.25 }
function randomWeightedChoice( hTable )
	local weight_sum = 0
	for k, v in pairs(hTable) do
		weight_sum = weight_sum + v
	end
	local random = RandomFloat(0, weight_sum)
	for k, v in pairs(harvest) do
		if random < v then
			return k
		end
		random = random - v
	end
end