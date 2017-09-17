item_seed_potato = class ({})
LinkLuaModifier( "modifier_plant", "modifiers/modifier_plant.lua", LUA_MODIFIER_MOTION_NONE )

function item_seed_potato:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end


function item_seed_potato:GetCastRange()
	return 128
end


function item_seed_potato:GetCastPoint()
	return 0
end

function item_seed_potato:CastFilterResultTarget( hTarget )
	if hTarget:GetUnitName() ~= "npc_dota_creature_soil" then
		return UF_FAIL_CUSTOM
	end
	if hTarget.planted ~= nil then
		return UF_FAIL_CUSTOM
	end
	return UF_SUCCESS
end


function item_seed_potato:GetCustomCastErrorTarget( hTarget )
	if hTarget:GetUnitName() ~= "npc_dota_creature_soil" then
		return "#dota_hud_error_must_cast_on_hoed_ground"
	end
	if hTarget.planted ~= nil then
		return "#dota_hud_error_soil_has_seed"
	end
	return ""
end


function item_seed_potato:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()

	if hTarget:GetUnitName() == "npc_dota_creature_soil" then
		hTarget.planted = CreateUnitByName("npc_dota_creature_plant_potato", hTarget:GetAbsOrigin(), false, hCaster, nil, hCaster:GetTeam())
		hTarget.planted.soil = hTarget
		hTarget.planted:AddNewModifier(hCaster, nil, "modifier_plant", {})
		hTarget.planted:SetAngles(0, math.random(360), 0)
	end

	local charges = self:GetCurrentCharges()
	self:SetCurrentCharges(charges - 1)
	if self:GetCurrentCharges() <= 0 then
		self:Destroy()
	end
end
