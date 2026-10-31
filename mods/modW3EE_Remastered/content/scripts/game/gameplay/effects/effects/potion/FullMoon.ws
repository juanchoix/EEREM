/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Potion_FullMoon extends W3ChangeMaxStatEffect
{
	default effectType = EET_FullMoon;
	default stat = BCS_Vitality;
	
	//W3EE - Begin
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{			
		super.OnEffectAdded(customParams);
		/*
		if(GetBuffLevel() == 3)
		{
			thePlayer.GainStat(BCS_Vitality, thePlayer.GetStat(BCS_Toxicity));
		}
		*/
	}
	
	public function ReduceDamage( out action : W3DamageAction )
	{
		var damageReduction : float = 0.5f;
		var damageMult : float;
		
		if( GetDayPart(GameTimeCreate()) == EDP_Midnight )
		{
			damageReduction += 0.1f;
			if( GetCurMoonState() == EMS_Full || GetCurMoonState() == EMS_Red )
				damageReduction += 0.15f;
		}
		
		damageMult = 1.f - MinF(damageReduction, action.processedDmg.vitalityDamage / target.GetStat(BCS_Vitality) * damageReduction);
		//theGame.GetGuiManager().ShowNotification(damageMult);
		action.processedDmg.vitalityDamage *= damageMult;
	}
	//W3EE - End
}