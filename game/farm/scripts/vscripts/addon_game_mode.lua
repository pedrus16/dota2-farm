-- Generated from template

if CAddonFarmGameMode == nil then
	CAddonFarmGameMode = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonFarm = CAddonFarmGameMode()
	GameRules.AddonFarm:InitGameMode()
end

function CAddonFarmGameMode:InitGameMode()
	print( "Farming Simulator is loaded." )
	GameRules:SetCustomGameSetupAutoLaunchDelay( 0 )
	GameRules:SetStartingGold( 250 )
	GameRules:SetGoldTickTime( 999999.0 )
	GameRules:SetGoldPerTick( 0 )
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:GetGameModeEntity():SetCameraSmoothCountOverride( 2 )
	GameRules:GetGameModeEntity():SetCustomGameForceHero( "npc_dota_hero_meepo" )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(CAddonFarmGameMode, "OrderFilter"), self)
end

-- Evaluate the state of the game
function CAddonFarmGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Farming Simulator script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end


function CAddonFarmGameMode:OrderFilter(event)

	if event.order_type ~= DOTA_UNIT_ORDER_MOVE_TO_TARGET then return true end
	local hTarget = EntIndexToHScript(event.entindex_target)
	if hTarget == nil then return true end
	local distance = nil
	local hUnit = nil
	for _, entID in pairs(event.units) do
		hUnit = EntIndexToHScript(entID)
		distance = CalcDistanceBetweenEntityOBB(hUnit, hTarget)
		break
	end
	if distance == nil or distance > 128 then return true end
	local hModifier = hTarget:FindModifierByName("modifier_plant")
	if hModifier == nil then return true end
	if hModifier:GetProgress() < 1 then return true end

	hModifier:DropHarvest(hUnit:GetOwner())

	return true

end