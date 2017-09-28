farmer_watering = class ({})
LinkLuaModifier( "modifier_watered", "modifiers/modifier_watered.lua", LUA_MODIFIER_MOTION_NONE )

function farmer_watering:GetBehavior()
	return bit.bor(DOTA_ABILITY_BEHAVIOR_UNIT_TARGET, DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING)
end


function farmer_watering:GetCastRange()
	return 128
end


function farmer_watering:GetCastPoint()
	return 0.4
end

function farmer_watering:CastFilterResultTarget( hTarget )
	if hTarget:GetUnitName() ~= "npc_dota_creature_soil" then
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end


function farmer_watering:GetCustomCastErrorTarget( hTarget )
	if hTarget:GetUnitName() ~= "npc_dota_creature_soil" then
		return "#dota_hud_error_must_cast_on_hoed_ground"
	end
	return ""
end


function farmer_watering:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()

	local nFXIndex = ParticleManager:CreateParticle( "particles/econ/courier/courier_kunkka_parrot/courier_kunkka_parrot_splash_c.vpcf", PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( nFXIndex, 0, hTarget:GetOrigin() )
	hCaster:EmitSound("BaseEntity.ExitWater")
	if hTarget:GetUnitName() == "npc_dota_creature_soil" then
		local hModifier = hTarget:AddNewModifier( hCaster, nil, "modifier_watered", {})
		hModifier:SetDuration(self:GetSpecialValueFor("duration"), true)
	end
end
