farmer_refill_water = class ({})


function farmer_refill_water:GetBehavior() 
	return bit.bor(DOTA_ABILITY_BEHAVIOR_NO_TARGET) 
end


function farmer_refill_water:GetCastRange()	
	return 128 
end


function farmer_refill_water:GetCastPoint()	
	return 0.4 
end


function farmer_refill_water:CastFilterResultLocation( vLocation )
	if IsClient() then 
		return UF_SUCCESS 
	end
	return UF_SUCCESS
end


function farmer_refill_water:GetCustomCastErrorLocation( vLocation )
	if IsClient() then 
		return "" 
	end
	return ""
end


function farmer_refill_water:OnSpellStart()
	local hModifier = self:GetCaster():FindModifierByName("modifier_watering_can")
	if hModifier == nil then return end
	hModifier:Refill()
end