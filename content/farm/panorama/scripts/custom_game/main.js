var particle = null;

(function test() {
	var unitId = Players.GetLocalPlayerPortraitUnit();
	var ability = Abilities.GetLocalPlayerActiveAbility();
	var abilityName = Abilities.GetAbilityName(ability);
	if (abilityName === 'farmer_hoe' || abilityName === 'farmer_watering') {
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