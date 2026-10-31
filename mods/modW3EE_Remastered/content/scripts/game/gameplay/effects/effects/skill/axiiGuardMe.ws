/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_AxiiGuardMe extends CBaseGameplayEffect
{
	private var drainStaminaOnExit : bool;
	//W3EE - Begin
	private var lethargyLevel : int;
	private var witcher : W3PlayerWitcher;
	private var sp : SAbilityAttributeValue;
	private var targetPoise : W3Effect_NPCPoise;
	private var scaredOfMonsters : bool;
	//W3EE - End
	
	default effectType = EET_AxiiGuardMe;
	default resistStat = CDS_WillRes;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default drainStaminaOnExit = false;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var npc : CNewNPC;
		var bonusAbilityName : name;
		var skillLevel, i : int;
		
		super.OnEffectAdded(customParams);
		
		npc = (CNewNPC)target;
		
		((CAIStorageReactionData)npc.GetScriptStorageObject('ReactionData')).ResetAttitudes(npc);
		
		//W3EE - Begin
		witcher = (W3PlayerWitcher)GetCreator();
		sp = witcher.GetTotalSignSpellPower(S_Magic_5);
		lethargyLevel = witcher.GetSkillLevel(S_Magic_s17);
		targetPoise = (W3Effect_NPCPoise)target.GetBuff(EET_NPCPoise);
		
		if( !target.HasAbility('IsNotScaredOfMonsters') )
		{
			target.AddAbility('IsNotScaredOfMonsters');
			scaredOfMonsters = true;
		}
		//W3EE - End
		
		if ( npc.HasAttitudeTowards( thePlayer ) && npc.GetAttitude( thePlayer ) == AIA_Hostile )
		{
			npc.ResetAttitude( thePlayer );
		}
		
		if ( npc.HasTag('animal') || npc.IsHorse() )
		{
			npc.SetTemporaryAttitudeGroup('animals_charmed', AGP_Axii);
		}
		else
		{
			npc.SetTemporaryAttitudeGroup('npc_charmed', AGP_Axii);
			//W3EE - Begin
			if( witcher.HasAbility('Glyphword 30 _Stats', true) )
				target.PlayEffect( 'demonic_possession' );
			//W3EE - End
		}
		
		npc.SignalGameplayEvent('AxiiGuardMeAdded');
		npc.SignalGameplayEvent('NoticedObjectReevaluation');
		
		//W3EE - Begin
		Combat().SetPuppetCount(1);
		target.RemoveAllBuffsOfType(EET_Confusion);
		/*
		skillLevel = GetWitcherPlayer().GetSkillLevel(S_Magic_s05);
		bonusAbilityName = thePlayer.GetSkillAbilityName(S_Magic_s05);
		for(i=0; i<skillLevel; i+=1)
			target.AddAbility(bonusAbilityName, true);

		
		skillLevel = thePlayer.GetSkillLevel( S_Magic_s31 );
		bonusAbilityName = thePlayer.GetSkillAbilityName( S_Magic_s31 );
		target.AddAbilityMultiple( bonusAbilityName, skillLevel );
		*/
		//W3EE - End
		if (npc.IsHorse())
			npc.GetHorseComponent().ResetPanic();
	}
	
	event OnEffectRemoved()
	{
		var npc : CNewNPC;
		var bonusAbilityName : name;
		var drainPercent : float; //W3EE
		var slowdownEffect : SCustomEffectParams; //W3EE
		var possessionAction : W3DamageAction; //W3EE
		
		super.OnEffectRemoved();
		
		npc = (CNewNPC)target;	
		if(npc)
		{
			npc.ResetTemporaryAttitudeGroup(AGP_Axii);
			npc.SignalGameplayEvent('NoticedObjectReevaluation');
			((CAIStorageReactionData)npc.GetScriptStorageObject('ReactionData')).ResetAttitudes(npc);
		}
		
		if(drainStaminaOnExit)
		{
			target.DrainStamina(ESAT_FixedValue, target.GetStat(BCS_Stamina));
		}
		
		//W3EE - Begin
		/*
		bonusAbilityName = thePlayer.GetSkillAbilityName(S_Magic_s05);		
		while(target.HasAbility(bonusAbilityName))
			target.RemoveAbility(bonusAbilityName);

		bonusAbilityName = thePlayer.GetSkillAbilityName( S_Magic_s31 );
		target.RemoveAbilityAll( bonusAbilityName );
		*/
		
		if( scaredOfMonsters )
		{
			target.RemoveAbility('IsNotScaredOfMonsters');
		}
		
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
		
		Combat().SetPuppetCount(-1);
			
		if( isSignEffect && (witcher.HasAbility('Glyphword 28 _Stats', true) || witcher.HasAbility('Glyphword 29 _Stats', true) || witcher.HasAbility('Glyphword 30 _Stats', true) ) )
		{
			possessionAction = new W3DamageAction in theGame.damageMgr;
			possessionAction.Initialize( witcher, target, NULL, "Possession", EHRT_Heavy, CPS_Undefined, false, false, true, false );
			possessionAction.AddDamage( theGame.params.DAMAGE_NAME_ELEMENTAL, 10000.f * sp.valueMultiplicative * (1 - npc.GetNPCCustomStat(theGame.params.DAMAGE_NAME_MENTAL)) );
			GCameraShake(0.5);
			possessionAction.SetForceExplosionDismemberment();
			theGame.damageMgr.ProcessAction( possessionAction );
			delete possessionAction;
			
			target.PlayEffect( 'demonic_possession' );
			target.StopEffect( 'demonic_possession' );
		}
		//W3EE - End
	}
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		super.CalculateDuration(setInitialDuration);
		
		//W3EE - Begin
		if ( duration > 0 )
			duration = MaxF(8.f,duration);
		/*
		if ( duration > 0 )
		{	
			if (FactsQuerySum("used_red_haze") > 0) 
			{
				duration = 8.f;
			}
			else if (FactsQuerySum("used_red_haze_2") > 0) 
			{
				duration = 10.f;
			}
			else if (FactsQuerySum("used_red_haze_3") > 0) 
			{
				duration = 12.f;
			}
			else if(thePlayer.IsSkillEquipped(S_Magic_s18)) 
			{
				switch(GetWitcherPlayer().GetSkillLevel(S_Magic_s18))
				{
					case 3: 
						duration = 15.f;
						break;
					case 2: 
						duration = 13.f;
						break;
					case 1: 
						duration = 11.f;
						break;
				}
			}
			
		}
		*/
		//W3EE - End
	}
	
	//W3EE - Begin
	event OnUpdate(deltaTime : float)
	{
		((CNewNPC)target).SetTemporaryAttitudeGroup('npc_charmed', AGP_Axii);
	}
	//W3EE - End
}