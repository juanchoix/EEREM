////////////////////////////////
//-- scripts\game\actor.ws --//
//////////////////////////////
@addMethod(CActor)
public function IsWeaponDamaged() : bool
{
	var heldWeapons				: array<SItemUniqueId>;
	var i						: int;
	var IsWeaponDamaged			: bool;
	var inv : CInventoryComponent;
	
	inv = GetInventory();		
	heldWeapons = inv.GetHeldWeapons();
	
	for ( i = 0; i < heldWeapons.Size(); i += 1 )
	{
		IsWeaponDamaged = inv.ItemHasTag( heldWeapons[i], 'DamagedWeapon' );
		
		if ( IsWeaponDamaged )
			break;
	}			
	
	return IsWeaponDamaged;
}
	
@addField(CActor) private var injurySystem : W3EEInjurySystem;

@addMethod(CActor)
public function GetInjuryManager() : W3EEInjurySystem
{
	return injurySystem;
}
	
@addMethod(CActor)
public function InitInjuryManager()
{
	injurySystem = new W3EEInjurySystem in this;
	injurySystem.Init(this);
}
	
@addMethod(CActor)
timer function StopHeadHitEffect( dt : float, id : int )
{
	StopEffect('stunned_ghost');
}
	
@addMethod(CActor)
public timer function PlayActorHitAnimation( dt : float, id : int )
{
	var damageAction : W3DamageAction;
	var hitReaction : EHitReactionType;
	
	if( ((CNewNPC)this).IsFlying() || HasBuff(EET_Stagger) || HasBuff(EET_LongStagger) || HasBuff(EET_Knockdown) || HasBuff(EET_HeavyKnockdown) || HasBuff(EET_Immobilized) || HasBuff(EET_CounterStrikeHit) )
		return;
	
	damageAction = new W3DamageAction in theGame.damageMgr;
	damageAction.Initialize(GetWitcherPlayer(), this, GetWitcherPlayer(), "ParriedCounter", EHRT_Light, CPS_Undefined, true, false, false, false);
	damageAction.SetHitAnimationPlayType(EAHA_ForceYes);
	damageAction.SetCannotReturnDamage(true);
	damageAction.SetSuppressHitSounds(true);
	damageAction.SetCanPlayHitParticle(false);
	theGame.damageMgr.ProcessAction(damageAction);
	delete damageAction;
}

@addMethod(CActor)
timer function ResetStumbleCooldown( dt : float, id : int )
{
	stumbleCooldown = false;
}
	
@addMethod(CActor)
private function SetStumbleCooldown()
{
	stumbleCooldown = true;
	AddTimer('ResetStumbleCooldown', 5.f, false);
}
	
@addMethod(CActor)
public timer function RollAttackStumble( dt : float, id : int )
{
	var damageAction : W3DamageAction;
	var hitReaction : EHitReactionType;
	
	if( ((CNewNPC)this).IsFlying() || HasBuff(EET_Stagger) || HasBuff(EET_LongStagger) || HasBuff(EET_Knockdown) || HasBuff(EET_HeavyKnockdown) || HasBuff(EET_Immobilized) || HasBuff(EET_CounterStrikeHit) )
		return;
	
	if( RandRange(100,0) <= 35 )
	{
		damageAction = new W3DamageAction in theGame.damageMgr;
		if( RandRange(100,0) <= 35 )
			hitReaction = EHRT_Heavy;
		else
			hitReaction = EHRT_Light;
		damageAction.Initialize(NULL, this, NULL, "CombatInjury", hitReaction, CPS_Undefined, false, false, false, true);
		damageAction.SetHitAnimationPlayType(EAHA_ForceYes);
		damageAction.SetCannotReturnDamage(true);
		damageAction.SetSuppressHitSounds(true);
		damageAction.SetCanPlayHitParticle(false);
		theGame.damageMgr.ProcessAction(damageAction);
		delete damageAction;
	}
}	

@addMethod(CActor)
public timer function RollRunningAttackStumble( dt : float, id : int )
{
	var damageAction : W3DamageAction;
	var hitReaction : EHitReactionType;
	var chance : int;
	
	if( stumbleCooldown || ((CNewNPC)this).IsFlying() || HasBuff(EET_Stagger) || HasBuff(EET_LongStagger) || HasBuff(EET_Knockdown) || HasBuff(EET_HeavyKnockdown) || HasBuff(EET_Immobilized) || HasBuff(EET_CounterStrikeHit) )
		return;
	
	chance = 10;
	if( (CNewNPC)this )
		chance += 20;
	
	if( RandRange(100,0) <= chance )
	{
		damageAction = new W3DamageAction in theGame.damageMgr;
		if( RandRange(100,0) <= 50 )
			hitReaction = EHRT_Heavy;
		else
			hitReaction = EHRT_Light;
		damageAction.Initialize(NULL, this, NULL, "CombatInjury", hitReaction, CPS_Undefined, false, false, false, true);
		SetOverrideDirection(true);
		damageAction.SetHitAnimationPlayType(EAHA_ForceYes);
		damageAction.SetCannotReturnDamage(true);
		damageAction.SetSuppressHitSounds(true);
		damageAction.SetCanPlayHitParticle(false);
		theGame.damageMgr.ProcessAction(damageAction);
		SetOverrideDirection(false);
		delete damageAction;
		SetStumbleCooldown();
	}
}
	
@addMethod(CActor)
public timer function RollDamagedBlindness( dt : float, id : int )
{
	var blindnessEffect : SCustomEffectParams;
	var hitReaction : EHitReactionType;
	var chance : int;
	
	if( stumbleCooldown || ((CNewNPC)this).IsFlying() || HasBuff(EET_Blindness) || HasBuff(EET_Confusion) || HasBuff(EET_CounterStrikeHit) )
		return;
	
	chance = 10;
	if( (CNewNPC)this )
		chance += 10;
	
	if( RandRange(100,0) <= chance )
	{
		if( (W3PlayerWitcher)this )
			blindnessEffect.effectType = EET_Blindness;
		else
			blindnessEffect.effectType = EET_Confusion;
		blindnessEffect.sourceName = 'CombatInjury';
		blindnessEffect.duration = 5.f;
		AddEffectCustom(blindnessEffect);
		SetStumbleCooldown();
	}
}
	
@addMethod(CActor)
public timer function RollParryStumble( dt : float, id : int )
{
	var damageAction : W3DamageAction;
	var hitReaction : EHitReactionType;
	var chance : int;
	
	if( stumbleCooldown || ((CNewNPC)this).IsFlying() || HasBuff(EET_Stagger) || HasBuff(EET_LongStagger) || HasBuff(EET_Knockdown) || HasBuff(EET_HeavyKnockdown) || HasBuff(EET_Immobilized) || HasBuff(EET_CounterStrikeHit) )
		return;
	
	chance = 20;
	if( (CNewNPC)this )
		chance += 30;
	
	if( RandRange(100,0) <= chance )
	{
		damageAction = new W3DamageAction in theGame.damageMgr;
		if( RandRange(100,0) <= 50 )
			hitReaction = EHRT_Heavy;
		else
			hitReaction = EHRT_Light;
		damageAction.Initialize(NULL, this, NULL, "CombatInjury", hitReaction, CPS_Undefined, false, false, false, true);
		SetOverrideDirection(true);
		damageAction.SetHitAnimationPlayType(EAHA_ForceYes);
		damageAction.SetCannotReturnDamage(true);
		damageAction.SetSuppressHitSounds(true);
		damageAction.SetCanPlayHitParticle(false);
		theGame.damageMgr.ProcessAction(damageAction);
		SetOverrideDirection(false);
		delete damageAction;
		SetStumbleCooldown();
	}
}
	
@addMethod(CActor)
public timer function RollDodgeStumble( dt : float, id : int )
{
	var damageAction : W3DamageAction;
	var hitReaction : EHitReactionType;
	var chance : int;
	
	if( stumbleCooldown || ((CNewNPC)this).IsFlying() || HasBuff(EET_Stagger) || HasBuff(EET_LongStagger) || HasBuff(EET_Knockdown) || HasBuff(EET_HeavyKnockdown) || HasBuff(EET_Immobilized) || HasBuff(EET_CounterStrikeHit) )
		return;
	
	chance = 30;
	
	if( RandRange(100,0) <= chance )
	{
		damageAction = new W3DamageAction in theGame.damageMgr;
		if( RandRange(100,0) <= 50 )
			hitReaction = EHRT_Heavy;
		else
			hitReaction = EHRT_Light;
		damageAction.Initialize(NULL, this, NULL, "CombatInjury", hitReaction, CPS_Undefined, false, false, false, true);
		SetOverrideDirection(true);
		damageAction.SetHitAnimationPlayType(EAHA_ForceYes);
		damageAction.SetCannotReturnDamage(true);
		damageAction.SetSuppressHitSounds(true);
		damageAction.SetCanPlayHitParticle(false);
		theGame.damageMgr.ProcessAction(damageAction);
		SetOverrideDirection(false);
		delete damageAction;
		SetStumbleCooldown();
	}
}

@wrapMethod(CActor)
function OnSpawned( spawnData : SEntitySpawnData )
{
	wrappedMethod( spawnData );
	
	InitInjuryManager();
	AddTimer('SetIsQuest', 1.5f, false);
}
	
@addMethod(CActor)
public function a() : bool
{
	return bParryEnabled;
}

@addMethod(CActor)
public function b() : bool
{
	return IsGuarded();
}

@wrapMethod(CActor)
function DrainStamina(action : EStaminaActionType, optional fixedCost : float, optional fixedDelay : float, optional abilityName : name, optional dt : float, optional costMult : float)
{
	//Kolaris - Absorption
	Combat().AbsorptionStaminaRestore(((CNewNPC)this), fixedCost);
		
	wrappedMethod( action, fixedCost, fixedDelay, abilityName, dt, costMult );
}

@addMethod(CActor)
timer function RemoveCripplingInjury( dt : float, id : int )
{
	var npcStats : SOpponentStats;
	
	npcStats = ((CNewNPC)this).GetNPCStats();
	ResetAnimationSpeedMultiplier(npcStats.spdMultID2);
	SetCrippled(false);
}
	
@addMethod(CActor)
public function SetCrippled( i : bool )
{
	isCrippled = i;
}
	
@addMethod(CActor)
public function GetCrippled() : bool
{
	return isCrippled;
}
	
@addMethod(CActor)
public function SetSlowdownFactor( i : float )
{
	slowdownFactor = i;
}
	
@addMethod(CActor)
public function GetSlowdownFactor() : float
{
	return slowdownFactor;
}
	
@addMethod(CActor)
public function GetBurnCounter() : float
{
	//Kolaris - Purgation
	if( GetWitcherPlayer().HasAbility('Glyphword 10 _Stats', true) )
		return 0.f;
	else
		return burnCounter;
}
	
@addMethod(CActor)
public function IncBurnCounter(optional by : float)
{
	if ( by )
		burnCounter += by;
	else
		burnCounter += 1;
	//Kolaris - Burnout
	ClampF(burnCounter, 0, 5);
}

/*@addMethod(CActor)
public function DecBurnCounter(optional by : float)
{
	if( by )
		burnCounter -= by;
	else
		burnCounter -= 1;
}*/

@addMethod(CActor)
public function GetAxiiHitCounter() : float
{
	return axiiHitCounter;
}

@addMethod(CActor)
public function IncAxiiHitCounter(optional by : float)
{
	if ( by )
		axiiHitCounter += by;
	else
		axiiHitCounter += 1;
	ClampF(axiiHitCounter, 0, 4);
}

@addMethod(CActor)
public function GetCremationCounter() : float
{
	return cremationCounter;
}
	
@addMethod(CActor)
public function IncCremationCounter()
{
	cremationCounter += 0.01f;
}

@addMethod(CActor)
public function GetDamageTakenMultiplier() : float
{
	return damageTakenMultiplier;
}
	
@addMethod(CActor)
public function SetDamageTakenMultiplier( to : float )
{
	damageTakenMultiplier = to;
}
	
@addMethod(CActor)
public function GetIsFrozenEffectPlaying() : bool
{
	return isFrozenEffectPlaying;
}
	
@addMethod(CActor)
public function SetIsFrozenEffectPlaying( to : bool )
{
	isFrozenEffectPlaying = to;
}
	
@addMethod(CActor)
public timer function RemoveFreezeEffects( dt : float, id : int )
{
	StopEffect('critical_frozen');
	isFrozenEffectPlaying = false;
}
	
@addMethod(CActor)
public function GetIsRecoveringFromParalysis() : bool
{
	return isRevoveringFromParalysis;
}
	
@addMethod(CActor)
public function SetIsRecoveringFromParalysis( to : bool )
{
	isRevoveringFromParalysis = to;
}
	
@addMethod(CActor)
public timer function ParalysisRecovery( dt : float, id : int )
{
	var npcStats : SOpponentStats;
	
	isRevoveringFromParalysis = false;
	
	npcStats = ((CNewNPC)this).GetNPCStats();
	ResetAnimationSpeedMultiplier(npcStats.spdMultID2);
}

@addMethod(CActor)
public function IsHelpless() : bool
{
	if( HasBuff(EET_Immobilized) || 
		HasBuff(EET_Burning) || 
		HasBuff(EET_Knockdown) || 
		HasBuff(EET_HeavyKnockdown) || 
		HasBuff(EET_Blindness) || 
		HasBuff(EET_Confusion) || 
		HasBuff(EET_Paralyzed) || 
		HasBuff(EET_Hypnotized) || 
		HasBuff(EET_Stagger) || 
		HasBuff(EET_LongStagger) ||
		HasBuff(EET_Tangled) ||
		HasBuff(EET_Ragdoll) ||
		HasBuff(EET_Frozen) ||
		HasBuff(EET_Trap) ||
		HasBuff(EET_KnockdownTypeApplicator) ||
		HasBuff(EET_CounterStrikeHit) 
	  )
		return true;
		
	return false;
}

@addMethod(CActor)
public function CountEffectsOfType( type : EEffectType ) : int
{
	if( effectManager && effectManager.IsReady() )
		return effectManager.CountEffectsOfType(type);
	
	return 0;
}
	
@addMethod(CActor)
public function HasDecoctionEffect() : bool
{
	if( effectManager && effectManager.IsReady() )
		return effectManager.HasDecoctionEffect();
	
	return 0;
}
	
@addMethod(CActor)
public function RemoveFirstBuffWithSource( source : string )
{
	if( effectManager && effectManager.IsReady() )
		effectManager.RemoveFirstBuffWithSource( source );
}

@addField(CActor) private var CBActive : bool;
@addField(CActor) private var CBCharge : int;
	
@addMethod(CActor)
public function IsColdBloodActive() : bool
{
	return CBActive;
}
	
@addMethod(CActor)
public function ColdBloodCharge() : int
{
	return CBCharge;
}
		
@addMethod(CActor)
public function SetColdBloodActive( i : bool )
{
	CBActive = i;
}
	
@addMethod(CActor)
public function IncColdBloodCharge()
{
	CBCharge += 1;
}
	
@addMethod(CActor)
timer function ResetCB( dt : float, id : int )
{
	SetColdBloodActive(false);
	CBCharge = 0;
}

@addMethod(CActor)
public function ApplyBleeding( numberStacks : int, causer : CGameplayEntity, sourceName : string, optional forceEffect : bool )
{
	var bleedingEffect : W3Effect_Bleeding;
	var bleedingParams : SCustomEffectParams;
	var effectValue : SAbilityAttributeValue;
	var resistPts, resistPerc : float;
	var i, stacksToApply : int;
	var runeword : bool = false;
	
	if( GetDisplayName() == "Tree's Heart" )
		return;
	
	bleedingEffect = (W3Effect_Bleeding)GetBuff(EET_Bleeding);
	
	numberStacks = Max(1, numberStacks);
	stacksToApply = 0;
	
	if( ((W3PlayerWitcher)causer).HasAbility('Runeword 19 _Stats', true) || ((W3PlayerWitcher)causer).HasAbility('Runeword 20 _Stats', true) || ((W3PlayerWitcher)causer).HasAbility('Runeword 21 _Stats', true) )
	{
		runeword = true;
	}
	
	bleedingParams.effectType = EET_Bleeding;
	bleedingParams.creator = causer;
	bleedingParams.sourceName = sourceName;
	bleedingParams.duration = -1;
	bleedingParams.customAbilityName = '';
	bleedingParams.customFXName = '';
	bleedingParams.isSignEffect = false;
	
	if( (CR4Player)this )
	{
		GetResistValue(CDS_BleedingRes, resistPts, resistPerc);
		if( forceEffect )
		{
			if( !bleedingEffect )
			{
				effectValue.valueMultiplicative = numberStacks;
				bleedingParams.effectValue = effectValue;
				AddEffectCustom(bleedingParams);
			}
			else
			{
				bleedingEffect.IncreaseStacks(numberStacks);
			}
		}
		else
		{
			for( i=0; i < numberStacks; i += 1 )
			{
				if( RandRangeF(1.f) > resistPerc )
					stacksToApply += 1;
			}
			if( !bleedingEffect )
			{
				effectValue.valueMultiplicative = stacksToApply;
				bleedingParams.effectValue = effectValue;
				AddEffectCustom(bleedingParams);
			}
			else
			{
				bleedingEffect.IncreaseStacks(stacksToApply);
			}
		}
	}
	else
	{
		if( forceEffect )
		{
			stacksToApply += numberStacks;
			if( runeword )
			{
				for( i=0; i < numberStacks; i += 1 )
				{
					if( UsesEssence() && RandF() < GetStatPercents(BCS_Essence) )
						stacksToApply += 1;
					else if( UsesVitality() && RandF() < GetStatPercents(BCS_Vitality) )
						stacksToApply += 1;
				}
			}
			if( !bleedingEffect )
			{
				effectValue.valueMultiplicative = stacksToApply;
				bleedingParams.effectValue = effectValue;
				AddEffectCustom(bleedingParams);
			}
			else
			{
				bleedingEffect.IncreaseStacks(stacksToApply);
				ShowFloatingValue(EFVT_Buff, 0, false,, theGame.params.DAMAGE_NAME_DIRECT, EET_Bleeding);
			}
			
			if( (W3PlayerWitcher)causer )
			{
				if( ((W3PlayerWitcher)causer).IsSetBonusActive(EISB_Wolf_1) )
					((W3PlayerWitcher)causer).GetAdrenalineEffect().AddAdrenalineWithMult(numberStacks * 0.25f * ((W3PlayerWitcher)causer).GetSetPartsEquipped(EIST_Wolf));
			}
		}
		else
		{
			resistPerc = ((CNewNPC)this).GetNPCCustomStat(theGame.params.DAMAGE_NAME_BLEEDING);
			for( i=0; i < numberStacks; i += 1 )
			{
				if( RandRangeF(1.f) > resistPerc )
				{
					stacksToApply += 1;
					if( runeword )
					{
						if( UsesEssence() && RandF() < GetStatPercents(BCS_Essence) )
							stacksToApply += 1;
						else if( UsesVitality() && RandF() < GetStatPercents(BCS_Vitality) )
							stacksToApply += 1;
					}
				}
			}
			if( !bleedingEffect )
			{
				effectValue.valueMultiplicative = stacksToApply;
				bleedingParams.effectValue = effectValue;
				AddEffectCustom(bleedingParams);
			}
			else
			{
				bleedingEffect.IncreaseStacks(stacksToApply);
				ShowFloatingValue(EFVT_Buff, 0, false,, theGame.params.DAMAGE_NAME_DIRECT, EET_Bleeding);
			}
			
			if( (W3PlayerWitcher)causer )
			{
				if( ((W3PlayerWitcher)causer).IsSetBonusActive(EISB_Wolf_1) )
					((W3PlayerWitcher)causer).GetAdrenalineEffect().AddAdrenalineWithMult(stacksToApply * 0.25f * ((W3PlayerWitcher)causer).GetSetPartsEquipped(EIST_Wolf));
			}
		}
	}
}

@addMethod(CActor)
public function ApplyPoisoning( numberStacks : int, causer : CGameplayEntity, sourceName : string, optional forceEffect : bool )
{
	var poisonEffect : W3Effect_Poison;
	var poisonParams : SCustomEffectParams;
	var effectValue : SAbilityAttributeValue;
	var resistPts, resistPerc : float;
	var i, stacksToApply : int;
	
	poisonEffect = (W3Effect_Poison)GetBuff(EET_Poison);
	
	effectValue.valueMultiplicative = Max(1, numberStacks);
	stacksToApply = 0;
	
	poisonParams.effectType = EET_Poison;
	poisonParams.creator = causer;
	poisonParams.sourceName = sourceName;
	poisonParams.duration = -1;
	poisonParams.customAbilityName = '';
	poisonParams.customFXName = '';
	poisonParams.isSignEffect = false;
	
	if( (CR4Player)this )
	{
		GetResistValue(CDS_PoisonRes, resistPts, resistPerc);
		if( forceEffect )
		{
			if( !poisonEffect )
			{
				effectValue.valueMultiplicative = numberStacks;
				poisonParams.effectValue = effectValue;
				AddEffectCustom(poisonParams);
			}
			else
			{
				poisonEffect.IncreaseStacks(numberStacks);
			}
		}
		else
		{
			for( i=0; i < numberStacks; i += 1 )
			{
				if( RandRangeF(1.f) > resistPerc )
					stacksToApply += 1;
			}
			if( !poisonEffect )
			{
				effectValue.valueMultiplicative = stacksToApply;
				poisonParams.effectValue = effectValue;
				AddEffectCustom(poisonParams);
			}
			else
			{
				poisonEffect.IncreaseStacks(stacksToApply);
			}
		}
	}
	else
	{
		if( forceEffect )
		{
			stacksToApply += numberStacks;
			if( !poisonEffect )
			{
				effectValue.valueMultiplicative = stacksToApply;
				poisonParams.effectValue = effectValue;
				AddEffectCustom(poisonParams);
			}
			else
			{
				poisonEffect.IncreaseStacks(stacksToApply);
				ShowFloatingValue(EFVT_Buff, 0, false,, theGame.params.DAMAGE_NAME_POISON, EET_Poison);
			}
			
			if( ((W3PlayerWitcher)causer).HasBuff(EET_Decoction10) )
				((W3Decoction10_Effect)((W3PlayerWitcher)causer).GetBuff(EET_Decoction10)).RestorePoiseFromPoisoning((int)effectValue.valueMultiplicative);
		}
		else
		{
			resistPerc = ((CNewNPC)this).GetNPCCustomStat(theGame.params.DAMAGE_NAME_POISON);
			for( i=0; i < numberStacks; i += 1 )
			{
				if( RandRangeF(1.f) > resistPerc )
				{
					stacksToApply += 1;
				}
			}
			if( !poisonEffect )
			{
				effectValue.valueMultiplicative = stacksToApply;
				poisonParams.effectValue = effectValue;
				AddEffectCustom(poisonParams);
			}
			else
			{
				poisonEffect.IncreaseStacks(stacksToApply);
				ShowFloatingValue(EFVT_Buff, 0, false,, theGame.params.DAMAGE_NAME_POISON, EET_Poison);
			}
			
			if( ((W3PlayerWitcher)causer).HasBuff(EET_Decoction10) )
				((W3Decoction10_Effect)((W3PlayerWitcher)causer).GetBuff(EET_Decoction10)).RestorePoiseFromPoisoning((int)effectValue.valueMultiplicative);
		}
	}
}

@addMethod(CActor)
public function SetIsImmobilized( b : bool )
{
	isImmobilized = b;
}
	
@addMethod(CActor)
public function IsImmobilized() : bool
{
	return isImmobilized;
}

@addMethod(CActor)
timer function SetIsQuest( dt : float, id : int )
{
	//Kolaris - Quest NPC Tags
	isQuest = 
	( GetAttitudeGroup() == 'mq1005_scavengers_hostile'
	|| GetAttitudeGroup() == 'mq3005_noble'
	|| GetAttitudeGroup() == 'mq3031_husband'
	|| HasTag('poi_bar_a_12_knight')
	|| HasTag('poi_gor_a_09_knight')
	|| HasTag('poi_gor_d_07_knight')
	|| HasAbility('_canBeFollower') 
	|| HasAbility('_combatFollowerHardcoreV') 
	|| HasAbility('_combatFollowerHardcoreE') 
	|| HasAbility('_combatFollowerHardV') 
	|| HasAbility('_combatFollowerHardE') 
	|| ((CNewNPC)this).GetNPCType() == ENGT_Quest) && (CNewNPC)this;
}
	
@addMethod(CActor)
public function IsQuestActor() : bool
{
	return isQuest && !HasAbility('mon_q703_arena_knights') && !HasAbility('SkillBoss') && !HasAbility('SkillShieldHard');
}

@addMethod(CActor)
public function SetYrdenCooldown( cooldown : float )
{
	yrdenImmobilizeCooldown = cooldown;
}
	
@addMethod(CActor)
public function GetYrdenCooldown() : float
{
	return yrdenImmobilizeCooldown;
}

//Kolaris - Hit Fx	
@addMethod(CActor)
public function CreateFXEntityAndPlayEffect( entityName : name, effectName : name )
{
	var fx : CEntity;
	
	fx = CreateFXEntityAtPelvis( entityName, true);
	fx.PlayEffect(effectName);
}

//Kolaris - Poison Fx
@addMethod(CActor)
timer function DisablePoisonFX( dt : float, id : int )
{
	var poisonEffect : W3Effect_Poison;
	
	poisonEffect = (W3Effect_Poison)GetBuff(EET_Poison);
	
	if( IsEffectActive('critical_poison') && poisonEffect.GetStacks() < 5 )
	{
		StopEffect('critical_poison');
	}
}

@addMethod(CActor)
public function SetWasPoiseBroken( b : bool )
{
	wasPoiseBroken = b;
}
	
@addMethod(CActor)
public function GetWasPoiseBroken() : bool
{
	return wasPoiseBroken;
}
	
@addMethod(CActor)
timer function NotifyStaggerEndTimed( dt : float, id : int )
{
	NotifyStaggerEnd();
}
	
@addMethod(CActor)
public function NotifyStaggerEnd()
{
	var playerPoise : W3Effect_Poise;
	var npcPoise : W3Effect_NPCPoise;
	
	wasPoiseBroken = false;
	playerPoise = (W3Effect_Poise)GetBuff(EET_Poise);
	npcPoise = (W3Effect_NPCPoise)GetBuff(EET_NPCPoise);
	if( playerPoise.IsPoiseBroken(true) )
		playerPoise.SetPoiseBreakTimer(0);
		
	if( npcPoise.IsPoiseBroken() )
		npcPoise.SetPoiseBreakTimer(0);
}

/////////////////////////////////////////////
//-- scripts\game\definitionsManager.ws --//
///////////////////////////////////////////

@addMethod(CDefinitionsManagerAccessor)
public function GetItemAttributeValue(itemName : name, playerItem : bool, attributeName : name) : SAbilityAttributeValue
{
	var abs : array<name>;
	var temp : array<float>;
	var tempInt : int;
	var min, max : SAbilityAttributeValue;
	
	GetItemAbilitiesWithWeights(itemName, playerItem, abs, temp, tempInt, tempInt);
	GetAbilitiesAttributeValue(abs, attributeName, min, max);
	
	return min;
}

@addMethod(CDefinitionsManagerAccessor)
public function GetItemQuality( itemName : name ) : int
{
	var min, max : SAbilityAttributeValue;
	
	GetItemAttributeValueNoRandom(itemName, false, 'quality', min, max);
	
	return (int)min.valueAdditive;
}

/////////////////////////////////////
//-- scripts\game\gameParams.ws --//
///////////////////////////////////

@wrapMethod(W3GameParams)
function Init()
{
	wrappedMethod();
	InitKnifeAbilities(); // Kolaris - Dynamic Knife Recipes
}

//Kolaris ++ Dynamic Knife Recipes
@addMethod(W3GameParams)
private function InitKnifeAbilities()
{
	KNIFE_MASTERWORK_ABILITIES.Clear();
	
	KNIFE_MASTERWORK_ABILITIES.PushBack('Master_Knife_Pierce');
	KNIFE_MASTERWORK_ABILITIES.PushBack('Master_Knife_Bleed');
	KNIFE_MASTERWORK_ABILITIES.PushBack('Master_Knife_Poison');
}

//Kolaris -- Dynamic Knife Recipes
@addMethod(W3GameParams)
public function GetMasterLightArmorAbilityArray() : array<name>
{
	return ARMOR_MASTERWORK_LIGHT_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMasterMediumArmorAbilityArray() : array<name>
{
	return ARMOR_MASTERWORK_MEDIUM_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMasterHeavyArmorAbilityArray() : array<name>
{
	return ARMOR_MASTERWORK_HEAVY_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMasterLightBootsAbilityArray() : array<name>
{
	return BOOTS_MASTERWORK_LIGHT_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMasterMediumBootsAbilityArray() : array<name>
{
	return BOOTS_MASTERWORK_MEDIUM_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMasterHeavyBootsAbilityArray() : array<name>
{
	return BOOTS_MASTERWORK_HEAVY_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMasterLightPantsAbilityArray() : array<name>
{
	return PANTS_MASTERWORK_LIGHT_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMasterMediumPantsAbilityArray() : array<name>
{
	return PANTS_MASTERWORK_MEDIUM_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMasterHeavyPantsAbilityArray() : array<name>
{
	return PANTS_MASTERWORK_HEAVY_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMasterLightGlovesAbilityArray() : array<name>
{
	return GLOVES_MASTERWORK_LIGHT_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMasterMediumGlovesAbilityArray() : array<name>
{
	return GLOVES_MASTERWORK_MEDIUM_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMasterHeavyGlovesAbilityArray() : array<name>
{
	return GLOVES_MASTERWORK_HEAVY_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMagicalLightArmorAbilityArray() : array<name>
{
	return ARMOR_MAGICAL_LIGHT_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMagicalMediumArmorAbilityArray() : array<name>
{
	return ARMOR_MAGICAL_MEDIUM_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMagicalHeavyArmorAbilityArray() : array<name>
{
	return ARMOR_MAGICAL_HEAVY_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMagicalLightBootsAbilityArray() : array<name>
{
	return BOOTS_MAGICAL_LIGHT_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMagicalMediumBootsAbilityArray() : array<name>
{
	return BOOTS_MAGICAL_MEDIUM_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMagicalHeavyBootsAbilityArray() : array<name>
{
	return BOOTS_MAGICAL_HEAVY_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMagicalLightPantsAbilityArray() : array<name>
{
	return PANTS_MAGICAL_LIGHT_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMagicalMediumPantsAbilityArray() : array<name>
{
	return PANTS_MAGICAL_MEDIUM_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMagicalHeavyPantsAbilityArray() : array<name>
{
	return PANTS_MAGICAL_HEAVY_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMagicalLightGlovesAbilityArray() : array<name>
{
	return GLOVES_MAGICAL_LIGHT_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMagicalMediumGlovesAbilityArray() : array<name>
{
	return GLOVES_MAGICAL_MEDIUM_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMagicalHeavyGlovesAbilityArray() : array<name>
{
	return GLOVES_MAGICAL_HEAVY_ABILITIES;
}

@addMethod(W3GameParams)
public function GetCommonWeaponAbilityArray() : array<name>
{
	return WEAPON_COMMON_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMasterworkWeaponAbilityArray() : array<name>
{
	return WEAPON_MASTERWORK_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMagicalWeaponAbilityArray() : array<name>
{
	return WEAPON_MAGICAL_ABILITIES;
}

@addMethod(W3GameParams)
public function GetMasterworkKnifeAbilityArray() : array<name>
{
	return KNIFE_MASTERWORK_ABILITIES;
}

///////////////////////////////////////
//-- scripts\game\inputManager.ws --//
/////////////////////////////////////

@wrapMethod(CInputManager)
function GetLastUsedGamepadType() : EInputDeviceType
{
	if(Options().ControlHintOverride() == 1)
		return IDT_KeyboardMouse;
	else if (Options().ControlHintOverride() == 2)
		return IDT_Steam;
	else if (Options().ControlHintOverride() == 3)
		return IDT_Xbox1;
	else if (Options().ControlHintOverride() == 4)
		return IDT_PS4;
	else
		return wrappedMethod();
}

/////////////////////////////////
//-- scripts\game\r4Game.ws --//
///////////////////////////////

@addField(CR4Game)
public var Experience : W3EEExperienceHandler;

@addField(CR4Game)
public var Combat : W3EECombatHandler;

@addField(CR4Game)
public var Scaling : W3EEScalingHandler;

@addField(CR4Game)
public var Options : W3EEOptionHandler;

@addField(CR4Game)
public var Enemies : W3EEEnemyHandler;
	
@addField(CR4Game)
public var Blood : W3EEBloodEffectsHandler;
	
@addField(CR4Game)
public var Damage : W3EEDamageHandler;
	
@addField(CR4Game)
public var Equipment : W3EEEquipmentHandler;
	
@addField(CR4Game)
public var Alchemy : W3EEAlchemyExtender;
	
@addField(CR4Game)
public var CampfireManager : CWitcherCampfireManager;
	
@addField(CR4Game)
public var GaunterMode : GaunterModeManager;
	
@addField(CR4Game)
public var MutagenSorter : CMutagenSorter;

@wrapMethod(CR4Game)
function OnGameStarting(restored : bool )
{
	wrappedMethod(restored);
	
	Experience = new W3EEExperienceHandler in this;
	Combat = new W3EECombatHandler in this;
	Scaling = new W3EEScalingHandler in this;
	Enemies = new W3EEEnemyHandler in this;
	Blood = new W3EEBloodEffectsHandler in this;
	Damage = new W3EEDamageHandler in this;
	Equipment = new W3EEEquipmentHandler in this;
	Alchemy = new W3EEAlchemyExtender in this;
	CampfireManager = new CWitcherCampfireManager in this;
	Blood.Init();
	
	//Kolaris - GaunterMode
	GaunterMode = new GaunterModeManager in this;
	MutagenSorter = new CMutagenSorter in this;
}

@wrapMethod(CR4Game)
function OnGameStarted(restored : bool)
{
	wrappedMethod(restored);
	
	CampfireManager.RestoreFirecamps();
}

@wrapMethod function MessageDialogPopup( locMessage : string )
{
    if( locMessage == "message_new_game_plus_unlocked" ) return;
    else wrappedMethod( locMessage );
}