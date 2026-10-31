/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Potion_WhiteHoney extends CBaseGameplayEffect
{
	default effectType = EET_WhiteHoney;
	default isPositive = false; //W3EE
	default isNeutral = false; //W3EE
	default isNegative = true; //W3EE
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var exceptions : array<CBaseGameplayEffect>;
		//var wolf : CBaseGameplayEffect; //W3EE
		var activeReduction, temp : SAbilityAttributeValue; //W3EE
		var toxicity, toxicityDrained : float; //W3EE
		
		super.OnEffectAdded(customParams);
		
		//W3EE - Begin
		/*
		target.ForceSetStat(BCS_Toxicity, 0);
		
		
		exceptions.PushBack(this);
		wolf = thePlayer.GetBuff(EET_WolfHour);
		if(wolf)
			exceptions.PushBack(wolf);
			
		thePlayer.RemoveAllPotionEffects(exceptions);
		
		
		((W3PlayerAbilityManager)GetWitcherPlayer().abilityManager).SetToxicityOffset(0.f);
		*/
		if( ((W3PlayerWitcher)target).IsMeditating() )
		{
			exceptions.PushBack(this);
			thePlayer.RemoveAllPotionEffects(exceptions);
			thePlayer.RemoveBuff(EET_AlbedoDominance, true);
			thePlayer.RemoveBuff(EET_RubedoDominance, true);
			thePlayer.RemoveBuff(EET_NigredoDominance, true);
			
			((CR4Player)target).DrainFocus(target.GetStatPercents(BCS_Toxicity) * target.GetStatMax(BCS_Focus));
			target.DrainStamina(ESAT_FixedValue, target.GetStatPercents(BCS_Toxicity) * target.GetStatMax(BCS_Stamina));
			
			((W3Effect_Toxicity)target.GetBuff(EET_Toxicity)).ClearToxicityHoney(1, 1);
				
			((W3Effect_ToxicityFever)target.GetBuff(EET_ToxicityFever)).CureFever();
		}
		else
		{
			toxicity = target.GetStat(BCS_Toxicity);
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(GetAbilityName(), 'active_toxicity_drain', activeReduction, temp);
			toxicityDrained = toxicity * activeReduction.valueMultiplicative;
			
			((CR4Player)target).DrainToxicity(toxicityDrained);
			((CR4Player)target).DrainFocus(toxicityDrained / 100.f * 3.f);
			target.DrainStamina(ESAT_FixedValue, toxicityDrained);
		}
		//W3EE - End
	}
	//W3EE - Begin
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	//W3EE - End
}