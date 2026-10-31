/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Action_Attack extends W3DamageAction
{
	private var weaponId : SItemUniqueId; 			
	private var crossbowId : SItemUniqueId;			
	private var attackName : name;					
	private var attackTypeName : name;				
	private var isAttackReflected : bool;			
	private var isParried : bool;					
	private var isCountered : bool;					
	private var attackAnimName : name;				
	private var hitTime : float;					
	private var weaponEntity : CItemEntity;			
	private var weaponSlot : name;					
	private var boneIndex : int;					
	private var soundAttackType : name;				
	private var usedZeroStaminaPerk : bool;			
	private var applyBuffsIfParried : bool;			
		
	
	//W3EE - Begin
	private var forceFinisher : bool;
	private var forceInjury : bool;
	private var perfectParried : bool;
	public function SetForceInjury( b : bool )
	{
		forceInjury = b;
	}
	
	public function GetForceInjury() : bool
	{
		return forceInjury;
	}
	
	public function SetForceFinisher( b : bool )
	{
		forceFinisher = b;
	}
	
	public function GetForceFinisher() : bool
	{
		return forceFinisher;
	}
	
	public function GetCrossbowID() : SItemUniqueId
	{
		return crossbowId;
	}
	
	public function SetIsPerfectParried( b : bool )
	{
		perfectParried = b;
	}
	
	public function IsPerfectParried() : bool
	{
		return perfectParried;
	}
	//W3EE - End
	
	public function Init( attackr : CGameplayEntity, victm : CGameplayEntity, causr : IScriptable, weapId : SItemUniqueId, attName : name, src :string, hrt : EHitReactionType, canParry : bool, canDodge : bool, skillName : name, swType : EAttackSwingType, swDir : EAttackSwingDirection, isM : bool, isR : bool, isW : bool, isE : bool, optional hitFX_ : name, optional hitBackFX_ : name, optional hitParriedFX_ : name, optional hitBackParriedFX_ : name, optional crossId : SItemUniqueId, optional attAnimName : name) //W3EE
	{		
		var player : CR4Player;
		var powerStat : ECharacterPowerStats;
	
		if(attName == '' || !attackr)
		{
			LogAssert(false, "W3Action_Attack.Init: missing attack data - debug (attack name OR attacker)!");
			return;
		}
		
		
		if(theGame.GetDefinitionsManager().AbilityHasTag(attName, 'UsesSpellPower'))
			powerStat = CPS_SpellPower;
		else
			powerStat = CPS_AttackPower;
		
		
		super.Initialize( attackr, victm, causr, src, hrt, powerStat, isM, isR, isW, isE, hitFX_, hitBackFX_, hitParriedFX_, hitBackParriedFX_);
		
		swingType = swType;
		swingDirection = swDir;
		//W3EE - Begin
		if( attAnimName != '' )
			attackName = Combat().GetModifiedAttackName((CActor)attackr, attName, attAnimName);
		else
			attackName = attName;
		//W3EE - End
		weaponId = weapId;
		crossbowId = crossId;
		canBeParried = canParry && !attackr.HasAbility( 'UnblockableAttacks' ) && !StrContains(NameToString(attackName), "tagger"); //W3EE
		canBeDodged = canDodge;
		soundAttackType = 'empty';
		boneIndex = -1;	
		
		player = (CR4Player)attacker;
		if(IsBasicAttack(skillName) || (player && player.CanUseSkill(SkillNameToEnum(skillName))) )
			attackTypeName = skillName;
		else
			attackTypeName = '';
		
		FillDataFromWeapon();
		FillDataFromAttackName();		
	}
	
	protected function Clear()
	{
		weaponId = GetInvalidUniqueId();
		crossbowId = GetInvalidUniqueId();
		attackName = '';
		attackTypeName = '';
		isAttackReflected = false;
		isParried = false;
		isCountered = false;
		attackAnimName = '';
		hitTime = 0;
		weaponSlot = '';
		soundAttackType = 'empty';
		boneIndex = -1;
		forceExplosionDismemberment = false;
		weaponEntity = NULL;		
	}
	
	
	public function Initialize( att : CGameplayEntity, vict : CGameplayEntity, caus : IScriptable, src : string, hrt : EHitReactionType, pwrStatType : ECharacterPowerStats, isM : bool, isR : bool, isW : bool, isE : bool, optional hitFX_ : name, optional hitBackFX_ : name, optional hitParriedFX_ : name, optional hitBackParriedFX_ : name)
	{
		LogAssert(false, "W3Action_Attack.Initialize: my friend... you are using wrong constructor :P - use Init()");
	}
	
	
	private function FillDataFromWeapon()
	{
		var inv : CInventoryComponent;
		var i, size : int;
		var dmgTypes : array< name >;
		var buffs : array<SEffectInfo>;
		var actorAttacker : CActor;
		var bolt : W3BoltProjectile; //W3EE
		
		bolt = (W3BoltProjectile)causer; //W3EE
		inv = attacker.GetInventory(); //W3EE
		
		actorAttacker = ( CActor ) attacker;
		if ( actorAttacker )
		{
			//W3EE - Begin
			if( bolt )
				size = bolt.GetDTNames(dmgTypes);
			else
				size = inv.GetWeaponDTNames(weaponId, dmgTypes);	
			
			for( i = 0; i < size; i += 1 )
				AddDamage( dmgTypes[i], actorAttacker.GetTotalWeaponDamage(weaponId, dmgTypes[i], crossbowId, bolt) );
			
			if( bolt )
				size = bolt.GetBoltBuffs(buffs);
			else
				size = inv.GetItemBuffs(weaponId, buffs);
			//W3EE - End
			for( i = 0; i < size; i += 1 )
				AddEffectInfo(buffs[i].effectType, , , buffs[i].effectAbilityName, ,buffs[i].applyChance);
				
			if( theGame.CanLog() && dmgTypes.Size() == 0 && buffs.Size() == 0 )
			{
				LogDMHits( "Weapon " + inv.GetItemName( weaponId ) + " has no damage and no buff stats defined - it will do nothing!" );
			}
		}
	}
	
	
	private function FillDataFromAttackName()
	{
		var attributes, abilities : array<name>;
		var i, size : int;
		var dm : CDefinitionsManagerAccessor;
		var dmgVal : float;
		var dmgAttributeName, abilityName : name;
		var type : EEffectType;
		var min, max : SAbilityAttributeValue;
		var actorAttacker : CActor;	

		actorAttacker = ( CActor ) attacker;
		
		dm = theGame.GetDefinitionsManager();		
		
		
		if(actorAttacker && IsBasicAttack(attackName))
		{
			for (i=0; i<dmgInfos.Size(); i+=1)
			{
				
				dmgAttributeName = GetBasicAttackDamageAttributeName(attackName, dmgInfos[i].dmgType);		
				dmgVal = CalculateAttributeValue(actorAttacker.GetAttributeValue(dmgAttributeName));
				
				if(dmgVal > 0)
					AddDamage(dmgInfos[i].dmgType, dmgVal);

				
				
				
				
			}
		}
				
		
		dm.GetContainedAbilities(attackName, abilities);
		size = abilities.Size();
		for( i = 0; i < size; i += 1 )
		{
			
			if( IsEffectNameValid(abilities[i]) )
			{
				EffectNameToType(abilities[i], type, abilityName);
				AddEffectInfo(type, , , abilityName);
			}
		}
		
		dm.GetContainedAbilities(attackName, attributes);
		size = attributes.Size();
		for( i = 0; i < size; i += 1 )
		{
			
			if( IsDamageTypeNameValid(attributes[i]) )
			{
				dm.GetAbilityAttributeValue(attackName, attributes[i], min, max);
				dmgVal = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));				
				
				if(dmgVal > 0)
					AddDamage(attributes[i], dmgVal);
			}
		}
	}
	
	function AddDamage( dmgType : name, dmgVal : float )
	{		
		if( theGame.GetDefinitionsManager().AbilityHasTag( attackName, theGame.params.ATTACK_NO_DAMAGE ) )
		{
			return;
		}
		
		if ( IsActionMelee() )
		{
			dmgVal = RandRangeF( dmgVal*1.1, dmgVal*0.9 ); //Kolaris - Damage Randomization Note
		}
		
		super.AddDamage( dmgType, dmgVal );
	}
	
	function AddEffectInfo(effectType : EEffectType, optional duration : float, optional effectCustomValue : SAbilityAttributeValue, optional effectAbilityName : name, optional customParams : W3BuffCustomParams, optional buffApplyChance : float )
	{
		
		if( theGame.GetDefinitionsManager().AbilityHasTag( attackName, theGame.params.ATTACK_NO_DAMAGE ) )
		{
			
			
			if(effectType == EET_Bleeding /*|| effectType == EET_Bleeding1 || effectType == EET_Bleeding2 || effectType == EET_Bleeding3*/) //W3EE
			
				return;
		}
		
		super.AddEffectInfo(effectType, duration, effectCustomValue, effectAbilityName, customParams, buffApplyChance);
	}
	
	public function GetPowerStatBonusAbilityTag() : name		{return attackName;}
	public function GetWeaponId() : SItemUniqueId				{return weaponId;}
	public function SetIsParried(b : bool)						{isParried = b;}
	public function IsParried() : bool							{return isParried;}
	public function SetIsCountered(b : bool)					{isCountered = b;}
	public function IsCountered() : bool						{return isCountered;}
	public function SetAttackAnimName(a : name)					{attackAnimName = a;}
	public function GetAttackAnimName() : name					{return attackAnimName;}
	public function SetHitTime(t : float)						{hitTime = t;}
	public function GetHitTime() : float						{return hitTime;}	
	public function SetWeaponEntity(e : CItemEntity)			{weaponEntity = e;}
	public function GetWeaponEntity() : CItemEntity				{return weaponEntity;}	
	public function SetWeaponSlot(w : name)						{weaponSlot = w;}
	public function GetWeaponSlot() : name						{return weaponSlot;}
	public function SetSoundAttackType(s : name)				{soundAttackType = s;}
	public function GetSoundAttackType() : name					{return soundAttackType;}	
	public function UsedZeroStaminaPerk() : bool				{return usedZeroStaminaPerk;}
	public function SetUsedZeroStaminaPerk()					{usedZeroStaminaPerk = true;}
	public function ApplyBuffsIfParried() : bool				{return applyBuffsIfParried;}
	public function SetApplyBuffsIfParried(b : bool)			{applyBuffsIfParried = b;}
	
	
	public function GetAttackName() : name						{return attackName;}
	
	
	public function GetAttackTypeName() : name					{return attackTypeName;}
	
	
	public function GetPowerStatValue() : SAbilityAttributeValue
	{
		var min, max, result, horseDamageBonus, tempAttr : SAbilityAttributeValue;
		var witcherAttacker : W3PlayerWitcher;
		var temp : name;
		var actorVictim, actorAttacker : CActor;
		var monsterCategory : EMonsterCategory;
		var tmpBool : bool;
		var horse : CNewNPC;
		var horseSpeed, holdRatio : float;
		var i : int;
		var dm : CDefinitionsManagerAccessor;
		var attributes : array<name>;
		//var mutagenBuff : W3Mutagen28_Effect; //W3EE
		var playerAttacker : CPlayer;
		//var mutagen25 : W3Mutagen25_Effect; //W3EE
		var poiseEffect : W3Effect_NPCPoise; //W3EE
		

		result = super.GetPowerStatValue();
		actorVictim = (CActor)victim;
		actorAttacker = (CActor)attacker;
		
		//W3EE - Begin
		/*
		if(actorVictim && actorAttacker)
		{
			
			theGame.GetMonsterParamsForActor( actorVictim, monsterCategory, temp, tmpBool, tmpBool, tmpBool);
			
			
			if( actorAttacker.GetInventory().ItemHasActiveOilApplied( weaponId, monsterCategory ) )
			{
				actorAttacker.GetInventory().GetItemAbilities(weaponId, attributes);
				result += actorAttacker.GetInventory().GetItemAttributeValue(weaponId, MonsterCategoryToAttackPowerBonus(monsterCategory) );
			}
			
			
			playerAttacker = (CPlayer)actorAttacker;
			if(playerAttacker && playerAttacker.HasBuff(EET_Mutagen28))
			{
				mutagenBuff = (W3Mutagen28_Effect)playerAttacker.GetBuff(EET_Mutagen28);
				result += mutagenBuff.GetMonsterDamageBonus(monsterCategory);				
			}
		}
		*/
		
		witcherAttacker = (W3PlayerWitcher)attacker;
		
		if( actorVictim.IsAttackerAtBack(actorAttacker) )
		{
			min = actorAttacker.GetAttributeValue('damage_from_behind_off');
			if( witcherAttacker && witcherAttacker.inv.IsIdValid(crossbowId) )
				min = witcherAttacker.inv.GetItemAttributeValue(crossbowId, 'damage_from_behind_off');
				
			result.valueMultiplicative += min.valueMultiplicative;
			result -= actorVictim.GetAttributeValue('damage_from_behind_def');
			result.valueMultiplicative += 0.1f;
			if( witcherAttacker && witcherAttacker.CanUseSkill(S_Perk_16) )
				result.valueMultiplicative += 0.1f;
			if( witcherAttacker && witcherAttacker.HasBuff(EET_LynxSetAttack) )
				result.valueMultiplicative += 0.1f * witcherAttacker.GetSetPartsEquipped(EIST_Lynx);
		}
		
		if( actorAttacker.HasBuff(EET_AxiiGuardMe) && GetWitcherPlayer().HasAbility('Glyphword 28 _Stats', true) || GetWitcherPlayer().HasAbility('Glyphword 29 _Stats', true) || GetWitcherPlayer().HasAbility('Glyphword 30 _Stats', true) )
		{
			result.valueMultiplicative += CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue('puppet_damage_bonus'));
		}
		//W3EE - End
		if(witcherAttacker)
		{		
			
			
			

			
			if(witcherAttacker.IsHeavyAttack(attackTypeName) && witcherAttacker.CanUseSkill(S_Sword_2))
				result += witcherAttacker.GetSkillAttributeValue(S_Sword_2, PowerStatEnumToName(CPS_AttackPower), false, true);
			//W3EE - Begin
			/*
			if(witcherAttacker.IsHeavyAttack(attackTypeName) && witcherAttacker.CanUseSkill(S_Sword_s04))
				result += witcherAttacker.GetSkillAttributeValue(S_Sword_s04, PowerStatEnumToName(CPS_AttackPower), false, true) * witcherAttacker.GetSkillLevel(S_Sword_s04);
			
			
			if(witcherAttacker.IsLightAttack(attackTypeName) && witcherAttacker.CanUseSkill(S_Sword_s21))
				result += witcherAttacker.GetSkillAttributeValue(S_Sword_s21, PowerStatEnumToName(CPS_AttackPower), false, true) * witcherAttacker.GetSkillLevel(S_Sword_s21);
			*/	
			
			if( (witcherAttacker.inv.IsIdValid(crossbowId) || (W3ThrowingKnife)causer) && witcherAttacker.CanUseSkill(S_Sword_s13))
			{				
				result.valueMultiplicative += 0.05f * witcherAttacker.GetSkillLevel(S_Sword_s13);
			}
			
			if( (witcherAttacker.inv.IsIdValid(crossbowId) || (W3ThrowingKnife)causer) && witcherAttacker.IsSetBonusActive(EISB_RedWolf_1) )
				result.valueMultiplicative += 0.06f * witcherAttacker.GetSetPartsEquipped(EIST_RedWolf);
			
			if( witcherAttacker.HasBuff(EET_Decoction7) )
				result.valueMultiplicative += 0.4f * (1.f - witcherAttacker.GetStatPercents(BCS_Vitality));
			
			if( witcherAttacker.IsMutationActive(EPMT_Mutation6) && (CNewNPC)actorVictim && ((witcherAttacker.inv.IsIdValid(crossbowId) || (W3ThrowingKnife)causer)) )
			{
				poiseEffect = (W3Effect_NPCPoise)(((CNewNPC)actorVictim).GetBuff(EET_NPCPoise));
				result.valueMultiplicative += 0.5f * (1.f - poiseEffect.GetPoisePercentage());
			}
				
			if( witcherAttacker.IsSetBonusActive(EISB_RedWolf_2) )
				result.valueMultiplicative += 0.002f * witcherAttacker.GetStat(BCS_Toxicity);
			
			if( witcherAttacker.IsSetBonusActive(EISB_Skellige) && (witcherAttacker.IsLightAttack(attackTypeName) || witcherAttacker.IsHeavyAttack(attackTypeName)) && Combat().IsUsingSecondaryWeapon() )
				result.valueMultiplicative += 0.5f;
			
			if( witcherAttacker.HasRecentlyCountered() || witcherAttacker.IsCounterAttack(GetAttackName()) )
			{
				min = witcherAttacker.GetAttributeValue('counter_damage_bonus');
				if( witcherAttacker.inv.IsIdValid(crossbowId) )
					min = witcherAttacker.inv.GetItemAttributeValue(crossbowId, 'counter_damage_bonus');
				
				if( (W3ThrowingKnife)causer )
					min.valueMultiplicative += ((W3ThrowingKnife)causer).GetKnifeCounterBonus();
					
				if( witcherAttacker.CanUseSkill(S_Sword_s11) )
					min += witcherAttacker.GetSkillAttributeValue(S_Sword_s11, PowerStatEnumToName(CPS_AttackPower), false, true) * witcherAttacker.GetSkillLevel(S_Sword_s11);
				
				//Kolaris - Reflection
				witcherAttacker.RemoveAbilityAll('Runeword 27 Ability');
				theGame.GameplayFactsSet( "reflectionCounter", 0);
				
				result.valueMultiplicative += MaxF(min.valueMultiplicative, 0.f);
			}
			
			if( ((CNewNPC)actorVictim).IsAttacking() && ((witcherAttacker.inv.IsIdValid(crossbowId) || (W3ThrowingKnife)causer)) )
			{
				min = witcherAttacker.GetAttributeValue('counter_damage_bonus');
				
				if( (W3ThrowingKnife)causer )
					min.valueMultiplicative += ((W3ThrowingKnife)causer).GetKnifeCounterBonus();
				
				if( witcherAttacker.inv.IsIdValid(crossbowId) )
					min = witcherAttacker.inv.GetItemAttributeValue(crossbowId, 'counter_damage_bonus');
			
				result.valueMultiplicative += MaxF(min.valueMultiplicative, 0.f);
			}
			
			if( witcherAttacker.IsInState('HorseRiding') )
			{
				result += witcherAttacker.GetAttributeValue('attack_power_horseback');
				//Kolaris - Horseman
				if( witcherAttacker.CanUseSkill(S_Perk_02) )
					result.valueMultiplicative += 0.25f;
			}
			/*
			if(witcherAttacker.inv.IsIdValid(crossbowId) && witcherAttacker.CanUseSkill(S_Perk_02))
			{				
				result += witcherAttacker.GetSkillAttributeValue(S_Perk_02, PowerStatEnumToName(CPS_AttackPower), false, true);
			}

			
			if(witcherAttacker.HasRecentlyCountered() && witcherAttacker.CanUseSkill(S_Sword_s11))
			{
				result += witcherAttacker.GetSkillAttributeValue(S_Sword_s11, PowerStatEnumToName(CPS_AttackPower), false, true) * witcherAttacker.GetSkillLevel(S_Sword_s11);
			}

			
			if((witcherAttacker.HasRecentlyCountered() || witcherAttacker.HasRecentlyDodged()) && witcherAttacker.CanUseSkill(S_Sword_s31) && attackName != 'counter_attack_light')
			{
				tempAttr = witcherAttacker.GetSkillAttributeValue(S_Sword_s31, PowerStatEnumToName(CPS_AttackPower), false, true) * witcherAttacker.GetSkillLevel(S_Sword_s31);
				if(attackName == 'bolt')
				{
					
					tempAttr.valueMultiplicative *= CalculateAttributeValue(witcherAttacker.GetSkillAttributeValue(S_Sword_s31, 'crossbow_multiplier', false, true));
					tempAttr.valueAdditive += result.valueAdditive;
				}

				result += tempAttr;
			}
			*/
			//W3EE - End
			
			if(witcherAttacker.IsLightAttack(attackTypeName))
			{
				result += witcherAttacker.GetAttributeValue('attack_power_fast_style');
			}
			
			
			if(witcherAttacker.IsHeavyAttack(attackTypeName))
			{
				result += witcherAttacker.GetAttributeValue('attack_power_heavy_style');
			}
			
			//W3EE - Begin
			if(witcherAttacker.IsMutationActive(EPMT_Mutation9))
			{
				if(witcherAttacker.IsLightAttack(attackTypeName) || witcherAttacker.IsHeavyAttack(attackTypeName))
					result.valueMultiplicative += 0.2f;
			}
			
			if(witcherAttacker.IsMutationActive(EPMT_Mutation1))
			{
				if(witcherAttacker.IsLightAttack(attackTypeName) || witcherAttacker.IsHeavyAttack(attackTypeName))
					result.valueMultiplicative -= 0.5f;
			}
			
			if(witcherAttacker.CountEffectsOfType(EET_NigredoDominance) > 0 )
			{
				result.valueMultiplicative += ((0.05f * ((W3Effect_NigredoDominance)witcherAttacker.GetBuff(EET_NigredoDominance)).GetSecondarySubstanceEffectLevel()) * (1.f + 0.2f * witcherAttacker.GetSkillLevel(S_Alchemy_s01)));
			}
			//W3EE - End
		}
			
		//W3EE - Begin
		/*
		if(actorAttacker)
		{
			horse = (CNewNPC)(actorAttacker.GetUsedVehicle());
			
			if( horse && horse.IsHorse())
			{
				
				
				
				if(actorAttacker == thePlayer && thePlayer.HasBuff(EET_Mutagen25) && IsActionMelee())
				{
					mutagen25 = (W3Mutagen25_Effect)thePlayer.GetBuff(EET_Mutagen25);
					result += mutagen25.GetAttackPowerBonus();
				}
			}
		}
		*/
		//W3EE - End
		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributes(attackName, attributes);		
		for(i=0; i<attributes.Size(); i+=1)
		{
			if(PowerStatNameToEnum(attributes[i]) == powerStatType)
			{
				dm.GetAbilityAttributeValue(attackName, attributes[i], min, max);
				result += GetAttributeRandomizedValue(min, max);
				break;
			}
		}
		
		
		if(result.valueMultiplicative < 0)
			result.valueMultiplicative = 0.001;
		
		return result;
	}
	
	
	public final function GetHitBoneIndex() : int
	{
		var weaponEntity : CItemEntity;
		var weaponSlotMatrix : Matrix;
		var weaponSlotPosition, weaponTipSlotPosition : Vector;
		var i : int;
		var dist, min : float;
		var category : name;
		var cr4HumanoidCombatComponent : CR4HumanoidCombatComponent;
		
		
		if(boneIndex == -1)
		{		
			category = attacker.GetInventory().GetItemCategory(weaponId);
			weaponSlotPosition = MatrixGetTranslation( attacker.GetBoneWorldMatrixByIndex(attacker.GetBoneIndex(weaponSlot)) );
			
			if(category == 'monster_weapon')
			{
				boneIndex = victim.GetRootAnimatedComponent().FindNearestBoneWS(weaponSlotPosition);
			}
			else if(category == 'fist')
			{
			}
			else	
			{
				weaponEntity = attacker.GetInventory().GetItemEntityUnsafe(weaponId);
				if(weaponEntity)
				{
					weaponEntity.CalcEntitySlotMatrix( 'blood_fx_point', weaponSlotMatrix );
					weaponTipSlotPosition = MatrixGetTranslation( weaponSlotMatrix );
					
					cr4HumanoidCombatComponent = (CR4HumanoidCombatComponent)victim.GetComponentByClassName( 'CR4HumanoidCombatComponent' );
					if( cr4HumanoidCombatComponent )
					{
						boneIndex = cr4HumanoidCombatComponent.GetBoneClosestToEdge(weaponSlotPosition, weaponTipSlotPosition);
					}
					else
					{
						boneIndex = victim.GetRootAnimatedComponent().FindNearestBoneToEdgeWS(weaponSlotPosition, weaponTipSlotPosition);
					}
				}
			}
		}
		
		return boneIndex;
	}
}