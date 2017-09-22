GameUI.SetMouseCallback(function(eventName, arg) {
	var CONTINUE_PROCESSING_EVENT = false;
	var LEFT_CLICK = (arg === 0);
    var RIGHT_CLICK = (arg === 1);

	if (eventName === "pressed" || eventName === "doublepressed") {
		if (RIGHT_CLICK) {
			e = GameUI.FindScreenEntities(GameUI.GetCursorPosition());
		}
	}
	return CONTINUE_PROCESSING_EVENT;
});