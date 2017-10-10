modifier_plant = class({})

local GROWTH_MULTIPLIER = 1

if IsInToolsMode() then
	GROWTH_MULTIPLIER = 100
end

function modifier_plant:CheckState()
	local hPlant = self:GetParent()
	local state = {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_UNSELECTABLE] = not hPlant.selectable,
	}
 
	return state
end

function modifier_plant:IsHidden()
	return true
end

function modifier_plant:OnCreated()
	if IsServer() then
		local hPlant = self:GetParent()
		hPlant.plantTime = Time()
		self.tick = hPlant.plantTime
		hPlant.growthProgress = 0
		hPlant.harvestProgress = 1
		hPlant.decay = 0
		hPlant.selectable = false
		hPlant.harvestCount = 0
		self:StartIntervalThink(1)
	end
end


function modifier_plant:OnIntervalThink()
	if IsServer() then
		local hPlant = self:GetParent()
		local duration = hPlant.plantDescription.growthDuration
		local timeBetweenHarvests = hPlant.plantDescription.timeBetweenHarvests
		local delta = Time() - self.tick
		self.tick = Time()
		local growthRate = self:GetSoilGrowthRate()
		if growthRate > 0 then
			hPlant.decay = 0
		elseif hPlant.growthProgress > 0 then
			hPlant.decay = hPlant.decay + (delta / duration) * GROWTH_MULTIPLIER
		end
		hPlant.growthProgress = hPlant.growthProgress + ((delta * growthRate) / duration) * GROWTH_MULTIPLIER
		if hPlant.decay >= 1 then
			hPlant:SetModel(hPlant.plantDescription.deadModel)
			hPlant.selectable = true
			self:StartIntervalThink(-1)
		elseif hPlant.harvestCount <= 0 then
			if hPlant.growthProgress >= 1 then
				if hPlant.harvestProgress >= 1 then
					self:SetPlantHarvestable(hPlant)
				else
					hPlant.harvestProgress = hPlant.harvestProgress + ((delta * growthRate) / timeBetweenHarvests) * GROWTH_MULTIPLIER
				end
			else
				self:SetModelFromProgress(hPlant)
			end
		end
	end
end


function modifier_plant:SetModelFromProgress(hPlant)
	local models = hPlant.plantDescription.growthStagesModels
	local stagesCount = 1
	local index = 1
	local model = nil
	for _, v in pairs(models) do stagesCount = stagesCount + 1 end
	for index = 1, stagesCount do
		if hPlant.growthProgress >= (index / stagesCount) then
			model = models[tostring(index)]
		end
	end
	if model then
		hPlant:SetModel(model)
	end
end


function modifier_plant:UnitInteracts(hUnit)
	if IsServer() then
		local hPlant = self:GetParent()
		if hPlant.decay >= 1 then
			hPlant.soil.planted = nil
			hPlant:Destroy()
		end
		if hPlant.harvestCount > 0 then
			self:DropHarvest(hUnit)
		end
	end

end


function modifier_plant:DropHarvest(hUnit)
	local hPlant = self:GetParent()
	for i=1, hPlant.harvestCount do
		local hItem = CreateItem(hPlant.plantDescription.harvestItem, nil, nil)
		hItem:SetPurchaser(hUnit)
		hItem:SetPurchaseTime(10)
		local hPhysItem = CreateItemOnPositionSync(hPlant:GetAbsOrigin(), hItem)
		hPhysItem:SetAngles(0, RandomInt(1, 360), 0)
		hItem:LaunchLoot(false, RandomInt(64, 128), 0.4, hPlant:GetAbsOrigin() + RandomVector(1):Normalized() * 64)
	end
	hPlant.harvestCount = 0
	if hPlant.plantDescription.timeBetweenHarvests ~= nil then
		hPlant:SetModel(hPlant.plantDescription.harvestedModel)
		hPlant.harvestProgress = 0
	else
		hPlant.soil.planted = nil
		hPlant:Destroy()
	end
	hPlant.selectable = false
end


function modifier_plant:GetSoilGrowthRate()
	local hPlant = self:GetParent()
	local hSoil = hPlant.soil
	if hSoil == nil then return 0 end
	local hSoilModifier = hSoil:FindModifierByName("modifier_soil")
	if hSoilModifier == nil then return 0 end
	return hSoilModifier:GetGrowthRate()
end


function modifier_plant:GetProgress()
	return self:GetParent().growthProgress
end


function modifier_plant:SetPlantHarvestable( hPlant )
	hPlant:SetModel(hPlant.plantDescription.matureModel)
	local harvest = hPlant.plantDescription.harvest
	if harvest and type(harvest) ~= 'table' then
		hPlant.harvestCount = hPlant.plantDescription.harvest
	else
		hPlant.harvestCount = tonumber(randomWeightedChoice(hPlant.plantDescription.harvest))
	end
	hPlant.selectable = true
end