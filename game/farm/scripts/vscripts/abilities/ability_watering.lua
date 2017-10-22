farmer_watering = class ({})
LinkLuaModifier( "modifier_watering_can", "modifiers/modifier_watering_can.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_watered", "modifiers/modifier_watered.lua", LUA_MODIFIER_MOTION_NONE )


function farmer_watering:GetBehavior() 
	return bit.bor(DOTA_ABILITY_BEHAVIOR_UNIT_TARGET, DOTA_ABILITY_BEHAVIOR_POINT, DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING) 
end


function farmer_watering:GetCastRange()	
	return 128 
end


function farmer_watering:GetCastPoint()	
	return 0.4 
end


function farmer_watering:GetIntrinsicModifierName()
	return "modifier_watering_can"
end


function farmer_watering:IsHidden()
	local hCaster = self:GetCaster()
	local hModifier = self:GetCaster():FindModifierByName("modifier_watering_can")
	if hModifier == nil then return end
	return hModifier:GetStackCount() <= 0
end


function farmer_watering:CastFilterResultLocation( vLocation )
	if IsClient() then 
		return UF_SUCCESS 
	end
	local hModifier = self:GetCaster():FindModifierByName("modifier_watering_can")
	if hModifier == nil or hModifier:GetStackCount() <= 0 then
		return UF_FAIL_CUSTOM
	end
	if GameRules.AddonFarm:GetSoilAt(vLocation) == nil then
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end


function farmer_watering:GetCustomCastErrorLocation( vLocation )
	if IsClient() then 
		return "" 
	end
	local hModifier = self:GetCaster():FindModifierByName("modifier_watering_can")
	if hModifier == nil or hModifier:GetStackCount() <= 0 then
		return "#dota_hud_error_empty"
	end
	if GameRules.AddonFarm:GetSoilAt(vLocation) == nil then
		return "#dota_hud_error_must_cast_on_hoed_ground"
	end
	return ""
end


function farmer_watering:CastFilterResultTarget( hTarget )
	if hTarget and hTarget:GetUnitName() ~= "npc_dota_creature_building_well" then
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end


function farmer_watering:GetCustomCastErrorTarget( hTarget )
	return ""
end


function farmer_watering:OnSpellStart()
	local hCaster = self:GetCaster()
	local vPosition = self:GetCursorPosition()
	local hSoil = GameRules.AddonFarm:GetSoilAt(vPosition)
	local hTarget = self:GetCursorTarget()
	
	if hTarget and hTarget:GetUnitName() == "npc_dota_creature_building_well" then
		-- Refill watering can
		local hModifier = self:GetCaster():FindModifierByName("modifier_watering_can")
		if hModifier == nil then return end
		hModifier:Refill()
	else
		-- Pour water
		if hSoil == nil then return end
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_tidehunter/tidehunter_gush_splash_water7_low.vpcf", PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 3, hSoil:GetOrigin() )
		hCaster:EmitSound("BaseEntity.ExitWater")
		local duration = self:GetSpecialValueFor("duration")
		local hModifier = hSoil:AddNewModifier( hCaster, self, "modifier_watered", { duration = duration })
		self:ConsumeWater()
	end
end


function farmer_watering:ConsumeWater()
	local hCaster = self:GetCaster()
	local hModifier = self:GetCaster():FindModifierByName("modifier_watering_can")
	if hModifier == nil then return end
	hModifier:DecrementStackCount()
end