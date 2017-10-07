modifier_watering_can = class({})


local MAX_QUANTITY = 20

function modifier_watering_can:IsPassive()
	return true
end


function modifier_watering_can:IsDebuff()
	return self:GetStackCount() <= 0
end


function modifier_watering_can:OnCreated( table )
	self:SetStackCount(MAX_QUANTITY)
	self:ToggleAbilities()
end


function modifier_watering_can:ToggleAbilities()
	if IsClient() then return end
	local iStackCount = self:GetStackCount()
	local hParent = self:GetParent()
	if hParent == nil then return end
	local hWateringAbility = hParent:FindAbilityByName("farmer_watering")
	local hRefillAbility = hParent:FindAbilityByName("farmer_refill_water")
	if hWateringAbility == nil or hRefillAbility == nil then return end
	if iStackCount > 0 then
		hWateringAbility:SetHidden(false)
		hRefillAbility:SetHidden(true)
	else
		hWateringAbility:SetHidden(true)
		hRefillAbility:SetHidden(false)
	end
end


function modifier_watering_can:OnStackCountChanged( iStackCount )
	self:ToggleAbilities()
end


function modifier_watering_can:Refill()
	self:SetStackCount(MAX_QUANTITY)
end