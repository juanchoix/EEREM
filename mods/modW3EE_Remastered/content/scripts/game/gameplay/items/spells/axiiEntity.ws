/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SAxiiEffects
{
	editable var castEffect		: name;
	editable var throwEffect	: name;
}

statemachine class W3AxiiEntity extends W3SignEntity
{
	editable var effects		: array< SAxiiEffects >;	
	editable var projTemplate	: CEntityTemplate;
	editable var distance		: float;	
	editable var projSpeed		: float;
	
	default skillEnum = S_Magic_5;
	
	protected var targets		: array<CActor>;
	protected var orientationTarget : CActor;
	
	public function GetSignType() : ESignType
	{
		return ST_Axii;
	}
	
	function Init( inOwner : W3SignOwner, prevInstance : W3SignEntity, optional skipCastingAnimation : bool, optional notPlayerCast : bool, optional isFreeCast : bool ) : bool //W3EE
	{	
		var ownerActor : CActor;
		var prevSign : W3SignEntity;
		
		ownerActor = inOwner.GetActor();
		
		CacheSignStats(inOwner); //W3EE
		
		if( (CPlayer)ownerActor )
		{
			prevSign = GetWitcherPlayer().GetSignEntity(ST_Axii);
			if(prevSign)
				prevSign.OnSignAborted(true);
		}
		
		ownerActor.SetBehaviorVariable( 'bStopSign', 0.f );
		//if ( inOwner.CanUseSkill(S_Magic_s17) && inOwner.GetSkillLevel(S_Magic_s17) > 1) //W3EE
			ownerActor.SetBehaviorVariable( 'bSignUpgrade', 1.f );
		//else //W3EE
			//ownerActor.SetBehaviorVariable( 'bSignUpgrade', 0.f ); //W3EE
		
		return super.Init( inOwner, prevInstance, skipCastingAnimation, notPlayerCast, isFreeCast ); //W3EE
	}
		
	event OnProcessSignEvent( eventName : name )
	{
		if ( eventName == 'axii_ready' )
		{
			PlayEffect( effects[fireMode].throwEffect );
		}
		else if ( eventName == 'horse_cast_begin' )
		{
			OnHorseStarted();
		}
		else
		{
			return super.OnProcessSignEvent( eventName );
		}
		
		return true;
	}
	
	event OnStarted()
	{
		var player : CR4Player;
		var i : int;
		
		SelectTargets();
		//W3EE - Begin
		if( !super.IsAlternateCast() )
			Combat().CacheAxiiLinkActors(targets);
		//W3EE - End
		
		for(i=0; i<targets.Size(); i+=1)
		{
			AddMagic17Effect(targets[i]);
		}
		
		Attach(true);
		
		player = (CR4Player)owner.GetActor();
		if(player)
		{
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
			player.AddTimer('ResetPadBacklightColorTimer', 2);
		}
			
		PlayEffect( effects[fireMode].castEffect );
		
		if ( owner.ChangeAspect( this, S_Magic_s05 ) /*|| owner.ChangeAspect( this, S_Magic_s31 )*/ ) //W3EE
		{
			CacheActionBuffsFromSkill();
			GotoState( 'AxiiChanneled' );
		}
		else
		{
			GotoState( 'AxiiCast' );
		}		
	}
	
	
	function OnHorseStarted()
	{
		Attach(true);
		PlayEffect( effects[fireMode].castEffect );
	}
	
	
	private final function IsTargetValid(actor : CActor, isAdditionalTarget : bool) : bool
	{
		var npc : CNewNPC;
		var horse : W3HorseComponent;
		var attitude : EAIAttitude;
		
		if(!actor)
			return false;
			
		if(!actor.IsAlive())
			return false;
		
				
		attitude = GetAttitudeBetween(owner.GetActor(), actor);
		
		
		if(isAdditionalTarget && attitude != AIA_Hostile)
			return false;
		
		npc = (CNewNPC)actor;
		
	
		if(attitude == AIA_Friendly)
		{
			
			if(npc.GetNPCType() == ENGT_Quest && !actor.HasTag(theGame.params.TAG_AXIIABLE_LOWER_CASE) && !actor.HasTag(theGame.params.TAG_AXIIABLE))
				return false;
		}
					
		
		if(npc)
		{
			horse = npc.GetHorseComponent();				
			if(horse && !horse.IsDismounted())	
			{
				if(horse.GetCurrentUser() != owner.GetActor())	
					return false;
			}
		}
		
		return true;
	}
	
	private function SelectTargets()
	{
		var projCount, i, j : int;
		var actors, finalActors : array<CActor>;
		var ownerPos : Vector;
		var ownerActor : CActor;
		var actor : CActor;
		
		if( owner.CanUseSkill(S_Magic_s18, this) && !owner.ChangeAspect( this, S_Magic_s05 ) ) //W3EE
			projCount = 1 + owner.GetSkillLevel(S_Magic_s18, this); //W3EE
		else
			projCount = 1;
		
		targets.Clear();
		actor = (CActor)thePlayer.slideTarget;	
		
		if(actor && IsTargetValid(actor, false))
		{
			targets.PushBack(actor);
			projCount -= 1;
			
			if(projCount == 0)
				return;
		}
		
		ownerActor = owner.GetActor();
		ownerPos = ownerActor.GetWorldPosition();
		
		
		actors = ownerActor.GetNPCsAndPlayersInCone(15, VecHeading(ownerActor.GetHeadingVector()), 150, 20, , FLAG_OnlyAliveActors );
					
		
		for(i=actors.Size()-1; i>=0; i-=1)
		{
			
			if(ownerActor == actors[i] || actor == actors[i] || !IsTargetValid(actors[i], true))
				actors.Erase(i);
		}
		
		
		if(actors.Size() > 0)
			finalActors.PushBack(actors[0]);
					
		for(i=1; i<actors.Size(); i+=1)
		{
			for(j=0; j<finalActors.Size(); j+=1)
			{
				if(VecDistance(ownerPos, actors[i].GetWorldPosition()) < VecDistance(ownerPos, finalActors[j].GetWorldPosition()))
				{
					finalActors.Insert(j, actors[i]);
					break;
				}
			}
			
			
			if(j == finalActors.Size())
				finalActors.PushBack(actors[i]);
		}
		
		
		if(finalActors.Size() > 0)
		{
			for(i=0; i<projCount; i+=1)
			{
				if(finalActors[i])
					targets.PushBack(finalActors[i]);
				else
					break;	
			}
		}
	}
	
	protected function ProcessThrow()
	{
		var proj : W3AxiiProjectile;
		var i : int;				
		var spawnPos : Vector;
		var spawnRot : EulerAngles;		
		
		
		
				
		
		spawnPos = GetWorldPosition();
		spawnRot = GetWorldRotation();
		
		
		StopEffect( effects[fireMode].castEffect );
		PlayEffect('axii_sign_push');
		
		
		for(i=0; i<targets.Size(); i+=1)
		{
			proj = (W3AxiiProjectile)theGame.CreateEntity( projTemplate, spawnPos, spawnRot );
			proj.PreloadEffect( proj.projData.flyEffect );
			proj.ExtInit( owner, skillEnum, this );			
			proj.PlayEffect(proj.projData.flyEffect );				
			proj.ShootProjectileAtNode(0, projSpeed, targets[i]);
		}		
	}
	
	event OnEnded(optional isEnd : bool)
	{
		var buff : EEffectInteract;
		var conf : W3ConfuseEffect;
		var i : int;
		var duration, durationAnimal, fortifiedSignsAtt : SAbilityAttributeValue;
		var casterActor : CActor;
		var dur, durAnimals : float;
		var params, staggerParams : SCustomEffectParams;
		var npcTarget : CNewNPC;
		var jobTreeType : EJobTreeType;
		var sp, pts, prc, raw, chance, reductionLevel : float; //W3EE
		var axiiPower : SAbilityAttributeValue; //W3EE
		
		casterActor = owner.GetActor();		
		ProcessThrow();
		StopEffect(effects[fireMode].throwEffect);
		
		
		for(i=0; i<targets.Size(); i+=1)
		{
			RemoveMagic17Effect(targets[i]);
		}
		
		
		RemoveMagic17Effect(orientationTarget);
				
		if(IsAlternateCast())
		{
			thePlayer.LockToTarget( false );
			thePlayer.EnableManualCameraControl( true, 'AxiiEntity' );
		}
		
		if (targets.Size() > 0 )
		{
			//W3EE - Begin
			/*
			duration = thePlayer.GetSkillAttributeValue(skillEnum, 'duration', false, true);
			durationAnimal = thePlayer.GetSkillAttributeValue(skillEnum, 'duration_animals', false, true);
			
			duration.valueMultiplicative = 1.0f;
			durationAnimal.valueMultiplicative = 1.0f;
			
			
			if(owner.CanUseSkill(S_Magic_s36))
			{
				fortifiedSignsAtt = owner.GetSkillAttributeValue(S_Magic_s36, 'duration', false, true) * owner.GetSkillLevel(S_Magic_s36);
				duration += fortifiedSignsAtt;
				durationAnimal += fortifiedSignsAtt;
			}

			
			
			
			if(owner.CanUseSkill(S_Magic_s19))
			{
				duration -= owner.GetSkillAttributeValue(S_Magic_s19, 'duration', false, true) * (3 - owner.GetSkillLevel(S_Magic_s19));
				durationAnimal -= owner.GetSkillAttributeValue(S_Magic_s19, 'duration', false, true) * (3 - owner.GetSkillLevel(S_Magic_s19));
			}
			
			
			dur = CalculateAttributeValue(duration);
			durAnimals = CalculateAttributeValue(durationAnimal);
			*/
			
			durAnimals = 30.f;
			if(IsAlternateCast())
				dur = 60.f;
			else
				dur = 10.f;
			
			if( ((W3PlayerWitcher)owner.GetActor()) )
				dur *= ((W3PlayerWitcher)owner.GetActor()).GetPlayerSignDurationMod();
			//W3EE - Begin
			
			params.creator = casterActor;
			params.sourceName = "axii_" + skillEnum;			
			params.customPowerStatValue = super.GetTotalSignIntensity(); //W3EE
			params.isSignEffect = true;
			
			//W3EE - Begin
			if( owner.CanUseSkill(S_Magic_s19, this) )
				dur *= 1.f + (owner.GetSkillLevel(S_Magic_s19, this) * 0.2f);
				
			if( !IsAlternateCast() )
				chance = 0.75f + owner.GetSkillLevel(S_Magic_s19, this) * 0.05f;
			else
				chance = 0.5f + (owner.GetSkillLevel(S_Magic_s19, this) * 0.05f) + (owner.GetSkillLevel(S_Magic_s05, this) * 0.05f);
				
			axiiPower = super.GetTotalSignIntensity();
				
			if( owner.CanUseSkill(S_Magic_s18, this) && targets.Size() > 1)
			{
				reductionLevel = (0.11f - owner.GetSkillLevel(S_Magic_s18, this) * 0.01f) * (targets.Size() - 1);
				chance -= reductionLevel;
			}
			//W3EE - End
			
			for(i=0; i<targets.Size(); i+=1)
			{
				npcTarget = (CNewNPC)targets[i];
				//W3EE - Begin
				prc = npcTarget.GetNPCCustomStat(theGame.params.DAMAGE_NAME_MENTAL);
				
				if( ((W3PlayerWitcher)casterActor).HasAbility('Glyphword 29 _Stats', true) || ((W3PlayerWitcher)casterActor).HasAbility('Glyphword 30 _Stats', true) )
					prc *= 0.5f;
				
				chance *= axiiPower.valueMultiplicative * (1 - prc);
				
				if( npcTarget.HasTag('WeakToAxii') )
				{
					dur *= 1.25f;
					chance *= 1.25f;
				}
				
				if( npcTarget.UsesEssence() )
				{
					chance *= 0.5f + npcTarget.GetStatPercents(BCS_Essence) / 2.f;
					dur *= 1.5f - npcTarget.GetStatPercents(BCS_Essence) / 2.f;
				}
				else
				{
					chance *= 0.5f + npcTarget.GetStatPercents(BCS_Vitality) / 2.f;
					dur *= 1.5f - npcTarget.GetStatPercents(BCS_Vitality) / 2.f;
				}
				//W3EE - End
				if( targets[i].IsAnimal() || npcTarget.IsHorse() )
				{
					params.duration = durAnimals;
				}
				else
				{
					params.duration = dur;
				}
				
				jobTreeType = npcTarget.GetCurrentJTType();	
					
				if ( jobTreeType == EJTT_InfantInHand )
				{
					params.effectType = EET_AxiiGuardMe;
				}
				
				else if(IsAlternateCast() && owner.GetActor() == thePlayer && GetAttitudeBetween(targets[i], owner.GetActor()) == AIA_Friendly)
				{
					params.effectType = EET_Confusion;
				}
				else
				{
					params.effectType = actionBuffs[0].effectType;
				}
			
				
				RemoveMagic17Effect(targets[i]);
			
				if( targets[i].IsAnimal() || npcTarget.IsHorse() || (owner.GetActor() == thePlayer && GetAttitudeBetween(targets[i], owner.GetActor()) == AIA_Friendly) )
				{
					chance = 1;
				}
				
				//W3EE - Begin
				if(IsAlternateCast())
				{
					chance -= 0.1f * Combat().GetPuppetCount();
					if( npcTarget.HasBuff(EET_Confusion) )
					{
						chance *= 2.f;
					}
				}
				
				chance *= 1 - 0.25f * npcTarget.GetAxiiHitCounter();
				
				if( ((W3Effect_NPCPoise)targets[i].GetBuff(EET_NPCPoise)).IsPoiseBroken() )
				{
					chance = 1.f;
					params.duration *= 3.f;
				}
				
				if(IsAlternateCast() && ((W3PlayerWitcher)casterActor).HasAbility('Glyphword 30 _Stats', true))
					params.duration = -1;
				
				if(RandF() < chance)
				{
					buff = targets[i].AddEffectCustom(params);
					if( ((W3PlayerWitcher)casterActor).IsSetBonusActive(EISB_Vampire_Alt_2) && (W3Effect_Bleeding)targets[i].GetBuff(EET_Bleeding) )
					{
						casterActor.PlayEffect('drain_energy_caretaker_shovel');
						casterActor.GainStat( BCS_Vitality, 500 * ((W3Effect_Bleeding)targets[i].GetBuff(EET_Bleeding)).GetStacks() );
						((W3Effect_Bleeding)targets[i].GetBuff(EET_Bleeding)).RemoveStack(15);
					}
					
					if( !IsAlternateCast() && ((W3PlayerWitcher)casterActor).IsSetBonusActive(EISB_Viper2) && casterActor.GetAttitude(targets[i]) == AIA_Hostile )
						targets[i].ApplyPoisoning(RandRange(((W3PlayerWitcher)casterActor).GetSetPartsEquipped(EIST_Viper), 0), casterActor, "Viper Set", true);
				}
				else
				{
					buff = EI_Deny;
					targets[i].IncAxiiHitCounter(-1.f);
				}
				//W3EE - End
				if( buff == EI_Pass || buff == EI_Override || buff == EI_Cumulate )
				{
					targets[i].OnAxiied( casterActor );
					//W3EE - Begin
					/*
					if(owner.CanUseSkill(S_Magic_s18))
					{
						conf = (W3ConfuseEffect)(targets[i].GetBuff(params.effectType, "axii_" + skillEnum));
						conf.SetDrainStaminaOnExit();
					}
					*/
					conf = (W3ConfuseEffect)(targets[i].GetBuff(params.effectType, "axii_" + skillEnum));
					
					if( npcTarget.IsFlying() && !npcTarget.HasAbility('mon_siren_base') )
					{
						staggerParams = params;
						staggerParams.effectType = EET_Stagger;
						params.duration = 0;	
						targets[i].AddEffectCustom(staggerParams);
					}
					//W3EE - End
				}
				else
				{
					
					if( !(targets[i].IsImmuneToBuff(EET_Stagger) || npcTarget.IsFlying()) ) //W3EE
					{
						staggerParams = params;
						staggerParams.effectType = EET_Stagger;
						params.duration = 0;	
						targets[i].AddEffectCustom(staggerParams);					
					}
					else
					{
						
						owner.GetActor().SetBehaviorVariable( 'axiiResisted', 1.f );
					}
				}
				Combat().CullAxiiLinkActors(targets[i], buff); //W3EE
			}
		}
		
		casterActor.OnSignCastPerformed(ST_Axii, fireMode);
		
		super.OnEnded();
	}
	
	event OnSignAborted( optional force : bool )
	{
		HAXX_AXII_ABORTED();
		super.OnSignAborted(force);
	}
	
	
	public function HAXX_AXII_ABORTED()
	{
		var i : int;
		
		for(i=0; i<targets.Size(); i+=1)
		{
			RemoveMagic17Effect(targets[i]);
		}
		RemoveMagic17Effect(orientationTarget);
	}
	
	
	public function OnDisplayTargetChange(newTarget : CActor)
	{
		var buffParams : SCustomEffectParams;
	
		//W3EE - Begin
		/*
		if(!owner.CanUseSkill(S_Magic_s17, this) || owner.GetSkillLevel(S_Magic_s17, this) == 0)
			return;
		*/
		//W3EE - End
		if(newTarget == orientationTarget)
			return;
			
		RemoveMagic17Effect(orientationTarget);
		orientationTarget = newTarget;
		
		AddMagic17Effect(orientationTarget);			
	}
	
	private function AddMagic17Effect(target : CActor)
	{
		var buffParams : SCustomEffectParams;
		
		if(!target || owner.GetActor() != GetWitcherPlayer() || ((CNewNPC)target).IsFlying()) //W3EE
			return;
		
		buffParams.effectType = EET_SlowdownAxii;
		buffParams.creator = this;
		buffParams.sourceName = "axii_immobilize";
		buffParams.duration = 10;
		buffParams.effectValue.valueAdditive = 0.999f;
		buffParams.isSignEffect = true;
		
		target.AddEffectCustom(buffParams);
	}
	
	private function RemoveMagic17Effect(target : CActor)
	{
		if(target)
			target.RemoveBuff(EET_SlowdownAxii, true, "axii_immobilize");
	}
}

state AxiiCast in W3AxiiEntity extends NormalCast
{
	event OnEnded(optional isEnd : bool)
	{
		var player			: CR4Player;
		
		
		parent.OnEnded(isEnd);
		super.OnEnded(isEnd);
			
		player = caster.GetPlayer();
		
		if( player )
		{
			parent.ManagePlayerStamina();
			//parent.ManageGryphonSetBonusBuff(); //W3EE
		}
		else
		{
			caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		}
	}
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.owner.GetActor().SetBehaviorVariable( 'axiiResisted', 0.f );
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
		{
			//W3EE - Begin
			if( caster.GetPlayer() )
				Experience().AwardSignXP(parent.GetSignType());
			//W3EE - End
			caster.GetActor().SetBehaviorVariable( 'bStopSign', 1.f );
		}
	}
	
	event OnSignAborted( optional force : bool )
	{
		parent.HAXX_AXII_ABORTED();
		parent.StopEffect( parent.effects[parent.fireMode].throwEffect );
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );
		
		super.OnSignAborted(force);
	}
}

state AxiiChanneled in W3AxiiEntity extends Channeling
{
	event OnEnded(optional isEnd : bool)
	{
		
		parent.OnEnded(isEnd);
		super.OnEnded(isEnd);
		//W3EE - Begin
		if( caster.GetPlayer() )
		{
			parent.ManagePlayerStamina();
			Experience().AwardSignXP(parent.GetSignType());
		}
		else
		{
			caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		}
		//W3EE - End
	}
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		parent.owner.GetActor().SetBehaviorVariable( 'axiiResisted', 0.f );
		caster.OnDelayOrientationChange();
	}

	event OnProcessSignEvent( eventName : name )
	{
		if( eventName == 'axii_alternate_ready' )
		{
			
			
		}
		else
		{
			return parent.OnProcessSignEvent( eventName );
		}
		
		return true;
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
			ChannelAxii();			
	}
		
	event OnSignAborted( optional force : bool )
	{
		parent.HAXX_AXII_ABORTED();
		parent.StopEffect( parent.effects[parent.fireMode].throwEffect );
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );

		if ( caster.IsPlayer() )
		{
			caster.GetPlayer().LockToTarget( false );
		}
	
		super.OnSignAborted( force );
	}
	
	//W3EE - Begin
	private var timeStamp : float;	default timeStamp = 0;
	private var DT : float; default DT = 0.006f;
	entry function ChannelAxii()
	{	
		timeStamp = theGame.GetEngineTimeAsSeconds();
		while( Update(DT) )
		{
			Sleep(DT);
			DT = MaxF(theGame.GetEngineTimeAsSeconds() - timeStamp, 0.002f);
			timeStamp = theGame.GetEngineTimeAsSeconds();
		}
	}
	//W3EE - End
}