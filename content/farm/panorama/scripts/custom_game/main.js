var particle = null;

(function test() {
	var unitId = Players.GetLocalPlayerPortraitUnit();
	var abilityId = Entities.GetAbilityByName(unitId, 'farmer_hoe');
	if (GameUI.GetClickBehaviors() == CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_CAST) {
		var screenPos = GameUI.GetCursorPosition();
		var worldPos = Game.ScreenXYToWorld(screenPos[0], screenPos[1]);
		var gridPos = [ 
			Math.floor(worldPos[0] / 64) * 64 + 32, 
			Math.floor(worldPos[1] / 64) * 64 + 32,
			worldPos[2]
		];
		if (!particle) {
			particle = Particles.CreateParticle('particles/mouse_square.vpcf', ParticleAttachment_t.PATTACH_CUSTOMORIGIN, 0);
		}
		Particles.SetParticleControl(particle, 7, gridPos);
	}
	else if (particle) {
		Particles.DestroyParticleEffect(particle, true);
		particle = null;
	}

	$.Schedule(0, test);
})();