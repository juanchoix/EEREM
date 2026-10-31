///////////////////////////////////////////////////
//-- scripts\game\gui\main_menu\ingameMenu.ws --//
/////////////////////////////////////////////////
@addField(CR4IngameMenu)
protected var primer_settings_changed : bool;

@wrapMethod(CR4IngameMenu)
function SaveChangedSettings()
{
	var playerLevel, i : int;
	var player : W3PlayerWitcher;
	
	if (hasChangedOption)
	{
		//W3EE
		player = GetWitcherPlayer();
		Damage().RefreshSettings();
		Combat().SetMaximumAdrenaline();
		Options().ReadOptionValues();
		player.UpdateEncumbrance();
		//W3EE - End
	}
	wrappedMethod();
}
