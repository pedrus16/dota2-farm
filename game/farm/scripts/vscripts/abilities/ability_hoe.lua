farmer_hoe = class ({})
LinkLuaModifier( "modifier_soil", LUA_MODIFIER_MOTION_NONE )

function farmer_hoe:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_POINT	
end


function farmer_hoe:GetCastRange()
	return 128
end


function farmer_hoe:GetCastPoint()
	return 0.1
end


function farmer_hoe:CastFilterResultLocation( vLocation )
 	if IsClient() then
 		return UF_SUCCESS
 	end

	vLocation.x = math.floor(vLocation.x / 128) * 128 + 64
	vLocation.y = math.floor(vLocation.y / 128) * 128 + 64

	unitsInTile = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
									vLocation,
									nil,
									64,
									DOTA_UNIT_TARGET_TEAM_BOTH,
									DOTA_UNIT_TARGET_BASIC,
									DOTA_UNIT_TARGET_FLAG_NONE,
									FIND_ANY_ORDER,
									false)

	for _, unit in pairs(unitsInTile) do
		if unit:GetUnitName() == "npc_dota_creature_soil" then
			return UF_FAIL_CUSTOM
		end
	end

	return UF_SUCCESS
end


function farmer_hoe:GetCustomCastErrorLocation( vLocation )
 	if IsClient() then
 		return ""
 	end

	vLocation.x = math.floor(vLocation.x / 128) * 128 + 64
	vLocation.y = math.floor(vLocation.y / 128) * 128 + 64

	unitsInTile = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
									vLocation,
									nil,
									64,
									DOTA_UNIT_TARGET_TEAM_BOTH,
									DOTA_UNIT_TARGET_BASIC,
									DOTA_UNIT_TARGET_FLAG_NONE,
									FIND_ANY_ORDER,
									false)

	for _, unit in pairs(unitsInTile) do
		if unit:GetUnitName() == "npc_dota_creature_soil" then
			return "#dota_hud_error_ground_already_hoed"
		end
	end

	return ""
end


function farmer_hoe:OnSpellStart()
	local hCaster = self:GetCaster()
	local vLocation = self:GetCursorPosition()

	vLocation.x = math.floor(vLocation.x / 128) * 128 + 64
	vLocation.y = math.floor(vLocation.y / 128) * 128 + 64

	local unit = CreateUnitByName("npc_dota_creature_soil", vLocation, false, hCaster, nil, hCaster:GetTeam())
	unit:AddNewModifier( hCaster, nil, "modifier_soil", {})
end
