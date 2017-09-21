modifier_lumberjack = class({})

function modifier_lumberjack:DeclareFunctions()
	local funcs = {
		-- MODIFIER_PROPERTY_CAN_ATTACK_TREES,
	}
 
	return funcs
end

function modifier_lumberjack:GetModifierCanAttackTrees()
    return 1
end

function modifier_lumberjack:IsHidden()
	return true
end