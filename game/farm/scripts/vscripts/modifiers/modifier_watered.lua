modifier_watered = class({})


function modifier_watered:GetStatusEffectName()
	return "particles/status_fx/status_effect_naga_riptide.vpcf"
end


function modifier_watered:StatusEffectPriority()
	return 1000
end


function modifier_watered:OnCreated()
	if IsClient() then return end
	local hParent = self:GetParent()
	if hParent == nil then return end
	hParent:SetRenderColor(180, 180, 180)
end


function modifier_watered:OnDestroy()
	if IsClient() then return end
	local hParent = self:GetParent()
	if hParent == nil then return end
	hParent:SetRenderColor(255, 255, 255)
end