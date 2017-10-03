modifier_soil = class({})

function modifier_soil:CheckState()
	local state = {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
	}
 
	return state
end

function modifier_soil:IsHidden()
	return true
end

function modifier_soil:GetGrowthRate()
	local hSoil = self:GetParent()
	if hSoil == nil then return 0 end
	local hWatered = hSoil:FindModifierByName("modifier_watered")
	if hWatered == nil then return 0 end
	return 1
end