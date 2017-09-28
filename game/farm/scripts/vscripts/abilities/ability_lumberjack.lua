farmer_lumberjack = class ({})
LinkLuaModifier( "modifier_lumberjack", "modifiers/modifier_lumberjack.lua", LUA_MODIFIER_MOTION_NONE )

function farmer_lumberjack:GetBehavior()
	return bit.bor(DOTA_ABILITY_BEHAVIOR_UNIT_TARGET, DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING)
end

function farmer_lumberjack:GetCastRange()
	return self:GetCaster():GetAttackRange()
end

function farmer_lumberjack:GetCastPoint()
	return 0.4
end

function farmer_lumberjack:GetIntrinsicModifierName()
	return "modifier_lumberjack"
end

function farmer_lumberjack:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()

	hCaster:EmitSound("Hero_Tiny_Tree.Attack")
	hTarget.hits = 1 + (hTarget.hits or 0)
	if hTarget.hits > 2 then
		hTarget:CutDown(DOTA_TEAM_GOODGUYS)
	end
end