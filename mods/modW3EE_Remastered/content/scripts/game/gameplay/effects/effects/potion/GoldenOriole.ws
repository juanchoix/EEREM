/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Potion_GoldenOriole extends CBaseGameplayEffect
{
	default effectType = EET_GoldenOriole;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{		
		super.OnEffectAdded(customParams);
		
		if(GetBuffLevel() <= 3) //W3EE
		{
			//target.RemoveAllBuffsOfType(EET_Poison); //W3EE
			target.RemoveAllBuffsOfType(EET_PoisonCritical);
		}
	}
	//W3EE - Begin
	event OnEffectAddedPost()
	{
		super.OnEffectAddedPost();
		
		((W3Effect_Poison)target.GetBuff(EET_Poison)).ResetStackTimer();
	}
	//W3EE - End
	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		super.CumulateWith(effect);
		
		if(GetBuffLevel() <= 3) //W3EE
		{
			//target.RemoveAllBuffsOfType(EET_Poison); //W3EE
			target.RemoveAllBuffsOfType(EET_PoisonCritical);
		}
	}
	
	
	
	//W3EE - Begin
	/*
	protected function GetEffectStrength() : float
	{		
		var i : int;
		var val, tmp : SAbilityAttributeValue;
		var ret : float;
		var isPoint : bool;
		var dm : CDefinitionsManagerAccessor;
		var atts : array<name>;
		
		dm.GetAbilityAttributes(abilityName, atts);
		
		
		for(i=0; i<atts.Size(); i+=1)
		{
			if(IsNonPhysicalResistStat(ResistStatNameToEnum(atts[i], isPoint)))
			{
				dm.GetAbilityAttributeValue(abilityName, atts[i], val, tmp);
				
				if(isPoint)
					ret += CalculateAttributeValue(val);
				else
					ret += 100 * CalculateAttributeValue(val);
			}
		}

		return ret;
	}
	*/
	event OnUpdate(deltaTime : float)
	{
		var updateInterval : float;
		
		super.OnUpdate(deltaTime);
		
		updateInterval += deltaTime;
		
		if( updateInterval < 1.0f )
			return false;
		else
		{
			effectManager.CacheStatUpdate(BCS_Toxicity, CalculateAttributeValue(effectValue) );
			updateInterval = 0.f;
		}
	}
	//W3EE - End
}