modifier_plant = class({})

function modifier_plant:CheckState()
	local state = {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
 
	return state
end


function modifier_plant:OnCreated()
	if IsServer() then
		local plant = self:GetParent()
		plant.plantTime = Time()
		self:StartIntervalThink(1)
	end
end


function modifier_plant:OnIntervalThink()
	if IsServer() then
		local plant = self:GetParent()
		local duration = 30
		local timeSpan = Time() - plant.plantTime
		local progress = timeSpan / duration
		if progress >= 1 then
			plant:SetModel("models/corn_low_03.vmdl")
			plant:
		elseif progress >= 0.75 then
			plant:SetModel("models/corn_low_02.vmdl")
		elseif progress >= 0.5 then
			plant:SetModel("models/corn_low_01.vmdl")
		elseif progress >= 0.25 then
			plant:SetModel("models/corn_low_00.vmdl")
		end
		if progress >= 1 then
			self:StartIntervalThink(-1)
		end
	end
end