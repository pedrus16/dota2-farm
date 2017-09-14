modifier_soil = class({})

function modifier_soil:CheckState()
	local hasPlant = false
	if self:GetParent().planted then
		hasPlant = true
	end
	local state = {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = hasPlant,
	}
 
	return state
end