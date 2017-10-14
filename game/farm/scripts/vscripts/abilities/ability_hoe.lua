farmer_hoe = class ({})
LinkLuaModifier( "modifier_soil", "modifiers/modifier_soil.lua", LUA_MODIFIER_MOTION_NONE )

TILE_SIZE = 64

function farmer_hoe:GetBehavior()
	return bit.bor(DOTA_ABILITY_BEHAVIOR_POINT, DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING)
end


function farmer_hoe:GetCastRange()
	return 128
end


function farmer_hoe:GetCastPoint()
	return self:GetSpecialValueFor('duration')
end


function farmer_hoe:GetPlaybackRateOverride()
	return 0.43 / self:GetSpecialValueFor('duration')
end


function farmer_hoe:CastFilterResultLocation( vLocation )
 	if IsClient() then
 		return UF_SUCCESS
 	end

	vLocation.x = GridNav:GridPosToWorldCenterX(GridNav:WorldToGridPosX(vLocation.x))
	vLocation.y = GridNav:GridPosToWorldCenterY(GridNav:WorldToGridPosY(vLocation.y))
	if GridNav:IsBlocked(vLocation) then
		return UF_FAIL_CUSTOM
	end
	local hCaster = self:GetCaster()
	if not GridNav:CanFindPath(hCaster:GetAbsOrigin(), vLocation) then
		return UF_FAIL_CUSTOM
	end

	if GameRules.AddonFarm:GetSoilAt(vLocation) then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end


function farmer_hoe:GetCustomCastErrorLocation( vLocation )
 	if IsClient() then
 		return ""
 	end

	vLocation.x = GridNav:GridPosToWorldCenterX(GridNav:WorldToGridPosX(vLocation.x))
	vLocation.y = GridNav:GridPosToWorldCenterY(GridNav:WorldToGridPosY(vLocation.y))
	local vGridPos = Vector(GridNav:WorldToGridPosX(vLocation.x), GridNav:WorldToGridPosY(vLocation.y), 0)
	if GridNav:IsBlocked(vLocation) then
		return "#dota_hud_error_location_not_clear"
	end
	local hCaster = self:GetCaster()
	if not GridNav:CanFindPath(hCaster:GetAbsOrigin(), vLocation) then
		return "#dota_hud_error_location_cant_reach"
	end

	if GameRules.AddonFarm:GetSoilAt(vLocation) then
		return "#dota_hud_error_ground_already_hoed"
	end

	return ""
end


function farmer_hoe:OnSpellStart()
	local hCaster = self:GetCaster()
	local vLocation = self:GetCursorPosition()

	vLocation.x = GridNav:GridPosToWorldCenterX(GridNav:WorldToGridPosX(vLocation.x))
	vLocation.y = GridNav:GridPosToWorldCenterY(GridNav:WorldToGridPosY(vLocation.y))

	local hUnit = CreateUnitByName("npc_dota_creature_soil", vLocation, false, hCaster, nil, hCaster:GetTeam())
	-- hUnit:SetAngles(0, RandomInt(1, 360), 0)
	hUnit:AddNewModifier( hCaster, nil, "modifier_soil", {})
	local iParticleId = ParticleManager:CreateParticle("particles/items2_fx/ward_spawn_generic_b.vpcf", PATTACH_ABSORIGIN, hUnit)
	-- Randomize the effect's rotation
	ParticleManager:SetParticleControl(iParticleId, 1, Vector(0, RandomFloat(1, 360), 0))
	hCaster:EmitSound("Tiny.Grow")
end
