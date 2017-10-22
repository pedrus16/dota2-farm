require('utils')
-- require('items/utils')

LinkLuaModifier( "modifier_plant", "modifiers/modifier_plant.lua", LUA_MODIFIER_MOTION_NONE )


if CAddonFarmGameMode == nil then
	CAddonFarmGameMode = class({})
end

function Precache( context )
	
	PrecacheResource( "model", "models/props_structures/radiant_statue001.vmdl", context )
	
	PrecacheResource( "model", "models/gameplay/cauliflower/cauliflower_00.vmdl", context )
	PrecacheResource( "model", "models/gameplay/cauliflower/cauliflower_01.vmdl", context )
	PrecacheResource( "model", "models/gameplay/cauliflower/cauliflower_seed.vmdl", context )

	PrecacheResource( "model", "models/gameplay/corn/corn_00.vmdl", context )
	PrecacheResource( "model", "models/gameplay/corn/corn_01.vmdl", context )
	PrecacheResource( "model", "models/gameplay/corn/corn_02.vmdl", context )
	PrecacheResource( "model", "models/gameplay/corn/corn_03.vmdl", context )
	PrecacheResource( "model", "models/gameplay/corn/corn_03_full.vmdl", context )
	PrecacheResource( "model", "models/gameplay/corn/corn_dead.vmdl", context )

	PrecacheResource( "model", "models/gameplay/potato/potato_00.vmdl", context )
	PrecacheResource( "model", "models/gameplay/potato/potato_01.vmdl", context )
	PrecacheResource( "model", "models/gameplay/potato/potato_02.vmdl", context )
	PrecacheResource( "model", "models/gameplay/potato/potato_seed.vmdl", context )
	PrecacheResource( "model", "models/gameplay/potato/potato_dead.vmdl", context )

	PrecacheResource( "model", "models/gameplay/soil/soil.vmdl", context )

	PrecacheResource( "model", "models/items/corn/corn_ear.vmdl", context )
	PrecacheResource( "model", "models/items/potato/potato.vmdl", context )
	PrecacheResource( "model", "models/items/wood_log/wood_log.vmdl", context )

	PrecacheResource( "soundfile",  "soundevents/game_sounds.vsndevts", context)
	PrecacheResource( "soundfile",  "soundevents/game_sounds_heroes/game_sounds_tiny.vsndevts", context)
	PrecacheResource( "soundfile",  "soundevents/game_sounds_ui_imported.vsndevts", context)

	PrecacheResource( "particle", "particles/items2_fx/ward_spawn_generic_b.vpcf", context )
	PrecacheResource( "particle", "particles/mouse_square.vpcf", context )
	PrecacheResource( "particle", "particles/status_fx/status_effect_naga_riptide.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_tidehunter/tidehunter_gush_splash_water7_low.vpcf", context )
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonFarm = CAddonFarmGameMode()
	GameRules.AddonFarm:InitGameMode()
end

function CAddonFarmGameMode:InitGameMode()
	print( "Farming Simulator is loaded." )
	GameRules:SetCustomGameSetupAutoLaunchDelay( 0 )
	GameRules:SetStartingGold( 100 )
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
	GameRules:GetGameModeEntity():SetStickyItemDisabled(true)
	GameRules:GetGameModeEntity():SetRecommendedItemsDisabled(true)
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(CAddonFarmGameMode, "OnNPCSpawned"), self)
	ListenToGameEvent("tree_cut", Dynamic_Wrap(CAddonFarmGameMode, "OnTreeCut"), self)
	self.unitsKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
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
		hNPC:HeroLevelUp(false)
		hNPC:HeroLevelUp(false)
		hNPC:AddExperience(1080, DOTA_ModifyXP_Unspecified, false, false)
		if hNPC:HasAbility("farmer_hoe") then
			hNPC:UpgradeAbility(hNPC:FindAbilityByName("farmer_hoe"))
		end
		if hNPC:HasAbility("farmer_watering") then
			hNPC:UpgradeAbility(hNPC:FindAbilityByName("farmer_watering"))
		end
		if hNPC:HasAbility("farmer_refill_water") then
			hNPC:UpgradeAbility(hNPC:FindAbilityByName("farmer_refill_water"))
		end
		if hNPC:HasAbility("farmer_lumberjack") then
			hNPC:UpgradeAbility(hNPC:FindAbilityByName("farmer_lumberjack"))
		end
		for i=1, 5 do hNPC:AddItemByName("item_seed_potato") end
		for i=1, 5 do hNPC:AddItemByName("item_seed_corn") end
	end
	if self.unitsKV[hNPC:GetUnitName()] == nil then return end
	local farmKV = self.unitsKV[hNPC:GetUnitName()]["Farm"]
	if farmKV == nil then return end
	self:FillPlantDescription(hNPC, farmKV)
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


function CAddonFarmGameMode:GetSoilAt( vLocation )
	unitsInTile = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
									vLocation,
									nil,
									32,
									DOTA_UNIT_TARGET_TEAM_BOTH,
									DOTA_UNIT_TARGET_BASIC,
									DOTA_UNIT_TARGET_FLAG_NONE,
									FIND_CLOSEST,
									false)

	for _, unit in pairs(unitsInTile) do
		if unit:GetUnitName() == "npc_dota_creature_soil" then
			return unit
		end
	end
	return nil
end


function CAddonFarmGameMode:FillPlantDescription( hUnit, hKV )
	hUnit.plantDescription = {
		growthDuration = hKV.GrowthDuration,
		timeBeforeDecay = hKV.TimeBeforeDecay,
		harvestItem = hKV.HarvestItem,
		harvest = hKV.Harvest,
		growthStagesModels = hKV.GrowthStagesModels,
		matureModel = hKV.MatureModel,
		harvestedModel = hKV.HarvestedModel,
		deadModel = hKV.DeadModel,
		timeBetweenHarvests = hKV.TimeBetweenHarvests
	}
end