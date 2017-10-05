modifier_watered = class({})

function modifier_watered:GetStatusEffectName()
	return "particles/status_fx/status_effect_naga_riptide.vpcf"
end

function modifier_watered:StatusEffectPriority()
	return 1000
end