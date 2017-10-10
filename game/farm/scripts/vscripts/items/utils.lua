function baseItemSeed( sPlantUnit )


	local item_seed_base = class ({})


	function item_seed_base:GetBehavior()
		return DOTA_ABILITY_BEHAVIOR_POINT
	end


	function item_seed_base:GetCastRange()
		return 128
	end


	function item_seed_base:GetCastPoint()
		return 0
	end


	function item_seed_base:CastFilterResultLocation( vLocation )
		if IsClient() then 
			return UF_SUCCESS 
		end
		local hSoil = GameRules.AddonFarm:GetSoilAt(vLocation)
		if hSoil == nil then
			return UF_FAIL_CUSTOM
		end
		if hSoil.planted ~= nil then
			return UF_FAIL_CUSTOM
		end
		return UF_SUCCESS
	end


	function item_seed_base:GetCustomCastErrorLocation( vLocation )
		local hSoil = GameRules.AddonFarm:GetSoilAt(vLocation)
		if hSoil == nil then
			return "#dota_hud_error_must_cast_on_hoed_ground"
		end
		if hSoil.planted ~= nil then
			return "#dota_hud_error_soil_has_seed"
		end
		return ""
	end


	function item_seed_base:OnSpellStart()
		local hCaster = self:GetCaster()
		local vPosition = self:GetCursorPosition()
		local hSoil = GameRules.AddonFarm:GetSoilAt(vPosition)

		if hSoil:GetUnitName() == "npc_dota_creature_soil" then
			hSoil.planted = CreateUnitByName(sPlantUnit, hSoil:GetAbsOrigin(), false, hCaster, nil, hCaster:GetTeam())
			hSoil.planted.soil = hSoil
			hSoil.planted:AddNewModifier(hCaster, nil, "modifier_plant", {})
			hSoil.planted:SetAngles(0, math.random(360), 0)
		end
		hCaster:EmitSound("ui.inv_drop")
		local charges = self:GetCurrentCharges()
		self:SetCurrentCharges(charges - 1)
		if self:GetCurrentCharges() <= 0 then
			self:Destroy()
		end
	end

	return item_seed_base

end


