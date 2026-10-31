/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_YrdenHealthDrain extends W3DamageOverTimeEffect
{
	//W3EE - Begin
	private var hitFxDelay, hitFxDelay2, immobilizeCooldown, slowResist, damageResist : float;
	private var isImmobilized, isGriffinSetBonus : bool;
	private var hitCount, GriffinCount : int;
	private var npc : CNewNPC;
	private var sp : SAbilityAttributeValue;
	private var immobilize : SCustomEffectParams;
	private var witcher: W3PlayerWitcher;
	
	default effectType = EET_YrdenHealthDrain;
	default resistStat = CDS_ElementalRes;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default isImmobilized = false;
	default immobilizeCooldown = 0;
	default hitCount = 0;
	default GriffinCount = 0;

	event OnEffectAdded( optional customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
		
		npc = (CNewNPC)target;
		witcher = GetWitcherPlayer();
		slowResist = npc.GetNPCCustomStat(theGame.params.DAMAGE_NAME_SLOW);
		damageResist = npc.GetNPCCustomStat(theGame.params.DAMAGE_NAME_ELEMENTAL);
		
		isGriffinSetBonus = witcher.IsSetBonusActive(EISB_Gryphon_2);
		if( isGriffinSetBonus )
			GriffinCount = witcher.GetSetPartsEquipped(EIST_Gryphon);
		
		sp = ((W3SignEntity)GetCreator()).GetTotalSignIntensity();
		
		immobilizeCooldown = target.GetYrdenCooldown();
		hitFxDelay = 0.9f + RandF() / 5.f;
		hitFxDelay2 = 0.5f + RandF() / 5.f;
		SetEffectValue();
		SetImmobilizeValues();
		
		if( ((W3Effect_NPCPoise)target.GetBuff(EET_NPCPoise)).IsPoiseBroken() )
		{
			immobilize.duration *= 2.f;
			hitCount = 100;
		}
	}

	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		target.PlayEffect('yrden_shock');
		target.SetYrdenCooldown(immobilizeCooldown);
	}

	event OnUpdate(dt : float)
	{
		super.OnUpdate(dt);
		
		if( !target.IsImmobilized() )
		{
			hitFxDelay -= dt;
			if( hitFxDelay <= 0.f )
			{
				hitFxDelay = 0.9f + RandF() / 5.f;
				immobilizeCooldown -= hitFxDelay;
				target.PlayEffect('yrden_shock');
				if( immobilizeCooldown <= 0.f )
				{
					hitCount += 1;
					if( hitCount >= RoundMath(3.f * (1.f + slowResist)) )
					{
						npc.AddEffectCustom(immobilize);
						RerollImmobilizeDuration();
						immobilizeCooldown = 5.f;
						
						hitCount = 0;
					}
				}
			}
			return false;
		}
		
		hitFxDelay2 -= dt;
		if( hitFxDelay2 <= 0.f )
		{
			hitFxDelay2 = 0.5f + RandF() / 5;
			if( target.IsImmobilized() )
			{
				target.PlayEffect('yrden_shock');
			}
		}
		
	}
	
	protected function SetEffectValue()
	{
		effectValue.valueAdditive = 20.f;
		effectValue.valueAdditive *= (1.f + ((W3SignEntity)GetCreator()).GetActualOwner().GetSkillLevel(S_Magic_s11, (W3SignEntity)GetCreator())) * sp.valueMultiplicative;
		
		if( witcher.HasAbility('Glyphword 17 _Stats', true) || witcher.HasAbility('Glyphword 18 _Stats', true) )
		{
			if( npc.UsesEssence() )
				effectValue.valueAdditive += npc.GetStatMax(BCS_Essence) * 0.005f;
			else
				effectValue.valueAdditive += npc.GetStatMax(BCS_Vitality) * 0.005f;
		}
		
		/*
		if(target.HasAbility( 'SkillBoss' ) || target.HasAbility( 'Boss' ) || target.HasAbility('MonsterMHBoss') || target.GetCharacterStats().HasAbilityWithTag('Boss') || (W3MonsterHuntNPC)target || (target.HasTag( 'HideHealthBarModule' ) && !target.HasTag( 'NotBoss' )) )
		{
			effectValue.valueMultiplicative *= 0.15;
		}
		*/
	}
	
	protected function SetImmobilizeValues()
	{
		var duration : float;
		
		duration = RandRangeF(3.f + ((W3SignEntity)GetCreator()).GetActualOwner().GetSkillLevel(S_Magic_s16, (W3SignEntity)GetCreator()), 2.f) * sp.valueMultiplicative * (1 - slowResist) * MaxF(1.f, witcher.GetPlayerSignDurationMod());
		
		immobilize.effectType = EET_Immobilized;
		immobilize.creator = (W3SignEntity)GetCreator();
		immobilize.sourceName = "YrdenImmobilize";
		immobilize.isSignEffect = true;
		immobilize.duration = duration;
	}
	
	protected function RerollImmobilizeDuration()
	{
		immobilize.duration = RandRangeF(3.f + ((W3SignEntity)GetCreator()).GetActualOwner().GetSkillLevel(S_Magic_s16, (W3SignEntity)GetCreator()), 2.f) * sp.valueMultiplicative * (1 - slowResist) * MaxF(1.f, witcher.GetPlayerSignDurationMod());
	}
	
	public function OnDamageDealt( dealtDamage : bool )
	{
		if( isGriffinSetBonus )
			npc.GryphonReduceResists(effectValue.valueAdditive * GriffinCount);
		
		if( witcher.HasAbility('Glyphword 16 _Stats', true) || witcher.HasAbility('Glyphword 17 _Stats', true) || witcher.HasAbility('Glyphword 18 _Stats', true) )
		{
			npc.DrainStamina(ESAT_FixedValue, npc.GetStatMax(BCS_Stamina) * 0.1f);
		}
	}
	//W3EE - End
}