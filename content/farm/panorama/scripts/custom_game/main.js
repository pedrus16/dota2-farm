// This is an example of how to use the GameUI.SetMouseCallback function
GameUI.SetMouseCallback( function( eventName, arg ) {
	var CONSUME_EVENT = true;
	var CONTINUE_PROCESSING_EVENT = false;

	if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE ) {
		return CONTINUE_PROCESSING_EVENT;
	}

	return CONTINUE_PROCESSING_EVENT;
} );