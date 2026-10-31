//////////////////////////////////////////////////////////////
//-- scripts\game\gui\hud\modules\hudModuleRadialMenu.ws --//
////////////////////////////////////////////////////////////

@wrapMethod(CR4HudModuleRadialMenu) 
function OnRadialMenuItemSelected(choosenSymbol : string, isDesaturated : bool )
{
	if( thePlayer.IsSwimming() )
	{ 
		_currentSelection = choosenSymbol;
	}
	wrappedMethod(choosenSymbol, isDesaturated);
}
