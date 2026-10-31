/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Potion_Tiara extends W3ChangeMaxStatEffect //W3EE
{
	//private var visionStrength : float; //W3EE

	//default effectType = EET_KillerWhale; //W3EE
	//default stat = BCS_Air; //W3EE
	
	default effectType = EET_Tiara; //W3EE
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		//SetUnderWaterBrightness(visionStrength); //W3EE
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		//SetUnderWaterBrightness(1); //W3EE
	}
	//W3EE - Begin
	/*
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		var min, max : SAbilityAttributeValue;
		
		super.OnLoad(t, eff);
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'vision_strength', min, max);
		visionStrength = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
	}
		
	public function CacheSettings()
	{
		var min, max : SAbilityAttributeValue;
	
		super.CacheSettings();
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'vision_strength', min, max);
		visionStrength = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
	}
	*/
	//W3EE - End
}