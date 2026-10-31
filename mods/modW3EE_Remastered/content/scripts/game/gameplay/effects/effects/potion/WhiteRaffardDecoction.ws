/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Potion_WhiteRaffardDecoction extends CBaseGameplayEffect
{
	default effectType = EET_WhiteRaffardDecoction;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		//var vitality : float; //W3EE
		//var vitAtt, min, max : SAbilityAttributeValue; //W3EE
		
		super.OnEffectAdded(customParams);
		
		//W3EE - Begin
		/*
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, StatEnumToName(BCS_Vitality), min, max);
		vitAtt = GetAttributeRandomizedValue(min, max);
		vitality = target.GetStatMax(BCS_Vitality) * vitAtt.valueMultiplicative + vitAtt.valueAdditive;
		target.GainStat(BCS_Vitality, vitality);
		
		if(GetBuffLevel() == 3)
		{
			target.SetImmortalityMode(AIM_Invulnerable, AIC_WhiteRaffardsPotion);
		}
		*/
		//W3EE - End		
	}
	//W3EE - Begin
	/*
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		if(GetBuffLevel() == 3)
		{
			target.SetImmortalityMode(AIM_None, AIC_WhiteRaffardsPotion);
		}
	}
	*/
	
	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		((W3Effect_Bleeding)target.GetBuff(EET_Bleeding)).ResetStackTimer();
	}
	
	public function OnTimeUpdated(deltaTime : float)
	{
		var vitalityStage : int = FloorF(6.f - thePlayer.GetStatPercents(BCS_Vitality) * 5.f);
		
		if( isActive )
		{
			timeActive += deltaTime;	
			if( duration != -1 )
			{
				timeLeft -= deltaTime * vitalityStage;
					
				if( timeLeft <= 0 )
					isActive = false;
			}
			
			OnUpdate(deltaTime);	
		}
	}
	//W3EE - End
}