/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Mutation11Buff extends CBaseGameplayEffect
{
	default effectType = EET_Mutation11Buff;
	default isPositive = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		var min, max			: SAbilityAttributeValue;		
		
		super.OnEffectAdded( customParams );
		
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation11', 'health_prc', min, max );		
		target.ForceSetStat( BCS_Vitality, target.GetMaxHealth() * min.valueAdditive );
	}

	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		
		GetWitcherPlayer().Mutation11StartAnimation();
		
		
		target.ResumeHPRegenEffects( '', true );
		
		
		target.StartVitalityRegen();
		
		
		target.AddEffectDefault( EET_Mutation11Immortal, target, "Mutation 11", false );
		
		//W3EE - Begin
		if( sourceName == "Mutation 11" )
			theGame.MutationHUDFeedback( MFT_PlayRepeat );
		//W3EE - End
	}
	
	event OnEffectRemoved()
	{
		//W3EE - Begin
		var bleedingEffect : W3Effect_Bleeding;
		var poiseEffect : W3Effect_Poise;
		var maxPoise : float;
		
		target.RemoveBuff( EET_Mutation11Immortal );
		
		if( sourceName == "Mutation 11" )
			target.AddEffectDefault( EET_Mutation11Debuff, NULL, "Mutation 11 Debuff", false );
		else if( GaunterMode().ConfigDeathMod() > 0 )
			target.AddEffectDefault( EET_Mutation11Debuff, NULL, "GM Debuff", false );
		
		target.ForceSetStat( BCS_Stamina, target.GetStatMax( BCS_Stamina ) );
		
		poiseEffect = (W3Effect_Poise)target.GetBuff(EET_Poise);
		maxPoise = poiseEffect.GetMaxPoise();
		poiseEffect.SetPoise(maxPoise);
		
		GetWitcherPlayer().GetInjuryManager().ClearInjuries();
		
		bleedingEffect = (W3Effect_Bleeding)target.GetBuff(EET_Bleeding);
		bleedingEffect.RemoveStack(bleedingEffect.GetStacks());
		//W3EE -  End
		
		super.OnEffectRemoved();
	}
}	