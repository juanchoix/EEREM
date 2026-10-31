/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SQuenEffects
{
	editable var lastingEffectUpgNone	: name;
	editable var lastingEffectUpg1		: name;
	editable var lastingEffectUpg2		: name;
	editable var lastingEffectUpg3		: name;
	editable var castEffect				: name;
	editable var cameraShakeStranth		: float;
}



statemachine class W3QuenEntity extends W3SignEntity
{
	editable var effects : array< SQuenEffects >;
	editable var hitEntityTemplate : CEntityTemplate;
		
	
	protected var shieldDuration	: float;
	protected var shieldHealth		: float;
	protected var initialShieldHealth : float;
	protected var dischargePercent	: float;
	protected var ownerBoneIndex	: int;
	protected var blockedAllDamage  : bool;
	protected var shieldStartTime	: EngineTime;
	private var hitEntityTimestamps : array<EngineTime>;
	private const var MIN_HIT_ENTITY_SPAWN_DELAY : float;
	private var hitDoTEntities : array<W3VisualFx>;
	public var showForceFinishedFX : bool;
	public var freeFromBearSetBonus	: bool;
	
	public var wasSignSupercharged : bool; 
	
	default skillEnum = S_Magic_4;
	default MIN_HIT_ENTITY_SPAWN_DELAY = 0.25f;
	
	public function GetSignType() : ESignType
	{
		return ST_Quen;
	}
	
	public function SetBlockedAllDamage(b : bool)
	{
		blockedAllDamage = b;
	}
	
	public function GetBlockedAllDamage() : bool
	{
		return blockedAllDamage;
	}
	
	function Init( inOwner : W3SignOwner, prevInstance : W3SignEntity, optional skipCastingAnimation : bool, optional notPlayerCast : bool, optional isFreeCast : bool ) : bool //W3EE
	{
		var oldQuen : W3QuenEntity;
		
		CacheSignStats(inOwner); //W3EE
		
		ownerBoneIndex = inOwner.GetActor().GetBoneIndex( 'pelvis' );
		if(ownerBoneIndex == -1)
			ownerBoneIndex = inOwner.GetActor().GetBoneIndex( 'k_pelvis_g' );
			
		//W3EE - Begin
		if( inOwner.GetPlayer() )
		{
			oldQuen = (W3QuenEntity)prevInstance;
			if(oldQuen)
				{
				oldQuen.OnSignAborted(true);
				if(!inOwner.GetPlayer().HasBuff(EET_Mutation11Buff) && oldQuen.shieldStartTime > 0 && (( !theInput.LastUsedPCInput() && theInput.GetActionValue( 'CastSignHold' ) == 0.f )|| theInput.IsActionPressed('DistanceModifier')))
				{
					oldQuen.CleanUp();
					oldQuen.Destroy();
					CleanUp();
					Destroy();
					inOwner.GetPlayer().OnBasicQuenFinishing();
					return false;
				}
			}
		}
		//W3EE - End
		hitEntityTimestamps.Clear();
		
		return super.Init( inOwner, prevInstance, skipCastingAnimation, notPlayerCast, isFreeCast ); //W3EE
	}
	
	event OnTargetHit( out damageData : W3DamageAction )
	{
		if(owner.GetActor() == thePlayer && !damageData.IsDoTDamage() && !damageData.WasDodged())
		{
			thePlayer.OnShieldHit();
			
		}
	}
		
	protected function GetSignStats()
	{
		var min, max, fortifiedSignsAtt : SAbilityAttributeValue;
		var player : CR4Player;
		var spellPower : SAbilityAttributeValue; //W3EE
		var sp : float; //W3EE
		
		super.GetSignStats();
		
		//wasSignSupercharged = GetWitcherPlayer().IsSuperchargedSign(); //W3EE
		
		//W3EE - Begin
		spellPower = super.GetTotalSignIntensity();
		sp = spellPower.valueMultiplicative;
		
		shieldDuration = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_4, 'shield_duration', true, true)) * 1.5f;
		shieldHealth = 10000;
		
		if( (W3PlayerWitcher)owner.GetActor() )
		{
			shieldDuration *= ((W3PlayerWitcher)owner.GetActor()).GetPlayerSignDurationMod();
			shieldHealth = 1000 * sp;
		}
		else
			shieldHealth = 10000;
		
		initialShieldHealth = shieldHealth;
		shieldDuration *= sp;
		
		/*
		if ( owner.CanUseSkill(S_Magic_s13))
		{			
			dischargePercent = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s13, 'discharge_percent', false, true)) * owner.GetSkillLevel(S_Magic_s13);
			if( owner.GetPlayer().IsSetBonusActive( EISB_Bear_2 ) )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_Bear_2 ), 'quen_dmg_boost', min, max );
				dischargePercent *= 1 + min.valueMultiplicative;
			}
		}
		else
		{
			dischargePercent = 0;
		}

		
		player = (CR4Player)owner.GetActor();
		if(player.CanUseSkill(S_Magic_s36))
		{
			fortifiedSignsAtt = player.GetSkillAttributeValue(S_Magic_s36, 'duration', false, true);
			shieldDuration *= 1 + fortifiedSignsAtt.valueMultiplicative * player.GetSkillLevel(S_Magic_s36);
		}
		*/
		//W3EE - End
	}
	
	public final function AddBuffImmunities(useDoTs : bool) //W3EE
	{
		var actor : CActor;
		var i : int;
		var crits : array<CBaseGameplayEffect>;
		var effectType : EEffectType;
		var size : int; //W3EE
		var dots : array<EEffectType>; //W3EE
		
		actor = owner.GetActor();
		
		
		crits = actor.GetBuffs();	
		for(i=0; i<crits.Size(); i+=1)
		{
			effectType = crits[i].GetEffectType();
			
			
			if( effectType == EET_SnowstormQ403 || effectType == EET_Snowstorm )
			{
				actor.FinishQuen( false );
				return;
			}
			
			
			
			
		}		
		//W3EE - Begin
		dots.PushBack(EET_Burning);
		dots.PushBack(EET_PoisonCritical);
		dots.PushBack(EET_Swarm);
		
		if(useDoTs)
		{
			for(i=0; i<dots.Size(); i+=1)
			{
				actor.AddBuffImmunity(dots[i], 'Quen', true );
			}			
		}		
		
		size = EnumGetMax('EEffectType')+1;
		for(i=0; i<size; i+=1)
		{
			if( i == 8 || i == 7 )
				continue;
			
			if(IsCriticalEffectType(i) && !dots.Contains(i))
				actor.AddBuffImmunity(i, 'Quen', true);
		}
		//W3EE - End
	}
	
	public final function RemoveBuffImmunities(useDoTs : bool) //W3EE
	{
		var actor : CActor;
		var i, size : int;
		var dots : array<EEffectType>;
		
		actor = owner.GetActor();
		
		//dots.PushBack(EET_Bleeding); //W3EE
		dots.PushBack(EET_Burning);
		//dots.PushBack(EET_Poison); //W3EE
		dots.PushBack(EET_PoisonCritical);
		dots.PushBack(EET_Swarm);
		//W3EE - Begin
		if(useDoTs)
		{
			for(i=0; i<dots.Size(); i+=1)
			{
				actor.RemoveBuffImmunity(dots[i], 'Quen' );
			}
		}
		//W3EE - End
		size = (int)EET_EffectTypesSize;
		for(i=0; i<size; i+=1)
		{
			if(IsCriticalEffectType(i) && !dots.Contains(i))
				actor.RemoveBuffImmunity(i, 'Quen');
		}
	}
	
	event OnStarted() 
	{
		var isAlternate		: bool;
		var witcherOwner	: W3PlayerWitcher;
		
		owner.ChangeAspect( this, S_Magic_s04 );
		isAlternate = IsAlternateCast();
		witcherOwner = owner.GetPlayer();
		
		if(isAlternate)
		{
			
			CreateAttachment( owner.GetActor(), 'quen_sphere' );
			
			if((CPlayer)owner.GetActor())
				GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
		}
		else
		{
			super.OnStarted();
			
			//W3EE - Begin
			if( owner.GetPlayer().IsSwimming() )
				WaterDestroysQuen();
			
			Combat().QuenJoltSkill(this);
			//W3EE - End
		}
		
		
		if(owner.GetActor() == thePlayer && ShouldProcessTutorial('TutorialSelectQuen'))
		{
			FactsAdd("tutorial_quen_cast");
		}
		
		if((CPlayer)owner.GetActor())
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
				
		if( isAlternate || !owner.IsPlayer() )
		{
			if( owner.IsPlayer() && GetWitcherPlayer().HasBuff( EET_Mutation11Immortal ) )
			{
				PlayEffect( 'quen_second_life' );
			}
			else
			{
				PlayEffect( effects[1].castEffect );
			}
			
			if( witcherOwner && (witcherOwner.HasAbility('Glyphword 20 _Stats', true) || witcherOwner.HasAbility('Glyphword 21 _Stats', true)) ) //W3EE
			{
				PlayEffect( 'default_fx_bear_abl2' );
				witcherOwner.PlayEffect( 'quen_lasting_shield_bear_abl2' );
			}
			
			CacheActionBuffsFromSkill();
			GotoState( 'QuenChanneled' );
		}
		else
		{
			PlayEffect( effects[0].castEffect );
			GotoState( 'QuenShield' );
		}
	}
	
	public final function IsAnyQuenActive() : bool
	{
		
		if(GetCurrentStateName() == 'QuenChanneled' || (GetCurrentStateName() == 'ShieldActive' && shieldHealth > 0) )
		{
			return true;
		}
				
		return false;
	}
	
	event OnSignAborted( optional force : bool ){}
	
	
	
	
	public final function PlayHitEffect(fxName : name, rot : EulerAngles, optional isDoT : bool)
	{
		var hitEntity : W3VisualFx;
		var currentTime : EngineTime;
		var dt : float;
		
		currentTime = theGame.GetEngineTime();
		if(hitEntityTimestamps.Size() > 0)
		{
			dt = EngineTimeToFloat(currentTime - hitEntityTimestamps[0]);
			if(dt < MIN_HIT_ENTITY_SPAWN_DELAY)
				return;
		}
		hitEntityTimestamps.Erase(0);
		hitEntityTimestamps.PushBack(currentTime);
		
		hitEntity = (W3VisualFx)theGame.CreateEntity(hitEntityTemplate, GetWorldPosition(), rot);
		if(hitEntity)
		{
			
			hitEntity.CreateAttachment(owner.GetActor(), 'quen_sphere', , rot);
			hitEntity.PlayEffect(fxName);
			hitEntity.DestroyOnFxEnd(fxName);
			
			if(isDoT)
				hitDoTEntities.PushBack(hitEntity);
		}
	}
	
	public function EraseFirstTimeStamp()
	{
		hitEntityTimestamps.Erase(0);
	}
	
	timer function RemoveDoTFX(dt : float, id : int)
	{
		RemoveHitDoTEntities();
	}
	
	public final function RemoveHitDoTEntities()
	{
		var i : int;
		
		for(i=hitDoTEntities.Size()-1; i>=0; i-=1)
		{
			if(hitDoTEntities[i])
				hitDoTEntities[i].Destroy();
		}
	}
	
	public final function GetShieldHealth() : float 		{return shieldHealth;}
	public final function GetInitialShieldHealth() : float 		{return initialShieldHealth;}
	
	public final function GetShieldRemainingDuration() : float
	{
		return shieldDuration - EngineTimeToFloat( theGame.GetEngineTime() - shieldStartTime );
	}
	
	public final function SetDataFromRestore(health : float, duration : float)
	{
		shieldHealth = health;
		shieldDuration = duration;
		shieldStartTime = theGame.GetEngineTime();
		AddTimer('Expire', shieldDuration, false, , , true, true);
	}
	
	timer function Expire( deltaTime : float , id : int)
	{		
		GotoState( 'Expired' );
	}
		
	public final function ForceFinishQuen( skipVisuals : bool, optional forceNoBearSetBonus : bool )
	{
		var min, max : SAbilityAttributeValue;
		var player : W3PlayerWitcher;
		
		player = owner.GetPlayer();
		
		//W3EE - Begin
		/*
		if( !forceNoBearSetBonus && player && player.IsSetBonusActive( EISB_Bear_1 ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( GetSetBonusAbility( EISB_Bear_1), 'quen_reapply_chance', min, max );
			
			min.valueMultiplicative *= player.GetSetPartsEquipped( EIST_Bear );
			
			
			min.valueMultiplicative /= player.m_quenReappliedCount;
			if( player.m_quenReappliedCount > 4 )
			{
				min.valueMultiplicative = 0;
			}	
			
			if( min.valueMultiplicative >= RandF() )
			{
				player.PlayEffect( 'quen_lasting_shield_back' );
				player.AddTimer( 'BearSetBonusQuenReapply', 0.9, true );
			}
			
			else
			{
				player.m_quenReappliedCount = 1;
			}
		}
		*/
		//W3EE - End
		
		if(IsAlternateCast())
		{
			OnEnded();
			
			if(!skipVisuals)
				owner.GetActor().PlayEffect('hit_electric_quen');
		}
		else
		{
			showForceFinishedFX = !skipVisuals;
			GotoState('Expired');
		}
	}
	//W3EE - Begin
	protected function DestroyQuen()
	{
		if( owner.GetPlayer() )
			owner.GetPlayer().AddTimer('DestroyQuen', 0.1f, false);
	}
	
	public function WaterDestroysQuen()
	{
		var player : W3PlayerWitcher = owner.GetPlayer();
		
		player.PlayEffect('hit_electric_quen');
		DestroyQuen();
	}
	
	public final function RegenerateQuen(dt : float)
	{
		shieldHealth = ClampF(shieldHealth + 5 * owner.GetPlayer().GetSkillLevel(S_Magic_s14) * dt, 0, GetInitialShieldHealth());
	}
	
	public function GetReflectWindow() : bool
	{
		if( shieldDuration - GetShieldRemainingDuration() <= 0.3f )
			return true;
		else
			return false;
	}
	//W3EE - End
}


state Expired in W3QuenEntity
{
	event OnEnterState( prevStateName : name )
	{
		parent.shieldHealth = 0;
		
		if(parent.showForceFinishedFX)
			parent.owner.GetActor().PlayEffect('quen_lasting_shield_hit');
			
		parent.DestroyAfter( 1.f );		
		
		
			
	}
}


state ShieldActive in W3QuenEntity extends Active
{
	//W3EE - Begin
	var cachedEffect : name;
	private function UpdateQuenShieldFx()
	{
		var currHP, maxHP, div : float;
		var cycledVisuals : array<name>;
		var initialVisual : name;
		var casterActor : CActor;
		var cycles, i : int;
		
		maxHP = parent.initialShieldHealth;
		currHP = parent.shieldHealth;
		initialVisual = GetLastingFxName();
		switch(initialVisual)
		{
			case parent.effects[0].lastingEffectUpg3:
				cycledVisuals.PushBack(parent.effects[0].lastingEffectUpg2);
				cycledVisuals.PushBack(parent.effects[0].lastingEffectUpg1);
				cycledVisuals.PushBack(parent.effects[0].lastingEffectUpgNone);
				cycles = 4;
			break;
			
			case parent.effects[0].lastingEffectUpg2:
				cycledVisuals.PushBack(parent.effects[0].lastingEffectUpg1);
				cycledVisuals.PushBack(parent.effects[0].lastingEffectUpgNone);
				cycles = 3;
			break;
			
			case parent.effects[0].lastingEffectUpg1:
				cycledVisuals.PushBack(parent.effects[0].lastingEffectUpgNone);
				cycles = 2;
			break;
			
			case parent.effects[0].lastingEffectUpgNone:
				return;
		}
		
		div = maxHP / cycles;
		casterActor = caster.GetActor();
		for(i=cycles-1; i>=1; i-=1)
		{
			if( currHP <= maxHP - i * div )
			{
				if( cachedEffect == cycledVisuals[i-1] )
					return;
				
				casterActor.StopEffect(parent.effects[0].lastingEffectUpg3);
				casterActor.StopEffect(parent.effects[0].lastingEffectUpg2);
				casterActor.StopEffect(parent.effects[0].lastingEffectUpg1);
				casterActor.StopEffect(parent.effects[0].lastingEffectUpgNone);
				casterActor.PlayEffect(cycledVisuals[i-1]);
				cachedEffect = cycledVisuals[i-1];
				
				return;
			}
		}
	}
	
	private final function GetLastingFxName() : name
	{
		var fx : CEntity;
		var spellPower : SAbilityAttributeValue;
		var sp, level : float;
		
		
		spellPower = parent.GetTotalSignIntensity();
		level = spellPower.valueMultiplicative;
		fx = GetWitcherPlayer().CreateFXEntityAtPelvis('mutation1_hit', true);
		fx.PlayEffect('mutation_1_hit_quen');
		
		if( level > 1.4 )
			return parent.effects[0].lastingEffectUpg3;
		else
		if( level > 1.2 )
			return parent.effects[0].lastingEffectUpg2;
		else
		if( level > 1.1 )
			return parent.effects[0].lastingEffectUpg1;
		else
			return parent.effects[0].lastingEffectUpgNone;
	}
	//W3EE - End
	
	event OnEnterState( prevStateName : name )
	{
		var witcher			: W3PlayerWitcher;
		var params 			: SCustomEffectParams;
		
		super.OnEnterState( prevStateName );
		
		witcher = (W3PlayerWitcher)caster.GetActor();
		
		if(witcher)
		{
			witcher.SetUsedQuenInCombat();
			witcher.m_quenReappliedCount = 1;
			
			params.effectType = EET_BasicQuen;
			params.creator = witcher;
			params.sourceName = "sign cast";
			params.duration = parent.shieldDuration;
			
			witcher.AddEffectCustom( params );
		}
		
		caster.GetActor().PlayEffect(GetLastingFxName());
		
		if( witcher && (witcher.HasAbility('Glyphword 20 _Stats', true) || witcher.HasAbility('Glyphword 21 _Stats', true)) ) //W3EE
		{
			witcher.PlayEffect( 'quen_force_discharge_bear_abl2_armour' );
		}
		
		parent.AddTimer( 'Expire', parent.shieldDuration, false, , , true );
		
		parent.AddBuffImmunities(true); //W3EE
		
		if( witcher )
		{
			if( !parent.freeFromBearSetBonus )
			{
				parent.ManagePlayerStamina();
				//parent.ManageGryphonSetBonusBuff(); //W3EE
			}
		}
		else
		{
			caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		}
		
		//W3EE - Begin
		/*
		if( !witcher.IsSetBonusActive( EISB_Bear_1 ) || ( !witcher.HasBuff( EET_HeavyKnockdown ) && !witcher.HasBuff( EET_Knockdown ) ) )
		{
			witcher.CriticalEffectAnimationInterrupted("basic quen cast");
		}
		*/
		witcher.CriticalEffectAnimationInterrupted("basic quen cast");
		//W3EE - End
		
		witcher.AddTimer('HACK_QuenSaveStatus', 0, true);
		parent.shieldStartTime = theGame.GetEngineTime();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		var witcher : W3PlayerWitcher;
		
		
		witcher = (W3PlayerWitcher)caster.GetActor();
		if(witcher && parent == witcher.GetSignEntity(ST_Quen))
		{
			witcher.StopEffect(parent.effects[0].lastingEffectUpg1);
			witcher.StopEffect(parent.effects[0].lastingEffectUpg2);
			witcher.StopEffect(parent.effects[0].lastingEffectUpg3);
			witcher.StopEffect(parent.effects[0].lastingEffectUpgNone);
			witcher.StopEffect( 'quen_force_discharge_bear_abl2_armour' );
			witcher.RemoveBuff( EET_BasicQuen );
		}
	
		parent.RemoveBuffImmunities(true); //W3EE
		
		parent.RemoveHitDoTEntities();
		
		if( parent.owner.GetActor() == thePlayer && parent.owner.GetPlayer().IsInCombat() ) //W3EE
		{
			caster.GetActor().PlayEffect( 'quen_lasting_shield_hit' ); //W3EE
			GetWitcherPlayer().OnBasicQuenFinishing();			
		}
	}
	
	event OnEnded(optional isEnd : bool)
	{
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );
	}
	
	event OnTargetHit( out damageData : W3DamageAction )
	{
		var pos : Vector;
		var reducedDamage, drainedHealth, skillBonus, incomingDamage, directDamage : float;
		var spellPower : SAbilityAttributeValue;
		var physX : CEntity;
		var inAttackAction : W3Action_Attack;
		var action : W3DamageAction;
		var casterActor : CActor;
		var effectTypes : array < EEffectType >;
		var damageTypes : array<SRawDamage>;
		var i : int;
		var isBleeding : bool;
		
		var min, max : SAbilityAttributeValue; 
		var wardingLevel : int; //W3EE
		var staggerParams : SCustomEffectParams; //W3EE
		var shieldDamage, originalShieldDamage, damageDifference, reflectedDamage : float; //W3EE
		
		if( damageData.WasDodged() ||
			(W3Effect_Toxicity)damageData.causer || //W3EE
			damageData.GetHitReactionType() == EHRT_Reflect )
		{
			return true;
		}
		
		parent.OnTargetHit(damageData);
		
		
		
			
		
		
			
		
		inAttackAction = (W3Action_Attack)damageData;
		if(inAttackAction && inAttackAction.CanBeParried() && (inAttackAction.IsParried() || inAttackAction.IsCountered()) )
			return true;
		
		casterActor = caster.GetActor();
		reducedDamage = 0;		
				
		
		damageData.GetDTs(damageTypes);
		for(i=0; i<damageTypes.Size(); i+=1)
		{
			if(damageTypes[i].dmgType == theGame.params.DAMAGE_NAME_DIRECT)
			{
				directDamage = damageTypes[i].dmgVal;
				break;
			}
		}
		
		
		if( (W3Effect_Bleeding)damageData.causer )
		{
			incomingDamage = directDamage;
			isBleeding = true;
		}
		else
		{	
			isBleeding = false;
			incomingDamage = MaxF(0, damageData.GetDamageDealt() - directDamage);
		}
		
		//W3EE - Begin
		damageDifference = damageData.GetOriginalDamageDealt() / damageData.GetOriginalDamageDealtWithArmor();
		shieldDamage = damageData.GetOriginalDamageDealt() * 0.2f * damageData.GetDamageDealt() / damageData.GetOriginalDamageDealtWithArmor() / parent.GetTotalSignIntensityFloat();
		originalShieldDamage = shieldDamage;
		if( incomingDamage > parent.shieldHealth / damageDifference )
			reducedDamage = parent.shieldHealth / damageDifference;
		else
			reducedDamage = incomingDamage;
		
		wardingLevel = caster.GetPlayer().GetSkillLevel(S_Magic_s15);
		if( parent.GetReflectWindow() )
		{
			caster.GetPlayer().GetAdrenalineEffect().AddAdrenalineWithMult(shieldDamage * 0.01f);
			shieldDamage *= 0.5f - 0.05f * wardingLevel;
			damageData.SetHitAnimationPlayType( EAHA_ForceNo );	
			reducedDamage = incomingDamage;
		}
		
		if( caster.GetPlayer().HasAbility('Glyphword 22 _Stats', true) || caster.GetPlayer().HasAbility('Glyphword 23 _Stats', true) || caster.GetPlayer().HasAbility('Glyphword 24 _Stats', true) )
			shieldDamage *= 0.5f;
		//W3EE - End
		
		if(!damageData.IsDoTDamage())
		{
			casterActor.PlayEffect( 'quen_lasting_shield_hit' );	
			
			GCameraShake( parent.effects[parent.fireMode].cameraShakeStranth, true, parent.GetWorldPosition(), 30.0f );
		}
		
		
		if ( theGame.CanLog() )
		{
			LogDMHits("Quen ShieldActive.OnTargetHit: reducing damage from " + damageData.processedDmg.vitalityDamage + " to " + (damageData.processedDmg.vitalityDamage - reducedDamage), action );
		}
		
		//damageData.SetHitAnimationPlayType( EAHA_ForceNo ); //W3EE
		damageData.SetCanPlayHitParticle( false );
		
		if(reducedDamage > 0)
		{
			
			//W3EE - Begin
			/*
			if ( parent.wasSignSupercharged )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'magic_s15', 'spell_power', min, max);
				skillBonus = CalculateAttributeValue( min ) * 3;
				skillBonus += CalculateAttributeValue( caster.GetSkillAttributeValue( S_Sword_s19, 'spell_power', false, true ) ) * thePlayer.GetSkillLevel( S_Sword_s19 );
			}
			else if ( caster.CanUseSkill( S_Magic_s15 ) )
				skillBonus = CalculateAttributeValue( caster.GetSkillAttributeValue( S_Magic_s15, 'bonus', false, true ) );
			else
				skillBonus = 0;
			
				
			drainedHealth = reducedDamage / (skillBonus + spellPower.valueMultiplicative);			
			parent.shieldHealth -= drainedHealth;
			
				
			damageData.processedDmg.vitalityDamage -= reducedDamage;
			
			
			if( damageData.processedDmg.vitalityDamage >= 20 )
				casterActor.RaiseForceEvent( 'StrongHitTest' );
				
			*/
			
			parent.shieldHealth -= shieldDamage;
				
			if( caster.CanUseSkill(S_Magic_s13, parent) && originalShieldDamage > (parent.GetInitialShieldHealth() * (0.7f - 0.1f * caster.GetSkillLevel(S_Magic_s13, parent))) )
				caster.GetPlayer().QuenImpulse( false, parent, "quen_impulse" );
			
			damageData.ClearEffects();
			damageData.processedDmg.vitalityDamage = incomingDamage - reducedDamage;
			
			if( damageData.processedDmg.vitalityDamage >= 20 )
				casterActor.RaiseForceEvent( 'StrongHitTest' );
			
			parent.dischargePercent = 0.15f + 0.03f * caster.GetSkillLevel(S_Magic_s13, parent) * parent.GetTotalSignIntensityFloat();
			parent.dischargePercent += CalculateAttributeValue(((W3PlayerWitcher)caster.GetPlayer()).GetAttributeValue('quen_reflect_bonus'));
			
			if( damageData.attacker.HasTag('WeakToQuen') )
			{
				staggerParams.creator = casterActor;
				staggerParams.isSignEffect = true;
				staggerParams.sourceName = "quen";
				staggerParams.effectType = EET_Stagger;
				((CActor)damageData.attacker).AddEffectCustom(staggerParams);
				parent.dischargePercent *= 1.5f;
			}
			
			if( parent.GetReflectWindow() )
			{
				caster.GetPlayer().QuenImpulse( false, parent, "quen_impulse" );
				caster.GetActor().PlayEffect('quen_force_discharge');
				
				staggerParams.creator = casterActor;
				staggerParams.isSignEffect = true;
				staggerParams.sourceName = "quen";
				staggerParams.effectType = EET_LongStagger;
				((CActor)damageData.attacker).AddEffectCustom(staggerParams);
				
				if( caster.GetPlayer().IsSetBonusActive(EISB_Bear_1) )
					((W3Effect_NPCPoise)((CActor)damageData.attacker).GetBuff(EET_NPCPoise)).ReducePoise(20 + 2 * caster.GetPlayer().GetSetPartsEquipped(EIST_Bear), 4, caster.GetPlayer());
				else
					((W3Effect_NPCPoise)((CActor)damageData.attacker).GetBuff(EET_NPCPoise)).ReducePoise(20, 4, caster.GetPlayer());
				
				parent.dischargePercent *= 1.5f;
				
				if( caster.GetPlayer().HasAbility('Glyphword 21 _Stats', true) )
				{
					caster.GetPlayer().QuenImpulse( false, parent, "21", VecHeading(damageData.attacker.GetWorldPosition() - casterActor.GetWorldPosition()) );
					parent.PlayHitEffect('quen_rebound_sphere_bear_abl2', VecToRotation(damageData.attacker.GetWorldPosition() - casterActor.GetWorldPosition()));
				}
			}
			
			reflectedDamage = incomingDamage;
			//W3EE - End
			if ( reflectedDamage > 0 && !damageData.IsDoTDamage() && casterActor == thePlayer && damageData.attacker != casterActor && parent.dischargePercent > 0 && !damageData.IsActionRanged() && VecDistanceSquared( casterActor.GetWorldPosition(), damageData.attacker.GetWorldPosition() ) <= 13 ) //W3EE
			{
				action = new W3DamageAction in theGame.damageMgr;
				action.Initialize( casterActor, damageData.attacker, parent, 'quen', EHRT_Light, CPS_SpellPower, false, false, true, false, 'hit_shock' );
				parent.InitSignDataForDamageAction( action );		
				action.AddDamage( theGame.params.DAMAGE_NAME_SHOCK, parent.dischargePercent * reflectedDamage ); //W3EE
				action.SetCanPlayHitParticle(true);
				action.SetHitEffect('hit_electric_quen');
				action.SetHitEffect('hit_electric_quen', true);
				action.SetHitEffect('hit_electric_quen', false, true);
				action.SetHitEffect('hit_electric_quen', true, true);
				
				//W3EE - Begin
				if( caster.GetPlayer().HasAbility('Glyphword 20 _Stats', true) || caster.GetPlayer().HasAbility('Glyphword 21 _Stats', true) )
				{
					((CActor)damageData.attacker).AddEffectDefault(EET_Electroshock, caster.GetActor(), "Glyphword 20");
					action.SetForceExplosionDismemberment();
					physX = ((CActor)damageData.attacker).CreateFXEntityAtPelvis('mutation1_hit', true);
					physX.PlayEffect('mutation_1_hit_quen');
				}
				//W3EE - End
				theGame.damageMgr.ProcessAction( action );		
				delete action;
				
				
				//casterActor.PlayEffect('quen_force_discharge'); //W3EE
			}
		}
		UpdateQuenShieldFx(); //W3EE
		
		if(reflectedDamage >= incomingDamage && reflectedDamage > 0 && (!damageData.DealsAnyDamage() || (isBleeding && reflectedDamage >= directDamage)) ) //W3EE
			parent.SetBlockedAllDamage(true);
		else
			parent.SetBlockedAllDamage(false);
		
		if( parent.shieldHealth <= 0 )
		{
			
			//W3EE - Begin
			/*
			if ( parent.owner.CanUseSkill(S_Magic_s13) || parent.wasSignSupercharged )
			{				
				casterActor.PlayEffect( 'lasting_shield_impulse' );
				if ( parent.wasSignSupercharged )
					caster.GetPlayer().QuenImpulse( false, parent, "quen_impulse", 3 );
				else
					caster.GetPlayer().QuenImpulse( false, parent, "quen_impulse" );
			}
			*/
			caster.GetPlayer().QuenImpulse( false, parent, "quen_impulse" );
			//W3EE - End
			damageData.SetEndsQuen(true);
		}
	}
}


state QuenShield in W3QuenEntity extends NormalCast
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		caster.OnDelayOrientationChange();
		
		caster.GetActor().OnSignCastPerformed(ST_Quen, false);
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
		{
			parent.CleanUp();	
			//W3EE - Begin
			if( caster.GetPlayer() )
				Experience().AwardSignXP(parent.GetSignType());
			//W3EE - End
			parent.GotoState( 'ShieldActive' );
		}
	}
	
	event OnSignAborted( optional force : bool )
	{
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );
		parent.GotoState( 'Expired' );
	}
}

state QuenChanneled in W3QuenEntity extends Channeling
{
	private const var HEALING_FACTOR : float;		
	private const var STAMINA_FACTOR : float; //W3EE
	
		default HEALING_FACTOR = 0.5f; //W3EE - Vanilla Value 0.2
		default STAMINA_FACTOR = 0.002f; //W3EE

	event OnEnterState( prevStateName : name )
	{
		var casterActor : CActor;
		var witcher : W3PlayerWitcher;
		
		super.OnEnterState( prevStateName );
	
		casterActor = caster.GetActor();
		witcher = (W3PlayerWitcher)casterActor;
		
		if(witcher)
			witcher.SetUsedQuenInCombat();
							
		caster.OnDelayOrientationChange();
		
		parent.GetSignStats();
		
		//W3EE - Begin
		if( witcher && (witcher.HasAbility('Glyphword 23 _Stats', true) || witcher.HasAbility('Glyphword 24 _Stats', true)) )
			witcher.PlayEffect( 'runeword_8' );
		//W3EE - End
		
		casterActor.GetMovingAgentComponent().SetVirtualRadius( 'QuenBubble' );
			
		parent.AddBuffImmunities(true); //W3EE
		
		
		witcher.CriticalEffectAnimationInterrupted("quen channeled");
		
		casterActor.OnSignCastPerformed(ST_Quen, true);
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
		{
			ChannelQuen();
		}
	}
	
	private var HAXXOR_LeavingState : bool;
	event OnLeaveState( nextStateName : name )
	{
		HAXXOR_LeavingState = true;
		OnEnded(true);
		super.OnLeaveState(nextStateName);
		parent.DestroyQuen(); //W3EE
	}
	
	
	
	event OnEnded(optional isEnd : bool)
	{
		var casterActor : CActor;
		
		if(!HAXXOR_LeavingState)
			super.OnEnded();
			
		casterActor = caster.GetActor();
		casterActor.GetMovingAgentComponent().ResetVirtualRadius();
		casterActor.StopEffect('quen_shield');		
		casterActor.StopEffect( 'quen_lasting_shield_bear_abl2' );
		
		parent.RemoveBuffImmunities(true); //W3EE
		
		parent.StopAllEffects();
		
		//W3EE - Begin
		if( caster.GetPlayer() && (caster.GetPlayer().HasAbility('Glyphword 23 _Stats', true) || caster.GetPlayer().HasAbility('Glyphword 24 _Stats', true)) )
			caster.GetPlayer().StopEffect( 'runeword_8' );
		//W3EE - End
		
		parent.RemoveHitDoTEntities();
		
		//W3EE - Begin
		/*
		if ( isEnd )
		{
			if ( parent.wasSignSupercharged )
				caster.GetPlayer().QuenImpulse( true, parent, "quen_impulse", 3 );
			else if ( caster.CanUseSkill(S_Magic_s13))
				caster.GetPlayer().QuenImpulse( true, parent, "quen_impulse" );
		}
		*/
		//W3EE - End
		Experience().AwardSignXP(parent.GetSignType(), timeStamp - startTime); //W3EE
	}
	
	event OnSignAborted( optional force : bool )
	{
		OnEnded();
	}
	
	private var timeStamp : float;	default timeStamp = 0; //W3EE
	private var startTime: float;	default startTime = 0; //W3EE
	private var DT : float; default DT = 0.006f; //W3EE
	entry function ChannelQuen()
	{
		//W3EE - Begin
		timeStamp = theGame.GetEngineTimeAsSeconds();
		startTime = theGame.GetEngineTimeAsSeconds();
		while( UpdateDrain(DT) )
		{
			ProcessQuenCollisionForRiders();
			Sleep(DT);
			DT = MaxF(theGame.GetEngineTimeAsSeconds() - timeStamp, 0.002f);
			timeStamp = theGame.GetEngineTimeAsSeconds();
		}
		//W3EE - End
	}
	
	private function ProcessQuenCollisionForRiders()
	{
		var mac	: CMovingPhysicalAgentComponent;
		var collisionData 						: SCollisionData;
		var collisionNum 						: int;
		var i 									: int;
		var npc									: CNewNPC;
		var riderActor 							: CActor;
		var collidedWithRider 					: bool;
		var horseComp 							: W3HorseComponent;
		var riderToPlayerHeading, riderHeading 	: float;
		var angleDist 							: float;
		
		mac	= (CMovingPhysicalAgentComponent)thePlayer.GetMovingAgentComponent();
		if( !mac )
		{
			return;
		}
		
		collisionNum = mac.GetCollisionCharacterDataCount();
		for( i = 0; i < collisionNum; i += 1 )
		{
			collisionData = mac.GetCollisionCharacterData( i );
			npc	= (CNewNPC)collisionData.entity;
			if( npc )
			{
				if( npc.IsUsingHorse() )
				{
					collidedWithRider = true;
					horseComp = npc.GetUsedHorseComponent();
				}
				else
				{
					horseComp = npc.GetHorseComponent();
					if( horseComp.user )
						collidedWithRider = true;
				}
				

			}
			
			if( collidedWithRider )
			{
				riderActor = horseComp.user;
				
				if( IsRequiredAttitudeBetween( riderActor, thePlayer, true ) )
				{
					riderToPlayerHeading = VecHeading( thePlayer.GetWorldPosition() - riderActor.GetWorldPosition() );
					riderHeading = riderActor.GetHeading();
					angleDist = AngleDistance( riderToPlayerHeading, riderHeading );
					
					if( AbsF( angleDist ) < 45.0 )
					{
						horseComp.ReactToQuen();
					}
				}
			}
		}
	}
	
	public function ShowHitFX(damageData : W3DamageAction, rot : EulerAngles)
	{
		var movingAgent : CMovingPhysicalAgentComponent;
		var inWater, hasFireDamage, hasElectricDamage, hasPoisonDamage, isDoT, isBirds : bool;
		var witcher	: W3PlayerWitcher;
		
		isBirds = (CFlyingCrittersLairEntityScript)damageData.causer;
		witcher = parent.owner.GetPlayer();
		
		if (isBirds)
		{
			
			parent.PlayHitEffect('quen_rebound_sphere_constant', rot, true);
			parent.AddTimer('RemoveDoTFX', 0.3, false, , , , true);
		}
		else
		{			
			isDoT = damageData.IsDoTDamage();
		
			if(!isDoT)
			{
				hasFireDamage = damageData.GetDamageValue(theGame.params.DAMAGE_NAME_FIRE) > 0;
				hasPoisonDamage = damageData.GetDamageValue(theGame.params.DAMAGE_NAME_POISON) > 0;		
				hasElectricDamage = damageData.GetDamageValue(theGame.params.DAMAGE_NAME_SHOCK) > 0;
		
				//W3EE - Begin
				/*
				if( witcher && ( witcher.CanUseSkill( S_Magic_s13 ) || parent.wasSignSupercharged ) && witcher.IsSetBonusActive( EISB_Bear_2 ) )
				
				{
					parent.PlayHitEffect( 'quen_rebound_sphere_bear_abl2', rot );
				}
				else
				*/
				//W3EE - End
				if (hasFireDamage)
				{
					parent.PlayHitEffect( 'quen_rebound_sphere_fire', rot );
				}
				else if (hasPoisonDamage)
				{
					parent.PlayHitEffect( 'quen_rebound_sphere_poison', rot );
				}
				else if (hasElectricDamage)
				{
					parent.PlayHitEffect( 'quen_rebound_sphere_electricity', rot );
				}
				else
				{
					parent.PlayHitEffect( 'quen_rebound_sphere', rot );
				}
			}
		}
		
		
		movingAgent = (CMovingPhysicalAgentComponent)caster.GetActor().GetMovingAgentComponent();
		inWater = movingAgent.GetSubmergeDepth() < 0;
		if(!inWater)
		{
			parent.PlayHitEffect( 'quen_rebound_ground', rot );
		}
	}
		
	event OnTargetHit( out damageData : W3DamageAction )
	{
		var reducedDamage, skillBonus, drainedStamina, reducibleDamage, directDamage, shieldFactor : float;		
		var spellPower : SAbilityAttributeValue;
		var drainAllStamina, isBleeding : bool;
		var casterActor : CActor;
		var attackerVictimEuler : EulerAngles;
		var action : W3DamageAction;		
		var shieldHP : float;
		
		var min, max : SAbilityAttributeValue; 
		var drainAllVigor : bool; //W3EE
		var player : W3PlayerWitcher; //W3EE
		var staggerParams : SCustomEffectParams; //W3EE
		var sp, drainedVigor, shieldDamage, returnDamage, incomingDamage, innerStrengthVal : float; //W3EE
		var fx : CEntity; //W3EE
		var wardingLevel : int; //W3EE
		
		parent.OnTargetHit(damageData);
		
		casterActor = caster.GetActor();
		//directDamage = damageData.GetDamageValue(theGame.params.DAMAGE_NAME_DIRECT); //W3EE
		
		
		
		if( !( (CBaseGameplayEffect) damageData.causer ) )
		{
			attackerVictimEuler = VecToRotation(damageData.attacker.GetWorldPosition() - casterActor.GetWorldPosition());
			attackerVictimEuler.Pitch = 0;
			attackerVictimEuler.Roll = 0;
			
			ShowHitFX(damageData, attackerVictimEuler);
		}
	
		
		if( damageData.processedDmg.vitalityDamage >= 20 )
			casterActor.RaiseForceEvent( 'StrongHitTest' );
		
		
		spellPower = parent.GetTotalSignIntensity();
		sp = spellPower.valueMultiplicative; //W3EE
		player = caster.GetPlayer(); //W3EE
		
		//W3EE - Begin
		/*
		if( (W3Effect_Bleeding)damageData.causer )
		{
			isBleeding = true;
			reducibleDamage = directDamage;
		}
		else
		{
			isBleeding = false;
			reducibleDamage = MaxF(0, damageData.processedDmg.vitalityDamage - directDamage);
		}
		
		shieldFactor = CalculateAttributeValue( caster.GetSkillAttributeValue( S_Magic_s04, 'shield_health_factor', false, true ) );
		
		if(reducibleDamage > 0)
		{
			if( casterActor.HasBuff( EET_Mutation11Buff ) )
			{
				shieldHP = 1000000;
				reducedDamage = reducibleDamage;
			}
			else
			{
				shieldHP = casterActor.GetStat( BCS_Stamina ) * shieldFactor * (skillBonus + spellPower.valueMultiplicative);
				reducedDamage = MinF( reducibleDamage, casterActor.GetStat( BCS_Stamina ) * shieldFactor * (skillBonus + spellPower.valueMultiplicative) );
			}
			
			if(reducedDamage < reducibleDamage)
			{
				drainAllStamina = true;
			}
		}
		else
		{
			reducedDamage = 0;
		}
		
		
		if(drainAllStamina)
			reducedDamage = damageData.processedDmg.vitalityDamage;
		

		
		if ( reducedDamage > 0 || (!damageData.DealsAnyDamage() || (isBleeding && reducedDamage >= reducibleDamage)) )
		{
			if ( theGame.CanLog() )
			{		
				LogDMHits("Quen QuenChanneled.OnTargetHit: reducing damage from " + damageData.processedDmg.vitalityDamage + " to " + (damageData.processedDmg.vitalityDamage - reducedDamage), damageData );
			}
			
			if(!damageData.IsDoTDamage())
				GCameraShake( parent.effects[parent.fireMode].cameraShakeStranth, true, parent.GetWorldPosition(), 30.0f );
			
			damageData.SetHitAnimationPlayType( EAHA_ForceNo );			
			damageData.processedDmg.vitalityDamage -= reducedDamage;
			damageData.SetCanPlayHitParticle(false);
						
			
			
			
			if( casterActor == thePlayer && parent.dischargePercent > 0 && !damageData.IsActionRanged() && IsRequiredAttitudeBetween( thePlayer, damageData.attacker, true) && ( GetWitcherPlayer().CanUseSkill(S_Magic_s13) || parent.wasSignSupercharged ) && VecDistanceSquared( casterActor.GetWorldPosition(), damageData.attacker.GetWorldPosition() ) <= 13 ) 
			
			{
				action = new W3DamageAction in theGame.damageMgr;
				action.Initialize( casterActor, damageData.attacker, parent, 'quen', EHRT_Light, CPS_SpellPower, false, false, true, false, 'hit_shock' );
				parent.InitSignDataForDamageAction( action );		
				action.AddDamage( theGame.params.DAMAGE_NAME_SHOCK, parent.dischargePercent * reducibleDamage );
				action.SetCanPlayHitParticle(true);
				action.SetHitEffect('hit_electric_quen');
				action.SetHitEffect('hit_electric_quen', true);
				action.SetHitEffect('hit_electric_quen', false, true);
				action.SetHitEffect('hit_electric_quen', true, true);
				
				theGame.damageMgr.ProcessAction( action );		
				delete action;
				
				
				parent.PlayHitEffect('discharge', attackerVictimEuler);				
			}
		}		
		parent.SetBlockedAllDamage( !damageData.DealsAnyDamage() );
		
		
		if(!drainAllStamina)
		{
			drainedStamina = reducedDamage / ((skillBonus + spellPower.valueMultiplicative) * shieldFactor);		
			casterActor.DrainStamina( ESAT_FixedValue, drainedStamina, 1 );
		}
		else
		{
			casterActor.DrainStamina( ESAT_FixedValue, casterActor.GetStat(BCS_Stamina), 2 );
		}
		
		
		
		
		if(drainAllStamina)
			caster.GetActor().Heal(reducedDamage / 2 * HEALING_FACTOR * spellPower.valueMultiplicative);
		else
			caster.GetActor().Heal(reducedDamage * HEALING_FACTOR * spellPower.valueMultiplicative);
		
		
		
		if( casterActor.GetStat( BCS_Stamina ) <= 0 && !casterActor.HasBuff( EET_Mutation11Buff ) )
		{
			
			
			
			if ( parent.owner.CanUseSkill(S_Magic_s13) || parent.wasSignSupercharged )
			{				
				parent.PlayHitEffect( 'quen_rebound_sphere_impulse', attackerVictimEuler );
				if ( parent.wasSignSupercharged )
					caster.GetPlayer().QuenImpulse( true, parent, "quen_impulse", 3 );
				else
					caster.GetPlayer().QuenImpulse( true, parent, "quen_impulse" );
			}
			
			
			damageData.SetEndsQuen(true);		
		}
		*/
		
		parent.dischargePercent = 0.15f + 0.03f * caster.GetSkillLevel(S_Magic_s14, parent) * sp;
		parent.dischargePercent += CalculateAttributeValue(player.GetAttributeValue('quen_reflect_bonus'));
		
		wardingLevel = caster.GetPlayer().GetSkillLevel(S_Magic_s15);
		if( damageData.attacker.HasTag('WeakToQuen') )
		{
			staggerParams.creator = casterActor;
			staggerParams.isSignEffect = true;
			staggerParams.sourceName = "quen";
			staggerParams.effectType = EET_Stagger;
			((CActor)damageData.attacker).AddEffectCustom(staggerParams);
			parent.dischargePercent *= 1.5f;
		}
		
		if( timeStamp - startTime <= 0.3f )
		{
			parent.PlayHitEffect( 'quen_rebound_sphere_impulse', attackerVictimEuler );
			
			fx = ((CActor)damageData.attacker).CreateFXEntityAtPelvis('mutation2_critical', true);
			fx.PlayEffect('critical_quen');
			fx = ((CActor)damageData.attacker).CreateFXEntityAtPelvis('mutation1_hit', true);
			fx.PlayEffect('mutation_1_hit_quen');
			
			staggerParams.creator = casterActor;
			staggerParams.isSignEffect = true;
			staggerParams.sourceName = "quen";
			staggerParams.effectType = EET_LongStagger;
			((CActor)damageData.attacker).AddEffectCustom(staggerParams);
			
			if( caster.GetPlayer().IsSetBonusActive(EISB_Bear_1) )
				((W3Effect_NPCPoise)((CActor)damageData.attacker).GetBuff(EET_NPCPoise)).ReducePoise(20 + 2 * caster.GetPlayer().GetSetPartsEquipped(EIST_Bear), 4, caster.GetPlayer());
			else
				((W3Effect_NPCPoise)((CActor)damageData.attacker).GetBuff(EET_NPCPoise)).ReducePoise(20, 4, caster.GetPlayer());
			
			parent.dischargePercent *= 1.5f;
			
			if( caster.GetPlayer().HasAbility('Glyphword 21 _Stats', true) )
			{
				caster.GetPlayer().QuenImpulse( false, parent, "21", VecHeading(damageData.attacker.GetWorldPosition() - casterActor.GetWorldPosition()) );
				parent.EraseFirstTimeStamp();
				parent.PlayHitEffect('quen_rebound_sphere_bear_abl2', attackerVictimEuler);
			}
		}
		
		if( casterActor.HasBuff( EET_Mutation11Buff ) )
		{
			parent.shieldHealth = 1000000;
			parent.dischargePercent = 0.f;
		}
		else
		{
			if( player )
				parent.shieldHealth = (1500.f + (300.f * caster.GetSkillLevel(S_Magic_s04, parent))) * sp;
			else
				parent.shieldHealth = 100000.f;
		}
		
		incomingDamage = damageData.GetOriginalDamageDealt();
		shieldDamage = incomingDamage * 0.2f;
		
		if( shieldDamage >= parent.shieldHealth / 3.f * (0.7f - 0.1f * caster.GetSkillLevel(S_Magic_s13, parent)) )
		{
			parent.PlayHitEffect( 'quen_rebound_sphere_impulse', attackerVictimEuler );
			caster.GetPlayer().QuenImpulse( true, parent, "quen_impulse" );
		}
		
		if( timeStamp - startTime <= 0.3f )
		{
			player.GetAdrenalineEffect().AddAdrenalineWithMult(shieldDamage * 0.01f);
			shieldDamage *= 0.5f - 0.05f * wardingLevel;
			if( caster.GetPlayer() )
				Experience().AwardSignXP(parent.GetSignType(), 2.5f);
		}
		else if( caster.GetPlayer() )
			Experience().AwardSignXP(parent.GetSignType(), 1.25f);
		
		if( caster.GetPlayer().HasAbility('Glyphword 22 _Stats', true) || caster.GetPlayer().HasAbility('Glyphword 23 _Stats', true) || caster.GetPlayer().HasAbility('Glyphword 24 _Stats', true) )
			shieldDamage *= 0.5f;		
		
		if( shieldDamage >= parent.shieldHealth )
		{
			drainAllVigor = true;
			drainedVigor = Options().MaxFocus() * (shieldDamage / parent.shieldHealth);
		}
		else
			drainedVigor = Options().MaxFocus() * (shieldDamage / parent.shieldHealth);
			
		if( !damageData.IsDoTDamage() )
			GCameraShake( parent.effects[parent.fireMode].cameraShakeStranth, true, parent.GetWorldPosition(), 30.0f );
			
		damageData.processedDmg.vitalityDamage = 0;
		if( !drainAllVigor )
		{
			damageData.SetHitAnimationPlayType(EAHA_ForceNo);
			damageData.SetCanPlayHitParticle(false);
			damageData.ClearEffects();
		}
		returnDamage = incomingDamage;
		if( casterActor == thePlayer && parent.dischargePercent > 0 && !damageData.IsActionRanged() && IsRequiredAttitudeBetween( thePlayer, damageData.attacker, true) && VecDistanceSquared( casterActor.GetWorldPosition(), damageData.attacker.GetWorldPosition() ) <= 13 ) 
		{
			action = new W3DamageAction in theGame.damageMgr;
			action.Initialize( casterActor, damageData.attacker, parent, 'quen', EHRT_Light, CPS_SpellPower, false, false, true, false, 'hit_shock' );
			parent.InitSignDataForDamageAction( action );		
			action.AddDamage( theGame.params.DAMAGE_NAME_SHOCK, parent.dischargePercent * returnDamage );
			action.SetCanPlayHitParticle(true);
			action.SetHitEffect('hit_electric_quen');
			action.SetHitEffect('hit_electric_quen', true);
			action.SetHitEffect('hit_electric_quen', false, true);
			action.SetHitEffect('hit_electric_quen', true, true);
			GCameraShake(parent.dischargePercent);
						
			if( caster.GetPlayer().HasAbility('Glyphword 20 _Stats', true) || caster.GetPlayer().HasAbility('Glyphword 21 _Stats', true) )
			{
				((CActor)damageData.attacker).AddEffectDefault(EET_Electroshock, caster.GetActor(), "Glyphword 20");
				action.SetForceExplosionDismemberment();
				fx = ((CActor)damageData.attacker).CreateFXEntityAtPelvis('mutation1_hit', true);
				fx.PlayEffect('mutation_1_hit_quen');
			}
			
			theGame.damageMgr.ProcessAction( action );
			delete action;
			
			parent.PlayHitEffect('discharge', attackerVictimEuler);
		}
		
		parent.SetBlockedAllDamage(true);
		if( !drainAllVigor )
		{
			if( player )
			{
				if( player.GetStat(BCS_Focus) > drainedVigor )
				{
					player.GainStat(BCS_Stamina, incomingDamage * (1.f + 0.2f * caster.GetSkillLevel(S_Magic_s04, parent)) * STAMINA_FACTOR * sp * Options().StamCostGlobal());
				}
				else if( player.GetStat(BCS_Focus) < drainedVigor )
				{
					player.GainStat(BCS_Stamina, incomingDamage * (1.f + 0.2f * caster.GetSkillLevel(S_Magic_s04, parent)) * STAMINA_FACTOR * sp * Options().StamCostGlobal() * player.GetStat(BCS_Focus) / drainedVigor);
					player.StartCustomVigorTimer(3.f + drainedVigor - player.GetStat(BCS_Focus));
					if( caster.GetSkillLevel(S_Perk_09) > 0 )
					{
						innerStrengthVal = (drainedVigor - player.GetStat(BCS_Focus)) * 35;
						if( player.GetStat(BCS_Stamina) >= innerStrengthVal * Options().StamCostGlobal() )
							player.DrainStamina(ESAT_FixedValue, innerStrengthVal / Options().StamCostGlobal());
						else
						{
							player.AddTimer('StunPlayer', 0.3f, false);
							player.DrainStamina(ESAT_FixedValue, player.GetStat(BCS_Stamina) / Options().StamCostGlobal());
						}
					}
					else
						player.AddTimer('StunPlayer', 0.3f, false);
				}
				
				player.DrainFocus(MinF(drainedVigor, player.GetStat(BCS_Focus)));
			}
			else
			{
				drainedVigor = casterActor.GetStatMax(BCS_Stamina) * (parent.shieldHealth / shieldDamage);
				casterActor.DrainStamina(ESAT_FixedValue, drainedVigor, 1);
			}
		}
		else
		{
			if( player )
			{
				player.GainStat(BCS_Stamina, incomingDamage * (1.f + 0.2f * caster.GetSkillLevel(S_Magic_s04, parent)) * STAMINA_FACTOR * sp * Options().StamCostGlobal() * player.GetStat(BCS_Focus) / drainedVigor);
				if( caster.GetSkillLevel(S_Perk_09) > 0 )
				{
					innerStrengthVal = (drainedVigor - player.GetStat(BCS_Focus)) * 35;
					if( player.GetStat(BCS_Stamina) >= innerStrengthVal * Options().StamCostGlobal() )
						player.DrainStamina(ESAT_FixedValue, innerStrengthVal / Options().StamCostGlobal());
					else
					{
						player.AddTimer('StunPlayer', 0.3f, false);
						player.DrainStamina(ESAT_FixedValue, player.GetStat(BCS_Stamina) / Options().StamCostGlobal());
					}
				}
				else
				{
					player.AddTimer('StunPlayer', 0.3f, false);
					player.DrainFocus(player.GetStatMax(BCS_Focus));
					player.StartCustomVigorTimer(player.GetStatMax(BCS_Focus) * 2.f);
				}
			}
			else
			{
				casterActor.AddEffectDefault(EET_LongStagger, damageData.attacker, "QuenBroken");
				casterActor.DrainStamina(ESAT_FixedValue, casterActor.GetStat(BCS_Stamina), 4);
			}
		}
		
		if( ( caster.GetPlayer() && caster.GetPlayer().GetStat(BCS_Focus) <= 0 ) || ( !caster.GetPlayer() && casterActor.GetStat( BCS_Stamina ) <= 0 ) && !casterActor.HasBuff( EET_Mutation11Buff ) )
		{
			if ( caster.CanUseSkill(S_Magic_s13, (W3SignEntity)parent) )
			{
				parent.PlayHitEffect( 'quen_rebound_sphere_impulse', attackerVictimEuler );
				caster.GetPlayer().QuenImpulse( true, parent, "quen_impulse" );
			}
			
			damageData.SetEndsQuen(true);
		}
		//W3EE - End
	}
}