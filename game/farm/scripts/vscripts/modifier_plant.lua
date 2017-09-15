modifier_plant = class({})

function modifier_plant:CheckState()
	local hPlant = self:GetParent()
	local state = {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_UNSELECTABLE] = not hPlant.harvest,
	}
 
	return state
end


function modifier_plant:OnCreated()
	if IsServer() then
		local hPlant = self:GetParent()
		hPlant.plantTime = Time()
		self:StartIntervalThink(1)
	end
end


function modifier_plant:OnIntervalThink()
	if IsServer() then
		local hPlant = self:GetParent()
		local duration = 5
		local timeSpan = Time() - hPlant.plantTime
		local progress = timeSpan / duration
		self.progress = progress
		if progress >= 1 then
			hPlant:SetModel("models/corn_low_03_full.vmdl")
			hPlant.harvest = 3
			self:StartIntervalThink(-1)
		elseif progress >= 0.75 then
			hPlant:SetModel("models/corn_low_02.vmdl")
		elseif progress >= 0.5 then
			hPlant:SetModel("models/corn_low_01.vmdl")
		elseif progress >= 0.25 then
			hPlant:SetModel("models/corn_low_00.vmdl")
		end
	end
end


function modifier_plant:DropHarvest()

	local hPlant = self:GetParent()
	if hPlant.harvest <= 0 then return end
	for i=1, hPlant.harvest do
		local hItem = CreateItem("item_harvest_corn", nil, nil)
		local hPhysItem = CreateItemOnPositionForLaunch(hPlant:GetAbsOrigin() + Vector(0, 0, 64), hItem)
		hItem:LaunchLoot(false, 128, 0.4, hPlant:GetAbsOrigin() + RandomVector(1):Normalized() * 64)
	end
	hPlant:SetModel("models/corn_low_03.vmdl")
	hPlant.harvest = 0

end