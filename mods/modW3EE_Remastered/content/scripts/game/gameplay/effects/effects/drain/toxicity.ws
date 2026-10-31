/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
//W3EE - Begin
struct SToxicityEntry
{
	var effectType : EEffectType;
	var activeTox : float;
	var dormantTox : float;
	var totalTox : float;
	var duration : float;
}
//W3EE - End
class W3Effect_Toxicity extends CBaseGameplayEffect
{
	
	default effectType = EET_Toxicity;
	default attributeName = 'toxicityRegen';
	default isPositive = false;
	default isNeutral = true;
	default isNegative = false;	
		
	
	private saved var dmgTypeName 			: name;							
	private saved var toxThresholdEffect	: int;
	private var delayToNextVFXUpdate		: float;
	private var witcher 					: W3PlayerWitcher; //W3EE
	private var updateInterval				: float; //W3EE
	
	public function CacheSettings()
	{
		//dmgTypeName = theGame.params.DAMAGE_NAME_DIRECT; //W3EE
		
		super.CacheSettings();
	}
	
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		//var witcher : W3PlayerWitcher; //W3EE
	
		if( !((W3PlayerWitcher)target) )
		{
			LogAssert(false, "W3Effect_Toxicity.OnEffectAdded: effect added on non-CR4Player object - aborting!");
			return false;
		}
		
		witcher = GetWitcherPlayer();
	
		
		//if( witcher.GetStatPercents(BCS_Toxicity) >= witcher.GetToxicityDamageThreshold()) //W3EE
		if(witcher.HasBuff(EET_ToxicityFever))
			switchCameraEffect = true;
		else
			switchCameraEffect = false;
			
		
		super.OnEffectAdded(customParams);	
	}

	
	
	event OnUpdate(deltaTime : float)
	{
		var dmg, maxStat, toxicity, threshold, drainVal, toxicityPerc, gainVal, netVal, damageVal : float; //W3EE
		var dmgValue, min, max : SAbilityAttributeValue;
		var currentStateName 	: name;
		var currentThreshold	: int;

		super.OnUpdate(deltaTime);
		
		//W3EE - Begin
		//toxicity = GetWitcherPlayer().GetStat(BCS_Toxicity, false) / GetWitcherPlayer().GetStatMax(BCS_Toxicity);
		toxicity = witcher.GetStat(BCS_Toxicity, false);
		threshold = GetWitcherPlayer().GetToxicityDamageThreshold();
		toxicityPerc = toxicity / witcher.GetStatMax(BCS_Toxicity);

		
		/*
		if( toxicity >= threshold && !isPlayingCameraEffect)	
			switchCameraEffect = true;
		else if(toxicity < threshold && isPlayingCameraEffect)	
			switchCameraEffect = true;
		*/
		//W3EE - End
		
		if( delayToNextVFXUpdate <= 0 )
		{				
			
			
			
			if(toxicity <= 0.0f)		currentThreshold = 0;
			else if(toxicity < 0.5f)	currentThreshold = 1; //W3EE - Vanilla Value < 0.25
			else if(toxicity < 0.75f)	currentThreshold = 2; //W3EE - Vanilla Value < 0.5
			else if(toxicity < 0.9f)	currentThreshold = 3; //W3EE - Vanilla Value < 0.75
			else if(toxicity >= 0.9f)	currentThreshold = 4; //W3EE - Vanilla Value >= 0.75

			
			if(  (toxThresholdEffect != currentThreshold &&  !target.IsEffectActive('invisible' )) || witcher.ShouldRefreshFace() ) //W3EE
			{
				
				
				
				if (toxThresholdEffect < 0) 
					toxThresholdEffect = 0;
				
				switch ( toxThresholdEffect )
				{
					case 0: 
						if (currentThreshold > toxThresholdEffect) 
						{ 
							PlayHeadEffect('toxic_000_025'); 
							toxThresholdEffect += 1; 							
						} 
						break;
					case 1: 
						if (currentThreshold > toxThresholdEffect) 
						{ 
							PlayHeadEffect('toxic_025_050'); 
							toxThresholdEffect += 1; 
						} 
						else 
						{ 
							PlayHeadEffect('toxic_025_000'); 
							toxThresholdEffect -= 1; 
						} 
						break;
					case 2: 
						if (currentThreshold > toxThresholdEffect) 
						{ 
							PlayHeadEffect('toxic_050_075'); 
							toxThresholdEffect += 1; 
						} 
						else 
						{ 
							PlayHeadEffect('toxic_050_025'); 
							toxThresholdEffect -= 1; 
						} 
						break;
					case 3: 
						if (currentThreshold > toxThresholdEffect) 
						{ 
							PlayHeadEffect('toxic_075_100'); 
							toxThresholdEffect += 1; 
						}
						else 
						{ 
							PlayHeadEffect('toxic_075_050'); 
							toxThresholdEffect -= 1; 
						} 
						break;
					case 4: 
						PlayHeadEffect('toxic_100_075'); 
						toxThresholdEffect -= 1; 
						break;
				}
				
				
				
				delayToNextVFXUpdate = 2;
				witcher.ResetRefreshFace(); //W3EE
			}		
			
		}
		else
		{
			delayToNextVFXUpdate -= deltaTime;
		}
				
		//W3EE - Begin
		/*
		if(toxicity >= threshold)
		{
			currentStateName = thePlayer.GetCurrentStateName();
			if(currentStateName != 'Meditation' && currentStateName != 'MeditationWaiting')
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, dmgTypeName, min, max);	
			
				if(DamageHitsVitality(dmgTypeName))
					maxStat = target.GetStatMax(BCS_Vitality);
				else
					maxStat = target.GetStatMax(BCS_Essence);
				
				dmgValue = GetAttributeRandomizedValue(min, max);
				dmg = MaxF(0, deltaTime * ( dmgValue.valueAdditive + (dmgValue.valueMultiplicative * (maxStat + dmgValue.valueBase) ) ));
				
				
				
				
				
				
			
				if(dmg > 0)
					effectManager.CacheDamage(dmgTypeName,dmg,NULL,this,deltaTime,true,CPS_Undefined,false);
				else
					LogAssert(false, "W3Effect_Toxicity: should deal damage but deals 0 damage!");
			}
			
			
			if(thePlayer.CanUseSkill(S_Alchemy_s20) && !target.HasBuff(EET_IgnorePain))
				target.AddEffectDefault(EET_IgnorePain, target, 'IgnorePain');
		}
		else
		{
			
			target.RemoveBuff(EET_IgnorePain);
		}
			
		
		drainVal = deltaTime * (effectValue.valueAdditive + (effectValue.valueMultiplicative * (effectValue.valueBase + target.GetStatMax(BCS_Toxicity)) ) );
		
		
		if(!target.IsInCombat())
			drainVal *= 1.1; 
			
		effectManager.CacheStatUpdate(BCS_Toxicity, drainVal);
		*/
		
		UpdateEntries(deltaTime);
		updateInterval += deltaTime;
		if( updateInterval >= 1.0f )
		{
			updateInterval = 0;
			drainVal = GetToxicityDrain();
			if( witcher.IsMutationActive(EPMT_Mutation5) && !witcher.IsMeditating() )
				drainVal = 0.f;
			gainVal = GetToxicityGain();
			netVal = gainVal + drainVal;
			
			if( !target.HasBuff(EET_ToxicityFever) && toxicityPerc >= 1 )
				StartFever();
			if( target.HasBuff(EET_ToxicityFever) && toxicityPerc <= 0.9f )
				target.RemoveBuff(EET_ToxicityFever);
			
			effectManager.CacheStatUpdate(BCS_Toxicity, netVal);
			if( toxicityPerc >= 1 && netVal > 0 && ((W3Effect_ToxicityFever)target.GetBuff(EET_ToxicityFever)).IsFeverActive() )
			{
				damageVal = netVal / 50 * (1 - 0.1f * witcher.GetSkillLevel(S_Alchemy_s15)) * witcher.GetStatMax(BCS_Vitality) * Options().GetDifficultySettingMod();
				effectManager.CacheDamage(theGame.params.DAMAGE_NAME_POISON, damageVal, NULL, this, 1.0f, true, CPS_Undefined, false);
				effectManager.CacheDamage(theGame.params.DAMAGE_NAME_DIRECT, damageVal, NULL, this, 1.0f, true, CPS_Undefined, false);
			}
		}
		//W3EE - End
	}
	
	function PlayHeadEffect( effect : name, optional stop : bool )
	{
		var inv : CInventoryComponent;
		var headIds : array<SItemUniqueId>;
		var headId : SItemUniqueId;
		var head : CItemEntity;
		var i : int;
		
		inv = target.GetInventory();
		headIds = inv.GetItemsByCategory('head');
		
		for ( i = 0; i < headIds.Size(); i+=1 )
		{
			if ( !inv.IsItemMounted( headIds[i] ) )
			{
				continue;
			}
			
			headId = headIds[i];
					
			if(!inv.IsIdValid( headId ))
			{
				LogAssert(false, "W3Effect_Toxicity : Can't find head item");
				return;
			}
			
			head = inv.GetItemEntityUnsafe( headId );
			
			if( !head )
			{
				LogAssert(false, "W3Effect_Toxicity : head item is null");
				return;
			}

			if ( stop )
			{
				if ( head.IsEffectActive( effect ) ) 	
					head.StopEffect( effect );
			}
			else
			{
				if ( head.IsEffectActive( effect ) ) 	
					head.StopEffect( effect );			
				head.PlayEffectSingle( effect );
			}
		}
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		
		toxThresholdEffect = -1;
		witcher = (W3PlayerWitcher)t; //W3EE
	}
	
	event OnEffectRemoved()
	{
		RemoveAllEntries(); //W3EE
		super.OnEffectRemoved();
		
		
		if(thePlayer.CanUseSkill(S_Alchemy_s20) && target.HasBuff(EET_IgnorePain))
			target.RemoveBuff(EET_IgnorePain);
			
		
		
		
		
		PlayHeadEffect( 'toxic_000_025', true );
		PlayHeadEffect( 'toxic_025_050', true );
		PlayHeadEffect( 'toxic_050_075', true );
		PlayHeadEffect( 'toxic_075_100', true );
		
		PlayHeadEffect( 'toxic_050_025', true );
		PlayHeadEffect( 'toxic_075_050', true );
		PlayHeadEffect( 'toxic_100_075', true );
		
		
		PlayHeadEffect( 'toxic_025_000', true ); 
		
		toxThresholdEffect = 0;
		//W3EE - Begin
		if( theSound.SoundIsBankLoaded("fever02a.bnk") )
			theSound.SoundUnloadBank("fever02a.bnk");
		
		((W3PlayerAbilityManager)target.GetAbilityManager()).Glyphword48MutagenUpdate(0);
		//W3EE - End
	}
	
	protected function SetEffectValue()
	{
		RecalcEffectValue();
	}
	
	public function RecalcEffectValue()
	{
		var min, max : SAbilityAttributeValue;
		var dm : CDefinitionsManagerAccessor;
	
		if(!IsNameValid(abilityName))
			return;
	
		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributeValue(abilityName, attributeName, min, max);
		effectValue = GetAttributeRandomizedValue(min, max);
		
		
		if(thePlayer.CanUseSkill(S_Alchemy_s15))
			effectValue += thePlayer.GetSkillAttributeValue(S_Alchemy_s15, attributeName, false, true) * thePlayer.GetSkillLevel(S_Alchemy_s15);
			
		if(thePlayer.HasAbility('Runeword 8 Regen'))
			effectValue += thePlayer.GetAbilityAttributeValue('Runeword 8 Regen', 'toxicityRegen');
	}
	//W3EE - Begin
	public function DisplayToxicity()
	{
		var i : int;
		var str : string;
		
		var messageData 	: W3MessagePopupData;
		var messagePopupRef : CR4MessagePopup;
		
		for(i=0; i<toxicityEntries.Size(); i+=1)
		{
			str += "effect: " + toxicityEntries[i].effectType + "<br>total tox: " + toxicityEntries[i].totalTox + "<br>active tox: " + toxicityEntries[i].activeTox + "<br>dormant tox: " + toxicityEntries[i].dormantTox + "<br><br>";
		}
		
		theGame.GetGuiManager().ShowUserDialogAdv( 0, "Toxicity info", str, false, UDB_Ok );
		//theGame.GetGuiManager().ShowNotification( str, 8.f );
	}
	
	public function StartFever()
	{
		var poisonEffect : W3Effect_Poison;
		var effectParams	: SCustomEffectParams;
		
		if( witcher.HasBuff(EET_GoldenOriole) )
		{
			witcher.DrainToxicity(witcher.GetStatMax(BCS_Toxicity) * 0.25f);
			if( witcher.HasBuff(EET_Poison) )
			{
				poisonEffect = (W3Effect_Poison)witcher.GetBuff(EET_Poison);
				poisonEffect.RemoveStack(poisonEffect.GetStacks());
			}
			witcher.RemoveBuff(EET_ToxicityVenom);
			witcher.RemoveBuff(EET_GoldenOriole);
			return;
		}
		
		effectParams.effectType = EET_ToxicityFever;
		effectParams.sourceName = "ToxicityFeverEffect";
		effectParams.duration = -1;
		
		target.AddEffectCustom(effectParams);
	}
	
	private saved var toxicityEntries : array<SToxicityEntry>;
	public function AddToxicityEntry( effect : EEffectType, toxicity: float, duration : float )
	{
		toxicityEntries.PushBack(SToxicityEntry(effect, toxicity, 0, toxicity, duration));
		if( witcher.HasAbility('Glyphword 48 _Stats', true) )
			((W3PlayerAbilityManager)target.GetAbilityManager()).Glyphword48MutagenUpdate(toxicityEntries.Size());
	}
	
	public function GetToxicityEntryCount() : int
	{
		return toxicityEntries.Size();
	}
	
	public function ClearToxicityHoney( activeReduction : float, dormantReduction : float )
	{
		var i : int;
		var drainVal : float;
		
		for(i=0; i<toxicityEntries.Size(); i+=1)
		{
			toxicityEntries[i].activeTox -= toxicityEntries[i].activeTox * activeReduction;
		}
		drainVal = witcher.GetStat(BCS_Toxicity, false) * dormantReduction;
		effectManager.CacheStatUpdate(BCS_Toxicity, -1 * drainVal);
	}
	
	public function ClearToxicityFever()
	{
		var i : int;
		var drainVal, reductionVal, sum : float;
		
		reductionVal = 15.f;
		for(i=0; i<toxicityEntries.Size(); i+=1)
		{
			if( toxicityEntries[i].dormantTox <= reductionVal )
			{
				reductionVal -= toxicityEntries[i].dormantTox;
				drainVal += toxicityEntries[i].dormantTox;
				toxicityEntries[i].dormantTox = 0.f;
			}
			else
			{
				drainVal += reductionVal;
				toxicityEntries[i].dormantTox -= reductionVal;
				break;
			}
		}
		
		effectManager.CacheStatUpdate(BCS_Toxicity, -1 * drainVal);
	}
	
	private function RemoveAllEntries()
	{
		var i, size : int;
		var drainVal : float;
		
		size = toxicityEntries.Size();
		for(i=0; i<size; i+=1)
		{
			drainVal = toxicityEntries[i].activeTox + toxicityEntries[i].dormantTox;
			effectManager.CacheStatUpdate(BCS_Toxicity, -1 * drainVal);
			toxicityEntries.Erase(i);
		}
		
		if( witcher.HasAbility('Glyphword 48 _Stats', true) )
			((W3PlayerAbilityManager)target.GetAbilityManager()).Glyphword48MutagenUpdate(toxicityEntries.Size());
	}
	
	private function FindInertElement() : int
	{
		var i : int;
		
		for(i=0; i<toxicityEntries.Size(); i+=1)
		{
			if( toxicityEntries[i].activeTox <= 0 && toxicityEntries[i].dormantTox <= 0 )
				return i;
		}
		
		return -1;
	}
	
	private function UpdateEntries( dt : float )
	{
		var i, idx : int;
		
		for(i=0; i<toxicityEntries.Size(); i+=1)
		{
			if( toxicityEntries[i].effectType == EET_Swallow && witcher.GetStatPercents(BCS_Vitality) >= 0.99f)
				continue;
			else
			if( toxicityEntries[i].effectType == EET_TawnyOwl && GetDayPart(GameTimeCreate()) == EDP_Midnight )
				continue;
			else
			if( toxicityEntries[i].effectType == EET_WhiteRaffardDecoction && witcher.GetStatPercents(BCS_Toxicity) < 0.9f )
				toxicityEntries[i].activeTox -= toxicityEntries[i].totalTox / toxicityEntries[i].duration * FloorF(6.f - witcher.GetStatPercents(BCS_Vitality) * 5.f) * dt;
			else
				toxicityEntries[i].activeTox -= toxicityEntries[i].totalTox / toxicityEntries[i].duration * dt;
		}
		
		do
		{
			idx = FindInertElement();
			if( idx > -1 )
			{
				toxicityEntries.Erase(idx);
				if( witcher.HasAbility('Glyphword 48 _Stats', true) )
					((W3PlayerAbilityManager)target.GetAbilityManager()).Glyphword48MutagenUpdate(toxicityEntries.Size());
			}
		}
		while(idx > -1)
	}
	
	public function GetToxicityDrain() : float
	{
		var drainVal, drainValMult : float;
		var toxicityDrain : SAbilityAttributeValue;
		
		toxicityDrain = witcher.GetAttributeValue('toxicity_drain');
		if( witcher.IsSetBonusActive(EISB_Ofieri) )
			toxicityDrain.valueMultiplicative += 0.1f * Combat().GetOfieriSetBonusCount("binding");
		drainValMult = 1.f + toxicityDrain.valueMultiplicative;
		drainValMult += witcher.GetSkillLevel(S_Alchemy_s17) * 0.1f;
		if( witcher.HasBuff(EET_WellHydrated) && (witcher.HasAbility('Glyphword 44 _Stats', true) || witcher.HasAbility('Glyphword 45 _Stats', true)) )
			drainValMult += 0.2f;
		if( witcher.HasAbility('Glyphword 48 _Stats', true) )
			drainValMult += 0.05f * toxicityEntries.Size();
		if( witcher.HasBuff(EET_AlbedoDominance) )
			drainValMult += ((0.25f * ((W3Effect_AlbedoDominance)witcher.GetBuff(EET_AlbedoDominance)).GetSecondarySubstanceEffectLevel()) * (1.f + 0.2f * witcher.GetSkillLevel(S_Alchemy_s02)));
		if( witcher.HasBuff(EET_MariborForest) && witcher.GetStatPercents(BCS_Focus) >= 0.99f )
			drainValMult += 0.5f;
		if( witcher.HasBuff(EET_Decoction10) )
			drainValMult += ((W3Effect_Poise)witcher.GetBuff(EET_Poise)).GetPoisePercentage() / 2.f;
		if( FactsQuerySum("TaFtSComplete") > 0 && (witcher.GetEquippedMutationType() == EPMT_Mutation4 || witcher.GetEquippedMutationType() == EPMT_Mutation5 || witcher.GetEquippedMutationType() == EPMT_Mutation10) )
			drainValMult += 0.5f;
		drainVal = -0.2f * drainValMult;
		if( witcher.IsMeditating() )
			drainVal *= 5.f;
		if( toxicityEntries.Size() == 0 && !witcher.HasBuff(EET_Poison) && Options().GetToxicityResidualDegenMult() > 0 )
			drainVal *= Options().GetToxicityResidualDegenMult();
		if( Options().GetToxicityActiveDegenMult() > 0 )
			drainVal *= Options().GetToxicityActiveDegenMult();
		drainVal *= MaxF(0.1f, witcher.GetStat(BCS_Toxicity, false) / witcher.GetStatMax(BCS_Toxicity));
		drainVal /= Options().GetDifficultySettingMod();
		
		if( 0.001f >= GetToxicityGain() && !witcher.IsMeditating() && (witcher.HasAbility('Glyphword 46 _Stats', true) || witcher.HasAbility('Glyphword 47 _Stats', true) || witcher.HasAbility('Glyphword 48 _Stats', true)) )
			drainVal = 0;
		
		return drainVal;
	}
	
	public function GetToxicityGain() : float
	{
		var i : int;
		var gainVal, resistPts, resistPerc : float;
		
		gainVal = 0;
		for(i=0; i<toxicityEntries.Size(); i+=1)
		{
			if( toxicityEntries[i].effectType == EET_Swallow && witcher.GetStatPercents(BCS_Vitality) >= 0.99f)
				continue;
			else
			if( toxicityEntries[i].effectType == EET_TawnyOwl && GetDayPart(GameTimeCreate()) == EDP_Midnight )
				continue;
			else
			if( toxicityEntries[i].effectType == EET_WhiteRaffardDecoction && witcher.GetStatPercents(BCS_Toxicity) < 0.9f )
				gainVal += toxicityEntries[i].totalTox / toxicityEntries[i].duration * FloorF(6.f - witcher.GetStatPercents(BCS_Vitality) * 5.f);
			else
				gainVal += toxicityEntries[i].totalTox / toxicityEntries[i].duration;
		}
		
		if( witcher.HasBuff(EET_Poison) )
		{
			witcher.GetResistValue(CDS_PoisonRes, resistPts, resistPerc);
			gainVal += 0.3 * ((W3Effect_Poison)witcher.GetBuff(EET_Poison)).GetStacks() * (1.f - resistPerc);
		}
		
		return gainVal;
	}
	//W3EE - End
}
