modifier_watered = class({})

function modifier_watered:OnCreated()
	local particleId = ParticleManager:CreateParticle("particles/status_fx/status_effect_rum.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	self:AddParticle(particleId, false, true, 1, true, false)
end