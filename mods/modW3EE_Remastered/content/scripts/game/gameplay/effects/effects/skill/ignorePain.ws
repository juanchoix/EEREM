/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_IgnorePain extends W3ChangeMaxStatEffect
{
	default effectType = EET_IgnorePain;
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		//W3EE - Begin
		/*
		var witcher : W3PlayerWitcher;
		var level : int;
		
		witcher = (W3PlayerWitcher)target;
	
		if(!witcher)
		{
			LogEffects("W3Effect_Toxicity.OnEffectAdded: effect added on non-CR4Player object - aborting!");
			target.RemoveBuff(EET_IgnorePain, true);
			return false;
		}
		
		level = witcher.GetSkillLevel(S_Alchemy_s20);
		
		
		if(level > 1)
			witcher.AddAbilityMultiple(abilityName, level - 1);
		
		super.OnEffectAdded(customParams);
		*/
		//W3EE - End
	}
	
	public final function OnSkillLevelChanged(delta : int)
	{
		//W3EE - Begin
		/*
		var i : int;
		
		for(i=0; i<Abs(delta); i+=1)
		{
			if(delta > 0)
			{
				thePlayer.AddAbilityMultiple(abilityName, delta);
			}
			else
			{
				thePlayer.RemoveAbilityMultiple(abilityName, -delta);
			}
		}
		*/
		//W3EE - End
	}
		
	event OnEffectRemoved()
	{
		//W3EE - Begin
		/*
		var percents : float;
		var level : int;
	
		percents = target.GetStatPercents(BCS_Vitality);
		
		super.OnEffectRemoved();
		
		level = GetWitcherPlayer().GetSkillLevel(S_Alchemy_s20);
		
		
		if(level > 1)
			target.RemoveAbilityMultiple(abilityName, level);
		
		
		target.UpdateStatMax(BCS_Vitality);
		target.ForceSetStat(BCS_Vitality, percents * target.GetStatMax(BCS_Vitality));
		*/
		//W3EE - End
	}
}