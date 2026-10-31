/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Slowdown extends CBaseGameplayEffect
{
	private saved var slowdownCauserId : int;
	private saved var decayPerSec : float;			
	private saved var decayDelay : float;			
	private saved var delayTimer : float;			
	private saved var slowdown : float;				
	private saved var incrementPerSec : float; //W3EE
	private saved var incrementDelay : float; //W3EE
	private saved var incrementTimer : float; //W3EE

	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default effectType = EET_Slowdown;
	default attributeName = 'slowdown';

	//W3EE - Begin
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		super.CalculateDuration(setInitialDuration);
		
		if(setInitialDuration)
			initialDuration = duration;
	}
	//W3EE - End
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var dm : CDefinitionsManagerAccessor;
		var min, max : SAbilityAttributeValue;
		var prc, pts : float;
		
		super.OnEffectAdded(customParams);
		
		dm = theGame.GetDefinitionsManager();
		
		dm.GetAbilityAttributeValue(abilityName, 'decay_per_sec', min, max);
		decayPerSec = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		
		dm.GetAbilityAttributeValue(abilityName, 'decay_delay', min, max);
		decayDelay = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		
		
		slowdown = CalculateAttributeValue(effectValue);
		//target.GetResistValue(CDS_ShockRes, pts, prc); //W3EE
		slowdown = ClampF(slowdown, 0.f, 0.75f); //slowdown = slowdown * (1 - ClampF(prc, 0, 1) ); //W3EE
		
		//W3EE - Begin
		if(isSignEffect && sourceName == "Glyphword18")
		{
			slowdown = 0;
			incrementPerSec = 0.005f;
			incrementDelay = 1.f;
			incrementTimer = 0;
		}
		//W3EE - End
		
		slowdownCauserId = target.SetAnimationSpeedMultiplier( 1 - slowdown );
		delayTimer = 0;
	}
	
	
	event OnUpdate(dt : float)
	{
		//W3EE - Begin
		if(incrementDelay >= 0 && incrementPerSec > 0)
		{
			if( incrementTimer >= incrementDelay )
			{
				target.ResetAnimationSpeedMultiplier(slowdownCauserId);
				slowdown += incrementPerSec;
				
				slowdownCauserId = target.SetAnimationSpeedMultiplier( 1 - slowdown );
				incrementTimer = 0;
			}
			else
			{
				incrementTimer += dt;
			}
		}
		else
		//W3EE - End
		if(decayDelay >= 0 && decayPerSec > 0)
		{
			if(delayTimer >= decayDelay)
			{
				target.ResetAnimationSpeedMultiplier(slowdownCauserId);
				slowdown -= decayPerSec * dt;
				
				if(slowdown > 0)
					slowdownCauserId = target.SetAnimationSpeedMultiplier( 1 - slowdown );
				else
					isActive = false;
			}
			else
			{
				delayTimer += dt;
			}
		}
		
		super.OnUpdate(dt);
	}
	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		super.CumulateWith(effect);
		delayTimer = 0;
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();		
		target.ResetAnimationSpeedMultiplier(slowdownCauserId);
	}
	
	event OnEffectAddedPost()
	{
		//W3EE - Begin
		/*
		if( IsAddedByPlayer() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation12 ) && target != thePlayer )
		{
			GetWitcherPlayer().AddMutation12Decoction();
		}
		*/
		//W3EE - End
		super.OnEffectAddedPost();
	}
}