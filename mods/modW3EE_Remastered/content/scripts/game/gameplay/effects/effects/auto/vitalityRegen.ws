/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_AutoVitalityRegen extends W3AutoRegenEffect
{
	private var regenModeIsCombat : bool;		
	private var cachedPlayer : CR4Player;
	private var inGameConfigWrapper : CInGameConfigWrapper;
	private var isAccessibilityAutoHealOn : bool;
	private var accessibilityMulCurr : float;
	private var accessibilityMulConst : int;	
	private var accessibilityAutoHealThreshold : float;
	private var witcherPlayer : W3PlayerWitcher; //W3EE
	private var glyphword39Duration : float; //W3EE
	private var glyphword39Value : float; //W3EE

		default regenStat = CRS_Vitality;	
		default effectType = EET_AutoVitalityRegen;
		default regenModeIsCombat = false;
		default glyphword39Duration = 0; //W3EE
		default glyphword39Value = 0; //W3EE
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		if(isOnPlayer)
		{
			cachedPlayer = (CR4Player)target;
			witcherPlayer = (W3PlayerWitcher)target; //W3EE
			inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();			
			isAccessibilityAutoHealOn =  inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealOn') == "true";
			accessibilityMulConst =  StringToInt(inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealMultiplier'));
			accessibilityAutoHealThreshold =  0.01f * StringToFloat(inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealThreshold'));
		}
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		if(isOnPlayer)
		{
			cachedPlayer = (CR4Player)target;
			witcherPlayer = (W3PlayerWitcher)target; //W3EE
			inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();			
			isAccessibilityAutoHealOn =  inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealOn') == "true";
			accessibilityMulConst =  StringToInt(inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealMultiplier'));
			accessibilityAutoHealThreshold =  0.01f * StringToFloat(inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealThreshold'));
		}
	}
	
	event OnUpdate(deltaTime : float)
	{
		var vitPerc : float;
		var accessibilityMulEffectScale : float;
		var vitThresholdRatio : float;

		
		if(isOnPlayer)
		{
			
			regenModeIsCombat = cachedPlayer.IsInCombat();
			if(regenModeIsCombat)
				attributeName = 'vitalityCombatRegen';
			else
				attributeName = RegenStatEnumToName(regenStat);
				
			if (isAccessibilityAutoHealOn)
			{
				vitPerc = cachedPlayer.GetStatPercents(BCS_Vitality);
				vitThresholdRatio = vitPerc / accessibilityAutoHealThreshold;
				
				if (vitThresholdRatio < 1.f )
				{
					accessibilityMulEffectScale = ClampF(1.f - vitThresholdRatio, 0.f, 1.f);
					accessibilityMulCurr = (accessibilityMulEffectScale + 0.1) * accessibilityMulConst; 
				}					
				else
				{
					accessibilityMulCurr = 1; 
				}
			}				
				
			SetEffectValue();
			
			//W3EE - Begin
			if( glyphword39Duration > 0 )
				glyphword39Duration -= deltaTime;
			//W3EE - End
		}
		
		super.OnUpdate(deltaTime);
		
		if( target.GetStatPercents( BCS_Vitality ) >= 1.0f /*&& !target.HasAbility('Runeword 4 _Stats', true)*/) //W3EE
		{
			target.StopVitalityRegen();
		}
	}
	
	public function RequestValueUpdates()
	{
		if(isOnPlayer)
		{
			cachedPlayer = (CR4Player)target;
			
			inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();			
			isAccessibilityAutoHealOn =  inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealOn') == "true";
			accessibilityMulConst =  StringToInt(inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealMultiplier'));
			accessibilityAutoHealThreshold =  0.01f * StringToFloat(inGameConfigWrapper.GetVarValue('Accessibility', 'LowHPAutoHealThreshold'));
		}
	}

	protected function SetEffectValue()
	{
		if (isAccessibilityAutoHealOn)
		{
			effectValue = target.GetAttributeValue(attributeName);
			effectValue.valueAdditive += accessibilityMulCurr;
		}
		else
			effectValue = target.GetAttributeValue(attributeName);
		
		//W3EE - Begin
		if( isOnPlayer )
		{
			if( target.GetStatPercents(BCS_Vitality) <= 0.5f && witcherPlayer.CanUseSkill(S_Sword_s18) )
				effectValue.valueAdditive += (0.3f * witcherPlayer.GetSkillLevel(S_Sword_s18)) * (1.f - target.GetStatPercents(BCS_Vitality) * 2) * (witcherPlayer.GetAdrenalineEffect().GetFullValue());
			
			if( witcherPlayer.IsSetBonusActive(EISB_RedWolf_2) )
				effectValue.valueAdditive += 0.3f * witcherPlayer.GetStat(BCS_Toxicity);
			
			if( witcherPlayer.CountEffectsOfType(EET_RubedoDominance) > 0 )
				effectValue.valueAdditive += ((10.f * ((W3Effect_RubedoDominance)witcherPlayer.GetBuff(EET_RubedoDominance)).GetSecondarySubstanceEffectLevel()) * (1.f + 0.2f * witcherPlayer.GetSkillLevel(S_Alchemy_s03)));
			
			if( witcherPlayer.CountEffectsOfType(EET_WhiteRaffardDecoction) > 0 && witcherPlayer.GetStatPercents(BCS_Toxicity) < 0.9f )
				effectValue.valueAdditive += (30.f + 10.f * witcherPlayer.GetPotionBuffLevel(EET_WhiteRaffardDecoction)) * FloorF(5.f - witcherPlayer.GetStatPercents(BCS_Vitality) * 5.f);
			
			if( FactsQuerySum("TaFtSComplete") > 0 && (witcherPlayer.GetEquippedMutationType() == EPMT_Mutation3 || witcherPlayer.GetEquippedMutationType() == EPMT_Mutation7 || witcherPlayer.GetEquippedMutationType() == EPMT_Mutation8 || witcherPlayer.GetEquippedMutationType() == EPMT_Mutation9) )
				effectValue.valueAdditive += 20.f;
			
			if( witcherPlayer.IsSetBonusActive(EISB_Ofieri) )
				effectValue.valueAdditive += 3.f * Combat().GetOfieriSetBonusCount("mending");
			
			if( (witcherPlayer.HasAbility('Glyphword 47 _Stats', true) || witcherPlayer.HasAbility('Glyphword 48 _Stats', true)) && (witcherPlayer.HasBuff(EET_Decoction1) || witcherPlayer.HasBuff(EET_Decoction2) || witcherPlayer.HasBuff(EET_Decoction3) || witcherPlayer.HasBuff(EET_Decoction4)) )
				effectValue.valueAdditive += 20.f;
			
			if( witcherPlayer.IsQuenActive(true) && (witcherPlayer.HasAbility('Glyphword 23 _Stats', true) || witcherPlayer.HasAbility('Glyphword 24 _Stats', true)) )
				effectValue += effectValue * 2.f;
			
			if( witcherPlayer.HasAbility('Glyphword 37 _Stats', true) || witcherPlayer.HasAbility('Glyphword 38 _Stats', true) || witcherPlayer.HasAbility('Glyphword 39 _Stats', true) )
			{
				if( witcherPlayer.GetStat(BCS_Stamina) >= witcherPlayer.GetStatMax(BCS_Stamina) )
				{
					effectValue.valueAdditive += Combat().GetPlayerStaminaRegen() / Options().StamRegenGlobal() * 2.f;
					if( !witcherPlayer.IsPlayerMoving() && (witcherPlayer.HasAbility('Glyphword 38 _Stats', true) || witcherPlayer.HasAbility('Glyphword 39 _Stats', true)) )
						effectValue.valueAdditive += Combat().GetPlayerStaminaRegen() / Options().StamRegenGlobal() * 2.f;
				}
				if( witcherPlayer.GetStat(BCS_Focus) >= witcherPlayer.GetStatMax(BCS_Focus) )
				{
					effectValue.valueAdditive += Combat().GetPlayerVigorRegen() * 200.f;
					if( !witcherPlayer.IsPlayerMoving() && (witcherPlayer.HasAbility('Glyphword 38 _Stats', true) || witcherPlayer.HasAbility('Glyphword 39 _Stats', true)) )
						effectValue.valueAdditive += Combat().GetPlayerVigorRegen() * 200.f;
				}
			}
			
			if( witcherPlayer.HasAbility('Glyphword 38 _Stats', true) || witcherPlayer.HasAbility('Glyphword 39 _Stats', true) )
				effectValue.valueAdditive *= 1.f + (1.f - target.GetStatPercents(BCS_Vitality)) / 2;
			
			if( witcherPlayer.IsMeditating() )
				effectValue += effectValue;
			else if( witcherPlayer.IsMutationActive(EPMT_Mutation7) && !thePlayer.IsCiri() )
				effectValue.valueAdditive = 0.f;
			
			if( glyphword39Duration > 0 )
				effectValue.valueAdditive += glyphword39Value;
			
			if( thePlayer.IsCiri() )
				effectValue.valueAdditive += 100.f * (1.f - target.GetStatPercents(BCS_Vitality));
		}
		//W3EE - End
	}
	
	//W3EE - Begin
	public function SetGlyphword39Value(amount : float)
	{
		glyphword39Value = amount / 20;
		//theGame.GetGuiManager().ShowNotification("Took " + amount + " Damage");
	}
	
	public function ResetGlyphword39Duration()
	{
		glyphword39Duration = 10.f;
		witcherPlayer.PlayEffect('runeword_8');
		witcherPlayer.AddTimer('StopRuneword8Effect', 9.f, true);
	}
	//W3EE - End
}