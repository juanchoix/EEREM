/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3DamageManagerProcessor extends CObject 
{
	
	private var playerAttacker				: CR4Player;				
	private var playerVictim				: CR4Player;				
	private var action						: W3DamageAction;
	private var attackAction				: W3Action_Attack;			
	private var weaponId					: SItemUniqueId;			
	private var actorVictim 				: CActor;					
	private var actorAttacker				: CActor;					
	private var dm 							: CDefinitionsManagerAccessor;
	private var attackerMonsterCategory		: EMonsterCategory;
	private var victimMonsterCategory		: EMonsterCategory;
	private var victimCanBeHitByFists		: bool;
	
	
	public function ProcessAction(act : W3DamageAction)
	{
		var wasAlive, validDamage, isFrozen, autoFinishersEnabled : bool;
		var focusDrain : float;
		var npc : CNewNPC;
		var buffs : array<EEffectType>;
		var arrStr : array<string>;
		var aerondight	: W3Effect_Aerondight;
		var trailFxName : name;
		
		
		var swordEntity : CWitcherSword;
		var swordItem : SItemUniqueId;
		var bloodType : EBloodType;
		
			
		wasAlive = act.victim.IsAlive();		
		npc = (CNewNPC)act.victim;
		
		
 		InitializeActionVars(act);
		
		
		if( ((CNewNPC)actorAttacker).IsHorse() && actorVictim.HasAbility('mon_werewolf_base'))
		{
			action.SetHitReactionType(EHRT_Light);
		}
		
		//W3EE - Begin
		if(attackAction && playerVictim && playerVictim.IsSetBonusActive(EISB_Skellige) && playerVictim.IsInCombatAction_Attack() && (Combat().IsUsingBattleMace() || Combat().IsUsingBattleAxe()))
 		{
			action.GetEffectTypes(buffs);
			
			if(!buffs.Contains(EET_Knockdown) && !buffs.Contains(EET_HeavyKnockdown))
			{
				action.SetHitAnimationPlayType(EAHA_ForceNo);
			}
 		}
		
		if(attackAction && playerAttacker && attackAction.IsActionMelee() && (GetWitcherPlayer().HasAbility('Runeword 49 _Stats', true) || GetWitcherPlayer().HasAbility('Runeword 50 _Stats', true) || GetWitcherPlayer().HasAbility('Runeword 51 _Stats', true)))
		{
			action.SetProcessBuffsIfNoDamage(true);
			attackAction.SetApplyBuffsIfParried(true);
		}
		
		/*
 		if(playerVictim && attackAction && attackAction.IsActionMelee() && !attackAction.CanBeParried() && attackAction.IsParried())
 		{
			action.GetEffectTypes(buffs);
			
			if(!buffs.Contains(EET_Knockdown) && !buffs.Contains(EET_HeavyKnockdown))
			{
				
				action.SetParryStagger();
				
				
				action.SetProcessBuffsIfNoDamage(true);
				
				
				action.AddEffectInfo(EET_LongStagger);
				
				
				action.SetHitAnimationPlayType(EAHA_ForceNo);
				action.SetCanPlayHitParticle(false);
				
				
				action.RemoveBuffsByType(EET_Bleeding);
				
				
				action.RemoveBuffsByType(EET_Bleeding1);
				action.RemoveBuffsByType(EET_Bleeding2);
				action.RemoveBuffsByType(EET_Bleeding3);
				
			}
 		}
		*/
		//W3EE - End		
 		
 		if(actorAttacker && playerVictim && ((W3PlayerWitcher)playerVictim) && GetWitcherPlayer().IsAnyQuenActive())
			FactsAdd("player_had_quen");
		
		if (!action.GetSimulateOnly())
		{
			
			ProcessPreHitModifications();

			
			ProcessActionQuest(act);
		}
		
		
		isFrozen = (actorVictim && actorVictim.HasBuff(EET_Frozen));
		
		
		validDamage = ProcessActionDamage();
		
		
		if(wasAlive && !action.victim.IsAlive())
		{
			arrStr.PushBack(action.victim.GetDisplayName());
			if(npc && npc.WillBeUnconscious())
			{
				theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_unconscious", , , arrStr), NULL, action.victim);
			}
			else if(action.attacker && action.attacker.GetDisplayName() != "")
			{
				arrStr.PushBack(action.attacker.GetDisplayName());
				theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_killed", , , arrStr), action.attacker, action.victim);
			}
			else
			{
				theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_dies", , , arrStr), NULL, action.victim);
			}
		}
		
		if( wasAlive && action.DealsAnyDamage() )
		{
			((CActor) action.attacker).SignalGameplayEventParamFloat(  'CausesDamage', MaxF( action.processedDmg.vitalityDamage, action.processedDmg.essenceDamage ) );
		}
		
		
		ProcessActionReaction(isFrozen, wasAlive);
		
		
		if(action.DealsAnyDamage() || action.ProcessBuffsIfNoDamage())
			ProcessActionBuffs();
		
		
		if(theGame.CanLog() && !validDamage && action.GetEffectsCount() == 0)
		{
			LogAssert(false, "W3DamageManagerProcessor.ProcessAction: action deals no damage and gives no buffs - investigate!");
			if ( theGame.CanLog() )
			{
				LogDMHits("*** Action has no valid damage and no valid buffs - investigate!", action);
			}
		}
		
		
		if( actorAttacker && wasAlive )
			actorAttacker.OnProcessActionPost(action);

		//W3EE - Begin
		/*
		if(actorVictim == GetWitcherPlayer() && action.DealsAnyDamage() && !action.IsDoTDamage())
		{
			if(actorAttacker && attackAction)
			{
				if(actorAttacker.IsHeavyAttack( attackAction.GetAttackName() ))
					focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('heavy_attack_focus_drain'));
				else if(actorAttacker.IsSuperHeavyAttack( attackAction.GetAttackName() ))
					focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('super_heavy_attack_focus_drain'));
				else 
					focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('light_attack_focus_drain')); 
			}
			else
			{
				
				focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('light_attack_focus_drain')); 
			}
			
			
			if ( GetWitcherPlayer().CanUseSkill(S_Sword_s16) )
				focusDrain *= 1 - (CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Sword_s16, 'focus_drain_reduction', false, true) ) * thePlayer.GetSkillLevel(S_Sword_s16));
				
			thePlayer.DrainFocus(focusDrain);
		}
		*/
		//W3EE - End
		
		if(actorAttacker == GetWitcherPlayer() && actorVictim && !actorVictim.IsAlive() && (action.IsActionMelee() || action.GetBuffSourceName() == "Kill"))
		{
			autoFinishersEnabled = theGame.GetInGameConfigWrapper().GetVarValue('Gameplay', 'AutomaticFinishersEnabled');
			
			//W3EE - Begin
			if ( !Combat().CheckAutoFinisher() )
				autoFinishersEnabled = false;
			//W3EE - End
			
			if(!autoFinishersEnabled || !thePlayer.GetFinisherVictim())
			{
				//W3EE - Begin
				/*
				if(thePlayer.HasAbility('Runeword 10 _Stats', true))
					GetWitcherPlayer().Runeword10Triggerred();
				if(thePlayer.HasAbility('Runeword 12 _Stats', true))
					GetWitcherPlayer().Runeword12Triggerred();
				*/
				//W3EE - End
			}
		}
		
		if(action.EndsQuen() && actorVictim)
		{
			actorVictim.FinishQuen(false);			
		}

		
		if(actorVictim == thePlayer && attackAction && attackAction.IsActionMelee() && (ShouldProcessTutorial('TutorialDodge') || ShouldProcessTutorial('TutorialCounter') || ShouldProcessTutorial('TutorialParry')) )
		{
			if(attackAction.IsCountered())
			{
				theGame.GetTutorialSystem().IncreaseCounters();
			}
			else if(attackAction.IsParried())
			{
				theGame.GetTutorialSystem().IncreaseParries();
			}
			
			if(attackAction.CanBeDodged() && !attackAction.WasDodged())
			{
				GameplayFactsAdd("tut_failed_dodge", 1, 1);
				GameplayFactsAdd("tut_failed_roll", 1, 1);
			}
		}
		
		if( playerAttacker && npc && action.IsActionMelee() && action.DealtDamage() && IsRequiredAttitudeBetween( playerAttacker, npc, true ))
		{		
			if(!npc.HasTag( 'AerondightIgnore' ))	
			{
				if( playerAttacker.inv.ItemHasTag( attackAction.GetWeaponId(), 'Aerondight' ) )
				{
					
					aerondight = (W3Effect_Aerondight)playerAttacker.GetBuff( EET_Aerondight );
					aerondight.IncreaseAerondightCharges( attackAction.GetAttackName() );
					
					
					if( aerondight.GetCurrentCount() == aerondight.GetMaxCount() )
					{
						switch( npc.GetBloodType() )
						{
							case BT_Red : 
								trailFxName = 'aerondight_blood_red';
								break;
								
							case BT_Yellow :
								trailFxName = 'aerondight_blood_yellow';
								break;
							
							case BT_Black : 
								trailFxName = 'aerondight_blood_black';
								break;
							
							case BT_Green :
								trailFxName = 'aerondight_blood_green';
								break;
						}
						
						playerAttacker.inv.GetItemEntityUnsafe( attackAction.GetWeaponId() ).PlayEffect( trailFxName );
					}
				}
			}
			//W3EE - Begin
			/*
			if(!action.WasDodged() && !attackAction.IsParried() && !attackAction.IsCountered())
			{
				swordItem = GetWitcherPlayer().GetHeldSword();
				if(swordItem != GetInvalidUniqueId())
				{
					swordEntity = (CWitcherSword)thePlayer.GetInventory().GetItemEntityUnsafe( swordItem );	
					if(swordEntity)
					{
						bloodType = npc.GetBloodType();
						if(bloodType == BT_Red || bloodType == BT_Yellow)
						{
							swordEntity.PlayEffectSingle('weapon_blood');
						}
						else if (bloodType == BT_Black || npc.HasAbility('mon_kikimora_warrior') || npc.HasAbility('mon_kikimora_worker') || npc.HasAbility('mon_black_spider_base') || npc.HasAbility('mon_black_spider_ep2_base') )
						{
							swordEntity.PlayEffectSingle('weapon_blood_black');
						}
						else if (bloodType == BT_Green)
						{
							swordEntity.PlayEffectSingle('weapon_blood_green');
						}
					}
				}
			}
			*/
			//W3EE - End
		}
		
		//W3EE - Begin
		if( playerAttacker && attackAction )
		{
			if( playerAttacker.IsHeavyAttack( attackAction.GetAttackName() ) )
			{
				if( ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 51 _Stats', true) )
					((CNewNPC)actorVictim).ModifyArmorValue(-0.05f);
				
				if( ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 59 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 60 _Stats', true) )
					((CNewNPC)actorVictim).SetDesolationStacks(true);
				
				if( playerAttacker.CanUseSkill(S_Sword_s04) && !attackAction.IsCountered() )
				{
					if( attackAction.IsParried() )
					{
						if( RandRange(100, 0) <= playerAttacker.GetSkillLevel(S_Sword_s04) * 4 )
							actorVictim.AddTimer('PlayActorHitAnimation', 0.05f, false);
					}
					else
					{
						if( RandRange(100, 0) <= playerAttacker.GetSkillLevel(S_Sword_s04) * 4 )
						{
							if( actorVictim.IsImmuneToBuff(EET_Stagger) )
								attackAction.SetHitAnimationPlayType(EAHA_ForceYes);
							else
								actorVictim.AddEffectDefault(EET_Stagger, playerAttacker, "StrengthTraining", false);
						}
					}
				}
			}
			else if( playerAttacker.IsLightAttack( attackAction.GetAttackName() ) )
			{
				if( ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 51 _Stats', true) && playerAttacker.GetBehaviorVariable( 'isPerformingSpecialAttack' ) == 0 )
				{
					((CNewNPC)actorVictim).Runeword51ModifyArmorValue(true);
					((CNewNPC)actorVictim).AddTimer('ResetRuneword51ModifyArmorValue', 3.f, false,,,,false);
				}
				
				if( ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 59 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 60 _Stats', true) )
					((CNewNPC)actorVictim).SetDesolationStacks(false);
			}
		}
		
		if ( Blood().ShouldShowBlood( act, actorVictim, victimMonsterCategory, playerAttacker, attackAction, attackAction.IsCriticalHit() ) )
			Blood().ShowBlood( attackAction.GetWeaponId(), (CNewNPC)actorVictim, attackAction.IsActionRanged() );
		//W3EE - End
	}
	
	private final function InitializeActionVars(act : W3DamageAction)
	{
		var tmpName : name;
		var tmpBool	: bool;
	
		action 				= act;
		playerAttacker 		= (CR4Player)action.attacker;
		playerVictim		= (CR4Player)action.victim;
		attackAction 		= (W3Action_Attack)action;		
		actorVictim 		= (CActor)action.victim;
		actorAttacker		= (CActor)action.attacker;
		dm 					= theGame.GetDefinitionsManager();
		
		if(attackAction)
			weaponId 		= attackAction.GetWeaponId();
			
		theGame.GetMonsterParamsForActor(actorVictim, victimMonsterCategory, tmpName, tmpBool, tmpBool, victimCanBeHitByFists);
		
		if(actorAttacker)
			theGame.GetMonsterParamsForActor(actorAttacker, attackerMonsterCategory, tmpName, tmpBool, tmpBool, tmpBool);
	}
	
	
	
	
	
	
	private function ProcessActionQuest(act : W3DamageAction)
	{
		var victimTags, attackerTags : array<name>;
		
		victimTags = action.victim.GetTags();
		
		if(action.attacker)
			attackerTags = action.attacker.GetTags();
		
		AddHitFacts( victimTags, attackerTags, "_weapon_hit" );
		
		
		if ((CGameplayEntity) action.victim) action.victim.OnWeaponHit(act);
	}
	
	
	
	
	
	private function ProcessActionDamage() : bool
	{
		var directDmgIndex, size, i : int;
		var dmgInfos : array< SRawDamage >;
		var immortalityMode : EActorImmortalityMode;
		var dmgValue : float;
		var anyDamageProcessed, fallingRaffard : bool;
		var victimHealthPercBeforeHit, frozenAdditionalDamage : float;
		var debilitatingPoisonMin, debilitatingPoisonMax: SAbilityAttributeValue;		
		var powerMod : SAbilityAttributeValue;
		var witcher : W3PlayerWitcher;
		var canLog : bool;
		var immortalityChannels : array<EActorImmortalityChannel>;
		var mainDamageIdx : int = 0; //W3EE
		var combatHandler : W3EECombatHandler = Combat(); //W3EE
		var damageHandler : W3EEDamageHandler = Damage(); //W3EE
		var oilInfos : SOilInfo; //W3EE
		
		canLog = theGame.CanLog();
		
		
		action.SetAllProcessedDamageAs(0);
		size = action.GetDTs( dmgInfos );
		action.SetDealtFireDamage(false);		
		
		
		//W3EE - Begin
		oilInfos = combatHandler.InitializeOilInfo(playerAttacker);
		damageHandler.HookBaseDamage(actorAttacker, action, dmgInfos);
		damageHandler.NPCSteelMonsterDamage(actorAttacker, dmgInfos, victimMonsterCategory);
		damageHandler.SteelMonsterDamage(actorAttacker, dmgInfos, victimMonsterCategory, oilInfos);
		damageHandler.GeraltFistDamage(attackAction, dmgInfos, victimMonsterCategory);
		damageHandler.ExhaustionExpandDamage(dmgInfos, action, playerAttacker, actorVictim);
		damageHandler.ElectrocutionExpandDamage(dmgInfos, action, playerAttacker, actorVictim);
		damageHandler.ProcessInvocationDamage(dmgInfos, action, playerAttacker);
		((W3Effect_SwordReachoftheDamned)playerAttacker.GetBuff(EET_SwordReachoftheDamned)).ExpandDamageTypes(dmgInfos, action, playerAttacker, actorVictim);
		//W3EE - End
		
		
		if(!actorVictim || (!actorVictim.UsesVitality() && !actorVictim.UsesEssence()) )
		{
			
			for(i=0; i<size; i+=1)
			{
				if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_FIRE && dmgInfos[i].dmgVal > 0)
				{
					action.victim.OnFireHit( (CGameplayEntity)action.causer );
					break;
				}
			}
			
			if ( !actorVictim.abilityManager )
				actorVictim.OnDeath(action);
			
			return false;
		}
		
		
		if(actorVictim.UsesVitality())
			victimHealthPercBeforeHit = actorVictim.GetStatPercents(BCS_Vitality);
		else
			victimHealthPercBeforeHit = actorVictim.GetStatPercents(BCS_Essence);
			
		//W3EE - Begin
		/*
		if ( actorVictim && playerAttacker && victimMonsterCategory == MC_Specter && playerAttacker.HasBuff(EET_Mutagen28) && !actorVictim.HasAbility( 'ShadowFormActive' ) && !action.GetSimulateOnly())
		{
			actorVictim.BlockAbility('ShadowForm', true);			
			actorVictim.BlockAbility('Flashstep', true);			
			actorVictim.BlockAbility('EssenceRegen', true);
			actorVictim.BlockAbility('Teleport', true);
			
			actorVictim.BlockAbility('Specter', true);			
		}
		*/
		//W3EE - End
		
		ProcessDamageIncrease( dmgInfos );

		
		//ProcessNewSkills_Combat( dmgInfos ); //W3EE
					
		
		if ( canLog )
		{
			LogBeginning();
		}
		
		
		ProcessCriticalHitCheck();
		
		//W3EE - Begin
		//ProcessOnBeforeHitChecks();
		
		if( playerAttacker && (W3Petard)action.causer && !action.IsDoTDamage() && (playerAttacker.HasAbility('Runeword 13 _Stats', true) || playerAttacker.HasAbility('Runeword 14 _Stats', true) || playerAttacker.HasAbility('Runeword 15 _Stats', true)) )
			combatHandler.ProcessOilEffects(attackAction, oilInfos, dmgInfos, size, actorVictim, victimMonsterCategory, true);
		else
			combatHandler.ProcessOilEffects(attackAction, oilInfos, dmgInfos, size, actorVictim, victimMonsterCategory);
		
		damageHandler.WeatherDamageMultiplier(dmgInfos, actorVictim);
		
		if( playerAttacker && !playerVictim && action.IsActionMelee() && playerAttacker.HasAbility('Runeword 36 _Stats', true) && playerAttacker.HasAbility('Runeword 36 Ability') )
		{
			((W3PlayerWitcher)playerAttacker).RemoveAbilityAll('Runeword 36 Ability');
			((W3PlayerWitcher)playerAttacker).AddTimer('ManageAssassinationVisuals', 0.5f,,,,,true);
		}
		//W3EE - End
		
		powerMod = GetAttackersPowerMod();
		
		
		anyDamageProcessed = false;
		directDmgIndex = -1;
		witcher = GetWitcherPlayer();
		size = dmgInfos.Size();			
		for( i = 0; i < size; i += 1 )
		{
			
			if(dmgInfos[i].dmgVal == 0)
				continue;
			
			//W3EE - Begin
			if( dmgInfos[i].dmgVal > dmgInfos[mainDamageIdx].dmgVal )
				mainDamageIdx = i;
			//W3EE - End
			
			if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_DIRECT)
			{
				directDmgIndex = i;
				continue;
			}
			
			//W3EE - Begin
			/*
			if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_POISON && witcher == actorVictim && witcher.HasBuff(EET_GoldenOriole) && witcher.GetPotionBuffLevel(EET_GoldenOriole) == 3)
			{
				witcher.GainStat(BCS_Vitality, dmgInfos[i].dmgVal);
				
				if ( canLog )
				{
					LogDMHits("", action);
					LogDMHits("*** Player absorbs poison damage from level 3 Golden Oriole potion: " + dmgInfos[i].dmgVal, action);
				}
				
				
				dmgInfos[i].dmgVal = 0;
				
				continue;
			}
			*/
			//W3EE - End
			
			if ( canLog )
			{
				LogDMHits("", action);
				LogDMHits("*** Incoming " + NoTrailZeros(dmgInfos[i].dmgVal) + " " + dmgInfos[i].dmgType + " damage", action);
				if(action.IsDoTDamage())
					LogDMHits("DoT's current dt = " + NoTrailZeros(action.GetDoTdt()) + ", estimated dps = " + NoTrailZeros(dmgInfos[i].dmgVal / action.GetDoTdt()), action);
			}
			
			
			anyDamageProcessed = true;
				
			
			dmgValue = MaxF(0, CalculateDamageW3EE(dmgInfos[i], powerMod)); //W3EE
		
			
			if( DamageHitsEssence(  dmgInfos[i].dmgType ) )		action.processedDmg.essenceDamage  += dmgValue;
			if( DamageHitsVitality( dmgInfos[i].dmgType ) )		action.processedDmg.vitalityDamage += dmgValue;
			if( DamageHitsMorale(   dmgInfos[i].dmgType ) )		action.processedDmg.moraleDamage   += dmgValue;
			if( DamageHitsStamina(  dmgInfos[i].dmgType ) )		action.processedDmg.staminaDamage  += dmgValue;
		}
		
		if(size == 0 && canLog)
		{
			LogDMHits("*** There is no incoming damage set (probably only buffs).", action);
		}
		
		if(canLog)
		{
			LogDMHits("", action);
			LogDMHits("Processing block, parry, immortality, signs and other GLOBAL damage reductions...", action);		
		}
		
		//W3EE - Begin
		if(actorVictim)
		{
			damageHandler.ColdBloodDamage(action, actorVictim);
			
			damageHandler.ManticoreSetStatusDamage(action, playerAttacker, actorVictim); //Kolaris - Manticore Set
			
			damageHandler.CremationDamageAmp(action, actorVictim); //Kolaris - Cremation
			
			damageHandler.ResolutionDamageMod(action, playerAttacker); //Kolaris - Resolution
			
			damageHandler.DestructionDamageMod(action, playerAttacker, actorVictim); //Kolaris - Destruction
			
			if( action.IsDoTDamage() )
				damageHandler.DOTModule(action);
			else
			{
				damageHandler.PlayerModule(action);
				damageHandler.NPCModule(action, actorAttacker, actorVictim);
			}
			
			combatHandler.CounterAndParry(playerVictim, actorAttacker, attackAction, action);
			combatHandler.ApplyDamageModifiers(action, actorVictim);
			
			actorVictim.ReduceDamage(action);
			
			combatHandler.WhirlBlockingModule(playerVictim, attackAction, action);
			
			if(!action.GetIgnoreImmortalityMode())
			{
				
				if( actorVictim.IsInvulnerable() )
				{
					if(theGame.CanLog())
					{
						LogDMHits("W3DamageManagerProcessor.ProcessActionDamage: victim Invulnerable - no damage will be dealt", action );
					}
					action.SetAllProcessedDamageAs(0);
				}
				
				else if(actorAttacker && action.DealsAnyDamage())
					actorAttacker.SignalGameplayEventParamObject( 'DamageInstigated', action );
				
				
				if(actorVictim.IsImmortal())
				{
					if(theGame.CanLog())
					{
						LogDMHits("W3DamageManagerProcessor.ProcessActionDamage: victim is Immortal, clamping damage", action );
					}
					action.processedDmg.vitalityDamage = ClampF(action.processedDmg.vitalityDamage, 0, actorVictim.GetStat(BCS_Vitality)-1 );
					action.processedDmg.essenceDamage  = ClampF(action.processedDmg.essenceDamage, 0, actorVictim.GetStat(BCS_Essence)-1 );
				}
			}
			else
			{
				
				if(actorAttacker && action.DealsAnyDamage())
					actorAttacker.SignalGameplayEventParamObject( 'DamageInstigated', action );
			}
		}
		if( !action.IsDoTDamage() )
		{
			if( ((CNewNPC)actorVictim).GetNPCCustomStat(dmgInfos[mainDamageIdx].dmgType) >= 1.f )
				action.SetHitAnimationPlayType(EAHA_ForceNo);
				
			combatHandler.ApplyPlayerStaggerMechanics(playerVictim, attackAction, action);
			combatHandler.ApplyNPCStaggerMechanics(playerVictim, attackAction, action);
			
			combatHandler.ProcessSecondaryEffects(attackAction, actorAttacker);
			combatHandler.SpecialAttackHeavy(attackAction);
			combatHandler.LightBashEffect(attackAction, action, actorVictim);
			
			combatHandler.ApplyBleedStack(attackAction, oilInfos, actorAttacker, actorVictim);
			
			combatHandler.CripplingShotEffects(action);
			
			combatHandler.DealInfusionDamage(action);
			
			combatHandler.BlockingStaggerImmunity(playerVictim, action, attackAction);
			
			combatHandler.PlayHitDamageEffects(attackAction, dmgInfos, playerAttacker, actorVictim);
			
			witcher.GetAdrenalineEffect().ManageAdrenaline(attackAction);
			
			combatHandler.ProcessAxiiLink(action);
			
			((W3Effect_SwordRendBlast)playerAttacker.GetBuff(EET_SwordRendBlast)).FireDischarge(attackAction, playerAttacker, actorVictim);
			
			combatHandler.BereavementRunewordAttack(attackAction);
			
			combatHandler.UndyingDamageReduction(action, playerVictim);
			
			combatHandler.AffinityDamageReduction(action, playerVictim, attackerMonsterCategory);
			
			combatHandler.ArchmutagenDamageBonus(action, playerAttacker, victimMonsterCategory);
			
			combatHandler.EndurePainDamageReduction(action, playerVictim);
			
			combatHandler.ProcessPuppetMorale(action, actorVictim, actorAttacker);
			
			if( playerAttacker && action.DealsAnyDamage() )
			{
				if( action.IsCriticalHit() && action.IsActionMelee() )
				{
					((W3Effect_SwordCritVigor)playerAttacker.GetBuff(EET_SwordCritVigor)).SetReductionActive(true, playerAttacker);
					((W3Effect_SwordInjuryHeal)playerAttacker.GetBuff(EET_SwordInjuryHeal)).HealCombatInjury();
					combatHandler.ObliterationRunewordExplosion(attackAction, true);
				}
				
				combatHandler.AfflictionPoisonChance(action, playerAttacker, actorVictim);
				
				combatHandler.AssassinationDamageBoost(action, playerAttacker, actorVictim);
				
				combatHandler.ProcessInvocationEffects(action, playerAttacker, actorVictim);
				
				((W3Effect_SwordWraithbane)playerAttacker.GetBuff(EET_SwordWraithbane)).StopWraithHealthRegen(action, actorVictim, victimMonsterCategory);
				((W3Effect_SwordKillBuff)playerAttacker.GetBuff(EET_SwordKillBuff)).BuffAttackDamage(attackAction);
				((W3Effect_SwordRedTear)playerAttacker.GetBuff(EET_SwordRedTear)).BoostAttackDamage(action, playerAttacker);
				((W3Effect_SwordGas)playerAttacker.GetBuff(EET_SwordGas)).SpawnGasCloud(action, playerAttacker);
				((W3Effect_SwordDarkCurse)playerAttacker.GetBuff(EET_SwordDarkCurse)).ResetCurseAttackTimer();
				
				if( action.GetAppliedBleeding() && RandRange(100) <= 25 )
					((W3Effect_SwordBloodFrenzy)playerAttacker.GetBuff(EET_SwordBloodFrenzy)).SetFrenzyActive(true);
				
				((W3Decoction1_Effect)playerAttacker.GetBuff(EET_Decoction1)).ApplySpeedBuff(action);
				((W3Decoction1_Effect)playerAttacker.GetBuff(EET_Decoction1)).ApplyDamageBuff(action, actorVictim);
				
				((W3Decoction5_Effect)playerAttacker.GetBuff(EET_Decoction5)).ApplyDamageBuff(action, playerAttacker);
				
				((W3Decoction10_Effect)playerAttacker.GetBuff(EET_Decoction10)).RestorePoiseFromAttack(action, actorVictim);
				
				combatHandler.Mutation2RestoreVigor(attackAction);
			}
			
			((W3Effect_DimeritiumCharge)playerVictim.GetBuff(EET_DimeritiumCharge, "DimeritiumSetBonus")).DischargeArmor(action);
			((W3Effect_DimeritiumCharge)playerVictim.GetBuff(EET_DimeritiumCharge, "DimeritiumSetBonus")).IncreaseDimeritiumCharge(action);
			
			((W3Effect_WolfSetParry)playerVictim.GetBuff(EET_WolfSetParry, "BearSetBonus2")).IncrementAbility(action);
			
			((W3Decoction3_Effect)playerVictim.GetBuff(EET_Decoction3)).ReduceDamage(action);
			
			((W3Decoction10_Effect)playerVictim.GetBuff(EET_Decoction10)).ApplyPoison(action);
			
			if( playerAttacker && ((W3PlayerWitcher)playerAttacker).IsSetBonusActive(EISB_Nilfgaard) && action.IsActionMelee() )
				combatHandler.ProcessNilfgaardAbility(attackAction, playerAttacker, actorVictim);
			
			if( playerAttacker && ((W3PlayerWitcher)playerAttacker).IsSetBonusActive(EISB_Temerian) && Combat().Perk21Active && action.IsActionMelee() )
				combatHandler.ProcessTemerianAbility();
			
			((W3Effect_RunewordObliteration)playerAttacker.GetBuff(EET_RunewordObliteration)).ProcessObliterationAbility(action);
			
			((W3Effect_RunewordElectrocution)playerAttacker.GetBuff(EET_RunewordElectrocution)).ProcessElectrocutionAbility(action);
			
			((W3Potion_FullMoon)playerVictim.GetBuff(EET_FullMoon)).ReduceDamage(action);
			
			combatHandler.Mutation8StaggerCheck(playerVictim, action.GetDamageDealt(), action);
			
			combatHandler.DealPoiseDamage(actorVictim, action);
			combatHandler.ProcessPoisebreak(actorVictim, actorAttacker, action);
			
			combatHandler.ProcessEnemyAoESpecialAttacks(attackAction, actorAttacker);
			
			actorVictim.GetInjuryManager().ApplyCombatInjury(attackAction, action.GetDamageDealt(), oilInfos, action.causer);
			
			if( playerVictim && actorAttacker && action.DealsAnyDamage() )
				((W3PlayerWitcher)playerVictim).StartRegenTimer(3.f);
				
			ModifyHitSeverityReactionFromDamage(action);
			FinisherStunInvulnerability();
			Experience().AwardCombatXP(attackAction, playerAttacker, playerVictim);
		}
		//W3EE - End
		
		
		if(directDmgIndex != -1)
		{
			anyDamageProcessed = true;
			
			
			immortalityChannels = actorVictim.GetImmortalityModeChannels(AIM_Invulnerable);
			fallingRaffard = false; //immortalityChannels.Size() == 1 && immortalityChannels.Contains(AIC_WhiteRaffardsPotion) && action.GetBuffSourceName() == "FallingDamage"; //W3EE

			dmgValue = dmgInfos[directDmgIndex].dmgVal;
			//W3EE - Begin
			/*
			if ( action.GetSignSkill() == S_Magic_1 )	
				dmgValue = MaxF(0, CalculateDamage(dmgInfos[directDmgIndex], powerMod));
			*/
			//W3EE - End
			if(action.GetIgnoreImmortalityMode() || (!actorVictim.IsImmortal() && !actorVictim.IsInvulnerable() && !actorVictim.IsKnockedUnconscious()) || fallingRaffard)
			{
				action.processedDmg.vitalityDamage += dmgValue;
				action.processedDmg.essenceDamage  += dmgValue;
			}
			else if( actorVictim.IsInvulnerable() )
			{
				
			}
			else if( actorVictim.IsImmortal() )
			{
				
				action.processedDmg.vitalityDamage += MinF(dmgValue, actorVictim.GetStat(BCS_Vitality)-1 );
				action.processedDmg.essenceDamage  += MinF(dmgValue, actorVictim.GetStat(BCS_Essence)-1 );
			}
		}
		
		
		if( actorVictim.HasAbility( 'OneShotImmune' ) )
		{
			if( action.processedDmg.vitalityDamage >= actorVictim.GetStatMax( BCS_Vitality ) )
			{
				action.processedDmg.vitalityDamage = actorVictim.GetStatMax( BCS_Vitality ) - 1;
			}
			else if( action.processedDmg.essenceDamage >= actorVictim.GetStatMax( BCS_Essence ) )
			{
				action.processedDmg.essenceDamage = actorVictim.GetStatMax( BCS_Essence ) - 1;
			}
		}
		
		
		
		if(action.HasDealtFireDamage())
			action.victim.OnFireHit( (CGameplayEntity)action.causer );
			
		
		ProcessInstantKill();
			
		
		ProcessActionDamage_DealDamage();
		
		
		if(playerAttacker && witcher && attackAction.GetAttackName() != 'counter_attack_light')
		{
			witcher.SetRecentlyCountered(false);
			witcher.SetRecentlyDodged(false);
		}
		
		
		if( attackAction && !attackAction.IsCountered() && playerVictim && attackAction.IsActionMelee())
			theGame.GetGamerProfile().ResetStat(ES_CounterattackChain);
		
		
		ProcessActionDamage_ReduceDurability( oilInfos ); //W3EE
		
		
		if(playerAttacker && actorVictim)
		{
			//W3EE - Begin
			if( playerAttacker.inv.ItemHasAnyActiveOilApplied(weaponId) && (!(attackAction.IsParried() || attackAction.IsCountered()) || ((attackAction.IsParried() || attackAction.IsCountered()) && action.DealsAnyDamage()) ) )
			{			
				if( playerAttacker.CanUseSkill(S_Alchemy_s06) && ((W3Effect_Bleeding)actorVictim.GetBuff(EET_Bleeding)).GetStacks() > 0 )
				{
					if( RandRange(100, 0) > (playerAttacker.GetSkillLevel(S_Alchemy_s06) * ((W3Effect_Bleeding)actorVictim.GetBuff(EET_Bleeding)).GetStacks()))
						playerAttacker.ReduceAllOilsAmmo( weaponId, playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) );
				}
				else
					playerAttacker.ReduceAllOilsAmmo( weaponId, playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) );
				
				if(ShouldProcessTutorial('TutorialOilAmmo'))
				{
					FactsAdd("tut_used_oil_in_combat");
				}
				
				/*
				if( !playerAttacker.inv.ItemHasActiveOilApplied( weaponId, victimMonsterCategory ) )
				{
					thePlayer.ShouldAutoApplyOilImmediately( actorVictim );
				}
				*/
			}
			else
			{
				//thePlayer.ShouldAutoApplyOilImmediately( actorVictim );
			}
			//W3EE - End
			
			
			playerAttacker.inv.ReduceItemRepairObjectBonusCharge(weaponId);
		}
		
		//W3EE - Begin
		if( playerVictim.IsSetBonusActive(EISB_Vampire) )
		{
			if( !action.IsDoTDamage() && action.IsActionMelee() && action.DealsAnyDamage() )
			{
				actorAttacker.ApplyBleeding(RandRange(3,1), actorVictim, "Bleeding");
			}
		}
		if( playerVictim.IsSetBonusActive(EISB_Vampire_Alt_1) )
		{
			if( !action.IsDoTDamage() && action.IsActionMelee() && action.DealsAnyDamage() )
			{
				((W3PlayerWitcher)playerVictim).VampiricSetAbilityCharm(actorAttacker);
			}
		}
		if( playerVictim.IsSetBonusActive(EISB_Skellige) )
		{
			if( !action.IsDoTDamage() && action.IsActionMelee() && action.DealsAnyDamage() )
			{
				if( RandF() < action.processedDmg.vitalityDamage / 2000 * (1.f - ((CNewNPC)actorAttacker).GetNPCCustomStat(theGame.params.DAMAGE_NAME_FROST)) )
					actorAttacker.AddEffectDefault(EET_SlowdownFrost, playerVictim, "SkelligeSet", false);
			}
		}
		if( ((W3PlayerWitcher)playerVictim).GetAdrenalineEffect().GetFullValue() >= 50.f && (((W3PlayerWitcher)playerVictim).HasAbility('Glyphword 7 _Stats', true) || ((W3PlayerWitcher)playerVictim).HasAbility('Glyphword 8 _Stats', true) || ((W3PlayerWitcher)playerVictim).HasAbility('Glyphword 9 _Stats', true)) )
		{
			if( !action.IsDoTDamage() && action.IsActionMelee() && action.DealsAnyDamage() && RandF() > ((CNewNPC)actorAttacker).GetNPCCustomStat(theGame.params.DAMAGE_NAME_FIRE) / 2 )
			{
				actorAttacker.AddEffectDefault(EET_Burning, playerVictim, "Immolation", false);
			}
		}
		
		if( playerAttacker )
			((W3PlayerWitcher)playerAttacker).ManageRepairBuffs(attackAction, weaponId, playerAttacker.IsHeavyAttack(attackAction.GetAttackName()));
			
		if( playerVictim )
			((W3PlayerWitcher)playerVictim).ManageRepairBuffs(attackAction, weaponId, !actorAttacker.IsLightAttack(attackAction.GetAttackName()));
			
		if(actorVictim && actorAttacker && !action.GetCannotReturnDamage() && !action.IsDoTDamage() && !action.GetSimulateOnly())
			ProcessActionReturnedDamage();	
		//W3EE - End
		
		return anyDamageProcessed;
	}
	
	//W3EE - Begin
	private function FinisherStunInvulnerability()
	{
		if( playerVictim.isInFinisher )
			action.SetHitAnimationPlayType(EAHA_ForceNo);
	}
	//W3EE - End
	
	private function ProcessInstantKill()
	{
		var instantKill, focus : float;
		var victimIsImmune:bool;
		var witcherAttacker:W3PlayerWitcher;
		
		witcherAttacker = GetWitcherPlayer();

		
		if( action.WasDodged() || ( attackAction && ( attackAction.IsParried() || attackAction.IsCountered() ) ) )
		{
			return;
		}

		victimIsImmune = actorVictim.IsImmuneToInstantKill();
		
		//W3EE - Begin
		/*
		if( !actorVictim || !actorAttacker || victimIsImmune || action.GetSimulateOnly() )
		{
			
			if(victimIsImmune 
			&& actorAttacker == witcherAttacker 
			&& witcherAttacker.CanUseSkill(S_Sword_s30) 
			&& witcherAttacker.IsDeadlyPrecisionEnabled()
			&& attackAction
			&& attackAction.GetAttackTypeName() == 'attack_heavy') 
			{
				
				witcherAttacker.GainStat(BCS_Focus, GetTriggerChance(S_Sword_s30));
			}
			return;
		}
		*/
		//W3EE - End
		
		if( actorAttacker.HasAbility( 'ForceInstantKill' ) && actorVictim != thePlayer )
		{
			action.SetInstantKill();
		}
		
		//W3EE - Begin
		/*
		if( actorAttacker == thePlayer && !action.GetIgnoreInstantKillCooldown() )
		{
			if( !GameTimeDTAtLeastRealSecs( thePlayer.lastInstantKillTime, theGame.GetGameTime(), theGame.params.INSTANT_KILL_INTERNAL_PLAYER_COOLDOWN ) )
			{
				return;
			}
		}
		*/
		
		if( actorAttacker.HasAbility( 'ForceInstantKill' ) && actorVictim != thePlayer && !actorAttacker.HasBuff(EET_AxiiGuardMe) && !actorVictim.HasBuff(EET_AxiiGuardMe) )
		{
			action.SetInstantKill();
		}
		
		if( action.IsCriticalHit() && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && ((W3Effect_NPCPoise)actorVictim.GetBuff(EET_NPCPoise)).IsPoiseBroken() && ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 60 _Stats', true) )
		{
			action.SetInstantKill();
			actorVictim.CreateFXEntityAndPlayEffect('mutation_2_explode', 'mutation_2_yrden');
		}
		
		if( actorAttacker == thePlayer )
			if(playerAttacker && playerAttacker.GetBehaviorVariable( 'isPerformingSpecialAttack' ) > 0 && playerAttacker.GetBehaviorVariable( 'playerAttackType' ) == (int)PAT_Light)
				return;
		//W3EE - End
	
		
		if( !action.GetInstantKill() )
		{
			
			instantKill = CalculateAttributeValue( actorAttacker.GetInventory().GetItemAttributeValue( weaponId, 'instant_kill_chance' ) );
			
			//W3EE - Begin
			/*
			if( ( action.IsActionMelee() || action.IsActionRanged() ) && playerAttacker && action.DealsAnyDamage() && thePlayer.CanUseSkill( S_Sword_s03 ) && !playerAttacker.inv.IsItemFists( weaponId ) )
			{
				focus = thePlayer.GetStat( BCS_Focus );
				
				if( focus >= 1 )
				{
					instantKill += focus * CalculateAttributeValue( thePlayer.GetSkillAttributeValue( S_Sword_s03, 'instant_kill_chance', false, true ) ) * thePlayer.GetSkillLevel( S_Sword_s03 );
				}
			}
			
			if( action.IsBouncedArrow() && playerAttacker && playerAttacker.CanUseSkill(S_Sword_s33))
			{
				instantKill += CalculateAttributeValue( thePlayer.GetSkillAttributeValue( S_Sword_s33, 'instant_kill_chance', false, true ) ) * thePlayer.GetSkillLevel( S_Sword_s33 );
			}

			if(attackAction.GetAttackName() == 'bolt' && action.GetIsHeadShot() && playerAttacker && playerAttacker.CanUseSkill(S_Sword_s32))
			{
				instantKill += CalculateAttributeValue( thePlayer.GetSkillAttributeValue( S_Sword_s32, 'instant_kill_chance', false, true ) ) * thePlayer.GetSkillLevel( S_Sword_s32 );
			}

			
			if(!victimIsImmune 
			&& actorAttacker == witcherAttacker 
			&& witcherAttacker.CanUseSkill(S_Sword_s30) 
			&& witcherAttacker.IsDeadlyPrecisionEnabled() 
			&& attackAction
			&& attackAction.GetAttackTypeName() == 'attack_heavy') 
			{
				instantKill += GetTriggerChance(S_Sword_s30);
				witcherAttacker.ResetDeadlyPrecision();
			}
			*/
			//W3EE - End
		}
		
		
		if( action.GetInstantKill() || ( RandF() < instantKill ) )
		{
			if( theGame.CanLog() )
			{
				if( action.GetInstantKill() )
				{
					instantKill = 1.f;
				}
				LogDMHits( "Instant kill!! (" + NoTrailZeros( instantKill * 100 ) + "% chance", action );
			}
		
			action.processedDmg.vitalityDamage += actorVictim.GetStat( BCS_Vitality );
			action.processedDmg.essenceDamage += actorVictim.GetStat( BCS_Essence );
			action.SetCriticalHit();	
			action.SetInstantKillFloater();			
			
			
			if( playerAttacker )
			{
				thePlayer.SetLastInstantKillTime( theGame.GetGameTime() );
				theSound.SoundEvent( 'cmb_play_deadly_hit' );
				theGame.SetTimeScale( 0.2, theGame.GetTimescaleSource( ETS_InstantKill ), theGame.GetTimescalePriority( ETS_InstantKill ), true, true );
				thePlayer.AddTimer( 'RemoveInstantKillSloMo', 0.2 );
			}			
		}
	}
	
	//W3EE - Begin
	/*
	private function ProcessOnBeforeHitChecks()
	{
		var effectAbilityName, monsterBonusType : name;
		var effectType : EEffectType;
		var null, monsterBonusVal : SAbilityAttributeValue;
		var oilLevel, skillLevel, i : int;
		var baseChance, perOilLevelChance, chance : float;
		var buffs : array<name>;
	
		
		if( playerAttacker && actorVictim && attackAction && attackAction.IsActionMelee() && playerAttacker.CanUseSkill(S_Alchemy_s12) && playerAttacker.inv.ItemHasActiveOilApplied( weaponId, victimMonsterCategory ) )
		{
			
			monsterBonusType = MonsterCategoryToAttackPowerBonus(victimMonsterCategory);
			monsterBonusVal = playerAttacker.inv.GetItemAttributeValue(weaponId, monsterBonusType);
		
			if(monsterBonusVal != null)
			{
				
				oilLevel = (int)CalculateAttributeValue(playerAttacker.inv.GetItemAttributeValue(weaponId, 'level')) - 1;				
				skillLevel = playerAttacker.GetSkillLevel(S_Alchemy_s12);
				baseChance = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Alchemy_s12, 'skill_chance', false, true));
				perOilLevelChance = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Alchemy_s12, 'oil_level_chance', false, true));						
				chance = baseChance * skillLevel + perOilLevelChance * oilLevel;
				
				
				if(RandF() < chance)
				{
					
					dm.GetContainedAbilities(playerAttacker.GetSkillAbilityName(S_Alchemy_s12), buffs);
					for(i=0; i<buffs.Size(); i+=1)
					{
						EffectNameToType(buffs[i], effectType, effectAbilityName);
						action.AddEffectInfo(effectType, , , effectAbilityName);
					}
				}
			}
		}

		
		if( playerAttacker && actorVictim && attackAction 
			&& !playerAttacker.GetInventory().IsItemFists(weaponId) 
			&& playerAttacker.IsLightAttack(attackAction.GetAttackName()) 
			&& playerAttacker.CanUseSkill(S_Sword_s29) && action.IsCriticalHit() )
		{
					ProcessNewSkill_CripplingStrikes();
		}
	}
	*/
	//W3EE - End
	
	private function ProcessCriticalHitCheck()
	{
		var critChance, critDamageBonus, rendLoad : float; //W3EE
		var oilCritChance : SAbilityAttributeValue; //W3EE
		var i : int; //W3EE
		var weaponId : SItemUniqueId; //W3EE
		var oils : array<W3Effect_Oil>; //W3EE
		var appliedOilName : name; //W3EE
		var	canLog, meleeOrRanged, redWolfSet, isLightAttack, isHeavyAttack, mutation2 : bool;
		var arrStr : array<string>;
		var samum : CBaseGameplayEffect;
		var signPower, min, max : SAbilityAttributeValue;
		var aerondight : W3Effect_Aerondight;
		var witcherAttacker : W3PlayerWitcher;
		
		
		witcherAttacker = GetWitcherPlayer();
		meleeOrRanged = playerAttacker && attackAction && ( attackAction.IsActionMelee() || attackAction.IsActionRanged() );
		redWolfSet = false; //( W3Petard )action.causer && ( W3PlayerWitcher )actorAttacker && GetWitcherPlayer().IsSetBonusActive( EISB_RedWolf_1 ); //W3EE
		mutation2 = false; //( W3PlayerWitcher )actorAttacker && GetWitcherPlayer().IsMutationActive(EPMT_Mutation2) && action.IsActionWitcherSign(); //W3EE
		
		if( meleeOrRanged || redWolfSet || mutation2 )
		{
			canLog = theGame.CanLog();
		
			
			if( mutation2 )
			{
				if( FactsQuerySum('debug_fact_critical_boy') > 0 )
				{
					critChance = 1.f;
				}
				else
				{
					signPower = action.GetPowerStatValue();
					theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation2', 'crit_chance_factor', min, max);
					critChance = min.valueAdditive + signPower.valueMultiplicative * min.valueMultiplicative;
				}
			} 			
			else
			{
				if( attackAction )
				{
					//W3EE - Begin
					if( playerAttacker.CanUseSkill(S_Sword_s11) && playerAttacker && GetWitcherPlayer().HasRecentlyCountered() || playerAttacker.IsCounterAttack(attackAction.GetAttackName()) )
					{
						critChance += playerAttacker.GetSkillLevel(S_Sword_s11) * 0.05f;
					}
					/*
					if(GetWitcherPlayer() && (GetWitcherPlayer().HasRecentlyCountered() || GetWitcherPlayer().HasRecentlyDodged()) && attackAction.GetAttackName() != 'counter_attack_light' 
						&& playerAttacker.CanUseSkill(S_Sword_s31) && playerAttacker.GetSkillLevel(S_Sword_s31) > 3)
					{
						critChance += CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s31, theGame.params.CRITICAL_HIT_CHANCE, false, true));
					}
					*/
					if( SkillEnumToName(S_Sword_s02) == attackAction.GetAttackTypeName() )
					{			
						rendLoad = GetWitcherPlayer().GetSpecialAttackTimeRatio();
						critChance += (0.1f + 0.03f * playerAttacker.GetSkillLevel(S_Sword_s02)) * rendLoad;
					}

					
					isLightAttack = playerAttacker.IsLightAttack( attackAction.GetAttackName() );
					isHeavyAttack = playerAttacker.IsHeavyAttack( attackAction.GetAttackName() );
					critChance += playerAttacker.GetCriticalHitChance(isLightAttack, isHeavyAttack, actorVictim, victimMonsterCategory, (W3BoltProjectile)action.causer || (W3ThrowingKnife)action.causer);
					//W3EE - End
					
					if(action.GetIsHeadShot())
					{
						critChance += theGame.params.HEAD_SHOT_CRIT_CHANCE_BONUS;
						actorVictim.SignalGameplayEvent( 'Headshot' );
					}
					
					
					if ( actorVictim && actorVictim.IsAttackerAtBack(playerAttacker) )
					{
						//W3EE - Begin
						if( ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 35 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 36 _Stats', true) )
							critChance += 1.f;
						else
							critChance += theGame.params.BACK_ATTACK_CRIT_CHANCE_BONUS;
						//W3EE - End
					}
						
					
					if( action.IsActionMelee() && playerAttacker.inv.ItemHasTag( attackAction.GetWeaponId(), 'Aerondight' ) )
					{
						aerondight = (W3Effect_Aerondight)playerAttacker.GetBuff( EET_Aerondight );
						
						if( aerondight && aerondight.IsFullyCharged() )
						{
							
							min = playerAttacker.GetAbilityAttributeValue( 'AerondightEffect', 'crit_chance_bonus' );
							critChance += min.valueAdditive;
						}
					}
					//W3EE - Begin
					if( playerAttacker && playerAttacker.CanUseSkill(S_Perk_11) )
					{
						critChance += actorVictim.GetInjuryManager().GetInjuryCount() * 0.03f;
					}
					
					if( playerAttacker && playerAttacker.CanUseSkill(S_Sword_s20) )
					{
						critChance += 0.005f * playerAttacker.GetSkillLevel(S_Sword_s20) * playerAttacker.GetStat(BCS_Focus);
					}
						
					if( playerAttacker && playerAttacker.IsSetBonusActive(EISB_Temerian) && Combat().Perk21Active )
					{
						critChance += 0.2f;
					}
					
					if( playerAttacker && playerAttacker.IsSetBonusActive(EISB_Elven_1) && attackAction.IsActionRanged() )
					{
						critChance += 0.1f;
					}
					
					if( playerAttacker && playerAttacker.IsSetBonusActive(EISB_Viper2) && actorVictim.HasBuff(EET_Poison) )
					{
						critChance += 0.0025f * ((W3PlayerWitcher)playerAttacker).GetSetPartsEquipped(EIST_Viper) * ((W3Effect_Poison)actorVictim.GetBuff(EET_Poison)).GetStacks();
					}
						
					if( ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 58 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 59 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 60 _Stats', true) )
					{
						if( action.IsActionMelee() )
						{
							if( actorVictim.UsesEssence() )
								critChance += 0.25f * MaxF(playerAttacker.GetStatPercents(BCS_Vitality) - actorVictim.GetStatPercents(BCS_Essence), actorVictim.GetStatPercents(BCS_Essence) - playerAttacker.GetStatPercents(BCS_Vitality));
							else
								critChance += 0.25f * MaxF(playerAttacker.GetStatPercents(BCS_Vitality) - actorVictim.GetStatPercents(BCS_Vitality), actorVictim.GetStatPercents(BCS_Vitality) - playerAttacker.GetStatPercents(BCS_Vitality));
						}
						if( ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 59 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 60 _Stats', true) )
						{
							critChance += ((CNewNPC)actorVictim).GetDesolationStacks(true) * 0.01f;
						}
					}
					//W3EE - End
				}
				else
				{
					
					critChance += playerAttacker.GetCriticalHitChance(false, false, actorVictim, victimMonsterCategory, (W3BoltProjectile)action.causer || (W3ThrowingKnife)action.causer ); //W3EE
				}
				
				//W3EE - Begin
				/*
				samum = actorVictim.GetBuff(EET_Blindness, 'petard');
				if(samum && samum.GetBuffLevel() == 3)
				{
					critChance += 1.0f;
				}
				*/
				
				if( !action.IsDoTDamage() && ((W3Effect_NPCPoise)actorVictim.GetBuff(EET_NPCPoise)).IsPoiseBroken() && ((CNewNPC)actorVictim).GetNPCCustomStat(theGame.params.DAMAGE_NAME_INJURY) >= 1.f && ((CNewNPC)actorVictim).GetNPCCustomStat(theGame.params.DAMAGE_NAME_BLEEDING) >= 1.f )
					critChance += 1.0f;
				//W3EE - End
			}
			
			
			if ( canLog )
			{
				
				critDamageBonus = 1 + CalculateAttributeValue(actorAttacker.GetCriticalHitDamageBonus(weaponId, victimMonsterCategory, actorVictim.IsAttackerAtBack(playerAttacker)));
				critDamageBonus += CalculateAttributeValue(actorAttacker.GetAttributeValue('critical_hit_chance_fast_style'));
				critDamageBonus = 100 * critDamageBonus;
				
				
				LogDMHits("", action);				
				LogDMHits("Trying critical hit (" + NoTrailZeros(critChance*100) + "% chance, dealing " + NoTrailZeros(critDamageBonus) + "% damage)...", action);
			}
			
			
			//W3EE - Begin
			if(playerAttacker && playerAttacker == GetWitcherPlayer() && playerAttacker.GetBehaviorVariable( 'isPerformingSpecialAttack' ) > 0 && playerAttacker.GetBehaviorVariable( 'playerAttackType' ) == (int)PAT_Light)
			{
				critChance = 0;
			}
			
			if(playerVictim && playerVictim == GetWitcherPlayer() && playerVictim.GetBehaviorVariable( 'isPerformingSpecialAttack' ) > 0 && playerVictim.GetBehaviorVariable( 'playerAttackType' ) == (int)PAT_Light)
			{
				critChance = 0;
			}
			//W3EE - End
			
			if(RandF() < critChance) 
			{
				
				action.SetCriticalHit();
								
				if ( canLog )
				{
					LogDMHits("********************", action);
					LogDMHits("*** CRITICAL HIT ***", action);
					LogDMHits("********************", action);				
				}
				
				arrStr.PushBack(action.attacker.GetDisplayName());
				theGame.witcherLog.AddCombatMessage(theGame.witcherLog.COLOR_GOLD_BEGIN + GetLocStringByKeyExtWithParams("hud_combat_log_critical_hit",,,arrStr) + theGame.witcherLog.COLOR_GOLD_END, action.attacker, NULL);
			}
			else if ( canLog )
			{
				LogDMHits("... nope", action);
			}
		}	
	}
	
	
	private function LogBeginning()
	{
		var logStr : string;
		
		if ( !theGame.CanLog() )
		{
			return;
		}
		
		LogDMHits("-----------------------------------------------------------------------------------", action);		
		logStr = "Beginning hit processing from <<" + action.attacker + ">> to <<" + action.victim + ">> via <<" + action.causer + ">>";
		if(attackAction)
		{
			logStr += " using AttackType <<" + attackAction.GetAttackTypeName() + ">>";		
		}
		logStr += ":";
		LogDMHits(logStr, action);
		LogDMHits("", action);
		LogDMHits("Target stats before damage dealt are:", action);
		if(actorVictim)
		{
			if( actorVictim.UsesVitality() )
				LogDMHits("Vitality = " + NoTrailZeros(actorVictim.GetStat(BCS_Vitality)), action);
			if( actorVictim.UsesEssence() )
				LogDMHits("Essence = " + NoTrailZeros(actorVictim.GetStat(BCS_Essence)), action);
			if( actorVictim.GetStatMax(BCS_Stamina) > 0)
				LogDMHits("Stamina = " + NoTrailZeros(actorVictim.GetStat(BCS_Stamina, true)), action);
			if( actorVictim.GetStatMax(BCS_Morale) > 0)
				LogDMHits("Morale = " + NoTrailZeros(actorVictim.GetStat(BCS_Morale)), action);
		}
		else
		{
			LogDMHits("Undefined - victim is not a CActor and therefore has no stats", action);
		}
	}
	//W3EE - Begin
	/*
	private function GetDamageIncreaseBaseMultiplier(skillId:ESkill, optional isPerLevel:bool) : float
	{
		var witcherAttacker : W3PlayerWitcher;
		var attribValue:SAbilityAttributeValue;

		witcherAttacker = GetWitcherPlayer();
		attribValue = witcherAttacker.GetSkillAttributeValue(skillId, 'damage_increase', false, true);
		if (isPerLevel)
		{
			return (float)attribValue.valueMultiplicative * witcherAttacker.GetSkillLevel(skillId);
		}
		else
		{
			return (float)attribValue.valueMultiplicative;
		}
	}

	private function GetTriggerChance(skillId:ESkill) : float
	{
		var witcherAttacker : W3PlayerWitcher;
		var attribValue:SAbilityAttributeValue;

		witcherAttacker = GetWitcherPlayer();
		attribValue = witcherAttacker.GetSkillAttributeValue(skillId, 'trigger_chance', false, true);
		return attribValue.valueBase * witcherAttacker.GetSkillLevel(skillId);
	}

	private function GetTriggerAtAttackCount(skillId:ESkill, optional isPerLevel:bool) : int
	{
		var witcherAttacker : W3PlayerWitcher;
		var attribValue:SAbilityAttributeValue;

		witcherAttacker = GetWitcherPlayer();
		attribValue = witcherAttacker.GetSkillAttributeValue(skillId, 'trigger_at_attack_count', false, true);
		if (isPerLevel)
		{
			return (int)attribValue.valueBase * witcherAttacker.GetSkillLevel(skillId);
		}
		else
		{
			return (int)attribValue.valueBase;
		}
	}

	private function GetSkillDuration(skillId:ESkill) : float
	{
		var attribValue:SAbilityAttributeValue;
		attribValue = GetWitcherPlayer().GetSkillAttributeValue(skillId, 'duration', false, true);
		return (float)attribValue.valueAdditive; 
	}

	private function ProcessNewSkill_MuscleMemory(out dmgInfos : array< SRawDamage >)
	{
		var witcherAttacker : W3PlayerWitcher;

		var skillId:ESkill;
		var damageIncreaseMultiplier:float;
		var i:int;
		var comboCounter:int;
		
		skillId = S_Sword_s22;
		witcherAttacker = GetWitcherPlayer();
		comboCounter = witcherAttacker.GetSkillComboCounter(skillId);

		
		if(comboCounter > 0)
		{
			damageIncreaseMultiplier = 1.0 + GetDamageIncreaseBaseMultiplier(skillId, false);

			for (i = 0; i < dmgInfos.Size(); i += 1)
			{
				dmgInfos[i].dmgVal *= damageIncreaseMultiplier;
			}

			LogNewCombatSkill(skillId, "Damage Multiplier : " + damageIncreaseMultiplier);
		}
	}

	private function ProcessNewSkill_StrengthTraining_Counter()
	{
		var witcherAttacker : W3PlayerWitcher;
		var swordEntity:CWitcherSword;
		var skillId:ESkill;
		var triggerAtAttackCount:int;
		var currentAttackCount:int;

		LogNewCombatSkill(skillId, "Enabled");

		skillId = S_Sword_s23;

		triggerAtAttackCount = GetTriggerAtAttackCount(skillId, false);

		
		witcherAttacker = GetWitcherPlayer();
		witcherAttacker.IncrementSkillComboCounter(skillId, GetSkillDuration(skillId));

		currentAttackCount = witcherAttacker.GetSkillComboCounter(skillId);

		if(currentAttackCount >= triggerAtAttackCount)
		{
			swordEntity = witcherAttacker.GetHeldSwordEntity();	
			if(swordEntity)
			{
				if(currentAttackCount == triggerAtAttackCount)
				{
					
					witcherAttacker.PlaySkillComboEffect(skillId, swordEntity, 'strong_attack_buff');
				}

				
				
			}
		}
	}

	private function ProcessNewSkill_StrengthTraining_Damage(out dmgInfos : array< SRawDamage >)
	{
		var witcherAttacker : W3PlayerWitcher;
		var swordEntity:CWitcherSword;

		var skillId:ESkill;
		var damageIncreaseMultiplier:float;
		var i:int;

		skillId = S_Sword_s23;

		witcherAttacker = GetWitcherPlayer();
		swordEntity = witcherAttacker.GetHeldSwordEntity();	

		LogNewCombatSkill(skillId, "Attack Num : " + witcherAttacker.GetSkillComboCounter(skillId));

		if (witcherAttacker.GetSkillComboCounter(skillId) >= GetTriggerAtAttackCount(skillId, false))
		{
			damageIncreaseMultiplier = 1.0 + GetDamageIncreaseBaseMultiplier(skillId, true);

			for (i = 0; i < dmgInfos.Size(); i += 1)
			{
				dmgInfos[i].dmgVal *= damageIncreaseMultiplier;
			}

			LogNewCombatSkill(skillId, "Damage Multiplier : " + damageIncreaseMultiplier);

			witcherAttacker.ResetSkillCombo(skillId);
		}
	}

	private function ProcessNewSkill_PreciseBlows(out dmgInfos : array< SRawDamage >, variation:EPreciseBlowsCounterId)
	{
		var witcherAttacker : W3PlayerWitcher;
		var swordEntity:CWitcherSword;
		var skillId:ESkill;
		var damageMultiplierValue:SAbilityAttributeValue;
		var i:int;
		var randVal:float;
		var triggerChance:float;
		var triggerAtAttackCount:int;
		var currentHitCount:int;
		var logMessage:string;
		var logMessageInGame:string;

		skillId = S_Sword_s24;

		witcherAttacker = GetWitcherPlayer();
		swordEntity = witcherAttacker.GetHeldSwordEntity();	

		witcherAttacker.IncrementSkillComboCounterEx(skillId, GetSkillDuration(skillId), variation);

		if(variation == PreciseBlowsCounterId_Fast)
			LogNewCombatSkill(skillId, "(Fast) : Attack Num : " + witcherAttacker.GetSkillComboCounterEx(skillId, variation));
		else
			LogNewCombatSkill(skillId, "(Strong) : Attack Num : " + witcherAttacker.GetSkillComboCounterEx(skillId, variation));

		
		triggerAtAttackCount = GetTriggerAtAttackCount(skillId, false);
		currentHitCount = witcherAttacker.GetSkillComboCounterEx(skillId, variation);
		
		if (currentHitCount == triggerAtAttackCount - 1)
		{
			logMessageInGame = currentHitCount + " ... Ready";
		}
		else if (currentHitCount == triggerAtAttackCount)
		{
			randVal = RandF();
			triggerChance = GetTriggerChance(skillId);
			if (randVal < triggerChance) 
			{
				logMessageInGame = "Power Strike !";
				if(swordEntity)
				{
					if(variation == PreciseBlowsCounterId_Fast)
						witcherAttacker.PlaySkillComboEffect(skillId, swordEntity, 'fast_attack_buff');
					else 
						witcherAttacker.PlaySkillComboEffect(skillId, swordEntity, 'strong_attack_buff');

					thePlayer.AddTimer('SkillPreciseBlowsActiveBuffDurationReset', GetSkillDuration(skillId), false, false, TICK_Main, false, false);
				}

				damageMultiplierValue = witcherAttacker.GetSkillAttributeValue(skillId, 'damage_increase', false, true);
				for (i = 0; i < dmgInfos.Size(); i += 1)
				{
					dmgInfos[i].dmgVal *= 1.0 + damageMultiplierValue.valueMultiplicative;
				}
				if(variation == PreciseBlowsCounterId_Fast)
					LogNewCombatSkill(skillId, "(Fast): Damage Multiplier : " + (1.0 + damageMultiplierValue.valueMultiplicative));
				else
					LogNewCombatSkill(skillId, "(Strong): Damage Multiplier : " + (1.0 + damageMultiplierValue.valueMultiplicative));
			}
			else 
			{
				logMessageInGame = "Missed ..."; 
				if(variation == PreciseBlowsCounterId_Fast)
					LogNewCombatSkill(skillId, "(Fast) : Chance failed : " + randVal + " > chance:" + triggerChance);
				else
					LogNewCombatSkill(skillId, "(Strong) : Chance failed : " + randVal + " > chance:" + triggerChance);
			}

			witcherAttacker.ResetSkillComboEx(skillId, PreciseBlowsCounterId_Fast);
			witcherAttacker.ResetSkillComboEx(skillId, PreciseBlowsCounterId_Strong);
		}
		else
		{
			logMessageInGame = currentHitCount + " ...";

			if(swordEntity)
			{
				witcherAttacker.StopAllSkillComboEffectsEx(skillId, PreciseBlowsCounterId_Fast);
				witcherAttacker.StopAllSkillComboEffectsEx(skillId, PreciseBlowsCounterId_Strong);
			}
		} 
	}

	private function ProcessNewSkill_CrushingBlows(out dmgInfos : array< SRawDamage >)
	{
		var witcherAttacker : W3PlayerWitcher;
		var swordEntity:CWitcherSword;
		var skillId:ESkill;
		var damageMultiplierValue:SAbilityAttributeValue;
		var triggerAtAttackCount:int;
		var firstPowerfulAttackCount:int;
		var attackCount:int;
		var i:int;
		var randVal:float;
		var triggerChance:float;
		var buffedAttackCount:int;
		var logMessage:string;
		var logMessageInGame:string;
		var resetCooldown:float;
		
		skillId = S_Sword_s25;

		resetCooldown = GetSkillDuration(skillId);

		witcherAttacker = GetWitcherPlayer();
		swordEntity = witcherAttacker.GetHeldSwordEntity();	

		triggerAtAttackCount = GetTriggerAtAttackCount(skillId, false);
		firstPowerfulAttackCount = triggerAtAttackCount + 1;

		attackCount = witcherAttacker.GetSkillComboCounter(skillId);

		if(attackCount == 0)
			witcherAttacker.IncrementSkillComboCounter(skillId, resetCooldown);
		else 
			witcherAttacker.IncrementSkillComboCounter(skillId, -1.0);

		attackCount += 1;

		if (attackCount >= triggerAtAttackCount)
		{
			buffedAttackCount = attackCount - triggerAtAttackCount;
			
			if(buffedAttackCount > 0)
			{
				
					

				
				damageMultiplierValue = witcherAttacker.GetSkillAttributeValue(skillId, 'damage_increase', false, true);
				for (i = 0; i < dmgInfos.Size(); i += 1)
				{
					dmgInfos[i].dmgVal *= 1.0 + damageMultiplierValue.valueMultiplicative;
				}
				logMessage += "Attack Num : " + attackCount + " POWER STRIKE: Damage Multiplier : " + (1.0 + damageMultiplierValue.valueMultiplicative);
				logMessageInGame += "Power Strike !";
			} 
			else 
			{
				logMessage += "Attack Num : " + attackCount;
			}

			randVal = RandF();
			triggerChance = GetTriggerChance(skillId);

			if (randVal < triggerChance) 
			{
				logMessage += " | SUCCESS";
				if(buffedAttackCount == 0)
					logMessageInGame += "Charging !";
				else	
					logMessageInGame += " (Recharged)";
				
				if(swordEntity && buffedAttackCount == 0)
					witcherAttacker.PlaySkillComboEffect(skillId, swordEntity, 'strong_attack_buff');
				
				
				witcherAttacker.ResetSkillComboCounter(skillId);
				witcherAttacker.IncrementSkillComboCounter(skillId, resetCooldown);
			}
			else 
			{
				logMessage += " | UNLUCKY : " + randVal + " > chance:" + triggerChance;

				
				if(buffedAttackCount == 0)
				{
					logMessageInGame = "Missed ...";
					witcherAttacker.ResetSkillComboCounter(skillId);
				}
				
				else if(buffedAttackCount == 2) 
				{
					
					
						
				}
			}
		}
	}


	private function ProcessNewSkill_AnatomicalKnowledge() : float
	{
		var witcherAttacker : W3PlayerWitcher;

		var i : int;
		var skillId : ESkill;
		var silverDamageValue, powerMod : SAbilityAttributeValue;
		var damageMultiplierValue : float;
		var equipedItem 		: SItemUniqueId;
		var silverSwordId : SItemUniqueId;
		
		skillId = S_Sword_s26;
		witcherAttacker = GetWitcherPlayer();
		
		if (witcherAttacker.GetItemEquippedOnSlot(EES_SilverSword, silverSwordId))
		{
			silverDamageValue = witcherAttacker.inv.GetItemAttributeValue(silverSwordId, 'SilverDamage');
			damageMultiplierValue = GetDamageIncreaseBaseMultiplier(skillId, true);

			
			powerMod = action.GetPowerStatValue();
			
			return silverDamageValue.valueBase * damageMultiplierValue;
		}

		return 0;
	}

	private function ProcessNewSkill_CripplingShot()
	{
		
	}

	private function ProcessNewSkill_SunderArmor()
	{
		var witcherAttacker : W3PlayerWitcher;
		var swordEntity:CWitcherSword;
		var skillId:ESkill;
		var armorReducAddValue:SAbilityAttributeValue;
		var attackCount:int;
		var i:int;
		var duration:float;
		var stackedCount:int;
		var skillLevel:int;
		var armorReduc:float;
		var currMultiplier:float;
		var npcVictim:CNewNPC;
		
		skillId = S_Sword_s28;

		npcVictim = (CNewNPC)attackAction.victim;

		if(!npcVictim) 
			return;

		duration = GetSkillDuration(skillId);

		witcherAttacker = GetWitcherPlayer();
		swordEntity = witcherAttacker.GetHeldSwordEntity();	

		skillLevel = witcherAttacker.GetSkillLevel(skillId);

		armorReducAddValue = witcherAttacker.GetSkillAttributeValue(skillId, 'armor_reduction_perc', false, true);

		armorReduc = CalculateAttributeValue(armorReducAddValue);

		
		currMultiplier = npcVictim.SunderArmor(armorReduc, armorReduc*skillLevel, duration);

		if(swordEntity )
			witcherAttacker.PlaySkillComboEffect(skillId, swordEntity, ''); 
	}

	private function ProcessNewSkill_CripplingStrikes()
	{
		var witcherAttacker : W3PlayerWitcher;
		var swordEntity:CWitcherSword;
		var skillId:ESkill;
		var damageMultiplier:float;
		var attackCount:int;
		var i:int;
		var duration:float;
		var skillLevel:int;
		var npcVictim:CNewNPC;
		
		skillId = S_Sword_s29;

		npcVictim = (CNewNPC)attackAction.victim;

		if(!npcVictim) 
			return;

		duration = GetSkillDuration(skillId);

		witcherAttacker = GetWitcherPlayer();

		swordEntity = witcherAttacker.GetHeldSwordEntity();	

		damageMultiplier = GetDamageIncreaseBaseMultiplier(skillId, true);

		npcVictim.CripplingStrike(damageMultiplier, duration);

		if(swordEntity)
			witcherAttacker.PlaySkillComboEffect(skillId, swordEntity, ''); 
	}

	private function ProcessNewSkills_Combat(out dmgInfos : array< SRawDamage >)
	{
		var witcherAttacker : W3PlayerWitcher;

		
		var perLevelDamageMultiplier:float;
		var damageIncreaseValue:SAbilityAttributeValue;
		var triggerChanceValue:SAbilityAttributeValue;
		var i:int;
		var triggerAtAttackCount:int;
		var cooldownSeconds:float;

		witcherAttacker = GetWitcherPlayer();

		

		if(witcherAttacker == playerAttacker 
			&& attackAction)
		{
			if(!playerAttacker.GetInventory().IsItemFists(weaponId) && playerAttacker.IsLightAttack(attackAction.GetAttackName())) 
			{
				if(witcherAttacker.CanUseSkill(S_Sword_s22))  
				{
					ProcessNewSkill_MuscleMemory(dmgInfos);
				}
				if(witcherAttacker.CanUseSkill(S_Sword_s23)) 
				{
					ProcessNewSkill_StrengthTraining_Counter();
				}
				if(witcherAttacker.CanUseSkill(S_Sword_s24)) 
				{
					witcherAttacker.ResetSkillComboEx(S_Sword_s24, PreciseBlowsCounterId_Strong); 

					
					witcherAttacker.StopAllSkillComboEffectsEx(S_Sword_s24, PreciseBlowsCounterId_Strong); 
					ProcessNewSkill_PreciseBlows(dmgInfos, PreciseBlowsCounterId_Fast); 
				}
			}
			else if( playerAttacker.IsHeavyAttack(attackAction.GetAttackName())) 
			{
				if(witcherAttacker.CanUseSkill(S_Sword_s23)) 
				{
					ProcessNewSkill_StrengthTraining_Damage(dmgInfos);
				}
				if(witcherAttacker.CanUseSkill(S_Sword_s24)) 
				{
					witcherAttacker.ResetSkillComboEx(S_Sword_s24, PreciseBlowsCounterId_Fast); 

					
					witcherAttacker.StopAllSkillComboEffectsEx(S_Sword_s24, PreciseBlowsCounterId_Fast); 
					ProcessNewSkill_PreciseBlows(dmgInfos, PreciseBlowsCounterId_Strong); 
				}
				if(witcherAttacker.CanUseSkill(S_Sword_s25))
				{
					ProcessNewSkill_CrushingBlows(dmgInfos); 
				}
				if(witcherAttacker.CanUseSkill(S_Sword_s28)) 
				{
					ProcessNewSkill_SunderArmor();
				}
			}
		}
	}
	*/
	//W3EE - End
	private function ProcessDamageIncrease(out dmgInfos : array< SRawDamage >)
	{
		var difficultyDamageMultiplier, rendLoad, rendBonus, overheal, rendRatio, focusCost, extraSignDamageMult, extraPoisonDamageMult, tempBonus : float;
		var i, j, dmgIdx, bonusCount, signSkillCatalystLevel, alchemySkillToxicShockLevel, meleeAttackCounterForResonanceSkill : int;
		var frozenBuff : W3Effect_Frozen;
		var frozenDmgInfo : SRawDamage;
		var hadFrostDamage, signSkillCatalystActive : bool;
		var mpac : CMovingPhysicalAgentComponent;
		var rendBonusPerPoint, staminaRendBonus, perk20Bonus, minCatalyst, maxCatalyst, minEnhanced, maxEnhanced : SAbilityAttributeValue;
		var witcherAttacker : W3PlayerWitcher;
		var damageVal, damageBonus, min, max			: SAbilityAttributeValue;		
		var npcVictim : CNewNPC;
		var sword : SItemUniqueId;
		var actionFreeze : W3DamageAction;
		var aerondight	: W3Effect_Aerondight;
		var conjunctionDamageMult, spellPowerIgni : float;
		var toxicShockDamage : SRawDamage;
		var swordEntity: CWitcherSword;
		var inv			: CInventoryComponent;

		
		var aardDamage : SRawDamage;
		var yrdens : array<W3YrdenEntity>;
		var levelDiff, forceDamageIdx : int; //W3EE
		var aardDamageF, bonusDamagePercents, damageBonusStack : float; //W3EE
		var spellPower, spellPowerAard, spellPowerYrden : float;
		var spNetflix : SAbilityAttributeValue;
		var poisonDamageValue : SAbilityAttributeValue;
		var attackPowerValue : SAbilityAttributeValue;
		var adrenalineEffect : W3Effect_CombatAdrenaline; //W3EE
		var lynxEffect : W3Effect_SwordDancing; //W3EE
		
		var entities : array<CGameplayEntity>;
		var skillPassiveMod : float;
		

		
		var monsterBonusType : name;
		var null, tempAttribute : SAbilityAttributeValue;
		var resonanceDamage : SRawDamage;

		var elementOfSurpriseMult : float;
		var survivalSkillElementOfSurpriseLevel : int;
		var minElementOfSurprise, maxElementOfSurprise : SAbilityAttributeValue;
		
		//W3EE - Begin
		if(playerAttacker && playerAttacker.GetBehaviorVariable( 'isPerformingSpecialAttack' ) > 0 && playerAttacker.GetBehaviorVariable( 'playerAttackType' ) == (int)PAT_Light)
			damageBonusStack -= 0.2f;
		
		if(playerAttacker && playerAttacker.IsInCombatAction_SpecialAttack() && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()))
		{
			witcherAttacker = (W3PlayerWitcher)playerAttacker;
			rendRatio = witcherAttacker.GetSpecialAttackTimeRatio();
			bonusDamagePercents = (0.5f + 0.1f * playerAttacker.GetSkillLevel(S_Sword_s02)) * rendRatio;
			
			if( rendRatio > 0.75f && witcherAttacker.HasAbility('Runeword 45 _Stats', true) )
			{
				bonusDamagePercents += witcherAttacker.GetStat(BCS_Focus) / 2;
				actorVictim.CreateFXEntityAtPelvis( 'runeword_4', true );
			}
			
			damageBonusStack += bonusDamagePercents * 1.f;
		}
		/*
		if(actorAttacker && !actorAttacker.IgnoresDifficultySettings() && !action.IsDoTDamage())
		{
			difficultyDamageMultiplier = CalculateAttributeValue(actorAttacker.GetAttributeValue(theGame.params.DIFFICULTY_DMG_MULTIPLIER));
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				dmgInfos[i].dmgVal = dmgInfos[i].dmgVal * difficultyDamageMultiplier;
			}
		}
		*/
		
		
		
		if(actorVictim && playerAttacker && !action.IsDoTDamage() && (actorVictim.HasBuff(EET_Frozen) || actorVictim.HasBuff(EET_SlowdownFrost)) && ( (W3AardProjectile)action.causer || (W3AardEntity)action.causer || action.DealsPhysicalOrSilverDamage()) )
		{
			damageBonusStack += 0.1f;
			action.SetWasFrozen();
			/*
			if( !( ( W3WhiteFrost )action.causer ) )
			{				
				damageBonusStack += 0.1f;
			}
			
			actorVictim.RemoveAllBuffsOfType(EET_Frozen);
			
			
			if( !( ( W3WhiteFrost )action.causer ) )
			{
				actionFreeze = new W3DamageAction in theGame;
				actionFreeze.Initialize( actorAttacker, actorVictim, action.causer, action.GetBuffSourceName(), EHRT_None, CPS_Undefined, action.IsActionMelee(), action.IsActionRanged(), action.IsActionWitcherSign(), action.IsActionEnvironment() );
				actionFreeze.SetCannotReturnDamage( true );
				actionFreeze.SetCanPlayHitParticle( false );
				actionFreeze.SetHitAnimationPlayType( EAHA_ForceNo );
				actionFreeze.SetWasFrozen();		
				actionFreeze.AddDamage( theGame.params.DAMAGE_NAME_FROST, frozenDmgInfo.dmgVal );
				theGame.damageMgr.ProcessAction( actionFreeze );
				delete actionFreeze;
			}
			*/
		}
		
		
		/*
		if(actorVictim && playerAttacker && GetWitcherPlayer().IsSetBonusActive( EISB_Netflix_2 ) && !action.IsDoTDamage() && ( (W3AardProjectile)action.causer || (W3AardEntity)action.causer)) 
		{	
			yrdens = GetWitcherPlayer().yrdenEntities;
			
			if(yrdens.Size() > 0)
			{
				spellPowerAard = CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue('spell_power_aard'));
				spellPowerYrden = CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue('spell_power_yrden'));				
				spellPower = ClampF(1 + spellPowerAard + spellPowerYrden + CalculateAttributeValue(GetWitcherPlayer().GetPowerStatValue(CPS_SpellPower)), 1, 3); 				
			
				for(i=0; i<yrdens.Size(); i+=1)
				{
					for(j=0; j<yrdens[i].validTargetsInArea.Size(); j+=1)
					{			
						if(yrdens[i].validTargetsInArea[j] == actorVictim )
						{
							levelDiff = playerAttacker.GetLevel() - actorVictim.GetLevel();
							aardDamage.dmgType = theGame.params.DAMAGE_NAME_DIRECT;	
							if( GetWitcherPlayer().CanUseSkill(S_Magic_s06) )
								aardDamageF = (RandRangeF(375.0, 325.0) + (playerAttacker.GetLevel() * 1.8f) + (GetWitcherPlayer().GetSkillLevel(S_Magic_s06) * 100) ) * spellPower;
							else
								aardDamageF = (RandRangeF(375.0, 325.0) + (playerAttacker.GetLevel() * 1.8f) ) * spellPower;
							
							if( actorVictim.GetCharacterStats().HasAbilityWithTag('Boss') || (W3MonsterHuntNPC)actorVictim || (levelDiff < 0 && Abs(levelDiff) > theGame.params.LEVEL_DIFF_HIGH))
							{
								aardDamage.dmgVal = aardDamageF * 0.75f;
							}					
							else
							{
								aardDamage.dmgVal = aardDamageF;
							}
							
							spNetflix = action.GetPowerStatValue();
							aardDamage.dmgVal += 3 * actorVictim.GetHealth() * ( 0.01 + 0.03 * LogF( spNetflix.valueMultiplicative ) );
							dmgInfos.PushBack(aardDamage);
						}
					}
				}
			}
		}

		
		if ( actorVictim && playerAttacker && GetWitcherPlayer().CanUseSkill( S_Magic_s35 ) )
		{
			yrdens = GetWitcherPlayer().yrdenEntities;
			signSkillCatalystLevel = playerAttacker.GetSkillLevel( S_Magic_s35 );
			signSkillCatalystActive = yrdens.Size() > 0 && ( action.GetSignType() == ST_Aard || action.GetSignType() == ST_Igni );

			if ( signSkillCatalystActive )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('magic_s35', 'spell_power_aard_igni', minCatalyst, maxCatalyst);
				extraSignDamageMult = minCatalyst.valueMultiplicative * signSkillCatalystLevel;

				spellPower = action.GetDamageValueTotal();

				for(i=0; i<yrdens.Size(); i+=1)
				{
					for(j=0; j<yrdens[i].validTargetsInArea.Size(); j+=1)
					{			
						if(yrdens[i].validTargetsInArea[j] == actorVictim )
						{
							
							for ( dmgIdx = 0; dmgIdx < dmgInfos.Size(); dmgIdx += 1 )
							{
								dmgInfos[dmgIdx].dmgVal *= ( 1 + extraSignDamageMult );
							}
						}
					}
				}
			}
		}

		

		
		if( playerAttacker && action.IsActionMelee() && playerAttacker.IsHeavyAttack( attackAction.GetAttackName() ) &&
			playerAttacker.CanUseSkill( S_Alchemy_s23 ) && GetWitcherPlayer().CanUseToxicShock() )
		{
			if ( actorVictim && actorVictim.HasBuff( EET_Poison ) )
			{
				alchemySkillToxicShockLevel = playerAttacker.GetSkillLevel(S_Alchemy_s23);
				switch (alchemySkillToxicShockLevel)
				{
					case 1:
						theGame.GetDefinitionsManager().GetAbilityAttributeValue('alchemy_s23', 'poison_dmg_level_1', minEnhanced, maxEnhanced);
						extraPoisonDamageMult = minEnhanced.valueMultiplicative;
						break;
					case 2:
						theGame.GetDefinitionsManager().GetAbilityAttributeValue('alchemy_s23', 'poison_dmg_level_2', minEnhanced, maxEnhanced);
						extraPoisonDamageMult = minEnhanced.valueMultiplicative;
						break;
					case 3:
						theGame.GetDefinitionsManager().GetAbilityAttributeValue('alchemy_s23', 'poison_dmg_level_3', minEnhanced, maxEnhanced);
						extraPoisonDamageMult = minEnhanced.valueMultiplicative;
						break;
					default:
						theGame.GetDefinitionsManager().GetAbilityAttributeValue('alchemy_s23', 'poison_dmg_level_3', minEnhanced, maxEnhanced);
						extraPoisonDamageMult = minEnhanced.valueMultiplicative;
						break;
				}

				toxicShockDamage.dmgType = theGame.params.DAMAGE_NAME_POISON;
				toxicShockDamage.dmgVal = action.GetDamageValueTotal() * extraPoisonDamageMult;
				dmgInfos.PushBack( toxicShockDamage );
				actorVictim.RemoveBuff( EET_Poison );
				GetWitcherPlayer().ConsumeToxicShock();
				thePlayer.AddTimer( 'ResetToxicShock', 5.0,,,, true );

				swordEntity = GetWitcherPlayer().GetHeldSwordEntity();
				if (swordEntity)
				{
					swordEntity.PlayEffect('toxic_shock_sword');
				}
			}
		}

		
		if ( actorVictim && playerAttacker && playerAttacker.CanUseSkill( S_Perk_37 ) )
		{
			conjunctionDamageMult = CalculateAttributeValue( playerAttacker.GetSkillAttributeValue( S_Perk_37, 'damage_multiplier', false, false ) );
			conjunctionDamageMult = 1 + playerAttacker.GetSkillLevel( S_Perk_37 ) * conjunctionDamageMult;

			for ( i = 0; i < dmgInfos.Size(); i += 1 )
			{
				if ( IsDamageTypeAnyPhysicalType( dmgInfos[i].dmgType ) )
				{
					continue;
				}

				dmgInfos[i].dmgVal *= conjunctionDamageMult;
			}
		}
			
		
		if(actorVictim)
		{
			mpac = (CMovingPhysicalAgentComponent)actorVictim.GetMovingAgentComponent();
						
			if(mpac && mpac.IsDiving())
			{
				mpac = (CMovingPhysicalAgentComponent)actorAttacker.GetMovingAgentComponent();	
				
				if(mpac && mpac.IsDiving())
				{
					action.SetUnderwaterDisplayDamageHack();
				
					if(playerAttacker && attackAction && attackAction.IsActionRanged())
					{
						for(i=0; i<dmgInfos.Size(); i+=1)
						{
							if(FactsQuerySum("NewGamePlus"))
							{
								dmgInfos[i].dmgVal *= (1 + theGame.params.UNDERWATER_CROSSBOW_DAMAGE_BONUS_NGP);
							}
							else
							{
								dmgInfos[i].dmgVal *= (1 + theGame.params.UNDERWATER_CROSSBOW_DAMAGE_BONUS);
							}
						}
					}
				}
			}
		}
		
		
		if(playerAttacker && attackAction && SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02)
		{
			witcherAttacker = (W3PlayerWitcher)playerAttacker;
			
			
			rendRatio = witcherAttacker.GetSpecialAttackTimeRatio();
			
			
			rendLoad = MinF(rendRatio * playerAttacker.GetStatMax(BCS_Focus), playerAttacker.GetStat(BCS_Focus));
			
			
			if(rendLoad >= 1)
			{
				rendBonusPerPoint = witcherAttacker.GetSkillAttributeValue(S_Sword_s02, 'adrenaline_damage_bonus', false, true);
				rendBonus = FloorF(rendLoad) * rendBonusPerPoint.valueMultiplicative * witcherAttacker.GetSkillLevel(S_Sword_s02);
				
				for(i=0; i<dmgInfos.Size(); i+=1)
				{
					dmgInfos[i].dmgVal *= (1 + rendBonus);
				}
			}
			
			
			staminaRendBonus = witcherAttacker.GetSkillAttributeValue(S_Sword_s02, 'stamina_max_dmg_bonus', false, true);
			
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				dmgInfos[i].dmgVal *= (1 + rendRatio * staminaRendBonus.valueMultiplicative);
			}
			
			
			thePlayer.SetAttackActionName('');
		}	
 
		
		if ( actorAttacker != thePlayer && action.IsActionRanged() && (int)CalculateAttributeValue(actorAttacker.GetAttributeValue('level',,true)) > 31)
		{
			damageVal = actorAttacker.GetAttributeValue('light_attack_damage_vitality',,true);
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				dmgInfos[i].dmgVal = dmgInfos[i].dmgVal + CalculateAttributeValue(damageVal) / 2;
			}
		}
		
		
		if ( actorVictim && playerAttacker && attackAction && action.IsActionMelee() && thePlayer.HasAbility('Runeword 4 _Stats', true) && !attackAction.WasDodged() )
		{
			overheal = thePlayer.abilityManager.GetOverhealBonus() / thePlayer.GetStatMax(BCS_Vitality);
		
			if(overheal > 0.005f)
			{
				for(i=0; i<dmgInfos.Size(); i+=1)
				{
					dmgInfos[i].dmgVal *= 1.0f + overheal;
				}
			
				thePlayer.abilityManager.ResetOverhealBonus();
				
				
				actorVictim.CreateFXEntityAtPelvis( 'runeword_4', true );				
			}
		}
		
		
		if( playerAttacker && actorVictim && attackAction.IsActionMelee() && GetWitcherPlayer().IsSetBonusActive( EISB_Wolf_1 ) )
		{
			FindGameplayEntitiesInRange( entities, playerAttacker, 50, 1000, , FLAG_OnlyAliveActors );
			if( entities.Size() > 0 )
			{
				for( i=0; i<entities.Size(); i+=1 )
				{
					npcVictim = (CNewNPC) entities[i];
					if( npcVictim )
					{
						if( npcVictim.HasBuff( EET_Bleeding ) )  bonusCount += 1;
						if( npcVictim.HasBuff( EET_Bleeding1 ) ) bonusCount += 1;
						if( npcVictim.HasBuff( EET_Bleeding2 ) ) bonusCount += 1;
						if( npcVictim.HasBuff( EET_Bleeding3 ) ) bonusCount += 1;
					}
				}
				
				bonusCount *= ((W3PlayerWitcher)playerAttacker).GetSetPartsEquipped( EIST_Wolf );
				
				for( i=0; i<dmgInfos.Size() ; i+=1 )
				{
					dmgInfos[i].dmgVal *= 1 + bonusCount*0.01;
				}
			}
		}
		

		
		if ( playerAttacker && attackAction.IsActionMelee() && thePlayer.HasBuff( EET_ElementOfSurprise ) )
		{
			survivalSkillElementOfSurpriseLevel = thePlayer.GetSkillLevel( S_Perk_44 );
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('perk_44', 'melee_damage_increase', minElementOfSurprise, maxElementOfSurprise);
			elementOfSurpriseMult = minElementOfSurprise.valueMultiplicative * survivalSkillElementOfSurpriseLevel;

			for( i=0 ; i<dmgInfos.Size() ; i += 1 )
			{
				dmgInfos[i].dmgVal *= 1 + elementOfSurpriseMult;
			}
		}
		
		
		if( playerAttacker && playerAttacker.IsLightAttack( attackAction.GetAttackName() ) && playerAttacker.HasBuff( EET_LynxSetBonus ) && !attackAction.WasDodged() ) 
		{
			if( !attackAction.IsParried() && !attackAction.IsCountered() )
			{
				
				damageBonus = playerAttacker.GetAttributeValue( 'lynx_dmg_boost' );
				
				damageBonus.valueAdditive *= ((W3PlayerWitcher)playerAttacker).GetSetPartsEquipped( EIST_Lynx );
				
				for( i=0 ; i<dmgInfos.Size() ; i += 1 )
				{
					dmgInfos[i].dmgVal *= 1 + damageBonus.valueAdditive;
				}
			}
		}

		
		if( playerAttacker && attackAction.IsActionMelee() && actorVictim.IsAttackerAtBack( playerAttacker ) && !actorVictim.HasAbility( 'CannotBeAttackedFromBehind' ) && ((W3PlayerWitcher)playerAttacker).IsSetBonusActive( EISB_Lynx_2 ) && !attackAction.WasDodged() && ( playerAttacker.inv.IsItemSteelSwordUsableByPlayer( attackAction.GetWeaponId() ) || playerAttacker.inv.IsItemSilverSwordUsableByPlayer( attackAction.GetWeaponId() ) ) )
		{
			if( !attackAction.IsParried() && !attackAction.IsCountered() && playerAttacker.GetStat(BCS_Focus) >= 1.0f )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_Lynx_2 ), 'lynx_2_dmg_boost', min, max );
				for( i=0; i<dmgInfos.Size() ; i+=1 )
				{
					dmgInfos[i].dmgVal *= 1 + min.valueAdditive;
				}
				
				if ( !( thePlayer.IsInCombatAction() && ( thePlayer.GetCombatAction() == EBAT_SpecialAttack_Light || thePlayer.GetCombatAction() == EBAT_SpecialAttack_Heavy ) ) )
				{
					theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_Lynx_2 ), 'lynx_2_adrenaline_cost', min, max );
					focusCost = min.valueAdditive;
					if( GetWitcherPlayer().GetStat( BCS_Focus ) >= focusCost )
					{				
						theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_Lynx_2 ), 'lynx_2_stun_duration', min, max );
						attackAction.AddEffectInfo( EET_Confusion, min.valueAdditive );
						playerAttacker.SoundEvent( "ep2_setskill_lynx_activate" );
						playerAttacker.DrainFocus( focusCost );
					}
				}
			}
		}

		
		
		
		if ( playerAttacker && action.IsActionRanged() && ((W3Petard)action.causer) )
		{
			skillPassiveMod = CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue('potion_duration'));
			for( i = 0 ; i < dmgInfos.Size() ; i+=1)
			{
				dmgInfos[i].dmgVal *= ( 1 + skillPassiveMod );
			}
			
			
			if ( GetWitcherPlayer().CanUseSkill(S_Perk_20) && !action.IsDoTDamage() )
			{
				perk20Bonus = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_20, 'dmg_multiplier', false, false);
				for( i = 0 ; i < dmgInfos.Size() ; i+=1)
				{
					dmgInfos[i].dmgVal *= ( 1 + perk20Bonus.valueMultiplicative );
				}
			}
			

			
			if ( GetWitcherPlayer().CanUseSkill(S_Perk_27) && !action.IsDoTDamage() )
			{
				perk20Bonus = GetWitcherPlayer().GetAttributeValue('bomb_dmg_multiplier');
				for( i = 0 ; i < dmgInfos.Size() ; i+=1)
				{
					dmgInfos[i].dmgVal *= ( 1 + perk20Bonus.valueMultiplicative );
				}
			}

			
			if ( !playerVictim && playerAttacker.CanUseSkill(S_Alchemy_s25) && !action.IsDoTDamage() )
			{
				tempBonus = playerAttacker.GetStat(BCS_Toxicity) * CalculateAttributeValue(playerAttacker.GetSkillAttributeValue( S_Alchemy_s25, 'bomb_damage_bonus', false, false) * playerAttacker.GetSkillLevel(S_Alchemy_s25));
				for( i = 0 ; i < dmgInfos.Size() ; i+=1)
				{
					dmgInfos[i].dmgVal *= ( 1 + tempBonus );
				}
			}

			
			if ( GetWitcherPlayer().CanUseSkill(S_Perk_44) && !action.IsDoTDamage() )
			{
				thePlayer.AddEffectDefault( EET_ElementOfSurprise, NULL, "ElementOfSurpriseEffect" );
			}	
		}
		
		
		if( playerAttacker && action.IsActionWitcherSign() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation1 ) )
		{
			sword = playerAttacker.inv.GetCurrentlyHeldSword();
			
			damageVal.valueBase = 0;
			damageVal.valueMultiplicative = 0;
			damageVal.valueAdditive = 0;
		
			if( playerAttacker.inv.GetItemCategory(sword) == 'steelsword' )
			{
				damageVal += playerAttacker.inv.GetItemAttributeValue(sword, theGame.params.DAMAGE_NAME_SLASHING);
			}
			else if( playerAttacker.inv.GetItemCategory(sword) == 'silversword' )
			{
				damageVal += playerAttacker.inv.GetItemAttributeValue(sword, theGame.params.DAMAGE_NAME_SILVER);
			}
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation1', 'dmg_bonus_factor', min, max);				
			
			damageVal.valueBase *= CalculateAttributeValue(min);
			
			if( action.IsDoTDamage() )
			{
				damageVal.valueBase *= action.GetDoTdt();
			}
			
			for( i = 0 ; i < dmgInfos.Size() ; i+=1)
			{
				dmgInfos[i].dmgVal += damageVal.valueBase;
			}
		}
		
		
		npcVictim = (CNewNPC) actorVictim;
		if( playerAttacker && npcVictim && attackAction && action.IsActionMelee() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation8 ) && ( victimMonsterCategory != MC_Human || npcVictim.IsImmuneToMutation8Finisher() ) && attackAction.GetWeaponId() == GetWitcherPlayer().GetHeldSword() )
		{
			dm.GetAbilityAttributeValue( 'Mutation8', 'dmg_bonus', min, max );
			
			for( i = 0 ; i < dmgInfos.Size() ; i+=1)
			{
				dmgInfos[i].dmgVal *= 1 + min.valueMultiplicative;
			}
		}
		
		
		if( playerAttacker && actorVictim && attackAction && action.IsActionMelee() && playerAttacker.inv.ItemHasTag( attackAction.GetWeaponId(), 'Aerondight' ) )
		{	
			aerondight = (W3Effect_Aerondight)playerAttacker.GetBuff( EET_Aerondight );	
			
			if( aerondight )
			{
				min = playerAttacker.GetAbilityAttributeValue( 'AerondightEffect', 'dmg_bonus' );
				bonusCount = aerondight.GetCurrentCount();
			
				if( bonusCount > 0 )
				{
					min.valueMultiplicative *= bonusCount;
					
					for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
					{
						dmgInfos[i].dmgVal *= 1 + min.valueMultiplicative;
					}
				}				
			}
		}

		
		
		if(npcVictim) 
		{
			for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
			{
				dmgInfos[i].dmgVal *= 1 + npcVictim.GetCripplingStrikeDamageMultiplier();
			}
		}

		
		if(playerAttacker && playerAttacker.CanUseSkill(S_Perk_28))
		{
			for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
			{
				if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_POISON)
				{
					poisonDamageValue = playerAttacker.GetAttributeValue('poison_dmg_multiplier');
					dmgInfos[i].dmgVal *= 1 + poisonDamageValue.valueMultiplicative;
				}
			}
		}

		
		if( !playerAttacker && actorAttacker && playerVictim && playerVictim.CanUseSkill( S_Alchemy_s24 ) )
		{
			
			if ( playerVictim.GetStat( BCS_Toxicity, false ) / playerVictim.GetStatMax( BCS_Toxicity ) >= CalculateAttributeValue( playerVictim.GetSkillAttributeValue(S_Alchemy_s24, 'toxicity_threshold', false, true ) ) )
			{
				tempBonus = CalculateAttributeValue( playerVictim.GetSkillAttributeValue( S_Alchemy_s24, 'received_damage_multiplier', false, true ) );
				for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
				{
					dmgInfos[i].dmgVal *= tempBonus;
				}
			}
		}
	
		
		if( actorVictim && playerAttacker && attackAction && attackAction.IsActionMelee() && playerAttacker.CanUseSkill(S_Alchemy_s26) 
			&& playerAttacker.inv.ItemHasActiveOilApplied( weaponId, victimMonsterCategory ) )
		{
			
			monsterBonusType = MonsterCategoryToAttackPowerBonus(victimMonsterCategory);
			tempAttribute = playerAttacker.inv.GetItemAttributeValue(weaponId, monsterBonusType);
		
			if(tempAttribute != null && actorVictim.IsImmuneToBuff( EET_Poison ) )
			{
				tempBonus = CalculateAttributeValue( playerAttacker.GetSkillAttributeValue(S_Alchemy_s26, 'damage_bonus_immune', false, true ) * playerAttacker.GetSkillLevel(S_Alchemy_s26) );
				for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
				{
					dmgInfos[i].dmgVal *= 1 + tempBonus;
				}
			}
			else if(tempAttribute != null)
			{
				tempBonus = CalculateAttributeValue( playerAttacker.GetSkillAttributeValue(S_Alchemy_s26, 'damage_bonus', false, true ) * playerAttacker.GetSkillLevel(S_Alchemy_s26) );
				for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
				{
					dmgInfos[i].dmgVal *= 1 + tempBonus;
				}
			}
		}

		
		meleeAttackCounterForResonanceSkill = thePlayer.GetMeleeAttackCounterForResonanceSkill();
		if( playerAttacker && attackAction && attackAction.IsActionMelee() && !playerAttacker.GetInventory().IsItemFists(weaponId) && playerAttacker.HasBuff(EET_Resonance) &&
			meleeAttackCounterForResonanceSkill <= 3)
		{
			tempAttribute = playerAttacker.GetPowerStatValue(CPS_SpellPower);
			tempBonus = tempAttribute.valueMultiplicative;
			tempBonus *= CalculateAttributeValue( playerAttacker.GetSkillAttributeValue(S_Magic_s41, 'sign_intensity_ratio', false, true ) * playerAttacker.GetSkillLevel(S_Magic_s41) );

			for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
			{
				dmgInfos[i].dmgVal *= 1 + tempBonus;
			}

			if (meleeAttackCounterForResonanceSkill == 3)
			{
				playerAttacker.RemoveBuff(EET_Resonance);
				thePlayer.SetMeleeAttackCounterForResonanceSkill(1);

				if(GetWitcherPlayer())
				{
					GetWitcherPlayer().StopEffect('resonance_sword');
				}
			}
			else
			{
				thePlayer.SetMeleeAttackCounterForResonanceSkill(meleeAttackCounterForResonanceSkill+1);
			}
		}

		
		if(attackAction.GetAttackName() == 'bolt')
		{
			if(thePlayer.CanUseSkill(S_Sword_s26)) 
			{
				tempBonus = ProcessNewSkill_AnatomicalKnowledge();
				for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
				{
					dmgInfos[i].dmgVal += tempBonus;
				}
			}

			if(attackAction.GetIsHeadShot() && playerAttacker && playerAttacker.CanUseSkill(S_Sword_s32))
			{
				tempBonus = CalculateAttributeValue( playerAttacker.GetSkillAttributeValue(S_Sword_s32, 'damage_increase', false, true ));
				for( i = 0 ; i < dmgInfos.Size() ; i += 1 )
				{
					dmgInfos[i].dmgVal *= 1 + tempBonus;
				}
			}


		}
		*/
		if( playerAttacker && playerAttacker.HasBuff( EET_SwordDancing ) && !attackAction.WasDodged() ) 
		{
			if( !attackAction.IsParried() && !attackAction.IsCountered() )
			{
				lynxEffect = (W3Effect_SwordDancing)playerAttacker.GetBuff(EET_SwordDancing);
				if( lynxEffect.GetSourceName() == "HeavyAttack" && playerAttacker.IsLightAttack(attackAction.GetAttackName()) || lynxEffect.GetSourceName() == "LightAttack" && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) )
				{
					damageBonusStack += 0.15f;
				}
			}
		}
		
		if( actorAttacker.HasBuff(EET_GlyphDebuff) && GetWitcherPlayer().CanUseSkill(S_Magic_s11) )
		{
			if( GetWitcherPlayer().HasAbility('Glyphword 18 _Stats', true) )
				dmgInfos[i].dmgVal *= 1.f - 0.06f * GetWitcherPlayer().GetSkillLevel(S_Magic_s11);
			else
				dmgInfos[i].dmgVal *= 1.f - 0.03f * GetWitcherPlayer().GetSkillLevel(S_Magic_s11);
		}
		
		if( damageBonusStack )
		{
			for(i=0; i<dmgInfos.Size(); i+=1)
				dmgInfos[i].dmgVal *= 1.f + damageBonusStack;
		}
		//W3EE - End

	}
	
	
	private function ProcessActionReturnedDamage()
	{
		var witcher 			: W3PlayerWitcher;
		var quen 				: W3QuenEntity;
		var params 				: SCustomEffectParams;
		var processFireShield, canBeParried, canBeDodged, wasParried, wasDodged, returned : bool;
		var g5Chance			: SAbilityAttributeValue;
		var dist, checkDist		: float;
		
		
		if((W3PlayerWitcher)playerVictim && !playerAttacker && actorAttacker && !action.IsDoTDamage() && action.IsActionMelee() && (attackerMonsterCategory == MC_Necrophage || attackerMonsterCategory == MC_Vampire) && actorVictim.HasBuff(EET_BlackBlood))
		{
			returned = ProcessActionBlackBloodReturnedDamage();		
		}
		

		
		
		if(action.IsActionMelee() && actorVictim.HasAbility( 'Thorns' ) )
		{
			returned = ProcessActionThornDamage() || returned;
		}
		
		//W3EE - Begin
		/*
		if(actorVictim.HasAbility( 'Glyphword 5 _Stats', true))
		{			
			if( GetAttitudeBetween(actorAttacker, actorVictim) == AIA_Hostile)
			{
				if( !action.IsDoTDamage() )
				{
					g5Chance = actorVictim.GetAttributeValue('glyphword5_chance');
					
					if(RandF() < g5Chance.valueAdditive)
					{
						canBeParried = attackAction.CanBeParried();
						canBeDodged = attackAction.CanBeDodged();
						wasParried = attackAction.IsParried() || attackAction.IsCountered();
						wasDodged = attackAction.WasDodged();
				
						if(!action.IsActionMelee() || (!canBeParried && canBeDodged && !wasDodged) || (canBeParried && !wasParried && !canBeDodged) || (canBeParried && canBeDodged && !wasDodged && !wasParried))
						{
							returned = ProcessActionReflectDamage() || returned;
						}
					}	
				}
			}			
			
		}
		
		
		if(playerVictim && !playerAttacker && actorAttacker && attackAction && attackAction.IsActionMelee() && thePlayer.HasBuff(EET_Mutagen26))
		{
			returned = ProcessActionLeshenMutagenDamage() || returned;
		}
		*/
		//W3EE - End
		
		
		if(action.IsActionMelee() && actorVictim.HasAbility( 'FireShield' ) )
		{
			witcher = GetWitcherPlayer();			
			processFireShield = true;			
			if(playerAttacker == witcher)
			{
				quen = (W3QuenEntity)witcher.GetSignEntity(ST_Quen);
				if(quen && quen.IsAnyQuenActive())
				{
					processFireShield = false;
				}
			}
			
			if(processFireShield)
			{
				params.effectType = EET_Burning;
				params.creator = actorVictim;
				params.sourceName = actorVictim.GetName();
				
				params.effectValue.valueMultiplicative = 0.01;
				actorAttacker.AddEffectCustom(params);
				returned = true;
			}
		}
		
		
		if(actorAttacker.UsesEssence())
		{
			returned = ProcessSilverStudsReturnedDamage() || returned;
		}
		//W3EE - Begin
		/*
		if( (W3PlayerWitcher)playerVictim && !playerAttacker && actorAttacker && !playerAttacker.IsInFistFightMiniGame() && !action.IsDoTDamage() && action.IsActionMelee() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation4 ) )
		{
			
			dist = VecDistance( actorAttacker.GetWorldPosition(), actorVictim.GetWorldPosition() );
			checkDist = 3.f;
			if( actorAttacker.IsHuge() )
			{
				checkDist += 3.f;
			}
 
			if( dist <= checkDist )
			{
				returned = GetWitcherPlayer().ProcessActionMutation4ReturnedDamage( action.processedDmg.vitalityDamage, actorAttacker, EAHA_ForceYes, action ) || returned;
			}
		}
		*/
		//W3EE - End
		action.SetWasDamageReturnedToAttacker( returned );
	}
	//W3EE - Begin
	/*
	private function ProcessActionLeshenMutagenDamage() : bool
	{
		var damageAction : W3DamageAction;
		var returnedDamage, pts, perc : float;
		var mutagen : W3Mutagen26_Effect;
		
		mutagen = (W3Mutagen26_Effect)playerVictim.GetBuff(EET_Mutagen26);
		mutagen.GetReturnedDamage(pts, perc);
		
		if(pts <= 0 && perc <= 0)
			return false;
			
		
		
		returnedDamage = pts + perc * action.processedDmg.vitalityDamage;
		
		
		
		damageAction = new W3DamageAction in this;		
		damageAction.Initialize( action.victim, action.attacker, NULL, "Mutagen26", EHRT_None, CPS_AttackPower, true, false, false, false );		
		damageAction.SetCannotReturnDamage( true );		
		damageAction.SetHitAnimationPlayType( EAHA_ForceNo );		
		
		
		
		damageAction.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, returnedDamage);
		
		
		theGame.damageMgr.ProcessAction(damageAction);
		delete damageAction;
		
		return true;
	}
	*/
	//W3EE - End
	private function ProcessSilverStudsReturnedDamage() : bool
	{
		var damageAction : W3DamageAction;
		var returnedDamage : float;
		
		returnedDamage = CalculateAttributeValue(actorVictim.GetAttributeValue('returned_silver_damage'));
		
		if(returnedDamage <= 0)
			return false;
		
		damageAction = new W3DamageAction in this;		
		damageAction.Initialize( action.victim, action.attacker, NULL, "SilverStuds", EHRT_None, CPS_AttackPower, true, false, false, false );		
		damageAction.SetCannotReturnDamage( true );		
		damageAction.SetHitAnimationPlayType( EAHA_ForceNo );		
		damageAction.SetPointResistIgnored( true ); //W3EE
		
		damageAction.AddDamage(theGame.params.DAMAGE_NAME_SILVER, returnedDamage);
		
		theGame.damageMgr.ProcessAction(damageAction);
		delete damageAction;
		
		return true;
	}
	
	
	private function ProcessActionBlackBloodReturnedDamage() : bool
	{
		var returnedAction : W3DamageAction;
		var returnVal : SAbilityAttributeValue;
		var bb : W3Potion_BlackBlood;
		var potionLevel : int;
		var returnedDamage : float;
		var attackerPoise : W3Effect_NPCPoise; //W3EE
	
		if(action.processedDmg.vitalityDamage <= 0)
			return false;
		
		bb = (W3Potion_BlackBlood)actorVictim.GetBuff(EET_BlackBlood);
		potionLevel = bb.GetBuffLevel();
		
		
		returnedAction = new W3DamageAction in this;		
		returnedAction.Initialize( action.victim, action.attacker, bb, "BlackBlood", EHRT_None, CPS_Undefined, true, false, false, false );	//W3EE
		returnedAction.SetCannotReturnDamage( true );
		//W3EE - Begin
		/*
		returnVal = bb.GetReturnDamageValue();
		
		if(potionLevel == 1)
		{
			returnedAction.SetHitAnimationPlayType(EAHA_ForceNo);
		}
		else
		{
			returnedAction.SetHitAnimationPlayType(EAHA_ForceYes);
			returnedAction.SetHitReactionType(EHRT_Reflect);
		}
		*/
		//W3EE - End
		returnedDamage = bb.GetReturnDamageValue(action.processedDmg.vitalityDamage); //W3EE
		returnedAction.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, returnedDamage);
		
		//W3EE - Begin
		if( returnedDamage > 0)
		{
			attackerPoise = (W3Effect_NPCPoise)actorAttacker.GetBuff(EET_NPCPoise);
			attackerPoise.ReducePoise(returnedDamage / 50.f, 4.f);
			returnedAction.AddDamage(theGame.params.DAMAGE_NAME_MORALE, returnedDamage / 100.f);
			actorAttacker.ApplyPoisoning(CeilF(returnedDamage / 500.f), action.victim, "BlackBlood", true);
		}
		returnedAction.SetHitAnimationPlayType(EAHA_ForceNo);
		returnedAction.AddEffectInfo(EET_Stagger);
		returnedAction.SetPointResistIgnored( true );
		//W3EE - End
		theGame.damageMgr.ProcessAction(returnedAction);
		delete returnedAction;
		
		return true;
	}
	//W3EE - Begin
	/*
	private function ProcessActionReflectDamage() : bool
	{
		var returnedAction : W3DamageAction;
		var returnVal, min, max : SAbilityAttributeValue;
		var potionLevel : int;
		var returnedDamage : float;
		var template : CEntityTemplate;
		var fxEnt : CEntity;
		var boneIndex: int;
		var b : bool;
		var component : CComponent;
		
		
		if(action.processedDmg.vitalityDamage <= 0)
			return false;
		
		returnedDamage = CalculateAttributeValue(actorVictim.GetTotalArmor());
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 5 _Stats', 'damage_mult', min, max);
		
		
		
		
		returnedAction = new W3DamageAction in this;		
		returnedAction.Initialize( action.victim, action.attacker, NULL, "Glyphword5", EHRT_None, CPS_AttackPower, true, false, false, false );		
		returnedAction.SetCannotReturnDamage( true );		
		returnedAction.SetHitAnimationPlayType(EAHA_ForceYes);
		returnedAction.SetHitReactionType(EHRT_Heavy);
		
		returnedAction.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, returnedDamage * min.valueMultiplicative);
		
		
		
		
		theGame.damageMgr.ProcessAction(returnedAction);
		delete returnedAction;
		
		template = (CEntityTemplate)LoadResource('glyphword_5');
		
		
		
		
		
		
		component = action.attacker.GetComponent('torso3effect');
		if(component)
			thePlayer.PlayEffect('reflection_damge', component);
		else
			thePlayer.PlayEffect('reflection_damge', action.attacker);
		action.attacker.PlayEffect('yrden_shock');
		
		return true;
	}
	*/
	//W3EE -  End
	private function ProcessActionThornDamage() : bool
	{
		var damageAction 		: W3DamageAction;
		var damageVal 			: SAbilityAttributeValue;
		var damage				: float;
		var inv					: CInventoryComponent;
		var damageNames			: array < CName >;
		
		damageAction	= new W3DamageAction in this;
		
		damageAction.Initialize( action.victim, action.attacker, NULL, "Thorns", EHRT_Light, CPS_AttackPower, true, false, false, false );
		
		damageAction.SetCannotReturnDamage( true );		
		//W3EE - Begin
		/*
		damageVal 				=  actorVictim.GetAttributeValue( 'light_attack_damage_vitality' );
		
		
		
		
		
		inv = actorAttacker.GetInventory();		
		inv.GetWeaponDTNames(weaponId, damageNames );
		damageVal.valueBase  = actorAttacker.GetTotalWeaponDamage(weaponId, damageNames[0], GetInvalidUniqueId() );
		
		damageVal.valueBase *= 0.10f;
		
		if( damageVal.valueBase == 0 )
		{
			damageVal.valueBase = 10;
		}
		
		damage = (damageVal.valueBase + action.processedDmg.vitalityDamage) * damageVal.valueMultiplicative + damageVal.valueAdditive;
		*/
		damage = ((CNewNPC)actorAttacker).GetScaledDamage() * RandRangeF(0.35f, 0.15f);
		damageAction.AddDamage(  theGame.params.DAMAGE_NAME_PIERCING, damage );
		damageAction.SetPointResistIgnored(true);
		actorAttacker.ApplyBleeding(RandRange(4,1), actorVictim, "Bleeding");
		//W3EE - End
		
		damageAction.SetHitAnimationPlayType( EAHA_ForceYes );
		theGame.damageMgr.ProcessAction(damageAction);
		delete damageAction;
		
		return true;
	}
	
	private function GetAttackersPowerMod() : SAbilityAttributeValue
	{		
		var powerMod, criticalDamageBonus, min, max, critReduction, sp : SAbilityAttributeValue;
		var mutagen : CBaseGameplayEffect;
		var totalBonus, tempBonus : float;
		var difficultyDamageMultiplier, armorPiercing : float; //W3EE
		var staminaRendBonus, blockCrush : SAbilityAttributeValue; //W3EE
		var witcherAttacker : W3PlayerWitcher; //W3EE
		var inv	: CInventoryComponent; 
		var weaponName : name;
		
			
		
		powerMod = action.GetPowerStatValue();
		if ( powerMod.valueAdditive == 0 && powerMod.valueBase == 0 && powerMod.valueMultiplicative == 0 && theGame.CanLog() )
			LogDMHits("Attacker has power stat of 0!", action);
		
		//W3EE - Begin
		/*
		if(playerAttacker && attackAction && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()))
			powerMod.valueMultiplicative -= 0.433;
		
		
		if ( playerAttacker && (W3IgniProjectile)action.causer )
			powerMod.valueMultiplicative = 1 + (powerMod.valueMultiplicative - 1) * theGame.params.IGNI_SPELL_POWER_MILT;
		
		
		if ( playerAttacker && (W3AardProjectile)action.causer )
			powerMod.valueMultiplicative = 1 + (powerMod.valueMultiplicative - 1) * theGame.params.AARD_SPELL_POWER_MULT;

		
		if(attackAction.GetAttackName() == 'bolt')
		{
			if(attackAction.GetIsHeadShot() && playerAttacker && playerAttacker.CanUseSkill(S_Sword_s32))
			{
				tempBonus = CalculateAttributeValue( playerAttacker.GetSkillAttributeValue(S_Sword_s32, 'damage_increase', false, true ));
				powerMod.valueAdditive *= 1 + tempBonus;
			}
		}

		
		
		inv = actorAttacker.GetInventory();	
		weaponName = inv.GetItemName( weaponId );
		
		if( !playerAttacker && actorVictim && !thePlayer.IsInFistFightMiniGame() && GetAttitudeBetween( thePlayer, actorAttacker ) == AIA_Friendly && !actorAttacker.HasTag( 'keira' ) && !actorAttacker.HasTag( 'Yennefer' )
			&& ( actorAttacker.IsWeaponHeld( 'silversword' ) || actorAttacker.IsWeaponHeld( 'staff2h' ) || weaponName == 'fists_lightning' || weaponName == 'fists_fire' || actorAttacker.HasAbility( 'SkillWitcher' ) || actorAttacker.HasTag( 'regis' )  || actorAttacker.HasBuff(EET_AxiiGuardMe) ) )
		{
			if ( powerMod.valueMultiplicative <= 0.1 )
			{
				actorAttacker.AddAbility( 'FCR3HighDamageBoost' );
				actorAttacker.AddAbility( 'FCR3LowDamageBoost');
			}
			else if ( powerMod.valueMultiplicative <= 0.4 )
			{
				actorAttacker.AddAbility( 'FCR3MedDamageBoost' );
				actorAttacker.AddAbility( 'FCR3LowDamageBoost' );
			}
			else if ( powerMod.valueMultiplicative <= 0.9 )
			{
				actorAttacker.AddAbility( 'FCR3MedDamageBoost' );
			}
			else if ( powerMod.valueMultiplicative <= 1.1 )
			{
				actorAttacker.AddAbility( 'FCR3LowDamageBoost' );
			}
		}
		*/
		
		if( playerAttacker && action.IsActionMelee() && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) )
			powerMod.valueMultiplicative += 0.25f;
		//W3EE - End
		
		if(action.IsCriticalHit())
		{
			//W3EE - Begin
			/*
			if( playerAttacker && action.IsActionWitcherSign() && GetWitcherPlayer().IsMutationActive(EPMT_Mutation2) )
			{
				sp = action.GetPowerStatValue();
				
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation2', 'crit_damage_factor', min, max);				
				criticalDamageBonus.valueAdditive = sp.valueMultiplicative * min.valueMultiplicative;
			}
			else 
			{
				criticalDamageBonus = actorAttacker.GetCriticalHitDamageBonus(weaponId, victimMonsterCategory, actorVictim.IsAttackerAtBack(playerAttacker));
				
				criticalDamageBonus += actorAttacker.GetAttributeValue('critical_hit_chance_fast_style');
				
				if(attackAction && playerAttacker)
				{
					if(playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s08))
						criticalDamageBonus += playerAttacker.GetSkillAttributeValue(S_Sword_s08, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * playerAttacker.GetSkillLevel(S_Sword_s08);
					else if (!playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s17))
						criticalDamageBonus += playerAttacker.GetSkillAttributeValue(S_Sword_s17, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * playerAttacker.GetSkillLevel(S_Sword_s17);
				}
			}

			
			if ( thePlayer.CanUseSkill( S_Alchemy_s27 ) && thePlayer.GetStatMax(BCS_Focus) == thePlayer.GetStat(BCS_Focus) && IsMonsterOilTarget() )
			{
				criticalDamageBonus += playerAttacker.GetSkillAttributeValue(S_Alchemy_s27, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * playerAttacker.GetSkillLevel(S_Alchemy_s27);				
			}
			*/
			
			criticalDamageBonus = actorAttacker.GetCriticalHitDamageBonus(weaponId, victimMonsterCategory, actorVictim.IsAttackerAtBack(playerAttacker));
			
			if(attackAction && playerAttacker)
			{
				if(playerAttacker.IsLightAttack(attackAction.GetAttackName()))
					criticalDamageBonus += actorAttacker.GetAttributeValue('critical_hit_chance_fast_style');
				if(playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s08))
					criticalDamageBonus += playerAttacker.GetSkillAttributeValue(S_Sword_s08, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * playerAttacker.GetSkillLevel(S_Sword_s08);
				
				if(((W3PlayerWitcher)playerAttacker).IsSetBonusActive(EISB_Temerian))
					criticalDamageBonus.valueAdditive += ((CNewNPC)actorVictim).GetNPCCustomStat(theGame.params.DAMAGE_NAME_PHYSICAL) / 2.f;
				
				if( action.IsActionMelee() && ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 36 _Stats', true) && ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 36 Ability') )
				{
					criticalDamageBonus.valueAdditive += 2.f;
					actorVictim.CreateFXEntityAndPlayEffect('mutation9_hit', 'hit_refraction');
				}
				
				if( action.IsActionMelee() && (((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 50 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 51 _Stats', true)) )
				{
					armorPiercing = 0.5f + ((W3PlayerWitcher)playerAttacker).GetPlayerArmorPiercingValue(action.IsActionMelee(), action.IsActionRanged(), (CThrowable)action.causer, attackAction.GetAttackName());
					if( !attackAction.IsParried() )
					{
						blockCrush = witcherAttacker.GetAttributeValue('damage_through_blocks');
						blockCrush.valueMultiplicative += witcherAttacker.GetSkillLevel(S_Sword_s06) * 0.05f;
						armorPiercing += blockCrush.valueMultiplicative / 2;
					}
					criticalDamageBonus.valueAdditive += MaxF(0, armorPiercing - ((CNewNPC)actorVictim).GetNPCCustomStat(theGame.params.DAMAGE_NAME_PHYSICAL));
				}
				
				if( action.IsActionMelee() && (((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 59 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 60 _Stats', true)) )
				{
					criticalDamageBonus.valueAdditive += ((CNewNPC)actorVictim).GetDesolationStacks(false) * 0.01f;
					if( ((W3Effect_NPCPoise)actorVictim.GetBuff(EET_NPCPoise)).IsPoiseBroken() && ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 60 _Stats', true) )
						criticalDamageBonus.valueAdditive += 1.f;
				}
			}
			//W3EE - End
			
			totalBonus = CalculateAttributeValue(criticalDamageBonus);
			critReduction = actorVictim.GetAttributeValue(theGame.params.CRITICAL_HIT_REDUCTION);
			totalBonus = totalBonus * ClampF(1 - critReduction.valueMultiplicative, 0.f, 1.f);
			
			
			powerMod.valueMultiplicative += totalBonus;
		}
		//W3EE - Begin
		if(actorAttacker && !actorAttacker.IgnoresDifficultySettings() && !action.IsDoTDamage())
		{
			if(playerVictim && playerVictim == thePlayer || actorVictim  && GetAttitudeBetween(actorVictim, thePlayer) == AIA_Friendly)
			{
				difficultyDamageMultiplier = CalculateAttributeValue(actorAttacker.GetAttributeValue(theGame.params.DIFFICULTY_DMG_MULTIPLIER));
				powerMod.valueMultiplicative += difficultyDamageMultiplier - 1;
			}
		}
		//W3EE - End
		
		return powerMod;
	}
	
	private function GetDamageResists(dmgType : name, out resistPts : float, out resistPerc : float)
	{
		var armorReduction, armorReductionPerc, skillArmorReduction : SAbilityAttributeValue;
		var bonusReduct, bonusResist : float;
		//var mutagenBuff : W3Mutagen28_Effect; //W3EE
		var appliedOilName, vsMonsterResistReduction : name;
		var oils : array< W3Effect_Oil >;
		var i : int;
		
		//W3EE - Begin
		/*
		if(attackAction && attackAction.IsActionMelee() && actorAttacker.GetInventory().IsItemFists(weaponId) && !actorVictim.UsesEssence())
			return;
		*/
		
		if( actorAttacker.IsHuman() && actorAttacker.IsWeaponHeld('fist') && attackAction && attackAction.IsActionMelee() && dmgType == theGame.params.DAMAGE_NAME_BLUDGEONING && actorVictim.IsHuman() && actorVictim.IsWeaponHeld('fist') )
			return;
		//W3EE - End		
		
		if(actorVictim)
		{
			//W3EE - Begin
			/*
			actorVictim.GetResistValue( GetResistForDamage(dmgType, action.IsDoTDamage()), resistPts, resistPerc );
			
			
			if(playerVictim && actorAttacker && playerVictim.CanUseSkill(S_Alchemy_s05))
			{
				GetOilProtectionAgainstMonster(dmgType, bonusResist, bonusReduct);
				
				resistPerc += bonusResist * playerVictim.GetSkillLevel(S_Alchemy_s05);
			}

			
			if (playerVictim && playerVictim.CanUseSkill(S_Alchemy_s22) && actorAttacker && actorAttacker.HasBuff(EET_Poison))
			{
				resistPerc += CalculateAttributeValue( playerVictim.GetSkillAttributeValue(S_Alchemy_s22, 'defence_bonus', false, true ) ) * playerVictim.GetSkillLevel(S_Alchemy_s22);
			}		
			
			
			if(playerVictim && actorAttacker && playerVictim.HasBuff(EET_Mutagen28))
			{
				mutagenBuff = (W3Mutagen28_Effect)playerVictim.GetBuff(EET_Mutagen28);
				mutagenBuff.GetProtection(attackerMonsterCategory, dmgType, action.IsDoTDamage(), bonusResist, bonusReduct);
				resistPts += bonusReduct;
				resistPerc += bonusResist;
			}
			
			
			if(actorAttacker)
			{
				
				armorReduction = actorAttacker.GetAttributeValue('armor_reduction');
				armorReductionPerc = actorAttacker.GetAttributeValue('armor_reduction_perc');
				
				
				if(playerAttacker)
				{
					vsMonsterResistReduction = MonsterCategoryToResistReduction(victimMonsterCategory);
					oils = playerAttacker.inv.GetOilsAppliedOnItem( weaponId );
					
					if( oils.Size() > 0 )
					{
						for( i=0; i<oils.Size(); i+=1 )
						{
							appliedOilName = oils[ i ].GetOilItemName();
							
							
							if( oils[ i ].GetAmmoCurrentCount() > 0 && dm.ItemHasAttribute( appliedOilName, true, vsMonsterResistReduction ) )
							{
								armorReductionPerc.valueMultiplicative += oils[ i ].GetAmmoPercentage();
							}
						}
					}	
				}
				
				
				if(playerAttacker && action.IsActionMelee() && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_2))
					armorReduction += playerAttacker.GetSkillAttributeValue(S_Sword_2, 'armor_reduction', false, true);
				
				
				if ( playerAttacker && 
					 action.IsActionMelee() && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && 
					 ( dmgType == theGame.params.DAMAGE_NAME_PHYSICAL || 
					   dmgType == theGame.params.DAMAGE_NAME_SLASHING || 
				       dmgType == theGame.params.DAMAGE_NAME_PIERCING || 
					   dmgType == theGame.params.DAMAGE_NAME_BLUDGEONING || 
					   dmgType == theGame.params.DAMAGE_NAME_RENDING || 
					   dmgType == theGame.params.DAMAGE_NAME_SILVER
					 )
				   ) 
				{
					if(playerAttacker.CanUseSkill(S_Sword_s06))
					{
						
						skillArmorReduction = playerAttacker.GetSkillAttributeValue(S_Sword_s06, 'armor_reduction_perc', false, true);
						armorReductionPerc += skillArmorReduction * playerAttacker.GetSkillLevel(S_Sword_s06);				
					}
					if(playerAttacker.CanUseSkill(S_Sword_s28) && (CNewNPC)actorVictim)
					{
						armorReductionPerc.valueAdditive += ((CNewNPC)actorVictim).GetSunderArmorPercent();
					}
				}
			}
			*/
			
			if( action.IsDoTDamage() )
			{
				if( playerVictim )
					actorVictim.GetResistValue( GetResistForDamage(dmgType, action.IsDoTDamage()), resistPts, resistPerc );
				else
				if( !((CNewNPC)actorVictim).IsProtectedByArmor() )
					resistPerc = ((CNewNPC)actorVictim).GetNPCCustomStat(dmgType);
				else
					resistPerc = 0;
					
				resistPts = 0;
				return;
			}
			else
			{
				if( playerVictim )
					actorVictim.GetResistValue( GetResistForDamage(dmgType, action.IsDoTDamage()), resistPts, resistPerc );
				else
					resistPerc = ((CNewNPC)actorVictim).GetNPCCustomStat(dmgType);
			}
			//W3EE - End
		}
		
		
		if( !action.GetIgnoreArmor() && playerVictim ) //W3EE
			resistPts += CalculateAttributeValue( actorVictim.GetTotalArmor() );
		
		
		//resistPerc -= CalculateAttributeValue(armorReductionPerc); //W3EE

		
		//resistPts = MaxF(0, (resistPts - CalculateAttributeValue(armorReduction)) * (1 + MinF(resistPerc, 0.f) ) ); //W3EE
		resistPts = MaxF(0, resistPts); //W3EE
		
		//resistPerc = MaxF(0, resistPerc); //W3EE
	}
	//W3EE - Begin
	/*
	private function CalculateDamage(dmgInfo : SRawDamage, powerMod : SAbilityAttributeValue) : float
	{
		var finalDamage : float;
		var resistPoints, resistPercents : float;
		var ptsString, percString : string;
		var mutagen : CBaseGameplayEffect;
		var min, max : SAbilityAttributeValue;
		var encumbranceBonus : float;
		var temp : bool;
		var fistfightDamageMult : float;
		var burning : W3Effect_Burning;
		
		
		var weaponName 		: name;
		var dmgBonus 		: float;
		var playerStlDmg 	: float;
		var playerSlvDmg 	: float;
		var playerFastSlvDmg: float;
		var playerSlvCritDmg: float;
		var multBonus 		: float;
		var dmgLevel		: int;
		var curStats		: SPlayerOffenseStats;
		var inv				: CInventoryComponent;
		
	
		
		GetDamageResists(dmgInfo.dmgType, resistPoints, resistPercents);
	
		
		if( thePlayer.IsFistFightMinigameEnabled() && actorAttacker == thePlayer )
		{
			finalDamage = MaxF(0, (dmgInfo.dmgVal));
		}
		else
		{
			
			burning = (W3Effect_Burning)action.causer;
			if( burning && burning.IsSignEffect() )
			{
				if ( powerMod.valueMultiplicative > 2.5f )
				{
					powerMod.valueMultiplicative = 2.5f + LogF( (powerMod.valueMultiplicative - 2.5f) + 1 );
				}
			}
			
			finalDamage = MaxF(0, (dmgInfo.dmgVal + powerMod.valueBase) * powerMod.valueMultiplicative + powerMod.valueAdditive);
			
			
			
			inv = actorAttacker.GetInventory();	
			weaponName = inv.GetItemName( weaponId );
			if( thePlayer.IsCiri() )
			{
				dmgLevel = ( actorVictim.GetLevel() -2 ) * 10;
			}
			else
			{
				dmgLevel = Min( actorVictim.GetLevel(), GetWitcherPlayer().GetLevel() ) * 40;
			}
			
			if( !playerAttacker && actorVictim && GetAttitudeBetween( thePlayer, actorAttacker ) == AIA_Friendly && !action.IsDoTDamage() && !actorAttacker.HasTag( 'Yennefer' ) && !actorAttacker.HasTag( 'keira' ) 
				&& !actorAttacker.HasTag( 'Philippa' ) && ( actorAttacker.IsWeaponHeld( 'silversword' ) || actorAttacker.IsWeaponHeld( 'staff2h' ) || weaponName == 'fists_lightning' || weaponName == 'fists_fire' 
				|| actorAttacker.HasAbility( 'SkillWitcher' ) || actorAttacker.HasTag( 'zoltan' ) || actorAttacker.HasTag( 'hjalmar' ) || actorAttacker.HasTag( 'regis' ) || actorAttacker.HasBuff(EET_AxiiGuardMe) ) && ( finalDamage < dmgLevel || thePlayer.IsCiri() ) )
			{
				dmgBonus += dmgLevel - finalDamage;
				finalDamage = MaxF(0, (dmgInfo.dmgVal + powerMod.valueBase + dmgBonus) * powerMod.valueMultiplicative + powerMod.valueAdditive);
			}
			
		}
			
		if(finalDamage > 0.f)
		{
			
			if(!action.IsPointResistIgnored() && !(dmgInfo.dmgType == theGame.params.DAMAGE_NAME_ELEMENTAL || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_FIRE || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_FROST ))
			{
				finalDamage = MaxF(0, finalDamage - resistPoints);
				
				if(finalDamage == 0.f)
					action.SetArmorReducedDamageToZero( true ); 
			}
		}
		
		if(finalDamage > 0.f)
		{
			
			if (playerVictim == GetWitcherPlayer() && playerVictim.HasBuff(EET_Mutagen02))
			{
				encumbranceBonus = 1 - (GetWitcherPlayer().GetEncumbrance() / GetWitcherPlayer().GetMaxRunEncumbrance(temp));
				if (encumbranceBonus < 0)
					encumbranceBonus = 0;
				mutagen = playerVictim.GetBuff(EET_Mutagen02);
				dm.GetAbilityAttributeValue(mutagen.GetAbilityName(), 'resistGainRate', min, max);
				encumbranceBonus *= CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
				resistPercents += encumbranceBonus;
			}
			finalDamage *= 1 - resistPercents;
		}	



		
		
		if( !playerAttacker && actorVictim && !action.IsDoTDamage() && !thePlayer.IsFistFightMinigameEnabled() && finalDamage <= actorVictim.GetMaxHealth() * 0.01 && (GetAttitudeBetween( thePlayer, actorAttacker ) == AIA_Friendly || actorAttacker.HasBuff(EET_AxiiGuardMe)) )
		{
			dmgBonus += dmgLevel - finalDamage;
			if ( powerMod.valueMultiplicative < 1.0 )
			{
				multBonus = 1.0 - powerMod.valueMultiplicative;
			}
			finalDamage = MaxF(actorVictim.GetMaxHealth() * 0.01, (dmgInfo.dmgVal + powerMod.valueBase + dmgBonus) * ( powerMod.valueMultiplicative + multBonus ) + powerMod.valueAdditive);
			
			if(!action.IsPointResistIgnored() && !(dmgInfo.dmgType == theGame.params.DAMAGE_NAME_ELEMENTAL || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_FIRE || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_FROST ))
			{
				finalDamage = MaxF(actorVictim.GetMaxHealth() * 0.01, finalDamage - resistPoints);
				
				if(finalDamage == 0.f)
					action.SetArmorReducedDamageToZero( true );
				else
					action.SetArmorReducedDamageToZero( false );
			}
			
			finalDamage *= 1 - resistPercents;
		}
		
		
		curStats = GetWitcherPlayer().GetOffenseStatsList();
		playerStlDmg = MaxF(0, curStats.steelStrongDmg - resistPoints);
		playerStlDmg *= 1 - resistPercents;
		playerStlDmg /= 6;
		
		playerFastSlvDmg = MaxF(0, curStats.silverFastDmg - resistPoints);
		playerFastSlvDmg *= 1 - resistPercents;
		playerFastSlvDmg /= 6;

		playerSlvDmg = MaxF(0, curStats.silverStrongDmg - resistPoints);
		playerSlvDmg *= 1 - resistPercents;
		playerSlvDmg /= 6;
		
		playerSlvCritDmg = MaxF(0, curStats.silverStrongCritDmg - resistPoints);
		playerSlvCritDmg *= 1 - resistPercents;
		playerSlvCritDmg /= 6;
		
		if( !playerAttacker && actorVictim && !action.IsDoTDamage() && !thePlayer.IsFistFightMinigameEnabled() && (GetAttitudeBetween( thePlayer, actorAttacker ) == AIA_Friendly || actorAttacker.HasBuff(EET_AxiiGuardMe)) && !thePlayer.IsCiri()  )
		{
			if(finalDamage > playerStlDmg && !actorAttacker.HasAbility( 'ForceInstantKill' ))
			{
				if ( actorAttacker.HasTag( 'regis' ) )
				{
					if ( finalDamage > playerSlvCritDmg * 2 )
					{
						finalDamage = ClampF( finalDamage, 0, playerSlvCritDmg * 2 );
						finalDamage = MaxF(actorVictim.GetMaxHealth() * 0.01, finalDamage);
					}
					if ( finalDamage < playerSlvCritDmg )
					{
						finalDamage = ClampF( finalDamage, playerSlvCritDmg, finalDamage );
					}
				}
				else if ( actorAttacker.IsWeaponHeld( 'staff2h' ) || weaponName == 'fists_lightning' || weaponName == 'fists_fire' || action.GetPowerStatType() == CPS_SpellPower )
				{
					if ( finalDamage > playerSlvDmg * 2 )
					{
						finalDamage = ClampF( finalDamage, 0, playerSlvDmg );
						finalDamage = MaxF(actorVictim.GetMaxHealth() * 0.01, finalDamage);
					}
					
					if ( finalDamage < playerFastSlvDmg && attackAction )
					{
						finalDamage = ClampF( finalDamage, playerFastSlvDmg, finalDamage );
					}
				}
				else if ( actorAttacker.IsWeaponHeld( 'silversword' ) || actorAttacker.HasAbility( 'SkillWitcher' ) || actorAttacker.HasBuff(EET_AxiiGuardMe) )
				{
					if ( finalDamage > playerSlvCritDmg )
					{
						finalDamage = ClampF( finalDamage, 0, playerSlvCritDmg );
						finalDamage = MaxF(actorVictim.GetMaxHealth() * 0.01, finalDamage);
					}
					if ( action.IsActionMelee() )
					{
						
						if ( finalDamage < playerSlvDmg && actorVictim.UsesEssence() )
						{
							finalDamage = ClampF( finalDamage, playerSlvDmg, finalDamage );
						}
						else if ( finalDamage < playerStlDmg )
						{
							finalDamage = ClampF( finalDamage, playerStlDmg, finalDamage );
						}
					}
				}
				else
				{
					finalDamage = ClampF( finalDamage, 0, playerStlDmg );
					finalDamage = MaxF(actorVictim.GetMaxHealth() * 0.01, finalDamage);
				}
			}
		
			
			if(thePlayer.GetBossTag() != '' || (W3MonsterHuntNPC)actorVictim || actorVictim.GetCharacterStats().HasAbilityWithTag('Boss') || actorVictim.HasAbility( 'Boss' ) || actorVictim.HasAbility( 'SkillBoss') )
			{
				finalDamage = ClampF(finalDamage, 0, actorVictim.GetMaxHealth() * 0.005);
			}
		}
		if(actorAttacker.HasBuff(EET_AxiiGuardMe))
		{
			switch(GetWitcherPlayer().GetSkillLevel(S_Magic_s05))
			{
				case 3: 
					finalDamage *= 1.6;	
					break;
				case 2: 
					finalDamage *= 1.4;	
					break;
				case 1: 
					finalDamage *= 1.2;	
					break;
			}

			if ( thePlayer.CanUseSkill( S_Magic_s31 ) )
			{
				finalDamage *= 1 + thePlayer.GetSkillLevel( S_Magic_s31 ) * CalculateAttributeValue( thePlayer.GetSkillAttributeValue( S_Magic_s31, 'attack_power', false, true ) );
			}
		}
		
	
		
		if(dmgInfo.dmgType == theGame.params.DAMAGE_NAME_FIRE && finalDamage > 0)
			action.SetDealtFireDamage(true);
			
		if( playerAttacker && thePlayer.IsWeaponHeld('fist') && !thePlayer.IsInFistFightMiniGame() && action.IsActionMelee() )
		{
			if(FactsQuerySum("NewGamePlus") > 0)
			{fistfightDamageMult = thePlayer.GetLevel()* 0.1;}
			else
			{fistfightDamageMult = thePlayer.GetLevel()* 0.05;}
			
			finalDamage *= ( 1+fistfightDamageMult );
		}
		
		if(playerAttacker && attackAction && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()))
			finalDamage *= 1.833;
			
		
		burning = (W3Effect_Burning)action.causer;
		if(actorVictim && (((W3IgniEntity)action.causer) || ((W3IgniProjectile)action.causer) || ( burning && burning.IsSignEffect())) )
		{
			min = actorVictim.GetAttributeValue('igni_damage_amplifier');
			finalDamage = finalDamage * (1 + min.valueMultiplicative) + min.valueAdditive;
		}
		
		
		
		
		if ( theGame.CanLog() )
		{
			LogDMHits("Single hit damage: initial damage = " + NoTrailZeros(dmgInfo.dmgVal), action);
			LogDMHits("Single hit damage: attack_power = base: " + NoTrailZeros(powerMod.valueBase) + ", mult: " + NoTrailZeros(powerMod.valueMultiplicative) + ", add: " + NoTrailZeros(powerMod.valueAdditive), action );
			if(action.IsPointResistIgnored())
				LogDMHits("Single hit damage: resistance pts and armor = IGNORED", action);
			else
				LogDMHits("Single hit damage: resistance pts and armor = " + NoTrailZeros(resistPoints), action);			
			LogDMHits("Single hit damage: resistance perc = " + NoTrailZeros(resistPercents * 100), action);
			LogDMHits("Single hit damage: final damage to sustain = " + NoTrailZeros(finalDamage), action);
		}
		
		
		if( playerVictim && actorAttacker && FactsQuerySum("NewGamePlus") > 0)
			finalDamage *= 1.1;
		
			
		return finalDamage;
	}
	*/
	
	private function CalculateDamageW3EE(dmgInfo : SRawDamage, powerMod : SAbilityAttributeValue) : float
	{
		var finalDamage, armorPiercing, tempDamage : float;
		var resistPoints, resistPercents, resistPointsTemp, resistPercentsTemp : float;
		var min, max, blockCrush : SAbilityAttributeValue;
		var npcAttacker : CNewNPC;
		var witcherAttacker, witcherVictim : W3PlayerWitcher;
		var damageHandler : W3EEDamageHandler = Damage();
		var actionIgnoresArmor : bool;
		
		if( dmgInfo.dmgSplit == 0.f )
			dmgInfo.dmgSplit = 1.f; 
		GetDamageResists(dmgInfo.dmgType, resistPoints, resistPercents);
		
		if( action.IsActionWitcherSign() )
			finalDamage = MaxF(0, dmgInfo.dmgVal + powerMod.valueBase + powerMod.valueAdditive);
		else
			finalDamage = MaxF(0, (dmgInfo.dmgVal + powerMod.valueBase) * powerMod.valueMultiplicative + powerMod.valueAdditive);
		
		if( !action.IsDoTDamage() )
		{
			if( !playerAttacker && actorAttacker.IsHuman() && attackAction && attackAction.IsActionMelee() )
			{
				if( actorAttacker.IsWeaponHeld('fist') && dmgInfo.dmgType == theGame.params.DAMAGE_NAME_BLUDGEONING )
				{
					finalDamage /= 2;
				}
				else
				if( actorAttacker.IsSwordWooden() || actorAttacker.IsWeaponDamaged() )
				{
					finalDamage /= 2;
				}
			}
			
			if( !playerAttacker && action.IsActionWitcherSign() )
			{
				finalDamage /= 3;
			}
			
			if( !playerAttacker && !playerVictim && actorAttacker && actorVictim )
			{
				finalDamage /= 3;
			}
			
			if( actorVictim.IsQuestActor() && !playerAttacker )
			{
				finalDamage /= 20;
			}
			
			if( actorAttacker.IsQuestActor() && action.IsActionRanged() && !playerVictim )
			{
				finalDamage /= 2;
			}
			
			if( playerAttacker && dmgInfo.dmgType == theGame.params.DAMAGE_NAME_POISON && (playerAttacker.HasAbility('Runeword 14 _Stats', true) || playerAttacker.HasAbility('Runeword 15 _Stats', true)) )
			{
				if( victimMonsterCategory == MC_Specter || victimMonsterCategory == MC_Vampire || victimMonsterCategory == MC_Cursed )
				{
					GetDamageResists(theGame.params.DAMAGE_NAME_SILVER, resistPointsTemp, resistPercentsTemp);
					if( resistPercentsTemp < resistPercents )
					{
						resistPercents = resistPercentsTemp;
						dmgInfo.dmgType = theGame.params.DAMAGE_NAME_SILVER;
					}
				}
				else
				{
					GetDamageResists(theGame.params.DAMAGE_NAME_SLASHING, resistPointsTemp, resistPercentsTemp);
					if( resistPercentsTemp < resistPercents )
					{
						resistPercents = resistPercentsTemp;
						dmgInfo.dmgType = theGame.params.DAMAGE_NAME_SLASHING;
					}
				}
			}
		}
		
		if( action.IsPointResistIgnored() || action.IsDoTDamage() )
		{
			resistPoints = 0;
		}
		
		if( DamageHitsEssence(  dmgInfo.dmgType ) )		action.originalDamage.essenceDamage  += finalDamage;
		if( DamageHitsVitality( dmgInfo.dmgType ) )		action.originalDamage.vitalityDamage += finalDamage;
		if( DamageHitsMorale(   dmgInfo.dmgType ) )		action.originalDamage.moraleDamage   += finalDamage;
		if( DamageHitsStamina(  dmgInfo.dmgType ) )		action.originalDamage.staminaDamage  += finalDamage;
		
		witcherVictim = (W3PlayerWitcher)playerVictim;
		actionIgnoresArmor = action.GetIgnoreArmor();
		
		if( !action.IsDoTDamage() && !actionIgnoresArmor )
		{
			witcherAttacker = (W3PlayerWitcher)playerAttacker;
			if( witcherAttacker )
			{
				if( action.IsActionMelee() || action.IsActionRanged() )
				{
					armorPiercing = witcherAttacker.GetPlayerArmorPiercingValue(action.IsActionMelee(), action.IsActionRanged(), (CThrowable)action.causer, attackAction.GetAttackName());
					
					if( action.IsCriticalHit() )
						armorPiercing += 0.5f;
					
					if( action.IsActionMelee() && !attackAction.IsParried() && (witcherAttacker.HasAbility('Runeword 49 _Stats', true) || witcherAttacker.HasAbility('Runeword 50 _Stats', true) || witcherAttacker.HasAbility('Runeword 51 _Stats', true)) )
					{
						blockCrush = witcherAttacker.GetAttributeValue('damage_through_blocks');
						blockCrush.valueMultiplicative += witcherAttacker.GetSkillLevel(S_Sword_s06) * 0.05f;
						armorPiercing += blockCrush.valueMultiplicative / 2;
					}
					
					armorPiercing = MinF(1.f, armorPiercing);
					
					if( dmgInfo.dmgType == theGame.params.DAMAGE_NAME_SILVER )
					{
						if( resistPercents > 0 )
							resistPercents = MinF(1.f, resistPercents * (1.f - armorPiercing));
						resistPercents -= witcherAttacker.GetOilResistIgnore(victimMonsterCategory);
					}
					else if( (dmgInfo.dmgType == theGame.params.DAMAGE_NAME_PHYSICAL || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_SLASHING || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_PIERCING || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_BLUDGEONING) && !(victimMonsterCategory == MC_Specter || victimMonsterCategory == MC_Vampire || victimMonsterCategory == MC_Cursed) )
					{
						if( resistPercents > 0 )
							resistPercents = MinF(1.f, resistPercents * (1.f - armorPiercing));
						resistPercents -= witcherAttacker.GetOilResistIgnore(victimMonsterCategory);
					}
				}
			}
			else
			if( playerAttacker )
			{
				finalDamage = MaxF(830.f, finalDamage);
				resistPoints = 0;
				resistPercents = 0;
				armorPiercing = 1;
			}
			else
			{
				npcAttacker = (CNewNPC)actorAttacker;
				if( action.IsActionRanged() && npcAttacker.GetScaledRangedDamage() )
					armorPiercing = MinF(1.f, npcAttacker.GetNPCCustomStat(theGame.params.DAMAGE_NAME_ARMOR_PIERCE_RANGED));
				else
					armorPiercing = MinF(1.f, npcAttacker.GetNPCCustomStat(theGame.params.DAMAGE_NAME_ARMOR_PIERCE));
					
				if( npcAttacker.IsLightAttack(attackAction.GetAttackName()) )
					armorPiercing = MinF(1.f, armorPiercing * damageHandler.eapl);
				else
				if( npcAttacker.IsHeavyAttack(attackAction.GetAttackName()) || npcAttacker.IsSuperHeavyAttack(attackAction.GetAttackName()) )
					armorPiercing = MinF(1.f, armorPiercing * damageHandler.eaph);
				
				if( ((W3PlayerWitcher)playerVictim).IsSetBonusActive(EISB_Bear_2) )
					armorPiercing *= MaxF(0.f, 1.f - ((W3Effect_Poise)playerVictim.GetBuff(EET_Poise)).GetCurrentPoise() * 0.002f);
			}
		}
		
		if( playerVictim )
		{
			if( dmgInfo.dmgType == theGame.params.DAMAGE_NAME_ELEMENTAL )
			{
				resistPercents = MaxF(0.f, resistPercents * (1 - armorPiercing * 0.5f));
				resistPoints *= (1 - armorPiercing);
			}
			else
				resistPercents = MaxF(0.f, resistPercents * (1 - armorPiercing));
		}
			
		if( playerVictim )
			tempDamage = MaxF(finalDamage - resistPoints * (1 - armorPiercing) * dmgInfo.dmgSplit, finalDamage * 0.1f) * (1 - resistPercents);
		else
			tempDamage = MaxF(finalDamage - resistPoints * (1 - armorPiercing), finalDamage * 0.1f) * (1 - resistPercents);
			
		if( DamageHitsEssence(  dmgInfo.dmgType ) )		action.originalDamageArmor.essenceDamage  += tempDamage;
		if( DamageHitsVitality( dmgInfo.dmgType ) )		action.originalDamageArmor.vitalityDamage += tempDamage;
		if( DamageHitsMorale(   dmgInfo.dmgType ) )		action.originalDamageArmor.moraleDamage   += tempDamage;
		if( DamageHitsStamina(  dmgInfo.dmgType ) )		action.originalDamageArmor.staminaDamage  += tempDamage;
		
		if( actionIgnoresArmor )
		{
			if (playerVictim || !actorVictim.HasTag('IsBoss'))
			{
				resistPoints = 0;
				resistPercents = 0;
				armorPiercing = 1;
			}
			else
			{
				if( dmgInfo.dmgType == theGame.params.DAMAGE_NAME_SILVER )
				{
					resistPoints = 0;
					resistPercents = 0;
				}
				else if( (dmgInfo.dmgType == theGame.params.DAMAGE_NAME_PHYSICAL || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_SLASHING || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_PIERCING || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_BLUDGEONING) && !(victimMonsterCategory == MC_Specter || victimMonsterCategory == MC_Vampire || victimMonsterCategory == MC_Cursed) )
				{
					resistPoints = 0;
					resistPercents = 0;
				}
			}
		}
		
		if( playerVictim )
			finalDamage = MaxF(finalDamage - resistPoints * (1 - armorPiercing) * dmgInfo.dmgSplit, finalDamage * 0.1f) * (1 - resistPercents);
		else
			finalDamage = MaxF(finalDamage - resistPoints * (1 - armorPiercing), finalDamage * 0.1f) * (1 - resistPercents);
		
		if(playerAttacker && ((W3PlayerWitcher)playerAttacker).IsSetBonusActive(EISB_Gryphon_2) && dmgInfo.dmgType == theGame.params.DAMAGE_NAME_ELEMENTAL && finalDamage > 0 )
			((CNewNPC)actorVictim).GryphonReduceResists(finalDamage * ((W3PlayerWitcher)playerAttacker).GetSetPartsEquipped(EIST_Gryphon));
		
		((W3Decoction5_Effect)playerAttacker.GetBuff(EET_Decoction5)).ReduceElementalResists(dmgInfo.dmgType, finalDamage, ((CNewNPC)actorVictim));
		
		if(playerAttacker && (((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 4 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 5 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 6 _Stats', true)) && dmgInfo.dmgType == theGame.params.DAMAGE_NAME_FROST && finalDamage > 0 )
			actorVictim.DrainStamina(ESAT_FixedValue, finalDamage / 10, 0);
		
		if(dmgInfo.dmgType == theGame.params.DAMAGE_NAME_FIRE && finalDamage > 0)
			action.SetDealtFireDamage(true);
			
		if(finalDamage == 0.f)
			action.SetArmorReducedDamageToZero(true);
		
		if ( theGame.CanLog() )
		{
			LogDMHits("Single hit damage: initial damage = " + NoTrailZeros(dmgInfo.dmgVal), action);
			LogDMHits("Single hit damage: attack_power = base: " + NoTrailZeros(powerMod.valueBase) + ", mult: " + NoTrailZeros(powerMod.valueMultiplicative) + ", add: " + NoTrailZeros(powerMod.valueAdditive), action );
			if(action.IsPointResistIgnored())
				LogDMHits("Single hit damage: resistance pts and armor = IGNORED", action);
			else
				LogDMHits("Single hit damage: resistance pts and armor = " + NoTrailZeros(resistPoints), action);			
			LogDMHits("Single hit damage: resistance perc = " + NoTrailZeros(resistPercents * 100), action);
			LogDMHits("Single hit damage: final damage to sustain = " + NoTrailZeros(finalDamage), action);
		}
			
		return finalDamage;
	}
	//W3EE - End
	
	private function ProcessActionDamage_DealDamage()
	{
		var logStr : string;
		var hpPerc : float;
		var npcVictim : CNewNPC;
	
		
		if ( theGame.CanLog() )
		{
			logStr = "";
			if(action.processedDmg.vitalityDamage > 0)			logStr += NoTrailZeros(action.processedDmg.vitalityDamage) + " vitality, ";
			if(action.processedDmg.essenceDamage > 0)			logStr += NoTrailZeros(action.processedDmg.essenceDamage) + " essence, ";
			if(action.processedDmg.staminaDamage > 0)			logStr += NoTrailZeros(action.processedDmg.staminaDamage) + " stamina, ";
			if(action.processedDmg.moraleDamage > 0)			logStr += NoTrailZeros(action.processedDmg.moraleDamage) + " morale";
				
			if(logStr == "")
				logStr = "NONE";
			LogDMHits("Final damage to sustain is: " + logStr, action);
		}
		
		
		if(actorVictim && !action.GetSimulateOnly())
		{
			hpPerc = actorVictim.GetHealthPercents();
			
			
			if(actorVictim.IsAlive())
			{
				npcVictim = (CNewNPC)actorVictim;
				if(npcVictim && npcVictim.IsHorse())
				{
					npcVictim.GetHorseComponent().OnTakeDamage(action);
				}
				else
				{
					actorVictim.OnTakeDamage(action);
				}
			}
			
			if(!actorVictim.IsAlive() && hpPerc == 1)
				action.SetWasKilledBySingleHit();
		}
			
		if ( theGame.CanLog() )
		{
			LogDMHits("", action);
			LogDMHits("Target stats after damage dealt are:", action);
			if(actorVictim)
			{
				if( actorVictim.UsesVitality())						LogDMHits("Vitality = " + NoTrailZeros( actorVictim.GetStat(BCS_Vitality)), action);
				if( actorVictim.UsesEssence())						LogDMHits("Essence = "  + NoTrailZeros( actorVictim.GetStat(BCS_Essence)), action);
				if( actorVictim.GetStatMax(BCS_Stamina) > 0)		LogDMHits("Stamina = "  + NoTrailZeros( actorVictim.GetStat(BCS_Stamina, true)), action);
				if( actorVictim.GetStatMax(BCS_Morale) > 0)			LogDMHits("Morale = "   + NoTrailZeros( actorVictim.GetStat(BCS_Morale)), action);
			}
			else
			{
				LogDMHits("Undefined - victim is not a CActor and therefore has no stats", action);
			}
		}
	}
	
	
	private function ProcessActionDamage_ReduceDurability(oilInfos : SOilInfo) //W3EE
	{		
		var witcherPlayer : W3PlayerWitcher;
		var dbg_currDur, dbg_prevDur1, dbg_prevDur2, dbg_prevDur3, dbg_prevDur4, dbg_prevDur : float;
		var dbg_armor, dbg_pants, dbg_boots, dbg_gloves, reducedItemId, weapon : SItemUniqueId;
		var slot : EEquipmentSlots;
		var weapons : array<SItemUniqueId>;
		var armorStringName : string;
		var canLog, playerHasSword : bool;
		var i : int;
		
		if (action.GetSimulateOnly())
			return;

		canLog = theGame.CanLog();

		witcherPlayer = GetWitcherPlayer();
	
		
		if ( playerAttacker && playerAttacker.inv.IsIdValid( weaponId ) && playerAttacker.inv.HasItemDurability( weaponId ) )
		{		
			dbg_prevDur = playerAttacker.inv.GetItemDurability(weaponId);
						
			if ( playerAttacker.inv.ReduceItemDurability(weaponId) && canLog )
			{
				LogDMHits("", action);
				LogDMHits("Player's weapon durability changes from " + NoTrailZeros(dbg_prevDur) + " to " + NoTrailZeros(action.attacker.GetInventory().GetItemDurability(weaponId)), action );
			}
		}
		
		else if(playerVictim && attackAction && attackAction.IsActionMelee() && (attackAction.IsParried() || attackAction.IsCountered()) )
		{
			weapons = playerVictim.inv.GetHeldWeapons();
			playerHasSword = false;
			for(i=0; i<weapons.Size(); i+=1)
			{
				weapon = weapons[i];
				if(playerVictim.inv.IsIdValid(weapon) && (playerVictim.inv.IsItemSteelSwordUsableByPlayer(weapon) || playerVictim.inv.IsItemSilverSwordUsableByPlayer(weapon)) )
				{
					playerHasSword = true;
					break;
				}
			}
			
			if(playerHasSword)
			{
				playerVictim.inv.ReduceItemDurability(weapon);
			}
		}
		
		else if(action.victim == witcherPlayer && (action.IsActionMelee() || action.IsActionRanged()) && action.DealsAnyDamage())
		{
			
			if ( canLog )
			{
				if ( witcherPlayer.GetItemEquippedOnSlot(EES_Armor, dbg_armor) )
					dbg_prevDur1 = action.victim.GetInventory().GetItemDurability(dbg_armor);
				else
					dbg_prevDur1 = 0;
					
				if ( witcherPlayer.GetItemEquippedOnSlot(EES_Pants, dbg_pants) )
					dbg_prevDur2 = action.victim.GetInventory().GetItemDurability(dbg_pants);
				else
					dbg_prevDur2 = 0;
					
				if ( witcherPlayer.GetItemEquippedOnSlot(EES_Boots, dbg_boots) )
					dbg_prevDur3 = action.victim.GetInventory().GetItemDurability(dbg_boots);
				else
					dbg_prevDur3 = 0;
					
				if ( witcherPlayer.GetItemEquippedOnSlot(EES_Gloves, dbg_gloves) )
					dbg_prevDur4 = action.victim.GetInventory().GetItemDurability(dbg_gloves);
				else
					dbg_prevDur4 = 0;
			}
			
			slot = GetWitcherPlayer().ReduceArmorDurability();
			
			
			if( canLog )
			{
				LogDMHits("", action);
				if(slot != EES_InvalidSlot)
				{		
					switch(slot)
					{
						case EES_Armor : 
							armorStringName = "chest armor";
							reducedItemId = dbg_armor;
							dbg_prevDur = dbg_prevDur1;
							break;
						case EES_Pants : 
							armorStringName = "pants";
							reducedItemId = dbg_pants;
							dbg_prevDur = dbg_prevDur2;
							break;
						case EES_Boots :
							armorStringName = "boots";
							reducedItemId = dbg_boots;
							dbg_prevDur = dbg_prevDur3;
							break;
						case EES_Gloves :
							armorStringName = "gloves";
							reducedItemId = dbg_gloves;
							dbg_prevDur = dbg_prevDur4;
							break;
					}
					
					dbg_currDur = action.victim.GetInventory().GetItemDurability(reducedItemId);
					LogDMHits("", action);
					LogDMHits("Player's <<" + armorStringName + ">> durability changes from " + NoTrailZeros(dbg_prevDur) + " to " + NoTrailZeros(dbg_currDur), action );
				}
				else
				{
					LogDMHits("Tried to reduce player's armor durability but failed", action);
				}
			}
				
			
			if(slot != EES_InvalidSlot)
				thePlayer.inv.ReduceItemRepairObjectBonusCharge(reducedItemId);
		}
	}	
	
	
	
	
	
	
	private function ProcessActionReaction(wasFrozen : bool, wasAlive : bool)
	{
		var dismemberExplosion 			: bool;
		var damageName 					: name;
		var damage 						: array<SRawDamage>;
		var points, percents, hp, dmg 	: float;
		var counterAction 				: W3DamageAction;		
		var moveTargets					: array<CActor>;
		var i 							: int;
		var canPerformFinisher			: bool;
		var weaponName					: name;
		var npcVictim					: CNewNPC;
		var toxicCloud					: W3ToxicCloud;
		var playsNonAdditiveAnim		: bool;
		var bleedCustomEffect 			: SCustomEffectParams;
		
		
		var min, max 					: SAbilityAttributeValue;
		var minDmg 						: float;
		
		
		if(!actorVictim)
			return;
		
		npcVictim = (CNewNPC)actorVictim;
		
		canPerformFinisher = CanPerformFinisher(actorVictim);
		
		if( actorVictim.IsAlive() && !canPerformFinisher )
		{
			
			if(!action.IsDoTDamage() && action.DealtDamage())
			{
				if ( actorAttacker && npcVictim)
				{
					npcVictim.NoticeActorInGuardArea( actorAttacker );
				}
				//W3EE - Begin
				/*
				if(playerAttacker && action.IsActionMelee() && !playerAttacker.GetInventory().IsItemFists(weaponId) && playerAttacker.IsLightAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s05))
				{
					bleedCustomEffect.effectType = EET_Bleeding;
					bleedCustomEffect.creator = playerAttacker;
					bleedCustomEffect.sourceName = SkillEnumToName(S_Sword_s05);
					
					
					
					theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'BleedingEffect', 'DirectDamage', min, max );
					bleedCustomEffect.effectValue = min;
					minDmg = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s05, 'dmg_per_sec', false, true)) * playerAttacker.GetSkillLevel(S_Sword_s05);
					dmg = bleedCustomEffect.effectValue.valueAdditive + (bleedCustomEffect.effectValue.valueMultiplicative * actorVictim.GetMaxHealth());
					
					if ( dmg < minDmg )
					{
						bleedCustomEffect.effectValue.valueAdditive += minDmg - dmg;
					}
					
					
					
					actorVictim.AddEffectCustom(bleedCustomEffect);
				}
				*/
				if ( !playerVictim )
				{
					if( playerAttacker && actorVictim.HasBuff(EET_Confusion) && ((W3ConfuseEffect)actorVictim.GetBuff(EET_Confusion)).IsSignEffect() )
						actorVictim.IncAxiiHitCounter(1);
					actorVictim.RemoveAllBuffsOfType(EET_Confusion);
				}
				//W3EE - End
			}
			
			
			if(actorVictim && wasAlive)
			{
				playsNonAdditiveAnim = actorVictim.ReactToBeingHit( action );
			}				
		}
		else
		{
			
			if( !canPerformFinisher && CanDismember( wasFrozen, dismemberExplosion, weaponName ) )
			{
				ProcessDismemberment(wasFrozen, dismemberExplosion);
				toxicCloud = (W3ToxicCloud)action.causer;
				
				if(toxicCloud && toxicCloud.HasExplodingTargetDamages())
					ProcessToxicCloudDismemberExplosion(toxicCloud.GetExplodingTargetDamages());
					
				
				if(IsRequiredAttitudeBetween(thePlayer, action.victim, true))
				{
					moveTargets = thePlayer.GetMoveTargets();
					for ( i = 0; i < moveTargets.Size(); i += 1 )
					{
						//W3EE - Begin
						if ( moveTargets[i].IsHuman() )
						{
							moveTargets[i].DrainMorale(20.f * (1.6f - Options().AggressionBehavior() * 0.2f));
							if( ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 56 _Stats', true) || ((W3PlayerWitcher)playerAttacker).HasAbility('Runeword 57 _Stats', true) )
								moveTargets[i].DrainMorale(20.f * (1.6f - Options().AggressionBehavior() * 0.2f));
						}
						//W3EE - End
					}
				}
				Combat().DismemberAdrenalineGain(); //W3EE
			}
			else if ( canPerformFinisher )
			{
				if ( actorVictim.IsAlive() )
					actorVictim.Kill( 'Finisher', false, thePlayer );
					
				thePlayer.AddTimer( 'DelayedFinisherInputTimer', 0.1f );
				thePlayer.SetFinisherVictim( actorVictim );
				thePlayer.CleanCombatActionBuffer();
				thePlayer.OnBlockAllCombatTickets( true );
				
				if( actorVictim.WillBeUnconscious() )
				{
					actorVictim.SetBehaviorVariable( 'prepareForUnconsciousFinisher', 1.0f );
					actorVictim.ActionRotateToAsync( thePlayer.GetWorldPosition() );
				}
				
				moveTargets = thePlayer.GetMoveTargets();
				
				for ( i = 0; i < moveTargets.Size(); i += 1 )
				{
					if ( actorVictim != moveTargets[i] )
						moveTargets[i].SignalGameplayEvent( 'InterruptChargeAttack' );
				}	
				//W3EE - Begin
				/*
				if 	( 	theGame.GetInGameConfigWrapper().GetVarValue('Gameplay', 'AutomaticFinishersEnabled' ) == "true" 
					|| ( (W3PlayerWitcher)playerAttacker && GetWitcherPlayer().IsMutationActive( EPMT_Mutation3 ) ) 
					
					)
				{
					actorVictim.AddAbility( 'ForceFinisher', false );
				}
				
				if ( actorVictim.HasTag( 'ForceFinisher' ) )
					actorVictim.AddAbility( 'ForceFinisher', false );
				*/
				//W3EE - End
				actorVictim.SignalGameplayEvent( 'ForceFinisher' );
				
				Combat().AllowAutoFinisher(actorVictim, playerAttacker); //W3EE
			} 
			else if ( weaponName == 'fists' && npcVictim )
			{
				npcVictim.DisableAgony();	
			}
			
			thePlayer.FindMoveTarget();
		}
		
		if( attackAction.IsActionMelee() )
		{
			actorAttacker.SignalGameplayEventParamObject( 'HitActionReaction', actorVictim );
			actorVictim.OnHitActionReaction( actorAttacker, weaponName );
		}
		
		
		actorVictim.ProcessHitSound(action, playsNonAdditiveAnim || !actorVictim.IsAlive());
		
		//W3EE - Begin
		/*
		if(action.IsCriticalHit() && action.DealtDamage() && !actorVictim.IsAlive() && actorAttacker == thePlayer )
			GCameraShake( 0.5, true, actorAttacker.GetWorldPosition(), 10 );
		*/
		//W3EE - End
		if( attackAction && npcVictim && npcVictim.IsShielded( actorAttacker ) && attackAction.IsParried() && attackAction.GetAttackName() == 'attack_heavy' &&  npcVictim.GetStaminaPercents() <= 0.1 )
		{
			npcVictim.ProcessShieldDestruction();
		}
		
		
		if( actorVictim && action.CanPlayHitParticle() && ( action.DealsAnyDamage() || (attackAction && attackAction.IsParried()) ) )
			actorVictim.PlayHitEffect(action);
			

		if( action.victim.HasAbility('mon_nekker_base') && !actorVictim.CanPlayHitAnim() && !((CBaseGameplayEffect) action.causer) ) 
		{
			
			actorVictim.PlayEffect(theGame.params.LIGHT_HIT_FX);
			actorVictim.SoundEvent("cmb_play_hit_light");
		}
		
		Combat().PlayCommonHitEffect(action, actorVictim, playsNonAdditiveAnim); //W3EE
		Combat().SwordCounterEffect(action, attackAction, actorVictim, playerAttacker); //W3EE
		
		if(actorVictim && playerAttacker && action.IsActionMelee() && thePlayer.inv.IsItemFists(weaponId) )
		{
			actorVictim.SignalGameplayEvent( 'wasHitByFists' );	
			
			if(MonsterCategoryIsMonster(victimMonsterCategory) && !((W3PlayerWitcher)playerAttacker).CanUseSkill(S_Perk_21)) //W3EE
			{
				if(!victimCanBeHitByFists)
				{
					playerAttacker.ReactToReflectedAttack(actorVictim);
				}
				else
				{			
					actorVictim.GetResistValue(CDS_PhysicalRes, points, percents);
				
					if(percents >= theGame.params.MONSTER_RESIST_THRESHOLD_TO_REFLECT_FISTS)
						playerAttacker.ReactToReflectedAttack(actorVictim);
				}
			}			
		}
		
		
		//ProcessSparksFromNoDamage(); //W3EE
		
		
		if(attackAction && attackAction.IsActionMelee() && actorAttacker && playerVictim && (attackAction.IsCountered() || attackAction.IsPerfectParried()) && playerVictim == GetWitcherPlayer()) //W3EE
		{
			GetWitcherPlayer().SetRecentlyCountered(true);
		}
		
		if(attackAction && attackAction.IsActionMelee() && actorAttacker && playerVictim && attackAction.WasDodged() && playerVictim == GetWitcherPlayer())
		{
			GetWitcherPlayer().SetRecentlyDodged(true);
		}
		
		
		
		
		
	}
	
	private function CanDismember( wasFrozen : bool, out dismemberExplosion : bool, out weaponName : name ) : bool
	{
		var dismember			: bool;
		var dismemberChance 	: int;
		var petard 				: W3Petard;
		var bolt 				: W3BoltProjectile;
		var arrow 				: W3ArrowProjectile;
		var inv					: CInventoryComponent;
		var toxicCloud			: W3ToxicCloud;
		var witcher				: W3PlayerWitcher;
		var i					: int;
		var secondaryWeapon		: bool;

		petard = (W3Petard)action.causer;
		bolt = (W3BoltProjectile)action.causer;
		arrow = (W3ArrowProjectile)action.causer;
		toxicCloud = (W3ToxicCloud)action.causer;
		
		dismemberExplosion = false;
		
		if(playerAttacker)
		{
			secondaryWeapon = playerAttacker.inv.ItemHasTag( weaponId, 'SecondaryWeapon' ) || playerAttacker.inv.ItemHasTag( weaponId, 'Wooden' );
		}
		
		if( actorVictim.HasAbility( 'DisableDismemberment' ) )
		{
			dismember = false;
		}
		else if( actorVictim.HasTag( 'DisableDismemberment' ) )
		{
			dismember = false;
		}
		else if (actorVictim.WillBeUnconscious())
		{
			dismember = false;		
		}
		//W3EE - Begin
		/*
		else if (playerAttacker && secondaryWeapon )
		{
			dismember = false;
		}
		*/
		else if( Combat().IsUsingBattleMace() )
		{
			dismember = false;
		}
		else if( Combat().IsUsingBattleAxe() )
		{
			dismember = true;
		}
		else if( playerAttacker && ((W3PlayerWitcher)playerAttacker).IsInCombatAction_SpecialAttackHeavy() && playerAttacker.GetSpecialAttackTimeRatio() > 0.78f && playerAttacker.inv.ItemHasTag(weaponId, 'SwordRendBlastEffect') )
		{
			dismember = true;
			dismemberExplosion = true;
		}
		else if( (((CNewNPC)actorVictim).GetNPCCustomStat(theGame.params.DAMAGE_NAME_PHYSICAL) > 0.5f && actorVictim.IsHuman()) )
		{
			dismember = false;
		}
		else if (playerAttacker && playerAttacker.inv.ItemHasTag(weaponId, 'Wooden') )
		{
			dismember = false;
		}
		//W3EE - End
		else if( arrow && !wasFrozen )
		{
			dismember = false;
		}		
		else if( actorAttacker.HasAbility( 'ForceDismemberment' ) )
		{
			dismember = true;
			dismemberExplosion = action.HasForceExplosionDismemberment();
		}
		else if(wasFrozen)
		{
			dismember = true;
			dismemberExplosion = action.HasForceExplosionDismemberment();
		}						
		else if( (petard && petard.DismembersOnKill()) || (bolt && bolt.DismembersOnKill()) )
		{
			dismember = true;
			dismemberExplosion = action.HasForceExplosionDismemberment();
		}
		else if( (W3Effect_YrdenHealthDrain)action.causer )
		{
			dismember = true;
			dismemberExplosion = true;
		}
		else if(toxicCloud && toxicCloud.HasExplodingTargetDamages())
		{
			dismember = true;
			dismemberExplosion = true;
		}
		//W3EE - Begin
		else if( (witcher.HasBuff(EET_WinterBlade) && ((W3Effect_WinterBlade)witcher.GetBuff(EET_WinterBlade)).IsWeaponCharged()) || (witcher.HasBuff(EET_PhantomWeapon) && witcher.GetPhantomWeaponMgr().IsWeaponCharged()) ) 
		{
			dismember = true;
			dismemberExplosion = true;
		}
		else if( action.IsActionWitcherSign() )
		{
			dismember = Combat().GetSignSkillDismember(action);
			dismemberExplosion = dismember || action.HasForceExplosionDismemberment();
		}
		//W3EE - End
		else
		{
			inv = actorAttacker.GetInventory();
			weaponName = inv.GetItemName( weaponId );
			
			if( attackAction 
				&& !inv.IsItemSteelSwordUsableByPlayer(weaponId) 
				&& !inv.IsItemSilverSwordUsableByPlayer(weaponId) 
				&& weaponName != 'polearm'
				&& weaponName != 'fists_lightning' 
				&& weaponName != 'fists_fire' )
			{
				dismember = false;
			}			
			else if ( action.IsCriticalHit() )
			{
				dismember = true;
				dismemberExplosion = action.HasForceExplosionDismemberment();
			}
			else if ( action.HasForceExplosionDismemberment() )
			{
				dismember = true;
				dismemberExplosion = true;
			}
			
			else if ( weaponName == 'fists_lightning' || weaponName == 'fists_fire' )
			{
				if(RandRange(100) > 75)
					dismember = true;
			}
			
			else
			{
				
				//dismemberChance = theGame.params.DISMEMBERMENT_ON_DEATH_CHANCE; //W3EE
				dismemberChance = Options().Dism(); //W3EE
				
				if(playerAttacker && playerAttacker.forceDismember)
				{
					dismemberChance = thePlayer.forceDismemberChance;
					dismemberExplosion = thePlayer.forceDismemberExplosion;
				}
				
				
				if(attackAction)
				{
					dismemberChance += RoundMath(100 * CalculateAttributeValue(inv.GetItemAttributeValue(weaponId, 'dismember_chance')));
					dismemberExplosion = attackAction.HasForceExplosionDismemberment();
				}
				
				witcher = (W3PlayerWitcher)actorAttacker;
				//W3EE - Begin
				/*
				if(witcher && witcher.CanUseSkill(S_Perk_03))
					dismemberChance += RoundMath(100 * CalculateAttributeValue(witcher.GetSkillAttributeValue(S_Perk_03, 'dismember_chance', false, true)));
				
				
				if( ( W3PlayerWitcher )playerAttacker && attackAction.IsActionMelee() && GetWitcherPlayer().IsMutationActive(EPMT_Mutation3) )	
				{
					if( thePlayer.inv.IsItemSteelSwordUsableByPlayer( weaponId ) || thePlayer.inv.IsItemSilverSwordUsableByPlayer( weaponId ) )
					{
						dismemberChance = 100;
					}
				}
				*/
				//W3EE - End
				
				dismemberChance = Clamp(dismemberChance, 0, 100);
				
				if (RandRange(100) < dismemberChance)
					dismember = true;
				else
					dismember = false;
			}
		}		
		
		return dismember;
	}	
	
	
	private function CanPerformFinisher( actorVictim : CActor ) : bool
	{
		var finisherChance 			: int;
		var areEnemiesAttacking		: bool;
		var i						: int;
		var victimToPlayerVector, playerPos	: Vector;
		var item 					: SItemUniqueId;
		var moveTargets				: array<CActor>;
		var b						: bool;
		var size					: int;
		var npc						: CNewNPC;
		
		if ( (W3ReplacerCiri)thePlayer || playerVictim || thePlayer.isInFinisher )
			return false;
		
		if ( actorVictim.IsAlive() && !CanPerformFinisherOnAliveTarget(actorVictim) )
			return false;
		
		
		if ( actorVictim.WillBeUnconscious() && !theGame.GetDLCManager().IsEP2Available() )
			return false;
		
		//W3EE - Begin
		if( Combat().GetShouldTargetExplode() )
			return false;
		
		//moveTargets = thePlayer.GetMoveTargets();
		//size = moveTargets.Size();
		playerPos = thePlayer.GetWorldPosition();
		
		/*
		if ( size > 0 )
		{
			areEnemiesAttacking = false;			
			for(i=0; i<size; i+=1)
			{
				npc = (CNewNPC)moveTargets[i];
				if(npc && VecDistanceSquared(playerPos, moveTargets[i].GetWorldPosition()) < 7 && npc.IsAttacking() && npc != actorVictim )
				{
					areEnemiesAttacking = true;
					break;
				}
			}
		}
		*/
		
		victimToPlayerVector = actorVictim.GetWorldPosition() - playerPos;
		/*
		if ( actorVictim.IsHuman() )
		{
			npc = (CNewNPC)actorVictim;
			if ( ( size <= 1 && theGame.params.FINISHER_ON_DEATH_CHANCE > 0 ) || ( actorVictim.HasAbility('ForceFinisher') ) || ( GetWitcherPlayer().IsMutationActive(EPMT_Mutation3) ) )
			{
				finisherChance = 100;
			}
			else if ( ( actorVictim.HasBuff(EET_Confusion) || actorVictim.HasBuff(EET_AxiiGuardMe) ) )
			{
				finisherChance = 75 + ( - ( npc.currentLevel - thePlayer.GetLevel() ) );
			}
			else if ( npc.currentLevel - thePlayer.GetLevel() < -5 )
			{
				finisherChance = theGame.params.FINISHER_ON_DEATH_CHANCE + ( - ( npc.currentLevel - thePlayer.GetLevel() ) );
			}
			else
				finisherChance = theGame.params.FINISHER_ON_DEATH_CHANCE;
				
			finisherChance = Clamp(finisherChance, 0, 100);
		}
		*/
		if ( actorVictim.IsHuman() && !thePlayer.HasAbility('ForceDismemberment') && !actorVictim.IsFrozen() )
		{
			finisherChance = Options().FinishChance();
		}
		//W3EE - End
		else 
			finisherChance = 0;	
			
		if ( actorVictim.HasTag('ForceFinisher') )
		{
			finisherChance = 100;
			areEnemiesAttacking = false;
		}
			
		item = thePlayer.inv.GetItemFromSlot( 'l_weapon' );	
		
		if ( thePlayer.forceFinisher && !thePlayer.forceFinisherKeepConditions )
		{
			b = playerAttacker && attackAction && attackAction.IsActionMelee();
			b = b && ( actorVictim.IsHuman() && !actorVictim.IsWoman() );
			b =	b && !thePlayer.IsInAir();
			b =	b && ( thePlayer.IsWeaponHeld( 'steelsword') || thePlayer.IsWeaponHeld( 'silversword') );
			b = b && !thePlayer.IsSecondaryWeaponHeld();
			b =	b && (!thePlayer.inv.IsIdValid( item ));
			b =	b && !actorVictim.IsKnockedUnconscious();
			b =	b && !actorVictim.HasBuff( EET_Knockdown );
			b =	b && !actorVictim.HasBuff( EET_Ragdoll );
			b =	b && !actorVictim.HasBuff( EET_Frozen );
			b =	b && !actorVictim.HasAbility( 'DisableFinishers' );
			b =	b && !thePlayer.IsUsingVehicle();
			b =	b && thePlayer.IsAlive();
			b =	b && !thePlayer.IsCurrentSignChanneled();
		}
		else
		{
			b = playerAttacker && attackAction && attackAction.IsActionMelee();
			b = b && ( actorVictim.IsHuman() && !actorVictim.IsWoman() );
			b =	b && RandRange(100) < finisherChance; //W3EE
			// b =	b && !areEnemiesAttacking; //W3EE
			b =	b && AbsF( victimToPlayerVector.Z ) < 0.4f;
			b =	b && !thePlayer.IsInAir();
			b =	b && ( thePlayer.IsWeaponHeld( 'steelsword') || thePlayer.IsWeaponHeld( 'silversword') );
			b = b && !thePlayer.IsSecondaryWeaponHeld();
			b =	b && !thePlayer.inv.IsIdValid( item );
			b =	b && !actorVictim.IsKnockedUnconscious();
			b =	b && !actorVictim.HasBuff( EET_Knockdown );
			b =	b && !actorVictim.HasBuff( EET_Ragdoll );
			b =	b && !actorVictim.HasBuff( EET_Frozen );
			b =	b && !actorVictim.HasAbility( 'DisableFinishers' );
			b =	b && actorVictim.GetAttitude( thePlayer ) == AIA_Hostile;
			b =	b && !thePlayer.IsUsingVehicle();
			b =	b && thePlayer.IsAlive();
			b =	b && !thePlayer.IsCurrentSignChanneled();
			// b =	b && ( theGame.GetWorld().NavigationCircleTest( actorVictim.GetWorldPosition(), 2.f ) || actorVictim.HasTag('ForceFinisher') ) ; //W3EE
			
		}

		if ( b  )
		{
			if ( !actorVictim.IsAlive() && !actorVictim.WillBeUnconscious() )
				actorVictim.AddAbility( 'DisableFinishers', false );
				
			return true;
		}
		
		return false;
	}
	
	private function CanPerformFinisherOnAliveTarget( actorVictim : CActor ) : bool
	{
		return false; //W3EE
		return actorVictim.IsHuman() 

		&& ( actorVictim.HasBuff(EET_Confusion) || actorVictim.HasBuff(EET_AxiiGuardMe) )

		&& actorVictim.IsVulnerable()
		&& !actorVictim.HasAbility('DisableFinisher')
		&& !actorVictim.HasAbility('InstantKillImmune');
	}
	
	
	
	
	
	
	private function ProcessActionBuffs() : bool
	{
		var inv : CInventoryComponent;
		var ret : bool;
	
		
		if(!action.victim.IsAlive() || action.WasDodged() || (attackAction && attackAction.IsActionMelee() && !attackAction.ApplyBuffsIfParried() && attackAction.CanBeParried() && attackAction.IsParried()) )
			return true;
			
		
		ApplyQuenBuffChanges();
		//W3EE - Begin
		/*
		if( actorAttacker == thePlayer && action.IsActionWitcherSign() && action.IsCriticalHit() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation2 ) && action.HasBuff( EET_Burning ) )
		{
			action.SetBuffSourceName( 'Mutation2ExplosionValid' );
		}
		*/
		//W3EE - End
		if(actorVictim && action.GetEffectsCount() > 0)
			ret = actorVictim.ApplyActionEffects(action);
		else
			ret = false;
			
		
		if(actorAttacker && actorVictim)
		{
			inv = actorAttacker.GetInventory();
			actorAttacker.ProcessOnHitEffects(actorVictim, inv.IsItemSilverSwordUsableByPlayer(weaponId), inv.IsItemSteelSwordUsableByPlayer(weaponId), action.IsActionWitcherSign() );
		}
		
		return ret;
	}
	
	
	private function ApplyQuenBuffChanges()
	{
		var npc : CNewNPC;
		var protection : bool;
		var witcher : W3PlayerWitcher;
		var quenEntity : W3QuenEntity;
		var i : int;
		var buffs : array<EEffectType>;
	
		if(!actorVictim || !actorVictim.HasAlternateQuen())
			return;
		
		npc = (CNewNPC)actorVictim;
		if(npc)
		{
			if(!action.DealsAnyDamage())
				protection = true;
		}
		else
		{
			witcher = (W3PlayerWitcher)actorVictim;
			if(witcher)
			{
				quenEntity = (W3QuenEntity)witcher.GetCurrentSignEntity();
				if(quenEntity.GetBlockedAllDamage())
				{
					protection = true;
				}
			}
		}
		
		if(!protection)
			return;
			
		action.GetEffectTypes(buffs);
		for(i=buffs.Size()-1; i>=0; i -=1)
		{
			if(buffs[i] == EET_KnockdownTypeApplicator || IsKnockdownEffectType(buffs[i]))
				continue;
				
			action.RemoveBuff(i);
		}
	}
	
	
	
	
	private function ProcessDismemberment(wasFrozen : bool, dismemberExplosion : bool )
	{
		var hitDirection		: Vector;
		var usedWound			: name;
		var npcVictim			: CNewNPC;
		var wounds				: array< name >;
		var i					: int;
		var petard 				: W3Petard;
		var bolt 				: W3BoltProjectile;		
		var forcedRagdoll		: bool;
		var isExplosion			: bool;
		var dismembermentComp 	: CDismembermentComponent;
		var specialWounds		: array< name >;
		var useHitDirection		: bool;
		var fxMask				: EDismembermentEffectTypeFlags;
		var template			: CEntityTemplate;
		var ent					: CEntity;
		var signType			: ESignType;
		
		if(!actorVictim)
			return;
			
		dismembermentComp = (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' ));
		if(!dismembermentComp)
			return;
			
		if(wasFrozen)
		{
			ProcessFrostDismemberment();
			return;
		}
		
		forcedRagdoll = false;
		
		
		petard = (W3Petard)action.causer;
		bolt = (W3BoltProjectile)action.causer;
		
		if( dismemberExplosion || (attackAction && ( attackAction.GetAttackName() == 'attack_explosion' || attackAction.HasForceExplosionDismemberment() ))
			|| (petard && petard.DismembersOnKill()) || (bolt && bolt.DismembersOnKill()) )
		{
			isExplosion = true;
		}
		else
		{
			isExplosion = false;
		}
		
		
		if(playerAttacker && thePlayer.forceDismember && IsNameValid(thePlayer.forceDismemberName))
		{
			usedWound = thePlayer.forceDismemberName;
		}
		else
		{	
			
			if(isExplosion)
			{
				dismembermentComp.GetWoundsNames( wounds, WTF_Explosion );	

				
				if( action.IsMutation2PotentialKill() )
				{
					
					for( i=wounds.Size()-1; i>=0; i-=1 )
					{
						if( !StrContains( wounds[ i ], "_ep2" ) )
						{
							wounds.EraseFast( i );
						}
					}
					
					signType = action.GetSignType();
					if( signType == ST_Aard )
					{
						fxMask = DETF_Aaard;
					}
					else if( signType == ST_Igni )
					{
						fxMask = DETF_Igni;
					}
					else if( signType == ST_Yrden )
					{
						fxMask = DETF_Yrden;
					}
					else if( signType == ST_Quen )
					{
						fxMask = DETF_Quen;
					}
				}
				else
				{
					fxMask = 0;
				}
				
				//W3EE - Begin
				fxMask = Combat().GetSkillDismemberType(action);
				fxMask = Combat().GetObliterationDismType(action);
				if( action.GetBuffSourceName() == "WinterBladeDamage" )
					fxMask = DETF_Aaard;
				//W3EE - End
				
				if ( wounds.Size() > 0 )
					usedWound = wounds[ RandRange( wounds.Size() ) ];
					
				if ( usedWound )
					StopVO( actorVictim ); 
			}
			else if(attackAction || action.GetBuffSourceName() == "riderHit")
			{
				if  ( attackAction.GetAttackTypeName() == 'sword_s2' || thePlayer.isInFinisher )
					useHitDirection = true;
				//W3EE - Begin
				if( actorVictim.IsHuman() )
				{
					wounds = Combat().GetDismembermentTypes(attackAction);
					if( wounds.Size() > 0 )
						usedWound = wounds[RandRange(wounds.Size())];
				}
				else
				//W3EE - End
				if ( useHitDirection ) 
				{
					hitDirection = actorAttacker.GetSwordTipMovementFromAnimation( attackAction.GetAttackAnimName(), attackAction.GetHitTime(), 0.1, attackAction.GetWeaponEntity() );
					usedWound = actorVictim.GetNearestWoundForBone( attackAction.GetHitBoneIndex(), hitDirection, WTF_Cut );
				}
				else
				{			
					
					dismembermentComp.GetWoundsNames( wounds );
					
					
					if(wounds.Size() > 0)
					{
						dismembermentComp.GetWoundsNames( specialWounds, WTF_Explosion );
						for ( i = 0; i < specialWounds.Size(); i += 1 )
						{
							wounds.Remove( specialWounds[i] );
						}
						
						if(wounds.Size() > 0)
						{
							
							dismembermentComp.GetWoundsNames( specialWounds, WTF_Frost );
							for ( i = 0; i < specialWounds.Size(); i += 1 )
							{
								wounds.Remove( specialWounds[i] );
							}
							
							
							if ( wounds.Size() > 0 )
								usedWound = wounds[ RandRange( wounds.Size() ) ];
						}
					}
				}
			}
		}
		
		if ( usedWound )
		{
			npcVictim = (CNewNPC)action.victim;
			if(npcVictim)
				npcVictim.DisableAgony();			
			
			actorVictim.SetDismembermentInfo( usedWound, actorVictim.GetWorldPosition() - actorAttacker.GetWorldPosition(), forcedRagdoll, fxMask );
			actorVictim.AddTimer( 'DelayedDismemberTimer', 0.05f );
			actorVictim.SetBehaviorVariable( 'dismemberAnim', 1.0 );
			
			
			if ( usedWound == 'explode_02' || usedWound == 'explode2' || usedWound == 'explode_02_ep2' || usedWound == 'explode2_ep2')
			{
				ProcessDismembermentDeathAnim( usedWound, true, EFDT_LegLeft );
				actorVictim.SetKinematic( false );
				
			}
			else
			{
				ProcessDismembermentDeathAnim( usedWound, false );
			}
			
			
			if( usedWound == 'explode_01_ep2' || usedWound == 'explode1_ep2' || usedWound == 'explode_02_ep2' || usedWound == 'explode2_ep2' )
			{
				template = (CEntityTemplate) LoadResource( "explosion_dismember_force" );
				ent = theGame.CreateEntity( template, npcVictim.GetWorldPosition(), , , , true );
				ent.DestroyAfter( 5.f );
			}
			
			DropEquipmentFromDismember( usedWound, true, true );
			
			if( attackAction && actorAttacker == thePlayer )			
				GCameraShake( 0.5, true, actorAttacker.GetWorldPosition(), 10);
			
			if(playerAttacker)
				theGame.HapticStart( "classic_vibro_large_oneshot" );
				
			
			if( dismemberExplosion && (W3AardProjectile)action.causer )
			{
				npcVictim.AddTimer( 'AardDismemberForce', 0.00001f );
			}
		}
		else
		{
			LogChannel( 'Dismemberment', "ERROR: No wound found to dismember on entity but entity supports dismemberment!!!" );
		}
	}
	
	function ApplyForce()
	{
		var size, i : int;
		var victim : CNewNPC;
		var fromPos, toPos : Vector;
		var comps : array<CComponent>;
		var impulse : Vector;
		
		victim = (CNewNPC)action.victim;
		toPos = victim.GetWorldPosition();
		toPos.Z += 1.0f;
		fromPos = toPos;
		fromPos.Z -= 2.0f;
		impulse = VecNormalize( toPos - fromPos.Z ) * 10;
		
		comps = victim.GetComponentsByClassName('CComponent');
		victim.GetVisualDebug().AddArrow( 'applyForce', fromPos, toPos, 1, 0.2f, 0.2f, true, Color( 0,0,255 ), true, 5.0f );
		size = comps.Size();
		for( i = 0; i < size; i += 1 )
		{
			comps[i].ApplyLocalImpulseToPhysicalObject( impulse );
		}
	}
	
	private function ProcessFrostDismemberment()
	{
		var dismembermentComp 	: CDismembermentComponent;
		var wounds				: array< name >;
		var wound				: name;
		var i, fxMask			: int;
		var npcVictim			: CNewNPC;
		
		dismembermentComp = (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' ));
		if(!dismembermentComp)
			return;
		
		dismembermentComp.GetWoundsNames( wounds, WTF_Frost );
		
		
		
		if( theGame.GetDLCManager().IsEP2Enabled() )
		{
			fxMask = DETF_Mutation6;
			
			
			for( i=wounds.Size()-1; i>=0; i-=1 )
			{
				if( !StrContains( wounds[ i ], "_ep2" ) )
				{
					wounds.EraseFast( i );
				}
			}
		}
		else
		{
			fxMask = 0;
		}
		
		if ( wounds.Size() > 0 )
		{
			wound = wounds[ RandRange( wounds.Size() ) ];
		}
		else
		{
			return;
		}
		
		npcVictim = (CNewNPC)action.victim;
		if(npcVictim)
		{
			npcVictim.DisableAgony();
			StopVO( npcVictim );
		}
		
		actorVictim.SetDismembermentInfo( wound, actorVictim.GetWorldPosition() - actorAttacker.GetWorldPosition(), true, fxMask );
		actorVictim.AddTimer( 'DelayedDismemberTimer', 0.05f );
		if( wound == 'explode_02' || wound == 'explode2' || wound == 'explode_02_ep2' || wound == 'explode2_ep2' )
		{
			ProcessDismembermentDeathAnim( wound, true, EFDT_LegLeft );
			npcVictim.SetKinematic(false);
		}
		else
		{
			ProcessDismembermentDeathAnim( wound, false );
		}
		DropEquipmentFromDismember( wound, true, true );
		
		if( attackAction )			
			GCameraShake( 0.5, true, actorAttacker.GetWorldPosition(), 10);
			
		if(playerAttacker)
			theGame.HapticStart( "classic_vibro_large_oneshot" );
	}
	
	
	private function ProcessDismembermentDeathAnim( nearestWound : name, forceDeathType : bool, optional deathType : EFinisherDeathType )
	{
		var dropCurveName : name;
		
		if ( forceDeathType )
		{
			if ( deathType == EFDT_Head )
				StopVO( actorVictim );
				
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)deathType );
			
			return;
		}
		
		dropCurveName = ( (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' )) ).GetMainCurveName( nearestWound );
		
		if ( dropCurveName == 'head' )
		{
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_Head );
			StopVO( actorVictim );
		}
		else if ( dropCurveName == 'torso_left' || dropCurveName == 'torso_right' || dropCurveName == 'torso' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_Torso );
		else if ( dropCurveName == 'arm_right' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_ArmRight );
		else if ( dropCurveName == 'arm_left' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_ArmLeft );
		else if ( dropCurveName == 'leg_left' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_LegLeft );
		else if ( dropCurveName == 'leg_right' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_LegRight );
		else 
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_None );
	}
	
	private function StopVO( actor : CActor )
	{
		actor.SoundEvent( "grunt_vo_death_stop", 'head' );
	}

	private function DropEquipmentFromDismember( nearestWound : name, optional dropLeft, dropRight : bool )
	{
		var dropCurveName : name;
		
		if( actorVictim.HasAbility( 'DontDropWeaponsOnDismemberment' ) )
		{
			return;
		}
		
		dropCurveName = ( (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' )) ).GetMainCurveName( nearestWound );
		
		if ( ChangeHeldItemAppearance() )
		{
			actorVictim.SignalGameplayEvent('DropWeaponsInDeathTask');
			return;
		}
		
		if ( dropLeft || dropRight )
		{
			
			if ( dropLeft )
				actorVictim.DropItemFromSlot( 'l_weapon', true );
			
			if ( dropRight )
				actorVictim.DropItemFromSlot( 'r_weapon', true );			
			
			return;
		}
		
		if ( dropCurveName == 'arm_right' )
			actorVictim.DropItemFromSlot( 'r_weapon', true );
		else if ( dropCurveName == 'arm_left' )
			actorVictim.DropItemFromSlot( 'l_weapon', true );
		else if ( dropCurveName == 'torso_left' || dropCurveName == 'torso_right' || dropCurveName == 'torso' )
		{
			actorVictim.DropItemFromSlot( 'l_weapon', true );
			actorVictim.DropItemFromSlot( 'r_weapon', true );
		}			
		else if ( dropCurveName == 'head' || dropCurveName == 'leg_left' || dropCurveName == 'leg_right' )
		{
			if(  RandRange(100) < 50 )
				actorVictim.DropItemFromSlot( 'l_weapon', true );
			
			if(  RandRange(100) < 50 )
				actorVictim.DropItemFromSlot( 'r_weapon', true );
		} 
	}
	
	function ChangeHeldItemAppearance() : bool
	{
		var inv : CInventoryComponent;
		var weapon : SItemUniqueId;
		
		inv = actorVictim.GetInventory();
		
		weapon = inv.GetItemFromSlot('l_weapon');
		
		if ( inv.IsIdValid( weapon ) )
		{
			if ( inv.ItemHasTag(weapon,'bow') || inv.ItemHasTag(weapon,'crossbow') )
				inv.GetItemEntityUnsafe(weapon).ApplyAppearance("rigid");
			return true;
		}
		
		weapon = inv.GetItemFromSlot('r_weapon');
		
		if ( inv.IsIdValid( weapon ) )
		{
			if ( inv.ItemHasTag(weapon,'bow') || inv.ItemHasTag(weapon,'crossbow') )
				inv.GetItemEntityUnsafe(weapon).ApplyAppearance("rigid");
			return true;
		}
	
		return false;
	}
	//W3EE - Begin
	/*
	private function GetOilProtectionAgainstMonster(dmgType : name, out resist : float, out reduct : float)
	{
		var i : int;
		var heldWeapons : array< SItemUniqueId >;
		var weapon : SItemUniqueId;
		
		resist = 0;
		reduct = 0;
		
		
		heldWeapons = thePlayer.inv.GetHeldWeapons();
		
		
		for( i=0; i<heldWeapons.Size(); i+=1 )
		{
			if( !thePlayer.inv.IsItemFists( heldWeapons[ i ] ) )
			{
				weapon = heldWeapons[ i ];
				break;
			}
		}
		
		
		if( !thePlayer.inv.IsIdValid( weapon ) )
		{
			return;
		}
	
		
		if( !thePlayer.inv.ItemHasActiveOilApplied( weapon, attackerMonsterCategory ) )
		{
			return;
		}
		
		resist = CalculateAttributeValue( thePlayer.GetSkillAttributeValue( S_Alchemy_s05, 'defence_bonus', false, true ) );
	}
	*/
	//W3EE - End
	private function ProcessToxicCloudDismemberExplosion(damages : array<SRawDamage>)
	{
		var act : W3DamageAction;
		var i, j : int;
		var ents : array<CGameplayEntity>;
		
		
		if(damages.Size() == 0)
		{
			LogAssert(false, "W3DamageManagerProcessor.ProcessToxicCloudDismemberExplosion: trying to process but no damages are passed! Aborting!");
			return;
		}		
		
		
		FindGameplayEntitiesInSphere(ents, action.victim.GetWorldPosition(), 3, 1000, , FLAG_OnlyAliveActors);
		
		
		for(i=0; i<ents.Size(); i+=1)
		{
			act = new W3DamageAction in this;
			act.Initialize(action.attacker, ents[i], action.causer, 'Dragons_Dream_3', EHRT_Heavy, CPS_Undefined, false, false, false, true);
			
			for(j=0; j<damages.Size(); j+=1)
			{
				act.AddDamage(damages[j].dmgType, damages[j].dmgVal);
			}
			
			theGame.damageMgr.ProcessAction(act);
			delete act;
		}
	}
	
	
	private final function ProcessSparksFromNoDamage()
	{
		var sparksEntity, weaponEntity : CEntity;
		var weaponTipPosition : Vector;
		var weaponSlotMatrix : Matrix;
		
		
		if(!playerAttacker || !attackAction || !attackAction.IsActionMelee() || attackAction.DealsAnyDamage())
			return;
		
		
		if( ( !attackAction.DidArmorReduceDamageToZero() && !actorVictim.IsVampire() && ( attackAction.IsParried() || attackAction.IsCountered() ) ) 
			|| ( ( attackAction.IsParried() || attackAction.IsCountered() ) && !actorVictim.IsHuman() && !actorVictim.IsVampire() )
			|| actorVictim.IsCurrentlyDodging() )
			return;
		
		
		if(actorVictim.HasTag('NoSparksOnArmorDmgReduced'))
			return;
		
		
		if (!actorVictim.GetGameplayVisibility())
			return;
		
		
		weaponEntity = playerAttacker.inv.GetItemEntityUnsafe(weaponId);
		weaponEntity.CalcEntitySlotMatrix( 'blood_fx_point', weaponSlotMatrix );
		weaponTipPosition = MatrixGetTranslation( weaponSlotMatrix );
		
		
		sparksEntity = theGame.CreateEntity( (CEntityTemplate)LoadResource( 'sword_colision_fx' ), weaponTipPosition );
		sparksEntity.PlayEffect('sparks');
	}
	
	private function ProcessPreHitModifications()
	{
		var fireDamage, totalDmg, maxHealth, currHealth : float;
		var attribute, min, max : SAbilityAttributeValue;
		var infusion : ESignType;
		var hack : array< SIgniEffects >;
		var dmgValTemp : float;
		var igni : W3IgniProjectile; //var igni : W3IgniEntity; //W3EE
		var quen : W3QuenEntity;
		var fireEffect : W3DamageAction; //W3EE
		var witcher : W3PlayerWitcher; //W3EE
		var resist : float; //W3EE
		
		if( actorVictim.HasAbility( 'HitWindowOpened' ) && !action.IsDoTDamage() )
		{
			if( actorVictim.HasTag( 'fairytale_witch' ) )
			{
				
				
				
				
				
				
					((CNewNPC)actorVictim).SetBehaviorVariable( 'shouldBreakFlightLoop', 1.0 );
				
			}
			else
			{
				quen = (W3QuenEntity)action.causer; 
			
				if( !quen )
				{
					if( actorVictim.HasTag( 'dettlaff_vampire' ) )
					{
						actorVictim.StopEffect( 'shadowdash' );
					}
					
					action.ClearDamage();
					if( action.IsActionMelee() )
					{
						actorVictim.PlayEffect( 'special_attack_break' );
					}
					actorVictim.SetBehaviorVariable( 'repelType', 0 );
					
					actorVictim.AddEffectDefault( EET_CounterStrikeHit, thePlayer ); 
					action.RemoveBuffsByType( EET_KnockdownTypeApplicator );
				}
			}
			
			((CNewNPC)actorVictim).SetHitWindowOpened( false );
		}
		
		//W3EE - Begin
		/*
		if(playerAttacker && attackAction && attackAction.IsActionMelee() && (W3PlayerWitcher)thePlayer && thePlayer.HasAbility('Runeword 1 _Stats', true))
		{
			infusion = GetWitcherPlayer().GetRunewordInfusionType();
			
			switch(infusion)
			{
				case ST_Aard:
					action.AddEffectInfo(EET_KnockdownTypeApplicator);
					action.SetProcessBuffsIfNoDamage(true);
					attackAction.SetApplyBuffsIfParried(true);
					actorVictim.CreateFXEntityAtPelvis( 'runeword_1_aard', false );
					break;
				case ST_Axii:
					action.AddEffectInfo(EET_Confusion);
					action.SetProcessBuffsIfNoDamage(true);
					attackAction.SetApplyBuffsIfParried(true);
					break;
				case ST_Igni:
					
					totalDmg = action.GetDamageValueTotal();
					attribute = thePlayer.GetAttributeValue('runeword1_fire_dmg');
					fireDamage = totalDmg * attribute.valueMultiplicative;
					action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, fireDamage);
					
					
					action.SetCanPlayHitParticle(false);					
					action.victim.AddTimer('Runeword1DisableFireFX', 1.f);
					action.SetHitReactionType(EHRT_Heavy);	
					action.victim.PlayEffect('critical_burning');
					break;
				case ST_Yrden:
					attribute = thePlayer.GetAttributeValue('runeword1_yrden_duration');
					action.AddEffectInfo(EET_Slowdown, attribute.valueAdditive);
					action.SetProcessBuffsIfNoDamage(true);
					attackAction.SetApplyBuffsIfParried(true);
					break;
				default:		
					break;
			}
		}
		
		
		if( playerAttacker && actorVictim && (W3PlayerWitcher)playerAttacker && GetWitcherPlayer().IsMutationActive( EPMT_Mutation9 ) && (W3BoltProjectile)action.causer )
		{
			maxHealth = actorVictim.GetMaxHealth();
			currHealth = actorVictim.GetHealth();
			
			
			if( AbsF( maxHealth - currHealth ) < 1.f )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation9', 'health_reduction', min, max);
				actorVictim.ForceSetStat( actorVictim.GetUsedHealthType(), maxHealth * ( 1 - min.valueMultiplicative ) );
			}
			
			
			action.AddEffectInfo( EET_KnockdownTypeApplicator, 0.1f, , , , 1.f );
		}
		*/
		
		igni = (W3IgniProjectile)action.causer;
		resist = ((CNewNPC)actorVictim).GetNPCCustomStat(theGame.params.DAMAGE_NAME_FIRE);
		if( igni && !igni.GetSignEntity().IsAlternateCast() && resist < 1 )
		{
			action.victim.AddTimer('Runeword1DisableFireFX', 1.5f);
			action.victim.PlayEffect('critical_burning');
			action.victim.PlayEffect('critical_burning_csx');
		}
		//W3EE - End
	}

	private function IsMonsterOilTarget() : bool
	{
		var appliedOilName : name;
		var monsterOil: array<name>;
		var oils : array< W3Effect_Oil >;
		var i : int;

		if(!playerAttacker)
		{
			return false;
		}

		monsterOil = MonsterCategoryToOilNames(victimMonsterCategory);
		oils = playerAttacker.inv.GetOilsAppliedOnItem( weaponId );
			
		if( oils.Size() > 0 )
		{
			for( i=0; i<oils.Size(); i+=1 )
			{
				appliedOilName = oils[ i ].GetOilItemName();
				
				
				if( oils[ i ].GetAmmoCurrentCount() > 0 && monsterOil.Contains( appliedOilName ) )
				{
					return true;
				}
			}
		}

		return false;
	}
}



exec function ForceDismember( b: bool, optional chance : int, optional n : name, optional e : bool )
{
	var temp : CR4Player;
	
	temp = thePlayer;
	temp.forceDismember = b;
	temp.forceDismemberName = n;
	temp.forceDismemberChance = chance;
	temp.forceDismemberExplosion = e;
} 

exec function ForceFinisher( b: bool, optional n : name, optional rightStance : bool, optional keepConditions : bool )
{
	var temp : CR4Player;
	
	temp = thePlayer;
	temp.forcedStance = rightStance;
	temp.forceFinisher = b;
	temp.forceFinisherAnimName = n;
	temp.forceFinisherKeepConditions = keepConditions;
}