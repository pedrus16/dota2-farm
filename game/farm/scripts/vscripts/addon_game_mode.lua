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
	PrecacheResource( "soundfile",  "soundevents/game_sounds.vsndevts", context)
	PrecacheResource( "soundfile",  "soundevents/game_sounds_ui_imported.vsndevts", context)
	PrecacheResource( "soundfile",  "soundevents/game_sounds_heroes/game_sounds_tiny.vsndevts", context)
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
	GameRules:SetTreeRegrowTime(-1)
	GameRules:SetPreGameTime(0)
	GameRules:GetGameModeEntity():SetCameraSmoothCountOverride( 2 )
	GameRules:GetGameModeEntity():SetCustomGameForceHero( "npc_dota_hero_meepo" )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(CAddonFarmGameMode, "OrderFilter"), self)
	GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter(Dynamic_Wrap(CAddonFarmGameMode, "InventoryFilter"), self)
	GameRules:GetGameModeEntity():SetStashPurchasingDisabled(true)
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(CAddonFarmGameMode, "OnNPCSpawned"), self)
	ListenToGameEvent("tree_cut", Dynamic_Wrap(CAddonFarmGameMode, "OnTreeCut"), self)
	self.units = LoadKeyValues("scripts/npc/npc_units_custom.txt")
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


function CAddonFarmGameMode:OrderFilter( event )
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

	hModifier:UnitInteracts(hUnit)

	return true
end


function CAddonFarmGameMode:InventoryFilter( event )
	local hUnit = EntIndexToHScript(event.inventory_parent_entindex_const)
	local hItem = EntIndexToHScript(event.item_entindex_const)
	hItem:SetPurchaser(hUnit)
	hItem:SetPurchaseTime(10)
	return true
end


function CAddonFarmGameMode:OnNPCSpawned( event )
	local hNPC = EntIndexToHScript(event.entindex)
	if hNPC:IsRealHero() then
		hNPC:HeroLevelUp(false)
		if hNPC:HasAbility("farmer_hoe") then
			hNPC:FindAbilityByName("farmer_hoe"):SetLevel(1)
		end
		if hNPC:HasAbility("farmer_watering") then
			hNPC:FindAbilityByName("farmer_watering"):SetLevel(1)
		end
		if hNPC:HasAbility("farmer_lumberjack") then
			hNPC:FindAbilityByName("farmer_lumberjack"):SetLevel(1)
		end
		for i=1, 5 do
			hNPC:AddItemByName("item_seed_potato")
		end
	end
	if self.units[hNPC:GetUnitName()] == nil then return end
	local farmKV = self.units[hNPC:GetUnitName()]["Farm"]
	if farmKV == nil then return end
	hNPC.plantDescription = {
		duration = farmKV.GrowthDuration,
		decayDuration = farmKV.DecayDuration,
		harvestItem = farmKV.Harvest,
		harvestCount = farmKV.HarvestCount,
		models = farmKV.GrowthModels,
		grownModel = farmKV.FullyGrownModel,
		emptyModel = farmKV.HarvestedModel,
		decayedModel = farmKV.DecayedModel,
		permanent = farmKV.Permanent == "1"
	}
end

function CAddonFarmGameMode:OnTreeCut( event )
	local vOrigin = Vector(event.tree_x, event.tree_y)
	for i=1, 3 do
		local hItem = CreateItem("item_wood_log", nil, nil)
		local hPhysItem = CreateItemOnPositionSync(vOrigin, hItem)
		hPhysItem:SetAngles(0, RandomInt(1, 360), 0)
		hItem:LaunchLoot(false, RandomInt(64, 128), 0.4, vOrigin + RandomVector(1):Normalized() * 16)
	end
end