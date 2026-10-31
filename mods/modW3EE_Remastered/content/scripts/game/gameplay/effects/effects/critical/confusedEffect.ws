/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ConfuseEffectCustomParams extends W3BuffCustomParams
{
	var criticalHitChanceBonus : float;
}

class W3ConfuseEffect extends W3CriticalEffect
{
	private saved var drainStaminaOnExit : bool;
	private var criticalHitBonus : float;
	private var lethargyLevel : int; //W3EE
	private var witcher : W3PlayerWitcher; //W3EE
	private var sp : SAbilityAttributeValue; //W3EE
	private var targetPoise : W3Effect_NPCPoise; //W3EE

	default criticalStateType 	= ECST_Confusion;
	default effectType 			= EET_Confusion;
	default resistStat 			= CDS_WillRes;
	default drainStaminaOnExit 	= false;
	default attachedHandling 	= ECH_Abort;
	default onHorseHandling 	= ECH_Abort;
		
	public function GetCriticalHitChanceBonus() : float
	{
		return criticalHitBonus;
	}

	public function OnTimeUpdated(deltaTime : float)
	{
		var i : int;

		if(!isOnPlayer && duration * 0.5 <= duration - timeLeft)
		{
			for(i=0; i<allowedHits.Size(); i+=1)
				allowedHits[i] = true;
		}

		super.OnTimeUpdated(deltaTime);
	}
		
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var params : W3ConfuseEffectCustomParams;
		var npc : CNewNPC;
		var i : int;
		
		super.OnEffectAdded(customParams);
		
		witcher = (W3PlayerWitcher)GetCreator(); //W3EE
		sp = witcher.GetTotalSignSpellPower(S_Magic_5); //W3EE
		lethargyLevel = witcher.GetSkillLevel(S_Magic_s17); //W3EE
		targetPoise = (W3Effect_NPCPoise)target.GetBuff(EET_NPCPoise); //W3EE
		
		if(isOnPlayer)
		{
			thePlayer.HardLockToTarget( false );
		}
		
		
		params = (W3ConfuseEffectCustomParams)customParams;
		if(params)
		{
			criticalHitBonus = params.criticalHitChanceBonus;
		}
		
		npc = (CNewNPC)target;
		
		if(npc)
		{
			
			npc.LowerGuard();
			
			if (npc.IsHorse())
			{
				if( npc.GetHorseComponent().IsDismounted() )
					npc.GetHorseComponent().ResetPanic();
				
				if ( IsSignEffect() &&  npc.IsHorse() )
				{
					npc.SetTemporaryAttitudeGroup('animals_charmed', AGP_Axii);
					npc.SignalGameplayEvent('NoticedObjectReevaluation');
				}
			}

			for(i=0; i<allowedHits.Size(); i+=1)
				allowedHits[i] = false;
		}
		
		//W3EE - Begin
		if( IsSignEffect() )
			npc.RemoveAllBuffsOfType(EET_AxiiGuardMe);
		//W3EE - End
	}
	
	public function CacheSettings()
	{
		super.CacheSettings();
	
		blockedActions.PushBack(EIAB_Signs);
		blockedActions.PushBack(EIAB_DrawWeapon);
		blockedActions.PushBack(EIAB_CallHorse);
		blockedActions.PushBack(EIAB_Fists);
		blockedActions.PushBack(EIAB_Jump);
		blockedActions.PushBack(EIAB_RunAndSprint);
		blockedActions.PushBack(EIAB_ThrowBomb);
		blockedActions.PushBack(EIAB_Crossbow);
		blockedActions.PushBack(EIAB_UsableItem);
		blockedActions.PushBack(EIAB_SwordAttack);
		blockedActions.PushBack(EIAB_Parry);
		blockedActions.PushBack(EIAB_Sprint);
		blockedActions.PushBack(EIAB_Explorations);
		blockedActions.PushBack(EIAB_Counter);
		blockedActions.PushBack(EIAB_LightAttacks);
		blockedActions.PushBack(EIAB_HeavyAttacks);
		blockedActions.PushBack(EIAB_SpecialAttackLight);
		blockedActions.PushBack(EIAB_SpecialAttackHeavy);
		blockedActions.PushBack(EIAB_QuickSlots);
		
		
		
	}
		
	event OnEffectRemoved()
	{
		var npc : CNewNPC;
		var drainPercent : float; //W3EE
		var slowdownEffect : SCustomEffectParams; //W3EE
		super.OnEffectRemoved();
		
		npc = (CNewNPC)target;
		
		if(npc)
		{
			if( !npc.HasBuff( EET_AxiiGuardMe ))
				npc.ResetTemporaryAttitudeGroup(AGP_Axii);
				
			npc.SignalGameplayEvent('NoticedObjectReevaluation');
		}
		
		if (npc && npc.IsHorse())
			npc.SignalGameplayEvent('WasCharmed');
			
		//W3EE - Begin
		if( isSignEffect && lethargyLevel > 0 )
		{
			drainPercent = 0.1f * lethargyLevel * sp.valueMultiplicative;
			
			if( target.UsesEssence() )
			{
				drainPercent *= MinF(1.f, 5000.f / target.GetStatMax(BCS_Essence));
			}
			else
			{
				drainPercent *= MinF(1.f, 5000.f / target.GetStatMax(BCS_Vitality));
			}
			
			target.DrainStamina(ESAT_FixedValue, target.GetStatMax(BCS_Stamina) * drainPercent);
			targetPoise.ReducePoise(targetPoise.GetPoise() / targetPoise.GetPoisePercentage() * drainPercent, 5.f);
			
			slowdownEffect.effectType = EET_SlowdownAxii;
			slowdownEffect.creator = witcher;
			slowdownEffect.sourceName = "S_Magic_s17";
			slowdownEffect.duration = 20.f * drainPercent * witcher.GetPlayerSignDurationMod();
			slowdownEffect.effectValue.valueAdditive = 0.4f * drainPercent;
			target.AddEffectCustom(slowdownEffect);
		}
		//W3EE - End
		
		if(drainStaminaOnExit)
		{
			target.DrainStamina(ESAT_FixedValue, target.GetStat(BCS_Stamina));
		}
	}
	
	public function SetDrainStaminaOnExit()
	{
		drainStaminaOnExit = true;
	}
}