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
		hPlant.progress = 0
		hPlant.decay = 0
		hPlant.selectable = false
		self:StartIntervalThink(1)
	end
end


function modifier_plant:OnIntervalThink()
	if IsServer() then
		local hPlant = self:GetParent()
		local duration = hPlant.plantDescription.duration
		local delta = Time() - self.tick
		self.tick = Time()
		local growthRate = self:GetSoilGrowthRate()
		if growthRate > 0 then
			hPlant.decay = 0
		elseif hPlant.progress > 0 then
			hPlant.decay = hPlant.decay + (delta / duration) * GROWTH_MULTIPLIER
		end
		hPlant.progress = hPlant.progress + ((delta * growthRate) / duration) * GROWTH_MULTIPLIER
		if hPlant.decay >= 1 then
			hPlant:SetModel(hPlant.plantDescription.decayedModel)
			hPlant.selectable = true
			self:StartIntervalThink(-1)
		elseif not hPlant.hasHarvest then
			if hPlant.progress >= 1 then
				hPlant:SetModel(hPlant.plantDescription.grownModel)
				hPlant.hasHarvest = true
				print(hPlant.plantDescription.harvestCount)
				for i=1, hPlant.plantDescription.harvestCount do
					hPlant:AddItemByName(hPlant.plantDescription.harvestItem)
				end
				hPlant.selectable = true
			elseif hPlant.progress >= 0.75 then
				hPlant:SetModel(hPlant.plantDescription.models["3"])
			elseif hPlant.progress >= 0.5 then
				hPlant:SetModel(hPlant.plantDescription.models["2"])
			elseif hPlant.progress >= 0.25 then
				hPlant:SetModel(hPlant.plantDescription.models["1"])
			end
		end
	end
end


function modifier_plant:UnitInteracts(hUnit)
	local hPlant = self:GetParent()
	if hPlant.decay >= 1 then
		hPlant.soil.planted = nil
		hPlant:Destroy()
	end
	if hPlant.progress >= 1 then
		self:DropHarvest(hUnit)
	end

end

function modifier_plant:DropHarvest(hUnit)
	local hPlant = self:GetParent()
	if not hPlant.hasHarvest then return end
	local hHarvest = hPlant:GetItemInSlot(0)
	if hHarvest == nil then return end
	for i=1, hHarvest:GetCurrentCharges() do
		local hItem = CreateItem(hHarvest:GetName(), nil, nil)
		hItem:SetPurchaser(hUnit)
		hItem:SetPurchaseTime(10)
		local hPhysItem = CreateItemOnPositionSync(hPlant:GetAbsOrigin(), hItem)
		hPhysItem:SetAngles(0, RandomInt(1, 360), 0)
		hItem:LaunchLoot(false, RandomInt(64, 128), 0.4, hPlant:GetAbsOrigin() + RandomVector(1):Normalized() * 64)
	end
	hPlant:RemoveItem(hHarvest)
	if hPlant.plantDescription.permanent then
		hPlant:SetModel(hPlant.plantDescription.emptyModel)
		hPlant.hasHarvest = false
	else
		hPlant.soil.planted = nil
		hPlant:Destroy()
	end
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
	return self:GetParent().progress
end