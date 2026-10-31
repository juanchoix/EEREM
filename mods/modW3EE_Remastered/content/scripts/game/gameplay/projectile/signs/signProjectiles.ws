/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3AardProjectile extends W3SignProjectile
{
	protected var staminaDrainPerc : float;
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var projectileVictim : CProjectileTrajectory;
		
		projectileVictim = (CProjectileTrajectory)collidingComponent.GetEntity();
		
		if( projectileVictim )
		{
			projectileVictim.OnAardHit( this );
		}
		
		super.OnProjectileCollision( pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex );
	}
	
	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		var dmgVal : float;
		var sp : SAbilityAttributeValue;
		var isMutation6 : bool;
		var victimNPC : CNewNPC;
		var aardDRTier : int;
		var effectParams : SCustomEffectParams; //W3EE
	
		
		if ( hitEntities.FindFirst( collider ) != -1 )
		{
			return;
		}
		
		
		hitEntities.PushBack( collider );
	
		super.ProcessCollision( collider, pos, normal );
		
		victimNPC = (CNewNPC) collider;
		//W3EE - Begin
		/*
		aardDRTier = 1;

		if( owner.IsPlayer() && victimNPC )
		{
			aardDRTier = victimNPC.SignDRRegisterAard();
		}
		*/
		//W3EE - End
		
		if( IsRequiredAttitudeBetween(victimNPC, caster, true ) )
		{
			//W3EE - Begin
			if( owner.GetPlayer().IsSwimming() )
				action.AddDamage(theGame.params.DAMAGE_NAME_FORCE, 20000.f);
			//W3EE - End
			isMutation6 = ( ( W3PlayerWitcher )owner.GetPlayer() && owner.CanUseSkill(S_Magic_s12, GetSignEntity()) ); //W3EE
			if( isMutation6 )
			{
				action.SetBuffSourceName( "Magic_s12" ); //W3EE
			}
			//W3EE - Begin
			/*
			else if ( owner.CanUseSkill( S_Magic_s33 ) )	
			{
				action.AddDamage( theGame.params.DAMAGE_NAME_DIRECT, GetWitcherPlayer().CalcMagic33Damage() );
			}
			*/
			else
			{
				dmgVal = 500.f;
				sp = GetSignEntity().GetTotalSignIntensity();
				if (owner.GetSkillLevel(S_Magic_s20, GetSignEntity()) >= 2)
					dmgVal += 125.f;
				if (owner.GetSkillLevel(S_Magic_s20, GetSignEntity()) >= 4)
					dmgVal += 125.f;
				
				dmgVal += CalculateAttributeValue(((W3PlayerWitcher)owner.GetPlayer()).GetAttributeValue('aard_damage_bonus'));
				
				dmgVal *= sp.valueMultiplicative;
				if( signEntity.IsAlternateCast() )
					dmgVal *= 0.25f + 0.05f * owner.GetSkillLevel(S_Magic_s01, GetSignEntity());
					
				action.AddDamage( theGame.params.DAMAGE_NAME_FORCE, dmgVal );
			}
			//W3EE - End
		}
		else
		{
			isMutation6 = false;
		}
		
		action.SetHitAnimationPlayType(EAHA_ForceNo);
		action.SetProcessBuffsIfNoDamage(true);

		
		if ( !owner.IsPlayer() )
		{
			action.AddEffectInfo( EET_KnockdownTypeApplicator );
		}
		
		
		
		
		//W3EE - Begin
		/*
		if( owner.IsPlayer() && victimNPC )
		{
			if( aardDRTier == 2 )
			{
				action.RemoveBuffsByType( EET_KnockdownTypeApplicator );
				action.RemoveBuffsByType( EET_Knockdown );
				action.RemoveBuffsByType( EET_HeavyKnockdown );
				action.RemoveBuffsByType( EET_LongStagger );
				action.RemoveBuffsByType( EET_Stagger );
				action.RemoveBuffsByType( EET_Ragdoll );

				action.AddEffectInfo( EET_LongStagger );
			}
			else if( aardDRTier == 3 )
			{
				action.RemoveBuffsByType( EET_KnockdownTypeApplicator );
				action.RemoveBuffsByType( EET_Knockdown );
				action.RemoveBuffsByType( EET_HeavyKnockdown );
				action.RemoveBuffsByType( EET_LongStagger );
				action.RemoveBuffsByType( EET_Stagger );
				action.RemoveBuffsByType( EET_Ragdoll );

				action.AddEffectInfo( EET_Stagger );
			}
			else if( aardDRTier >= 4 )
			{
				action.RemoveBuffsByType( EET_KnockdownTypeApplicator );
				action.RemoveBuffsByType( EET_Knockdown );
				action.RemoveBuffsByType( EET_HeavyKnockdown );
				action.RemoveBuffsByType( EET_LongStagger );
				action.RemoveBuffsByType( EET_Stagger );
				action.RemoveBuffsByType( EET_Ragdoll );

				action.SetHitReactionType( EHRT_None, false );
				action.SetHitAnimationPlayType( EAHA_ForceNo );
			}
		}
		*/
		//W3EE - End
		theGame.damageMgr.ProcessAction( action );
		
		CheckFrostEffect ( collider );

		collider.OnAardHit( this );
		
		
		
		if( isMutation6 && victimNPC && victimNPC.IsAlive() )
		{
			ProcessMutation6( victimNPC );
		}
		//W3EE - Begin
		if (RandRange(100, 0) < (5 + owner.GetSkillLevel(S_Magic_s06, GetSignEntity()) * 3) * sp.valueMultiplicative)
		{
			effectParams.effectType = EET_Confusion;
			effectParams.creator = owner.GetPlayer();
			effectParams.sourceName = 'AardShockwave';
			effectParams.duration = 3.f * sp.valueMultiplicative * ((W3PlayerWitcher)owner.GetPlayer()).GetPlayerSignDurationMod();
			victimNPC.AddEffectCustom(effectParams);
		}
		
		if( ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 1 _Stats', true) || ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 2 _Stats', true) || ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 3 _Stats', true) )
		{
			victimNPC.ApplyBleeding(RoundMath(RandRange(5, 1) * sp.valueMultiplicative), owner.GetPlayer(), "Disintegration", false);
			((CActor)collider).CreateBloodSpill();
		}
		
		if( ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 2 _Stats', true) || ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 3 _Stats', true) )
		{
			victimNPC.ModifyArmorValue(  -0.05f * sp.valueMultiplicative / (1.f + victimNPC.GetTotalArmorReduction('Sign')) , 'Sign' );
			victimNPC.ReduceNPCStat('force', 0.05f * sp.valueMultiplicative);
		}
		//W3EE - End
	}
	
	private function CheckFrostEffect ( collider : CGameplayEntity )
	{
		var isMutation6 : bool;
		
		isMutation6 = ( ( W3PlayerWitcher )owner.GetPlayer() && GetWitcherPlayer().CanUseSkill(S_Magic_s12) ); //W3EE
		
		if ( collider && isMutation6 )
			collider.OnFrostHit(this);
	}
	
	private final function ProcessMutation6( victimNPC : CNewNPC )
	{
		var result : EEffectInteract;
		var mutationAction : W3DamageAction;
		var min, max : SAbilityAttributeValue;
		var sp : SAbilityAttributeValue; 
		var dmgVal : float;
		var instaKill, hasKnockdown, applySlowdown : bool;
		var frostDmgVal, slowDuration, prc : float; //W3EE
		var chillParams : SCustomEffectParams; //W3EE
				
		instaKill = false;
		hasKnockdown = victimNPC.HasBuff( EET_Knockdown ) || victimNPC.HasBuff( EET_HeavyKnockdown ) || victimNPC.GetIsRecoveringFromKnockdown();
		
		
		
		//W3EE - Begin
		/*
		if( RandF() >= thePlayer.GetStat(BCS_Focus) * 0.1 && !isSupercharged )
		
		{
			
			applySlowdown = true;			
			instaKill = false;
		}
		else
		{
			
			if( victimNPC.IsImmuneToInstantKill() )
			{
				result = EI_Deny;
			}
			else
			{
				result = victimNPC.AddEffectDefault( EET_Frozen, this, "Mutation 6", true );
			}
			
			
			if( EffectInteractionSuccessfull( result ) && hasKnockdown && !victimNPC.HasTag('eredin') && !victimNPC.HasTag('imlerith') && !victimNPC.HasTag('Caranthir') )	
			{
				
				mutationAction = new W3DamageAction in theGame.damageMgr;
				mutationAction.Initialize( action.attacker, victimNPC, this, "Mutation 6", EHRT_None, CPS_Undefined, false, false, true, false );
				mutationAction.SetInstantKill();
				mutationAction.SetForceExplosionDismemberment();
				mutationAction.SetIgnoreInstantKillCooldown();
				theGame.damageMgr.ProcessAction( mutationAction );
				delete mutationAction;
				instaKill = true;
			}
		}
		
		if( applySlowdown && !hasKnockdown )
		{
			victimNPC.AddEffectDefault( EET_SlowdownFrost, this, "Mutation 6", true );
		}
		
		
		
		
		if( !instaKill )
		{			
			if ( owner.CanUseSkill(S_Magic_s06) )
			{
				
				sp = action.GetPowerStatValue();
				dmgVal += GetWitcherPlayer().GetSkillLevel(S_Magic_s06) * victimNPC.GetHealth() * ( 0.01 + 0.03 * LogF( sp.valueMultiplicative ) );
				
				action.AddDamage( theGame.params.DAMAGE_NAME_DIRECT, dmgVal );
				
				
				if(victimNPC.HasTag('eredin') || victimNPC.HasTag('imlerith') || victimNPC.HasTag('Caranthir'))
					theGame.damageMgr.ProcessAction( action );
			}
			else if ( owner.CanUseSkill( S_Magic_s33 ) ) 
			{
				action.AddDamage( theGame.params.DAMAGE_NAME_DIRECT, GetWitcherPlayer().CalcMagic33Damage() );
				
				
				if(victimNPC.HasTag('eredin') || victimNPC.HasTag('imlerith') || victimNPC.HasTag('Caranthir'))
					theGame.damageMgr.ProcessAction( action );
			}
			
			if( !victimNPC.HasBuff( EET_Frozen ) && !victimNPC.HasTag('eredin') && !victimNPC.HasTag('imlerith') && !victimNPC.HasTag('Caranthir'))	
			{ 
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation6', 'ForceDamage', min, max );
				dmgVal = CalculateAttributeValue( min );
				action.AddDamage( theGame.params.DAMAGE_NAME_FORCE, dmgVal );
				action.ClearEffects();
				action.SetProcessBuffsIfNoDamage( false );
				action.SetForceExplosionDismemberment();
				action.SetIgnoreInstantKillCooldown();
				action.SetBuffSourceName( "Mutation 6" );
				theGame.damageMgr.ProcessAction( action );
			}
		}
		*/
		dmgVal = 500.f;
		sp = GetSignEntity().GetTotalSignIntensity();
		if (owner.GetSkillLevel(S_Magic_s20, GetSignEntity()) >= 2)
			dmgVal += 125.f;
		if (owner.GetSkillLevel(S_Magic_s20, GetSignEntity()) >= 4)
			dmgVal += 125.f;
		
		frostDmgVal = 50 * owner.GetSkillLevel(S_Magic_s12, GetSignEntity() );
		
		frostDmgVal += CalculateAttributeValue(((W3PlayerWitcher)owner.GetPlayer()).GetAttributeValue('aard_damage_bonus'));
		
		dmgVal *= sp.valueMultiplicative;
		frostDmgVal *= sp.valueMultiplicative;
		
		if( signEntity.IsAlternateCast() )
		{
			dmgVal *= 0.25f + 0.05f * owner.GetSkillLevel(S_Magic_s01, GetSignEntity());
			frostDmgVal *= 0.25f + 0.05f * owner.GetSkillLevel(S_Magic_s01, GetSignEntity());
		}
			
		prc = victimNPC.GetNPCCustomStat(theGame.params.DAMAGE_NAME_FROST);
		action.AddDamage( theGame.params.DAMAGE_NAME_FORCE, dmgVal );
		action.AddDamage( theGame.params.DAMAGE_NAME_FROST, frostDmgVal );
		slowDuration = (1.f + owner.GetSkillLevel(S_Magic_s12, GetSignEntity() )) * sp.valueMultiplicative * (1 - prc) * ((W3PlayerWitcher)owner.GetPlayer()).GetPlayerSignDurationMod();
		if( ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 3 _Stats', true) )
		{
			applySlowdown = victimNPC.HasBuff(EET_SlowdownFrost);
			if( RandF() < (0.75f + (0.5f - (victimNPC.GetStatPercents(BCS_Stamina) + ((W3Effect_NPCPoise)victimNPC.GetBuff(EET_NPCPoise)).GetPoisePercentage()) / 4) ) * sp.valueMultiplicative * (1 - prc) )
			{
				chillParams.effectType = EET_SlowdownFrost;
				chillParams.creator = owner.GetPlayer();
				chillParams.sourceName = "Magic_s12";
				chillParams.isSignEffect = true;
				chillParams.duration = slowDuration;
				victimNPC.AddEffectCustom(chillParams);
			}
			else
			{
				applySlowdown = false;
			}
			if( hasKnockdown && applySlowdown && !victimNPC.IsImmuneToInstantKill() )
			{
				mutationAction = new W3DamageAction in theGame.damageMgr;
				mutationAction.Initialize( action.attacker, victimNPC, this, "Glyphword 3", EHRT_None, CPS_Undefined, false, false, true, false );
				mutationAction.SetInstantKill();
				mutationAction.SetForceExplosionDismemberment();
				mutationAction.SetIgnoreInstantKillCooldown();
				theGame.damageMgr.ProcessAction( mutationAction );
				delete mutationAction;
			}
		}
		else if( RandF() < (0.5f + (0.5f - (victimNPC.GetStatPercents(BCS_Stamina) + ((W3Effect_NPCPoise)victimNPC.GetBuff(EET_NPCPoise)).GetPoisePercentage()) / 4) ) * sp.valueMultiplicative * (1 - prc) )
		{
			chillParams.effectType = EET_SlowdownFrost;
			chillParams.creator = owner.GetPlayer();
			chillParams.sourceName = "Magic_s12";
			chillParams.isSignEffect = true;
			chillParams.duration = slowDuration;
			victimNPC.AddEffectCustom(chillParams);
		}
		//W3EE - End
	}
	
	event OnAttackRangeHit( entity : CGameplayEntity )
	{
		entity.OnAardHit( this );
	}
	
	public final function GetStaminaDrainPerc() : float
	{
		return staminaDrainPerc;
	}
	
	public final function SetStaminaDrainPerc(p : float)
	{
		var sp : SAbilityAttributeValue; //W3EE
		sp = GetSignEntity().GetTotalSignIntensity(); //W3EE
		staminaDrainPerc = p * sp.valueMultiplicative; //W3EE
	}
}



class W3AxiiProjectile extends W3SignProjectile
{
	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		DestroyAfter( 3.f );
		
		collider.OnAxiiHit( this );	
		
	}
	
	protected function ShouldCheckAttitude() : bool
	{
		return false;
	}
}

class W3IgniProjectile extends W3SignProjectile
{
	private var channelCollided : bool;
	private var dt : float;	
	private var isUsed : bool;
	
	default channelCollided = false;
	default isUsed = false;
	
	public function SetDT(d : float)
	{
		dt = d;
	}

	public function IsUsed() : bool
	{
		return isUsed;
	}

	public function SetIsUsed( used : bool )
	{
		isUsed = used;
	}

	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var rot, rotImp : EulerAngles;
		var v, posF, pos2, n : Vector;
		var igniEntity : W3IgniEntity;
		var ent, colEnt : CEntity;
		var template : CEntityTemplate;
		var f : float;
		var test : bool;
		var postEffect : CGameplayFXSurfacePost;
		
		channelCollided = true;
		
		
		igniEntity = (W3IgniEntity)signEntity;
		
		if(signEntity.IsAlternateCast())
		{			
			
			test = (!collidingComponent && hitCollisionsGroups.Contains( 'Terrain' ) ) || (collidingComponent && !((CActor)collidingComponent.GetEntity()));
			
			colEnt = collidingComponent.GetEntity();
			if( (W3BoltProjectile)colEnt || (W3SignEntity)colEnt || (W3SignProjectile)colEnt )
				test = false;
			
			if(test)
			{
				f = theGame.GetEngineTimeAsSeconds();
				
				if(f - igniEntity.lastFxSpawnTime >= 1)
				{
					igniEntity.lastFxSpawnTime = f;
					
					template = (CEntityTemplate)LoadResource( "igni_object_fx" );
					
					
					rot.Pitch	= AcosF( VecDot( Vector( 0, 0, 0 ), normal ) );
					rot.Yaw		= this.GetHeading();
					rot.Roll	= 0.0f;
					
					
					posF = pos + VecNormalize(pos - signEntity.GetWorldPosition());
					if(theGame.GetWorld().StaticTrace(pos, posF, pos2, n, igniEntity.projectileCollision))
					{					
						ent = theGame.CreateEntity(template, pos2, rot );
						ent.AddTimer('TimerStopVisualFX', 5, , , , true);
						
						postEffect = theGame.GetSurfacePostFX();
						postEffect.AddSurfacePostFXGroup( pos2, 0.5f, 8.0f, 10.0f, 0.3f, 1 );
					}
				}				
			}
			
			
			if ( !hitCollisionsGroups.Contains( 'Water' ) )
			{
				
				v = GetWorldPosition() - signEntity.GetWorldPosition();
				rot = MatrixGetRotation(MatrixBuildFromDirectionVector(-v));
				
				igniEntity.ShowChannelingCollisionFx(GetWorldPosition(), rot, -v);
			}
		}
		
		return super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
	}

	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		var signPower, channelDmg : SAbilityAttributeValue;
		var burnChance : float;					
		var maxArmorReduction : float;			
		var applyNbr : int;						
		var i : int;
		var npc : CNewNPC;
		var armorRedAblName : name;
		var currentReduction : int;
		var actorVictim : CActor;
		var ownerActor : CActor;
		var dmg : float;
		var performBurningTest : bool;
		var igniEntity : W3IgniEntity;
		var postEffect : CGameplayFXSurfacePost = theGame.GetSurfacePostFX();
		var igniDRTier : int;
		var armorRedAttr : SAbilityAttributeValue; //W3EE
		var pts, prc, reductionFactor, maxReductionFactor : float; //W3EE
		
		postEffect.AddSurfacePostFXGroup( pos, 0.5f, 8.0f, 10.0f, 2.5f, 1 );
		
		
		if ( hitEntities.Contains( collider ) )
		{
			return;
		}
		hitEntities.PushBack( collider );		
		
		super.ProcessCollision( collider, pos, normal );	
			
		ownerActor = owner.GetActor();
		actorVictim = ( CActor ) action.victim;
		npc = (CNewNPC)collider;
				
		signPower = signEntity.GetTotalSignIntensity(); //W3EE
		if(signEntity.IsAlternateCast())		
		{
			igniEntity = (W3IgniEntity)signEntity;
			//W3EE - Begin
			performBurningTest = false;
			if(!actorVictim.HasBuff(EET_Burning))
				performBurningTest = igniEntity.UpdateBurningChance(actorVictim, dt);
			//W3EE - End
			
			
			// signPower = signEntity.GetTotalSignIntensity(); //W3EE
			if( igniEntity.hitEntities.Contains( collider ) )
			{
				channelCollided = true;
				action.SetHitEffect('');
				action.SetHitEffect('', true );
				action.SetHitEffect('', false, true);
				action.SetHitEffect('', true, true);
				action.ClearDamage();
				
				
				//W3EE - Begin
				// channelDmg = owner.GetSkillAttributeValue(signSkill, 'channeling_damage', false, true);
				dmg = 800.f + GetSignEntity().GetActualOwner().GetSkillLevel(S_Magic_s09, GetSignEntity()) * 80;
				dmg += CalculateAttributeValue(((W3PlayerWitcher)owner.GetPlayer()).GetAttributeValue('igni_damage_bonus'));
				dmg *= signPower.valueMultiplicative;
				if(actorVictim.HasBuff(EET_Burning))
					dmg *= 0.5f + 0.1f * GetSignEntity().GetActualOwner().GetSkillLevel(S_Magic_s02, GetSignEntity());
				//W3EE - End
				dmg *= dt;
				action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, dmg);
				action.SetIsDoTDamage(dt);
				
				//W3EE - Begin
				if( ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 10 _Stats', true) || ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 11 _Stats', true) || ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 12 _Stats', true) )
					actorVictim.DrainMorale((dmg / 5) * (1.6f - Options().AggressionBehavior() * 0.2f));
				//W3EE - End
				if(!collider)	
					return;
			}
			else
			{
				igniEntity.hitEntities.PushBack( collider );
			}
			
			if(!performBurningTest)
			{
				action.ClearEffects();
			}
			//W3EE - Begin
			if( !actorVictim.HasBuff(EET_SlowdownFirestream) && !actorVictim.HasBuff(EET_Burning) )
				actorVictim.AddEffectDefault(EET_SlowdownFirestream, ownerActor,,true);
				
			actorVictim.AddTimer('Runeword1DisableFireFX', 1.f, false,,,, true);
			if( !actorVictim.IsEffectActive('critical_burning') )
			{
				actorVictim.PlayEffect('critical_burning');
				actorVictim.PlayEffect('critical_burning_csx');
			}
			//W3EE - End
		}
		//W3EE - Begin
		else if( ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 10 _Stats', true) || ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 11 _Stats', true) || ((W3PlayerWitcher)owner.GetPlayer()).HasAbility('Glyphword 12 _Stats', true) )
		{
			actorVictim.DrainMorale(20.f * (1.6f - Options().AggressionBehavior() * 0.2f));
			actorVictim.CreateFXEntityAtPelvis('runeword_4', true);
		}
		//W3EE - End
		
		if ( npc && npc.IsShielded( ownerActor ) )
		{
			collider.OnIgniHit( this );	
			return;
		}
		//W3EE - Begin
		/*
		igniDRTier = 1;

		if( owner.IsPlayer() && npc )
		{
			igniDRTier = npc.SignDRRegisterIgni( IsProjectileFromChannelMode() );
		}
		
		
		
		signPower = signEntity.GetOwner().GetTotalSignSpellPower(signEntity.GetSkill());
		*/
		//W3EE - End
		if ( !owner.IsPlayer() )
		{
			signPower = ownerActor.GetTotalSignSpellPower(S_Magic_s02); //W3EE
			burnChance = signPower.valueMultiplicative;
			if ( RandF() < burnChance )
			{
				action.AddEffectInfo(EET_Burning);
			}
			
			dmg = CalculateAttributeValue(signPower);
			if ( dmg <= 0 )
			{
				dmg = 20;
			}			
			action.AddDamage( theGame.params.DAMAGE_NAME_FIRE, dmg);
		}
		
		if(signEntity.IsAlternateCast())
		{
			action.SetHitAnimationPlayType(EAHA_ForceNo);
		}
		else		
		{
			
			if(ownerActor.HasTag('mq1060_witcher'))
			{
				action.SetHitEffect('igni_cone_hit_red', false, false);
				action.SetHitEffect('igni_cone_hit_red', true, false);
			}
			else
			{
				action.SetHitEffect('igni_cone_hit', false, false);
				action.SetHitEffect('igni_cone_hit', true, false);
			}			
			action.SetHitReactionType(EHRT_Igni, false);
		}
		//W3EE - Begin
		/*
		if( owner.IsPlayer() && npc )
		{
			if( igniDRTier == 2 )
			{
				if( RandF() >= 0.60f )
				{
					action.RemoveBuffsByType( EET_Burning );
				}
			}
			else if( igniDRTier == 3 )
			{
				if( RandF() >= 0.25f )
				{
					action.RemoveBuffsByType( EET_Burning );
				}
			}
			else if( igniDRTier >= 4 )
			{
				action.RemoveBuffsByType( EET_Burning );
			}
		}
		*/
		//W3EE - End
		theGame.damageMgr.ProcessAction( action );	
		
		
		//W3EE - Begin
		/*
		if ( owner.CanUseSkill(S_Magic_s08) && (CActor)collider)
		{	
			maxArmorReduction = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s08, 'max_armor_reduction', false, true)) * GetWitcherPlayer().GetSkillLevel(S_Magic_s08);
			applyNbr = RoundMath( 100 * maxArmorReduction * ( signPower.valueMultiplicative / theGame.params.MAX_SPELLPOWER_ASSUMED ) );
			
			armorRedAblName = SkillEnumToName(S_Magic_s08);
			currentReduction = ((CActor)collider).GetAbilityCount(armorRedAblName);
			
			applyNbr -= currentReduction;
			
			for ( i = 0; i < applyNbr; i += 1 )
				action.victim.AddAbility(armorRedAblName, true);
		}	
		*/
		if ( owner.CanUseSkill(S_Magic_s08, GetSignEntity()) && npc )
		{	
			prc = npc.GetNPCCustomStat(theGame.params.DAMAGE_NAME_FIRE);
			
			maxArmorReduction = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s08, 'max_armor_reduction', false, true)) * GetSignEntity().GetActualOwner().GetSkillLevel(S_Magic_s08, GetSignEntity());
			maxReductionFactor = 0.02f * GetSignEntity().GetActualOwner().GetSkillLevel(S_Magic_s08, GetSignEntity()) * signPower.valueMultiplicative;
			if ( !npc.IsProtectedByArmor() )
			{
				maxArmorReduction *= 0.5f;
				maxReductionFactor *= 0.5f;
			}
			reductionFactor = MinF(1, maxReductionFactor * (1 - prc / 2.f));
			if( signEntity.IsAlternateCast() )
			{
				reductionFactor = MinF(1, reductionFactor * dt);
			}
			
			reductionFactor = ClampF(reductionFactor, 0.f, maxArmorReduction - npc.GetTotalArmorReduction('Sign')) * -1.f;
			npc.ModifyArmorValue(reductionFactor, 'Sign');
		}
		//W3EE - End
		collider.OnIgniHit( this );		
	}	

	event OnAttackRangeHit( entity : CGameplayEntity )
	{
		entity.OnIgniHit( this );
	}

	
	event OnRangeReached()
	{
		var v : Vector;
		var rot : EulerAngles;
				
		
		if(!channelCollided)
		{			
			
			v = GetWorldPosition() - signEntity.GetWorldPosition();
			rot = MatrixGetRotation(MatrixBuildFromDirectionVector(-v));
			((W3IgniEntity)signEntity).ShowChannelingRangeFx(GetWorldPosition(), rot);
		}
		
		isUsed = false;
		
		super.OnRangeReached();
	}
	
	public function IsProjectileFromChannelMode() : bool
	{
		return signSkill == S_Magic_s02; //W3EE
	}
	
	//W3EE - Begin
	public function GetSignEntity() : W3SignEntity
	{
		return signEntity;
	}
	//W3EE - End
}