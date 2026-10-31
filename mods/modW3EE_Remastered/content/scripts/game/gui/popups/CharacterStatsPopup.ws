/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CharacterStatsPopupData extends TextPopupData
{	
	var m_flashValueStorage : CScriptedFlashValueStorage;
	
	protected  function GetContentRef() : string 
	{
		return "StatisticsFullRef";
	}
	
	protected  function DefineDefaultButtons():void
	{
		AddButtonDef("panel_button_common_exit", "escape-gamepad_B", IK_Escape);
		AddButtonDef("input_feedback_scroll_text", "gamepad_R_Scroll");
	}
	
	public function  OnUserFeedback( KeyCode:string ) : void
	{
		if (KeyCode == "escape-gamepad_B") 
		{
			ClosePopup();
		}
	}
	
	public  function GetGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject 
	{
		var gfxData : CScriptedFlashObject;
		
		m_flashValueStorage = parentFlashValueStorage;
		
		gfxData = parentFlashValueStorage.CreateTempFlashObject();
		GetPlayerStatsGFxData(parentFlashValueStorage);
		gfxData.SetMemberFlashString("ContentRef", GetContentRef());
		
		return gfxData;
	}
}

function GetPlayerStatsGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject
{ 
	var statsArray : CScriptedFlashArray;
	var gfxData    : CScriptedFlashObject;
	
	var gfxSilverDamage : CScriptedFlashObject;
	var gfxSteelDamage  : CScriptedFlashObject;
	var gfxArmor 		: CScriptedFlashObject;
	var gfxVitality 	: CScriptedFlashObject;
	var gfxSpellPower 	: CScriptedFlashObject;
	var gfxVigorStat 	: CScriptedFlashObject; //W3EE
	var gfxPoiseStat 	: CScriptedFlashObject; //W3EE
	var gfxAdrenaline 	: CScriptedFlashObject; //W3EE
	var gfxToxicity 	: CScriptedFlashObject;
	var gfxStamina 		: CScriptedFlashObject;
	//var gfxCrossbow  	: CScriptedFlashObject; //W3EE
	//var gfxAdditional  	: CScriptedFlashObject; //W3EE
	
	var gfxSilverDamageSub : CScriptedFlashArray;
	var gfxSteelDamageSub  : CScriptedFlashArray;
	var gfxArmorSub 	   : CScriptedFlashArray;
	var gfxVitalitySub 	   : CScriptedFlashArray;
	var gfxSpellPowerSub   : CScriptedFlashArray;
	var gfxVigorStatSub    : CScriptedFlashArray; //W3EE
	var gfxPoiseStatSub    : CScriptedFlashArray; //W3EE
	var gfxAdrenalineSub   : CScriptedFlashArray; //W3EE
	var gfxToxicitySub 	   : CScriptedFlashArray;
	var gfxStaminaSub	   : CScriptedFlashArray;
	//var gfxCrossbowSub     : CScriptedFlashArray; //W3EE
	//var gfxAdditionalSub   : CScriptedFlashArray; //W3EE
	
	var gameTime		: GameTime;
	var gameTimeHours	: string;
	var gameTimeMinutes : string;
	
	gfxData = parentFlashValueStorage.CreateTempFlashObject();
	statsArray = parentFlashValueStorage.CreateTempFlashArray();
	
	
	
	
	
	
	
	
	
	

	
	//W3EE - Begin
	gfxSilverDamage = AddCharacterStatU("mainSilverStat", 'silverdamage', "panel_common_statistics_tooltip_silver_dps", "attack_silver", statsArray, parentFlashValueStorage);
	gfxSilverDamageSub = parentFlashValueStorage.CreateTempFlashArray();
	
	AddCharacterHeader("panel_common_statistics_tooltip_silver_dps", gfxSilverDamageSub, parentFlashValueStorage, true, "Red");
	AddCharacterHeader("W3EE_LightAtk", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat1", 'silverFastDPS', "panel_common_statistics_tooltip_silver_fast_dps", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat2", 'silverFastAtkSpeed', "attribute_name_attack_speed", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat3", 'silverFastAP', "attribute_name_armor_reduction", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat4", 'silverFastCritChance', "panel_common_statistics_tooltip_silver_fast_crit_chance", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat5", 'silverFastCritDmg', "panel_common_statistics_tooltip_silver_fast_crit_dmg", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterHeader("W3EE_StrongAtk", gfxSilverDamageSub, parentFlashValueStorage);
	AddCharacterStatU("silverStat6", 'silverStrongDPS', "panel_common_statistics_tooltip_silver_strong_dps", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat7", 'silverStrongAtkSpeed', "attribute_name_attack_speed", "", gfxSilverDamageSub, parentFlashValueStorage);
	AddCharacterStatU("silverStat8", 'silverStrongAP', "attribute_name_armor_reduction", "", gfxSilverDamageSub, parentFlashValueStorage);
	AddCharacterStatU("silverStat9", 'silverStrongCritChance', "panel_common_statistics_tooltip_silver_strong_crit_chance", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat10", 'silverStrongCritDmg', "panel_common_statistics_tooltip_silver_strong_crit_dmg", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterHeader("W3EE_Modifiers", gfxSilverDamageSub, parentFlashValueStorage);	
	AddCharacterStatU("silverStat11", 'silverFlankingPower', "attribute_name_damage_from_behind_off", "", gfxSilverDamageSub, parentFlashValueStorage);
	AddCharacterStatU("silverStat12", 'silverModVsMortal', "W3EER_CSP_Stat_DamVsMortal", "", gfxSilverDamageSub, parentFlashValueStorage);
	AddCharacterStatU("silverStat13", 'silverModVsMonster', "W3EER_CSP_Stat_DamVsMonster", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat14", 'silverModVsSuper', "W3EER_CSP_Stat_DamVsSuper", "", gfxSilverDamageSub, parentFlashValueStorage); 
	//AddCharacterHeader("W3EE_EffectCh", gfxSilverDamageSub, parentFlashValueStorage); 
	//AddCharacterStatU2("silverStat8", 'silver_desc_poinsonchance_mult', "attribute_name_desc_poinsonchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	//AddCharacterStatU2("silverStat9", 'silver_desc_bleedingchance_mult', "attribute_name_desc_bleedingchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	//AddCharacterStatU2("silverStat10", 'silver_desc_burningchance_mult', "attribute_name_desc_burningchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	//AddCharacterStatU2("silverStat11", 'silver_desc_confusionchance_mult', "attribute_name_desc_confusionchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	//AddCharacterStatU2("silverStat12", 'silver_desc_freezingchance_mult', "attribute_name_desc_freezingchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	//AddCharacterStatU2("silverStat13", 'silver_desc_staggerchance_mult', "attribute_name_desc_staggerchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	gfxSilverDamage.SetMemberFlashArray("subStats", gfxSilverDamageSub);
	
	
	
	gfxSteelDamage = AddCharacterStatU("mainSteelStat", 'steeldamage', "panel_common_statistics_tooltip_steel_dps", "attack_steel", statsArray, parentFlashValueStorage);
	gfxSteelDamageSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("panel_common_statistics_tooltip_steel_dps", gfxSteelDamageSub, parentFlashValueStorage, true, "Red");
	AddCharacterHeader("W3EE_LightAtk", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat1", 'steelFastDPS', "panel_common_statistics_tooltip_steel_fast_dps", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat2", 'steelFastAtkSpeed', "attribute_name_attack_speed", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat3", 'steelFastAP', "attribute_name_armor_reduction", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat4", 'steelFastCritChance', "panel_common_statistics_tooltip_steel_fast_crit_chance", "", gfxSteelDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("steelStat5", 'steelFastCritDmg', "panel_common_statistics_tooltip_steel_fast_crit_dmg", "", gfxSteelDamageSub, parentFlashValueStorage); 
	AddCharacterHeader("W3EE_StrongAtk", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat6", 'steelStrongDPS', "panel_common_statistics_tooltip_steel_strong_dps", "", gfxSteelDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("steelStat7", 'steelStrongAtkSpeed', "attribute_name_attack_speed", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat8", 'steelStrongAP', "attribute_name_armor_reduction", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat9", 'steelStrongCritChance', "panel_common_statistics_tooltip_steel_strong_crit_chance", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat10", 'steelStrongCritDmg', "panel_common_statistics_tooltip_steel_strong_crit_dmg", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Modifiers", gfxSteelDamageSub, parentFlashValueStorage);	
	AddCharacterStatU("steelStat11", 'steelFlankingPower', "attribute_name_damage_from_behind_off", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat12", 'steelModVsMortal', "W3EER_CSP_Stat_DamVsMortal", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat13", 'steelModVsMonster', "W3EER_CSP_Stat_DamVsMonster", "", gfxSteelDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("steelStat14", 'steelModVsSuper', "W3EER_CSP_Stat_DamVsSuper", "", gfxSteelDamageSub, parentFlashValueStorage); 
	//AddCharacterHeader("W3EE_EffectCh", gfxSteelDamageSub, parentFlashValueStorage);
	//AddCharacterStatU2("steelStat8", 'steel_desc_poinsonchance_mult', "attribute_name_desc_poinsonchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	//AddCharacterStatU2("steelStat9", 'steel_desc_bleedingchance_mult', "attribute_name_desc_bleedingchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	//AddCharacterStatU2("steelStat10", 'steel_desc_burningchance_mult', "attribute_name_desc_burningchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	//AddCharacterStatU2("steelStat11", 'steel_desc_confusionchance_mult', "attribute_name_desc_confusionchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	//AddCharacterStatU2("steelStat12", 'steel_desc_freezingchance_mult', "attribute_name_desc_freezingchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	//AddCharacterStatU2("steelStat13", 'steel_desc_staggerchance_mult', "attribute_name_desc_staggerchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	gfxSteelDamage.SetMemberFlashArray("subStats", gfxSteelDamageSub);
	
	
	
	gfxArmor = AddCharacterStat("mainResStat", 'armor', "attribute_name_armor", "armor", statsArray, parentFlashValueStorage);
	gfxArmorSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("attribute_name_armor", gfxArmorSub, parentFlashValueStorage, true, "Red");
	AddCharacterHeader("W3EE_MeleeResist", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat2", 'slashing_resistance_perc', "slashing_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat3", 'piercing_resistance_perc', "attribute_name_piercing_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat4", 'bludgeoning_resistance_perc', "bludgeoning_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_ElementResist", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat6", 'elemental_resistance_perc', "attribute_name_elemental_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_EffectResist", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat8", 'poison_resistance_perc', "attribute_name_poison_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat9", 'bleeding_resistance_perc', "attribute_name_bleeding_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat10", 'burning_resistance_perc', "attribute_name_burning_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStat("defStat11", 'injury_resist', "attribute_name_injury_resist", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Modifiers", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdArm", 'AtkSpdArmor', "W3EE_AtkSpdMod", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStat("StamCostArm", 'StamCostArmor', "W3EE_StamCostArmMod", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStat("StamRegArm", 'StamRegArmor', "W3EE_StamRegArmMod", "", gfxArmorSub, parentFlashValueStorage);
	gfxArmor.SetMemberFlashArray("subStats", gfxArmorSub);
	
	
	
	//gfxCrossbow = AddCharacterStat("majorStat4", 'crossbow', "item_category_crossbow", "crossbow", statsArray, parentFlashValueStorage);
	//gfxCrossbowSub = parentFlashValueStorage.CreateTempFlashArray();
	//AddCharacterHeader("item_category_crossbow", gfxCrossbowSub, parentFlashValueStorage, true, "Red");
	//AddCharacterHeader("W3EE_DmgValues", gfxCrossbowSub, parentFlashValueStorage);
	//AddCharacterStatU("steelStat18", 'crossbowSteelDmg', "attribute_name_piercingdamage", "", gfxCrossbowSub, parentFlashValueStorage);
	//AddCharacterStatU("steelStat19", 'crossbowSilverDmg', "attribute_name_silverdamage", "", gfxCrossbowSub, parentFlashValueStorage);
	//AddCharacterHeader("W3EE_Modifiers", gfxCrossbowSub, parentFlashValueStorage);
	//AddCharacterStatU("steelStat17", 'crossbowCritChance', "panel_common_statistics_tooltip_crossbow_crit_chance", "", gfxCrossbowSub, parentFlashValueStorage);
	//gfxCrossbow.SetMemberFlashArray("subStats", gfxCrossbowSub);
	
	
	
	gfxAdrenaline = AddCharacterStat("adrStat", 'adrenaline', "W3EE_Adr", "toxicity", statsArray, parentFlashValueStorage);
	gfxAdrenalineSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("W3EE_Adr", gfxAdrenalineSub, parentFlashValueStorage, true, "Red");
	AddCharacterHeader("W3EE_AdrGen", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrGain", 'adrGain', "W3EE_AdrGain", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrGainCounter", 'adrGainCounter', "W3EE_AdrCount", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrGainAttack", 'adrGainAttack', "W3EE_AdrAtt", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrGainKill", 'adrGainKill', "W3EE_AdrKill", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrGainHit", 'adrGainHit', "W3EE_AdrHit", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterHeader("W3EER_CSP_Header_AdrDrain", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrDegenDelay", 'adrDegenDelay', "W3EER_CSP_Stat_AdrDegenDelay", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrDegenRate", 'adrDegenRate', "W3EER_CSP_Stat_AdrDegenRate", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Bonuses", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrStamReg", 'adrStamReg', "W3EE_StamRegenEffBon", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrVigReg", 'adrVigReg', "W3EE_VigRegenBon", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrDamBonus", 'adrDamBonus', "W3EE_DamBon", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrTimeSlow", 'adrTimeSlow', "W3EE_AdrTimeSlow", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrSignBonus", 'adrSignBonus', "W3EE_AdrSignBon", "", gfxAdrenalineSub, parentFlashValueStorage);
	gfxAdrenaline.SetMemberFlashArray("subStats", gfxAdrenalineSub);
	
	
	
	gfxVitality =  AddCharacterStat("majorStat1", 'vitality', "vitality", "vitality", statsArray, parentFlashValueStorage);
	gfxVitalitySub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("vitality", gfxVitalitySub, parentFlashValueStorage, true, "Green");
	AddCharacterHeader("W3EE_RegenRates", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterStat("vitStat1", 'vitalityRegen', "panel_common_statistics_tooltip_outofcombat_regen", "", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterStat("vitStat2", 'vitalityCombatRegen', "panel_common_statistics_tooltip_incombat_regen", "", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Modifiers", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterStat("vitStat3", 'healthSpeedRed', "W3EE_SpdRed", "", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterStat("vitStat4", 'healthRegenRed', "W3EE_StamRegenRed", "", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterStat("vitStat5", 'healthRegenRed', "W3EE_VigRegenRed", "", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterStat("vitStat6", 'healthAdrRed', "W3EER_CSP_Stat_VitAdrRed", "", gfxVitalitySub, parentFlashValueStorage);
	gfxVitality.SetMemberFlashArray("subStats", gfxVitalitySub);
	
	
	
	gfxStamina = AddCharacterStat("majorStat3", 'stamina', "stamina", "stamina", statsArray, parentFlashValueStorage);
	gfxStaminaSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("stamina", gfxStaminaSub, parentFlashValueStorage, true, "Green");
	AddCharacterHeader("W3EE_RegenRates", gfxStaminaSub, parentFlashValueStorage);
	//AddCharacterStat("stamStat1", 'staminaOutOfCombatRegen', "attribute_name_staminaregen_out_of_combat", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("stamStat2", 'staminaRegen', "attribute_name_staminaregen", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_RegenMod", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("stamStat3", 'healthRegenRed', "W3EE_StamRegenRedHP", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("stamStat4", 'adrStamReg', "W3EE_StamRegenIncAdr", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Efficiency", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("stamStat5", 'staminaEffAtt', "W3EE_StamEffAtt", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("stamStat6", 'staminaEffDef', "W3EE_StamEffDef", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("stamStat7", 'staminaEffMov', "W3EE_StamEffMov", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Maluses", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("stamStat8", 'staminaSpeedRed', "W3EE_SpdRed", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("stamStat9", 'staminaDamageRed', "W3EE_MeleeDamRed", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterHeader("W3EER_CSP_Header_Move", gfxStaminaSub, parentFlashValueStorage, true, "Green");
	AddCharacterStat("stamStat10", 'EvadeSpeed', "W3EE_EvSpeed", "", gfxStaminaSub, parentFlashValueStorage);	
	AddCharacterStatU("stamStat11", 'safe_dodge_angle', "W3EER_CSP_Stat_Dodge", "", gfxStaminaSub , parentFlashValueStorage);
	gfxStamina.SetMemberFlashArray("subStats", gfxStaminaSub);
	
	
	
	gfxToxicity = AddCharacterStat("majorStat2", 'toxicity', "attribute_name_toxicity", "toxicity", statsArray, parentFlashValueStorage);
	gfxToxicitySub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("attribute_name_toxicity", gfxToxicitySub, parentFlashValueStorage, true, "Green");	
	AddCharacterHeader("W3EE_Rates", gfxToxicitySub, parentFlashValueStorage);
	AddCharacterStatToxicity("toxicGain", 'toxicGain', "W3EE_ToxGain", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterStatToxicity("toxicDrain", 'toxicDrain', "W3EE_ToxDrain", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterStatToxicity("toxicDelta", 'toxicDelta', "W3EE_ToxDelta", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterHeader("W3EE_Bonuses", gfxToxicitySub, parentFlashValueStorage);
	AddCharacterStatToxicity("toxicSpeed", 'toxicSpeed', "W3EE_ToxSpeed", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterStatToxicity("toxicAdr", 'toxicAdr', "W3EE_ToxAdr", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterStatToxicity("toxicArm", 'toxicArm', "W3EE_ToxArm", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterStatToxicity("toxicPoise", 'toxicPoise', "W3EE_ToxPoise", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterHeader("W3EE_Maluses", gfxToxicitySub, parentFlashValueStorage);
	AddCharacterStat("toxicvigor", 'toxicRegenRed', "W3EE_VigRegenRed", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterStatToxicity("feverVigor", 'feverVigor', "W3EE_FevVigRed", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterStatToxicity("feverStam", 'feverStam', "W3EE_FevStamRed", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterStatToxicity("feverSpeed", 'feverSpeed', "W3EE_FevSpdRed", "", gfxToxicitySub, parentFlashValueStorage);	
	gfxToxicity.SetMemberFlashArray("subStats", gfxToxicitySub);
	
	
	
	gfxPoiseStat = AddCharacterStat("majorStat7", 'poise', "W3EE_Poise", "armor", statsArray, parentFlashValueStorage);
	gfxPoiseStatSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("W3EE_Poise", gfxPoiseStatSub, parentFlashValueStorage, true, "Blue");
	//AddCharacterStat("poiseStat1", 'poiseValue', "W3EE_CurPoise", "", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat2", 'poiseArmor', "W3EE_PoiseArmor", "", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat3", 'poiseGear', "W3EE_PoiseGear", "", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat4", 'poiseSkills', "W3EE_PoiseSkills", "", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat5", 'poiseStats', "W3EE_PoiseStats", "", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat6", 'poiseRegen', "W3EE_PoiseRegen", "", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Modifiers", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat7", 'poiseHitResist', "W3EER_CSP_Stat_PoiseHitResist", "", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat8", 'poiseChipResist', "W3EER_CSP_Stat_PoiseChipResist", "", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat9", 'poiseParryWindow', "W3EER_CSP_Stat_PoiseParryWindow", "", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat10", 'poiseCounterWindow', "W3EER_CSP_Stat_PoiseCounterWindow", "", gfxPoiseStatSub, parentFlashValueStorage);
	gfxPoiseStat.SetMemberFlashArray("subStats", gfxPoiseStatSub);
	
	
	
	gfxSpellPower = AddCharacterStat("mainMagicStat", 'spell_power', "stat_signs", "spell_power", statsArray, parentFlashValueStorage);
	gfxSpellPowerSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("stat_signs", gfxSpellPowerSub, parentFlashValueStorage, true, "Blue");
	AddCharacterHeader("Aard", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("aardStat1", 'spell_power_aard', "spell_power_aard", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("aardStat2", 'aard_damage', "attribute_name_forcedamage", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("aardStat3", 'aard_frost_damage', "attribute_name_frostdamage", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Igni", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("igniStat1", 'spell_power_igni', "spell_power_igni", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("igniStat2", 'igni_damage', "attribute_name_firedamage", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Quen", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("quenStat1", 'spell_power_quen', "spell_power_quen", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("quenStat3", 'quen_duration', "duration", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Yrden", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("yrdenStat1", 'spell_power_yrden', "spell_power_yrden", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("yrdenStat3", 'yrden_damage', "attribute_name_elementaldamage", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("yrdenStat4", 'yrden_duration', "duration", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Axii", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("axiiStat1", 'spell_power_axii', "spell_power_axii", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("axiiStat2", 'axii_duration_confusion', "duration", "", gfxSpellPowerSub, parentFlashValueStorage);
	gfxSpellPower.SetMemberFlashArray("subStats", gfxSpellPowerSub);



	gfxVigorStat = AddCharacterStat("majorStat6", 'focus', "W3EE_Vigor", "toxicity", statsArray, parentFlashValueStorage);
	gfxVigorStatSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("W3EE_Vigor", gfxVigorStatSub, parentFlashValueStorage, true, "Blue");
	AddCharacterHeader("W3EE_RegenRates", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterStatSigns("vigorStat1", 'vigorRegen', "W3EE_VigReg", "", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_RegenMod", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterStat("vigorStat2", 'healthRegenRed', "W3EE_VigRegenRedHP", "", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterStat("vigorStat3", 'toxicRegenRed', "W3EE_VigRegenRedTox", "", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterStat("vigorStat4", 'adrVigReg', "W3EE_VigRegenBonAdr", "", gfxVigorStatSub, parentFlashValueStorage);
	gfxVigorStat.SetMemberFlashArray("subStats", gfxVigorStatSub);



	//gfxAdditional = AddCharacterStat("majorStat5", 'additional', "panel_common_statistics_category_additional", "additional", statsArray, parentFlashValueStorage);
	//gfxAdditionalSub = parentFlashValueStorage.CreateTempFlashArray();
	//AddCharacterHeader("panel_common_statistics_category_additional", gfxAdditionalSub, parentFlashValueStorage, true, "Brown");
	//AddCharacterHeader("W3EE_AddStats", gfxAdditionalSub, parentFlashValueStorage);
	//AddCharacterStatF("extraStat1", 'bonus_herb_chance', "bonus_herb_chance", "", gfxAdditionalSub, parentFlashValueStorage);
	//AddCharacterStatU("extraStat3", 'human_exp_bonus_when_fatal', "human_exp_bonus_when_fatal", "", gfxAdditionalSub , parentFlashValueStorage);
	//AddCharacterStatU("extraStat4", 'nonhuman_exp_bonus_when_fatal', "nonhuman_exp_bonus_when_fatal", "", gfxAdditionalSub , parentFlashValueStorage);
	//gfxAdditional.SetMemberFlashArray("subStats", gfxAdditionalSub);
	//W3EE - End
	
	
	gameTime =	theGame.CalculateTimePlayed();
	gameTimeHours = (string)(GameTimeDays(gameTime) * 24 + GameTimeHours(gameTime));
	gameTimeMinutes = (string)GameTimeMinutes(gameTime);
	
	gfxData.SetMemberFlashArray("stats", statsArray);
	gfxData.SetMemberFlashString("hoursPlayed", gameTimeHours);
	gfxData.SetMemberFlashString("minutesPlayed", gameTimeMinutes);
	
	return gfxData;
	
	
	
	
}

function AddCharacterHeader(locKey:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage, optional isSuperHeader : bool, optional color : string):void
{
	var statObject : CScriptedFlashObject;
	//W3EE - Begin
	var finalname 		: string;
	finalname = GetLocStringByKeyExt(locKey); 

	if ( finalname == "#" || finalname == "" )
		finalname = locKey;
	//W3EE - End
	statObject = flashMaster.CreateTempFlashObject();
	
	statObject.SetMemberFlashString("name", finalname); //W3EE
	statObject.SetMemberFlashString("value", "");
	
	if (isSuperHeader)
	{
		statObject.SetMemberFlashString("tag", "SuperHeader");
		statObject.SetMemberFlashString("backgroundColor", color);
	}
	else
	{
		statObject.SetMemberFlashString("tag", "Header");
	}
	
	statObject.SetMemberFlashString("iconTag", "");
	toArray.PushBackFlashObject(statObject);
}

function AddCharacterStat(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject 		: CScriptedFlashObject;
	var valueStr 		: string;
	var valueMaxStr 	: string;
	var valueAbility 	: float;
	var final_name 		: string;
	var sp 				: SAbilityAttributeValue;
	var itemColor		: string;
	
	var gameTime		: GameTime;
	var gameTimeDays	: string;
	var gameTimeHours	: string;
	var gameTimeMinutes	: string;
	var gameTimeSeconds	: string;

	//W3EE - Begin
	var playerWitcher : W3PlayerWitcher;
	var adrGain, min : SAbilityAttributeValue;
	var clampVal : float;	
	var lightAttackSpeed, heavyAttackSpeed, evadeSpeed : float;
	var adrenalineEffect : W3Effect_CombatAdrenaline;
	var poiseEffect : W3Effect_Poise;
	var item : SItemUniqueId;
	var temp : bool;
	
	playerWitcher = GetWitcherPlayer();
	adrenalineEffect = playerWitcher.GetAdrenalineEffect();
	poiseEffect = playerWitcher.GetPoiseEffect();
	
	lightAttackSpeed = Combat().FastAttackSpeedModule(true) - 0.08f;
	heavyAttackSpeed = Combat().HeavyAttackSpeedModule(true) - 0.08f;
	evadeSpeed = Combat().EvadeSpeedModule(true) - 0.08f;
	//W3EE - End
	
	statObject			= 	flashMaster.CreateTempFlashObject();
	
	gameTime			=	theGame.CalculateTimePlayed();
	gameTimeDays 		= 	(string)GameTimeDays(gameTime);
	gameTimeHours 		= 	(string)GameTimeHours(gameTime);
	gameTimeMinutes 	= 	(string)GameTimeMinutes(gameTime);
	gameTimeSeconds 	= 	(string)GameTimeSeconds(gameTime);
	
	valueMaxStr = "";
	itemColor = "";

	if ( varKey == 'vitality' )
	{
		valueStr = (string)RoundMath(thePlayer.GetStat(BCS_Vitality, true));
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Vitality));
		itemColor = "Green";
	}
	else if ( varKey == 'toxicity' )
	{
		valueStr = (string)RoundMath(thePlayer.GetStat(BCS_Toxicity, false));
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Toxicity));
		itemColor = "Green";
	}
	else if ( varKey == 'stamina' ) 	
	{ 
		valueStr = (string)RoundMath(thePlayer.GetStat(BCS_Stamina, true));
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Stamina)); 
		itemColor = "Green"; //W3EE
	}
	else if ( varKey == 'focus' )
	{
		valueStr = (string)NoTrailZeros(RoundTo(thePlayer.GetStat(BCS_Focus, true), 2)); //W3EE
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Focus));
		itemColor = "Blue";
	}
	//W3EE - Begin
	else if ( varKey == 'spell_power' )
	{
		sp = GetWitcherPlayer().GetTotalSpellPower(true);
		valueAbility = sp.valueMultiplicative;
		valueStr = (string)RoundMath(valueAbility * 100) + " %";
		
		itemColor = "Blue";
	}
	else if ( varKey == 'vitalityRegen' ) 
	{ 
		valueAbility = Combat().GetPlayerVitalityRegen(false);
		valueStr = NoTrailZeros(RoundTo(valueAbility, 2)) + "/" + GetLocStringByKeyExt("per_second"); 
	}
	else if ( varKey == 'vitalityCombatRegen' ) 
	{ 
		valueAbility = Combat().GetPlayerVitalityRegen(true);
		valueStr = NoTrailZeros(RoundTo(valueAbility, 2)) + "/" + GetLocStringByKeyExt("per_second"); 
	}
	else if ( varKey == 'staminaRegen' ) 
	{
		valueAbility = Combat().GetPlayerStaminaRegen();
		valueStr = NoTrailZeros(RoundTo(valueAbility, 1)) + "/" + GetLocStringByKeyExt("per_second");
	}
	/*else if ( varKey == 'staminaOutOfCombatRegen' ) 
	{
		sp = GetWitcherPlayer().GetAttributeValue(varKey);
		
		valueAbility = GetWitcherPlayer().GetStatMax(BCS_Stamina) * sp.valueMultiplicative + sp.valueAdditive;
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "/" + GetLocStringByKeyExt("per_second"); 
	}*/
	else if ( varKey == 'healthRegenRed' ) 
	{
		valueAbility = 1.f - GetWitcherPlayer().GetHPReductionMult();
		valueAbility *= 100.f;
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%"; 
	}
	else if ( varKey == 'toxicRegenRed' ) 
	{
		if( GetWitcherPlayer().HasAbility('Glyphword 46 _Stats', true) || GetWitcherPlayer().HasAbility('Glyphword 47 _Stats', true) || GetWitcherPlayer().HasAbility('Glyphword 48 _Stats', true) )
			valueAbility =  (0.25f - 0.05f * GetWitcherPlayer().GetSkillLevel(S_Alchemy_s17)) * PowF(GetWitcherPlayer().GetStatPercents(BCS_Toxicity), 2) * 100;
		else
			valueAbility =  (0.5f - 0.05f * GetWitcherPlayer().GetSkillLevel(S_Alchemy_s17)) * PowF(GetWitcherPlayer().GetStatPercents(BCS_Toxicity), 2) * 100;
		sp = GetWitcherPlayer().GetAttributeValue('toxicity_vigor_penalty');
		valueAbility *= 1.f + sp.valueMultiplicative;
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%"; 
	}
	else if ( varKey == 'staminaSpeedRed' ) 
	{
		valueAbility = Options().StamRed();
		if(playerWitcher.HasBuff(EET_Overexertion))
		{
			if( playerWitcher.HasBuff(EET_Decoction8) )
				valueAbility *= MinF( 1.f, PowF(1 - thePlayer.GetStat(BCS_Focus) / thePlayer.GetStatMax(BCS_Focus), 2));
			valueAbility *= 2;
		}
		else
		{
			if( playerWitcher.HasBuff(EET_Decoction8) )
				valueAbility *= MinF( PowF(1 - thePlayer.GetStatPercents(BCS_Stamina), 2), PowF(1 - thePlayer.GetStat(BCS_Focus) / thePlayer.GetStatMax(BCS_Focus), 2));
			else
				valueAbility *= PowF(1 - thePlayer.GetStatPercents(BCS_Stamina), 2);
		}
		valueAbility *= 1 - thePlayer.GetSkillLevel(S_Sword_s16) * 0.05;
		if( playerWitcher.HasAbility('Glyphword 50 _Stats', true) || playerWitcher.HasAbility('Glyphword 51 _Stats', true) )
			valueAbility *= 0.5f * playerWitcher.GetAdrenalinePercMult();
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%"; 
	}
	else if ( varKey == 'staminaDamageRed' ) 
	{
		valueAbility = Options().StamDamRed();
		if(playerWitcher.HasBuff(EET_Overexertion))
		{
			if( playerWitcher.HasBuff(EET_Decoction8) )
				valueAbility *= MinF( 1.f, PowF(1 - thePlayer.GetStat(BCS_Focus) / thePlayer.GetStatMax(BCS_Focus), 2));
			valueAbility *= 2;
		}
		else
		{
			if( playerWitcher.HasBuff(EET_Decoction8) )
				valueAbility *= MinF( PowF(1 - thePlayer.GetStatPercents(BCS_Stamina), 2), PowF(1 - thePlayer.GetStat(BCS_Focus) / thePlayer.GetStatMax(BCS_Focus), 2));
			else
				valueAbility *= PowF(1 - thePlayer.GetStatPercents(BCS_Stamina), 2);
		}
		valueAbility *= 1 - thePlayer.GetSkillLevel(S_Sword_s16) * 0.05;
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%"; 
	}
	else if ( varKey == 'healthSpeedRed' ) 
	{
		valueAbility =  (1.f - GetWitcherPlayer().GetHPReductionMult()) * Options().HPRed() * ( 1 - (thePlayer.GetSkillLevel(S_Sword_s16) * 0.05) );
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%"; 
	}
	else if ( varKey == 'healthPoiseRed' ) 
	{
		valueAbility =  ( 1 - ClampF( thePlayer.GetStatPercents(BCS_Vitality) * 1.3f, 0.7f, 1.0f ) ) * 100;
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%"; 
	}
	else if (varKey == 'healthAdrRed' )
	{
		if( playerWitcher.HasAbility('Glyphword 40 _Stats', true) || playerWitcher.HasAbility('Glyphword 41 _Stats', true) || playerWitcher.HasAbility('Glyphword 42 _Stats', true) )
			valueAbility = 0;
		else
			valueAbility = 0.8f * playerWitcher.GetStatPercents(BCS_Vitality);
		valueAbility *= 100.f;
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%"; 
	}
	else if ( varKey == 'poise' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(poiseEffect.GetCurrentPoise()));
		valueMaxStr = (string)RoundMath(poiseEffect.GetMaxPoise());
		itemColor = "Blue";
	}
	else if ( varKey == 'AtkSpdArmor' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(Combat().CalcArmorPenalty(GetWitcherPlayer(), true) * 100)) + "%";
	}
	else if ( varKey == 'EvadeSpeed' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(evadeSpeed * 100)) + "%";
	}
	else if ( varKey == 'poiseValue' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(poiseEffect.GetCurrentPoise()));
	}
	else if ( varKey == 'poiseRegen' )
	{
		if( playerWitcher.IsSetBonusActive(EISB_Tiger_1) && GetDayPart(GameTimeCreate()) == EDP_Dusk )
			valueStr = (string)NoTrailZeros(RoundMath((20.f + CalculateAttributeValue(playerWitcher.GetAttributeValue('poiseRegen'))) * 1.25f)) + "/" + GetLocStringByKeyExt("per_second");
		else
			valueStr = (string)NoTrailZeros(RoundMath(20.f + CalculateAttributeValue(playerWitcher.GetAttributeValue('poiseRegen')))) + "/" + GetLocStringByKeyExt("per_second");
	}
	else if ( varKey == 'poiseStats' )
	{
		valueAbility = 100.f;
		if( playerWitcher.IsQuenActive(false) )
			valueAbility *= 0.8f - 0.04f * playerWitcher.GetSkillLevel(S_Magic_s15);
		min = playerWitcher.GetAttributeValue('parry_stamina_cost_bonus');
		valueAbility /= (1.f + min.valueMultiplicative);
		if( playerWitcher.IsSetBonusActive(EISB_RedWolf_2) )
		{
			if( playerWitcher.GetStat(BCS_Toxicity) * playerWitcher.GetSkillLevel(S_Alchemy_s20) <= 500 )
				valueAbility *= 1.f - playerWitcher.GetSkillLevel(S_Alchemy_s20) * 0.001f * playerWitcher.GetStat(BCS_Toxicity);
			else
				valueAbility /= playerWitcher.GetSkillLevel(S_Alchemy_s20) * 0.1f * playerWitcher.GetStat(BCS_Toxicity) / 25.f;
		}
		else
			valueAbility *= 1.f - playerWitcher.GetSkillLevel(S_Alchemy_s20) * 0.1f * playerWitcher.GetStatPercents(BCS_Toxicity); 
		valueStr = (string)NoTrailZeros(RoundMath(valueAbility)) + "%";
	}
	else if ( varKey == 'poiseArmor' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(poiseEffect.ArmorPoiseValue()));
	}
	else if ( varKey == 'poiseGear' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(CalculateAttributeValue(playerWitcher.GetAttributeValue('poise_bonus'))));
	}
	else if ( varKey == 'poiseSkills' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(10.f * playerWitcher.GetSkillLevel(S_Perk_21)));
	}
	else if ( varKey == 'poiseHitResist' )
	{
		valueAbility = 1.f;
		valueAbility += adrenalineEffect.GetDisplayCount() * 0.005f;
		valueAbility += playerWitcher.GetStat(BCS_Toxicity) * 0.005f;
		valueAbility += playerWitcher.GetSkillLevel(S_Sword_s16)  * 0.05f;
		
		if( playerWitcher.GetIsSprinting() || playerWitcher.IsCurrentlyDodging() )
			valueAbility += 0.5f;
		else if( playerWitcher.GetIsRunning() )
			valueAbility += 0.2f;
		
		if( playerWitcher.IsInCombatAction_Attack() )
			valueAbility += (0.2f + CalculateAttributeValue(playerWitcher.GetAttributeValue('stagger_resist_bonus')));
			
		if( playerWitcher.IsAnyQuenActive() )
			valueAbility += (0.25f + 0.05f * playerWitcher.GetSkillLevel(S_Magic_s15));
		
		if( playerWitcher.HasBuff(EET_Decoction3) )
			valueAbility += (0.05f * ((W3Decoction3_Effect)playerWitcher.GetBuff(EET_Decoction3)).GetHardeningStacks());
		
		if( playerWitcher.IsRuneword44Active() )
			valueAbility += 0.25f;
		
		if( playerWitcher.HasAbility('Glyphword 43 _Stats', true) || playerWitcher.HasAbility('Glyphword 44 _Stats', true) || playerWitcher.HasAbility('Glyphword 45 _Stats', true) )
			valueAbility += (0.2 * playerWitcher.GetEncumbrance() / playerWitcher.GetMaxRunEncumbrance(temp));
		
		valueAbility = valueAbility * poiseEffect.GetCurrentPoise() * 10.f;
		valueAbility *= (0.5f + playerWitcher.GetStatPercents(BCS_Vitality) * 0.5f);
		valueAbility *= (0.5f + playerWitcher.GetStatPercents(BCS_Stamina) * 0.5f);
		if( playerWitcher.HasBuff(EET_Overexertion) )
			valueAbility *= 0.5f;
		valueStr = RoundMath(valueAbility);
	}
	else if ( varKey == 'poiseChipResist' )
	{
		sp = playerWitcher.GetAttributeValue('damage_negation_defense');
		sp.valueMultiplicative += 0.04f * playerWitcher.GetSkillLevel(S_Sword_s03);
		if( playerWitcher.IsSetBonusActive(EISB_Bear_2) )
			sp.valueMultiplicative += poiseEffect.GetCurrentPoise() * 0.003f;
		sp.valueMultiplicative = MinF( 1.f, sp.valueMultiplicative );
		valueStr = NoTrailZeros(100 - RoundMath((1.f - poiseEffect.GetPoisePercentage() / 2.f) * (1.f - sp.valueMultiplicative) * 100)) + "%";
	}
	else if ( varKey == 'poiseParryWindow' )
	{
		valueAbility = 1.f - (0.8f - poiseEffect.GetPoisePercentage() * 0.8f);
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + "%";
	}
	else if ( varKey == 'poiseCounterWindow' )
	{
		valueAbility = 1.f - (0.9f - poiseEffect.GetPoisePercentage() * 0.4f);
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + "%";
	}
	else if ( varKey == 'adrenaline' )
	{
		if( adrenalineEffect )
		{
			valueStr = NoTrailZeros(adrenalineEffect.GetDisplayCount());
			valueMaxStr = IntToString(adrenalineEffect.GetMaxDisplayCount());
		}
		else
		{
			valueStr = 0;
			if( playerWitcher.IsSetBonusActive(EISB_Wolf_2) )
				valueMaxStr = 150;
			else
				valueMaxStr = 100;
		}

		itemColor = "Red";
	}
	else if ( varKey == 'adrGain' )
	{
		if( adrenalineEffect )
			valueAbility = adrenalineEffect.GetAdrenalineGainMult();
		else
			valueAbility = Combat().GetPlayerAdrenalineGainMult();
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + "%";
	}
	else if ( varKey == 'adrGainCounter' || varKey == 'adrGainAttack' || varKey == 'adrGainKill' || varKey == 'adrGainHit' )
	{
		if( adrenalineEffect )
			valueAbility = adrenalineEffect.GetAdrenalineGainMult();
		else
			valueAbility = Combat().GetPlayerAdrenalineGainMult();
		if( varKey == 'adrGainKill' )
			valueAbility *= 3.f;
		if( varKey == 'adrGainHit' )
		{
			valueAbility *= 5.f;
			if( playerWitcher.IsMutationActive(EPMT_Mutation3) )
			{
				if( playerWitcher.HasBuff(EET_Decoction2) )
					valueAbility *= 0.8f;
				valueAbility *= 1.f - CalculateAttributeValue(playerWitcher.GetAttributeValue('adrenaline_delay_bonus')) / 10.f;
				valueAbility *= -1.f;
			}
		}
		valueStr = NoTrailZeros(RoundTo(valueAbility, 2));
	}
	else if ( varKey == 'adrStamReg' )
	{
		valueStr = NoTrailZeros(RoundMath(adrenalineEffect.GetDisplayCount() / 5)) + "%"; 
	}
	else if ( varKey == 'adrVigReg' )
	{
		valueStr = NoTrailZeros(RoundMath(adrenalineEffect.GetDisplayCount() / 5)) + "%"; 
	}
	else if ( varKey == 'adrDegenDelay' )
	{
		valueAbility = 3;
		if( playerWitcher.HasBuff(EET_Decoction2) )
			valueAbility += 2;
		valueAbility += CalculateAttributeValue(playerWitcher.GetAttributeValue('adrenaline_delay_bonus'));
		valueStr = NoTrailZeros(RoundTo(valueAbility, 1)) + GetLocStringByKeyExt("per_second"); 
	}
	else if ( varKey == 'adrDegenRate' )
	{
		if( playerWitcher.IsMutationActive(EPMT_Mutation3) )
		{
			valueStr = 0;
		}
		else
		{
			valueAbility = 20.0f * (1.f - playerWitcher.GetSkillLevel(S_Sword_s20) * 0.05f);
			if( playerWitcher.IsRuneword44Active() )
				valueAbility *= 0.2f;
			valueStr = NoTrailZeros(RoundTo(valueAbility, 1)) + "/" + GetLocStringByKeyExt("per_second");
		}
	}
	else if( varKey == 'armor')
	{	
		valueAbility =  CalculateAttributeValue( GetWitcherPlayer().GetTotalArmor() );
		
		valueStr = IntToString( RoundMath(  valueAbility ) );
		itemColor = "Red";
	}
	else if (varKey == 'crossbow')
	{
		valueStr = NoTrailZeros(RoundMath(GetEquippedCrossbowDamage() * Damage().pdamc));
		itemColor = "Red";
	}	
	else if (varKey == 'additional')
	{
		valueStr = "";
		itemColor = "Brown";
	}
	else if ( varKey == 'StamCostArmor' )
	{
		min = playerWitcher.GetAttributeValue('armor_stamina_efficiency');
		if( playerWitcher.CanUseSkill(S_Perk_22) )
			min.valueMultiplicative *= 0.8f;
		valueStr = (string)NoTrailZeros(RoundMath(min.valueMultiplicative * 100)) + "%";
	}
	else if ( varKey == 'StamRegArmor' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(playerWitcher.CalculatedArmorStaminaRegenBonus() * 100)) + "%";
	}
	else if ( varKey == 'staminaEffAtt' || varKey == 'staminaEffDef' || varKey == 'staminaEffMov' )
	{
		valueAbility = 1.f;
		min = playerWitcher.GetAttributeValue('armor_stamina_efficiency');
		valueAbility *= 1.f - min.valueMultiplicative;
		if( varKey == 'staminaEffAtt' )
		{
			min = playerWitcher.GetAttributeValue('attack_stamina_cost_bonus');
		}
		else if( varKey == 'staminaEffDef' )
		{
			min = playerWitcher.GetAttributeValue('parry_stamina_cost_bonus');
			min.valueMultiplicative += 0.04f * playerWitcher.GetSkillLevel(S_Sword_s03);
			if( playerWitcher.IsMutationActive(EPMT_Mutation6) )
				min.valueMultiplicative -= 0.5f;
		}
		else
		{
			min = playerWitcher.GetAttributeValue('movement_stamina_efficiency');
			min.valueMultiplicative += 0.04f * playerWitcher.GetSkillLevel(S_Sword_s09);
		}
		min.valueMultiplicative *= MinF(1.f, (1.f / (1.f + min.valueMultiplicative)));
		valueAbility *= 1.f - min.valueMultiplicative;
		valueAbility = 1.f / valueAbility;
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + "%";
	}
	else if ( varKey == 'adrDamBonus' )
	{
		valueStr = NoTrailZeros(RoundMath(adrenalineEffect.GetDisplayCount() / 5)) + "%"; 
	}
	else if ( varKey == 'adrTimeSlow' )
	{
		if( playerWitcher.HasAbility('Glyphword 51 _Stats', true) )
			valueStr = NoTrailZeros(RoundMath(adrenalineEffect.GetDisplayCount() * 0.3f)) + "%"; 
		else
			valueStr = NoTrailZeros(RoundMath(adrenalineEffect.GetDisplayCount() * 0.3f * (1 - playerWitcher.GetStatPercents(BCS_Vitality)))) + "%"; 
	}
	else if ( varKey == 'adrSignBonus' )
	{
		valueStr = NoTrailZeros(RoundMath(adrenalineEffect.GetDisplayCount() * playerWitcher.GetSkillLevel(S_Sword_s19) / 10)) + "%"; 
	}
	else if ( varKey == 'injury_resist' ) 
	{
		min = playerWitcher.GetAttributeValue('injury_resist');
		min.valueMultiplicative = ClampF(min.valueMultiplicative, 0.f, 1.f);
		valueAbility = 1.f - (0.1f * playerWitcher.GetSkillLevel(S_Sword_s10));
		valueAbility *= 1.f - min.valueMultiplicative;
		valueStr = NoTrailZeros(RoundMath((1.f - valueAbility) * 100.f)) + "%"; 
	}
	else
	{	
		valueAbility =  CalculateAttributeValue( GetWitcherPlayer().GetAttributeValue( varKey ) );
		valueStr = IntToString( RoundMath(  valueAbility ) );
	}
	//W3EE - End
	
	final_name = GetLocStringByKeyExt(locKey);
	
	//W3EE - Begin
	if ( final_name == "#" || final_name == "" )
		final_name = locKey;
	//W3EE - End
	
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr);
	statObject.SetMemberFlashString("maxValue", valueMaxStr);
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", itemColor);
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatToxicity(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility : float;
	
	var toxicityLocked : float;
	var toxicityNoLock : float;
		
	var sp : SAbilityAttributeValue;
	var final_name 		: string;
	var itemColor		: string;
	
	var playerWitcher : W3PlayerWitcher; //W3EE
	var toxicityEffect : W3Effect_Toxicity; //W3EE
	
	statObject = flashMaster.CreateTempFlashObject();
	
	playerWitcher = GetWitcherPlayer(); //W3EE
	toxicityEffect = (W3Effect_Toxicity)playerWitcher.GetBuff(EET_Toxicity); //W#EE
	
	toxicityNoLock = playerWitcher.GetStat(BCS_Toxicity, true); //W3EE
	toxicityLocked = playerWitcher.GetStat(BCS_Toxicity) - toxicityNoLock; //W3EE
	
	//W3EE - Begin
	if ( varKey == 'lockedToxicity' )	
	{
		valueAbility = toxicityLocked;
		valueStr = NoTrailZeros(RoundMath(valueAbility));
	}
	else
	if ( varKey == 'toxPoiseVal' )
	{
		valueAbility = Combat().BaseStatsPoiseValue(GetWitcherPlayer()) * 100.f;
		valueStr = NoTrailZeros(RoundMath(valueAbility));
	}
	else if ( varKey == 'toxicGain' )
	{
		if( toxicityEffect )
			valueAbility = toxicityEffect.GetToxicityGain();
		else
			valueAbility = 0;
		valueStr = FloatToStringPrec( valueAbility, 2 );
	}
	else if ( varKey == 'toxicDrain' )
	{
		if( toxicityEffect )
			valueAbility = toxicityEffect.GetToxicityDrain() * -1.f;
		else
			valueAbility = 0;
		valueStr = FloatToStringPrec( valueAbility, 2 );
	}
	else if ( varKey == 'toxicDelta' )
	{
		if( toxicityEffect )
			valueAbility = toxicityEffect.GetToxicityGain() + toxicityEffect.GetToxicityDrain();
		else
			valueAbility = 0;
		valueStr = FloatToStringPrec( valueAbility, 2 );
	}
	else if ( varKey == 'toxicSpeed' )
	{
		if( playerWitcher.CanUseSkill(S_Alchemy_s16) )
		{
			if( playerWitcher.IsSetBonusActive(EISB_RedWolf_2) )
				valueAbility = playerWitcher.GetSkillLevel(S_Alchemy_s16) * 0.03f * playerWitcher.GetStat(BCS_Toxicity) / 100.f; 
			else
				valueAbility = playerWitcher.GetSkillLevel(S_Alchemy_s16) * 0.03f * playerWitcher.GetStatPercents(BCS_Toxicity); 
		}
		else
			valueAbility = 0;
		
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + "%"; 
	}
	else if ( varKey == 'toxicAdr' )
	{
		if( playerWitcher.CanUseSkill(S_Alchemy_s16) )
		{
			if( playerWitcher.IsSetBonusActive(EISB_RedWolf_2) )
				valueAbility = playerWitcher.GetSkillLevel(S_Alchemy_s16) * 0.1f * playerWitcher.GetStat(BCS_Toxicity) / 100.f; 
			else
				valueAbility = playerWitcher.GetSkillLevel(S_Alchemy_s16) * 0.1f * playerWitcher.GetStatPercents(BCS_Toxicity); 
		}
		else
			valueAbility = 0;
		
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + "%"; 
	}
	else if ( varKey == 'toxicArm' )
	{
		if( playerWitcher.CanUseSkill(S_Alchemy_s20) )
		{
			if( playerWitcher.IsSetBonusActive(EISB_RedWolf_2) )
				valueAbility = playerWitcher.GetSkillLevel(S_Alchemy_s20) * 0.03f * playerWitcher.GetStat(BCS_Toxicity) / 100.f; 
			else
				valueAbility = playerWitcher.GetSkillLevel(S_Alchemy_s20) * 0.03f * playerWitcher.GetStatPercents(BCS_Toxicity); 
		}
		else
			valueAbility = 0;
		
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + "%"; 
	}
	else if ( varKey == 'toxicPoise' )
	{
		if( playerWitcher.CanUseSkill(S_Alchemy_s20) )
		{
			if( playerWitcher.IsSetBonusActive(EISB_RedWolf_2) )
			{
				if( playerWitcher.GetStat(BCS_Toxicity) * playerWitcher.GetSkillLevel(S_Alchemy_s20) <= 500 )
					valueAbility = playerWitcher.GetSkillLevel(S_Alchemy_s20) * 0.001f * playerWitcher.GetStat(BCS_Toxicity); 
				else
					valueAbility = 1.f - (1.f / (playerWitcher.GetSkillLevel(S_Alchemy_s20) * 0.1f * playerWitcher.GetStat(BCS_Toxicity) / 25.f));
			}
			else
				valueAbility = playerWitcher.GetSkillLevel(S_Alchemy_s20) * 0.1f * playerWitcher.GetStatPercents(BCS_Toxicity); 
		}
		else
			valueAbility = 0;
		
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + "%"; 
	}
	else if ( varKey == 'feverVigor' ) 
	{
		if( playerWitcher.HasBuff(EET_ToxicityFever) )
			valueAbility = 0.5f * playerWitcher.GetFeverEffectReductionMult();
		else
			valueAbility = 0;
		
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + "%"; 
	}
	else if ( varKey == 'feverStam' ) 
	{
		if( playerWitcher.HasBuff(EET_ToxicityFever) )
			valueAbility = 0.5f * playerWitcher.GetFeverEffectReductionMult();
		else
			valueAbility = 0;
		
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + "%"; 
	}
	else if ( varKey == 'feverSpeed' ) 
	{
		if( playerWitcher.HasBuff(EET_ToxicityFever) )
			valueAbility = 0.15f * playerWitcher.GetFeverEffectReductionMult();
		else
			valueAbility = 0;
		
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + "%"; 
	}
	else
	{
		valueAbility = toxicityNoLock;
		valueStr = NoTrailZeros(RoundMath(valueAbility));
	}
	//W3EE - End
	

	final_name = GetLocStringByKeyExt(locKey);
	//W3EE - Begin
	if ( final_name == "#" || final_name == "" )
		final_name = locKey;
	//W3EE - End
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr);
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", itemColor);
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatSigns(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility : float;
	var final_name : string;
	var min, max : float;
	var sp, mutDmgMod, mutMin, mutMax : SAbilityAttributeValue;
	var sword : SItemUniqueId;
	var conjunctionDamageMult : float;
	
	statObject = flashMaster.CreateTempFlashObject();
	//W3EE - Begin
	/*
	if( GetWitcherPlayer().IsMutationActive( EPMT_Mutation1 ) )
	{
		sword = thePlayer.inv.GetCurrentlyHeldSword();
			
		if( thePlayer.inv.GetItemCategory(sword) == 'steelsword' )
		{
			mutDmgMod += thePlayer.inv.GetItemAttributeValue(sword, theGame.params.DAMAGE_NAME_SLASHING);
		}
		else if( thePlayer.inv.GetItemCategory(sword) == 'silversword' )
		{
			mutDmgMod += thePlayer.inv.GetItemAttributeValue(sword, theGame.params.DAMAGE_NAME_SILVER);
		}
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation1', 'dmg_bonus_factor', mutMin, mutMax);
			
		mutDmgMod.valueBase *= CalculateAttributeValue(mutMin);
	}
	*/
	//W3EE - End
	
	if ( varKey == 'aard_knockdownchance' )	
	{ 
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_1);
		valueAbility = sp.valueMultiplicative / theGame.params.MAX_SPELLPOWER_ASSUMED - 4 * theGame.params.NPC_RESIST_PER_LEVEL;  
		valueStr = (string)RoundMath( valueAbility * 100 ) + " %";
	}
	//W3EE - Begin
	else if ( varKey == 'spell_power_aard' )
	{
		sp = GetWitcherPlayer().GetSingleSignSpellPower(S_Magic_1);
		valueAbility = sp.valueMultiplicative;
		valueStr = (string)RoundMath(100 + valueAbility * 100) + " %";
	}
	else if ( varKey == 'spell_power_igni' )
	{
		sp = GetWitcherPlayer().GetSingleSignSpellPower(S_Magic_2);
		valueAbility = sp.valueMultiplicative;
		valueStr = (string)RoundMath(100 + valueAbility * 100) + " %";
	}
	else if ( varKey == 'spell_power_quen' )
	{
		sp = GetWitcherPlayer().GetSingleSignSpellPower(S_Magic_4);
		valueAbility = sp.valueMultiplicative;
		valueStr = (string)RoundMath(100 + valueAbility * 100) + " %";
	}
	else if ( varKey == 'spell_power_yrden' )
	{
		sp = GetWitcherPlayer().GetSingleSignSpellPower(S_Magic_3);
		valueAbility = sp.valueMultiplicative;
		valueStr = (string)RoundMath(100 + valueAbility * 100) + " %";
	}
	else if ( varKey == 'spell_power_axii' )
	{
		sp = GetWitcherPlayer().GetSingleSignSpellPower(S_Magic_5);
		valueAbility = sp.valueMultiplicative;
		valueStr = (string)RoundMath(100 + valueAbility * 100) + " %";
	}
	else if ( varKey == 'aard_damage' ) 	
	{  
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_1);
		valueAbility = 500.f;
		if (GetWitcherPlayer().GetSkillLevel(S_Magic_s20) >= 2)
			valueAbility += 125.f;
		if (GetWitcherPlayer().GetSkillLevel(S_Magic_s20) >= 4)
			valueAbility += 125.f;
		if( !GetWitcherPlayer().CanUseSkill(S_Magic_s12) )
			valueAbility += CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue('aard_damage_bonus'));
		valueAbility += mutDmgMod.valueBase;
		valueAbility *= sp.valueMultiplicative;
		valueStr = (string)RoundMath( valueAbility * Damage().pdams );
	}
	else if ( varKey == 'aard_frost_damage' ) 	
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_1);
		valueAbility = 50.f * GetWitcherPlayer().GetSkillLevel(S_Magic_s12);
		if( GetWitcherPlayer().CanUseSkill(S_Magic_s12) )
			valueAbility += CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue('aard_damage_bonus'));
		valueAbility += mutDmgMod.valueBase;
		valueAbility *= sp.valueMultiplicative;
		valueStr = (string)RoundMath( valueAbility * Damage().pdams );
	}
	else if ( varKey == 'igni_damage' ) 	
	{  
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
		valueAbility = 200.f + GetWitcherPlayer().GetSkillLevel(S_Magic_s09) * 40.f;
		valueAbility += CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue('igni_damage_bonus'));
		valueAbility += mutDmgMod.valueBase;
		valueAbility *= sp.valueMultiplicative;
		valueStr = (string)RoundMath( valueAbility * Damage().pdams );
	}
	else if ( varKey == 'igni_burnchance' ) 	
	{  
		valueAbility = 0.2f;
		if (GetWitcherPlayer().GetSignOwner().CanUseSkill(S_Magic_s07))
		{
			valueAbility += 0.05f * GetWitcherPlayer().GetSkillLevel(S_Magic_s07);
		}
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
		valueAbility *= sp.valueMultiplicative;
		valueAbility += 0.3f;
		valueStr = (string)Min(100, RoundMath(valueAbility * 100)) + " %";
	}
	else if ( varKey == 'quen_damageabs' )
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_4);
		valueAbility = 1000;
		valueAbility *= sp.valueMultiplicative;
		valueStr = (string)RoundMath( valueAbility );
	}
	else if ( varKey == 'quen_duration' )
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_4);
		valueAbility = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_4, 'shield_duration', true, true));
		valueAbility *= sp.valueMultiplicative * 1.5f * GetWitcherPlayer().GetPlayerSignDurationMod();
		valueStr = RoundMath(valueAbility) /*FloatToStringPrec( valueAbility, 2 )*/ + GetLocStringByKeyExt("per_second");
	}
	else if ( varKey == 'yrden_slowdown' )
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
		min = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_3, 'min_slowdown', false, true));
		max = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_3, 'max_slowdown', false, true));
		valueAbility =  0.15f * sp.valueMultiplicative;
		valueStr = (string)RoundMath( valueAbility * 100 ) + " %";
	}
	else if ( varKey == 'yrden_damage' )
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
		valueAbility = 20 * (GetWitcherPlayer().GetSkillLevel(S_Magic_s11) + 1) * sp.valueMultiplicative;
		valueStr = (string)RoundMath( valueAbility * Damage().pdams );
	}
	else if ( varKey == 'yrden_duration' )
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
		valueAbility = 40;
		if (GetWitcherPlayer().GetSignOwner().CanUseSkill(S_Magic_s10))
			valueAbility += GetWitcherPlayer().GetSkillLevel(S_Magic_s10) * 4;
		valueAbility *= sp.valueMultiplicative * GetWitcherPlayer().GetPlayerSignDurationMod();
		valueStr = FloatToStringPrec( valueAbility, 2 ) + GetLocStringByKeyExt("per_second");
	}
	else if ( varKey == 'axii_duration_confusion' )
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_5);
		valueAbility = 10 * (1 + GetWitcherPlayer().GetSkillLevel(S_Magic_s19) * 0.2f) * sp.valueMultiplicative * GetWitcherPlayer().GetPlayerSignDurationMod();
		valueStr = RoundMath(valueAbility) + GetLocStringByKeyExt("per_second");
	}
	else if ( varKey == 'vigorRegen' ) 
	{
		valueAbility = Combat().GetPlayerVigorRegen();
		if( GetWitcherPlayer().GetStatPercents(BCS_Vitality) >= 0.999f  && (GetWitcherPlayer().HasAbility('Glyphword 41 _Stats', true) || GetWitcherPlayer().HasAbility('Glyphword 42 _Stats', true)) )
			valueAbility *= 1.f + Combat().GetPlayerVitalityRegen(true) / 200;
		valueStr = NoTrailZeros(RoundTo(valueAbility, 2)) + "/" + GetLocStringByKeyExt("per_second");
	}
	//W3EE - End
	else
	{	
		valueAbility =  CalculateAttributeValue( GetWitcherPlayer().GetAttributeValue( varKey ) );
		valueStr = IntToString( RoundF(  valueAbility ) );
	}
	
	final_name = GetLocStringByKeyExt(locKey);
	//W3EE - Begin
	if ( final_name == "#" || final_name == "" )
		final_name = locKey;
	//W3EE - End
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr);
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", "Blue");
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatF(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility, pts, perc : float;
	var final_name : string;
	var witcher : W3PlayerWitcher;
	var isPointResist : bool;
	var stat : EBaseCharacterStats;
	var resist : ECharacterDefenseStats;
	var attributeValue : SAbilityAttributeValue;
	var powerStat : ECharacterPowerStats;
	
	statObject = flashMaster.CreateTempFlashObject();
		
	
	witcher = GetWitcherPlayer();
	stat = StatNameToEnum(varKey);
	if(stat != BCS_Undefined)
	{
		valueAbility = witcher.GetStat(stat);
	}
	else
	{
		resist = ResistStatNameToEnum(varKey, isPointResist);
		if(resist != CDS_None)
		{
			witcher.GetResistValue(resist, pts, perc);
			
			if(isPointResist)
				valueAbility = pts;
			else
				valueAbility = perc;
		}
		else
		{
			powerStat = PowerStatNameToEnum(varKey);
			if(powerStat != CPS_Undefined)
			{
				attributeValue = witcher.GetPowerStatValue(powerStat);
			}
			else
			{
				attributeValue = witcher.GetAttributeValue(varKey);
			}
			
			valueAbility = CalculateAttributeValue( attributeValue );
		}
	}
	
	
	valueStr = NoTrailZeros( RoundMath(valueAbility * 100) );
	
	final_name = GetLocStringByKeyExt(locKey);
	if ( final_name == "#" )
	{
		final_name = "";
	}
	
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr + " %");
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatU(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var curStats:SPlayerOffenseStats;
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility, maxHealth, curHealth : float;
	var sp : SAbilityAttributeValue;
	var final_name : string;
	var item : SItemUniqueId;
	
	var isNigredo : bool; //W3EE
	var nigredoLvl : float; //W3EE
	var itemBuffs : array<CBaseGameplayEffect>; //W3EE
	var playerWitcher : W3PlayerWitcher = GetWitcherPlayer(); //W3EE

	statObject = flashMaster.CreateTempFlashObject();
	
	if(varKey != 'safe_dodge_angle' && varKey != 'instant_kill_chance_mult' && varKey != 'human_exp_bonus_when_fatal' && varKey != 'nonhuman_exp_bonus_when_fatal' && varKey != 'area_nml' && varKey != 'area_novigrad' && varKey != 'area_skellige' && varKey != 'silverFastAP' && varKey != 'silverStrongAP' && varKey != 'steelFastAP' && varKey != 'steelStrongAP' && varKey != 'silverFlankingPower' && varKey != 'steelFlankingPower' && varKey != 'silverModVsMortal' && varKey != 'silverModVsMonster' && varKey != 'silverModVsSuper' && varKey != 'steelModVsMortal' && varKey != 'steelModVsMonster' && varKey != 'steelModVsSuper') //W3EE
	{
		curStats = playerWitcher.GetOffenseStatsList();
	}
	
	//W3EE - Begin
	if( playerWitcher.CountEffectsOfType(EET_NigredoDominance) > 0 )
	{
		isNigredo = true;
		nigredoLvl = 1.f + (0.05f * ((W3Effect_NigredoDominance)playerWitcher.GetBuff(EET_NigredoDominance)).GetSecondarySubstanceEffectLevel()) * (1.f + 0.2f * playerWitcher.GetSkillLevel(S_Alchemy_s01));
	}
	
	if ( varKey == 'silverdamage' ) { valueAbility = ((curStats.silverFastDPS * Damage().pdam * Combat().GetPlayerStaminaDamageModifier())+(curStats.silverStrongDPS * Damage().pdam * Combat().GetPlayerStaminaDamageModifier())); if( isNigredo ) valueAbility *= nigredoLvl; valueAbility /= 2; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	else if ( varKey == 'steeldamage' ) { valueAbility = ((curStats.steelFastDPS * Damage().pdam * Combat().GetPlayerStaminaDamageModifier())+(curStats.steelStrongDPS * Damage().pdam * Combat().GetPlayerStaminaDamageModifier())); if( isNigredo ) valueAbility *= nigredoLvl; valueAbility /= 2; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	else if ( varKey == 'silverFastDPS' ) { valueAbility = curStats.silverFastDmg * Damage().pdam * Combat().GetPlayerStaminaDamageModifier(); if( isNigredo ) valueAbility *= nigredoLvl; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	else if ( varKey == 'silverFastCritChance' ) 	valueStr = NoTrailZeros(RoundMath(curStats.silverFastCritChance)) + "%";
	else if ( varKey == 'silverFastCritDmg' ) { valueAbility = curStats.silverFastCritDmg * Damage().pdam * Combat().GetPlayerStaminaDamageModifier(); if( isNigredo ) valueAbility *= nigredoLvl; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	else if ( varKey == 'silverStrongDPS' )	{ valueAbility = curStats.silverStrongDmg * Damage().pdam * Combat().GetPlayerStaminaDamageModifier(); if( isNigredo ) valueAbility *= nigredoLvl; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	else if ( varKey == 'silverStrongCritChance' )	valueStr = NoTrailZeros(RoundMath(curStats.silverStrongCritChance)) + "%";
	else if ( varKey == 'silverStrongCritDmg' ) { valueAbility = curStats.silverStrongCritDmg * Damage().pdam * Combat().GetPlayerStaminaDamageModifier(); if( isNigredo ) valueAbility *= nigredoLvl; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	else if ( varKey == 'steelFastDPS' ) { valueAbility = curStats.steelFastDmg * Damage().pdam * Combat().GetPlayerStaminaDamageModifier(); if( isNigredo ) valueAbility *= nigredoLvl; valueStr = NoTrailZeros(RoundMath(valueAbility));	}
	else if ( varKey == 'steelFastCritChance' )		valueStr = NoTrailZeros(RoundMath(curStats.steelFastCritChance)) + "%";
	else if ( varKey == 'steelFastCritDmg' ) { valueAbility = curStats.steelFastCritDmg * Damage().pdam * Combat().GetPlayerStaminaDamageModifier(); if( isNigredo ) valueAbility *= nigredoLvl; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	else if ( varKey == 'steelStrongDPS' )	{ valueAbility = curStats.steelStrongDmg * Damage().pdam * Combat().GetPlayerStaminaDamageModifier(); if( isNigredo ) valueAbility *= nigredoLvl; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	else if ( varKey == 'steelStrongCritChance' )	valueStr = NoTrailZeros(RoundMath(curStats.steelStrongCritChance)) + "%";
	else if ( varKey == 'steelStrongCritDmg' ) { valueAbility = curStats.steelStrongCritDmg * Damage().pdam * Combat().GetPlayerStaminaDamageModifier(); if( isNigredo ) valueAbility *= nigredoLvl; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	else if ( varKey == 'silverFastAtkSpeed' ) { valueAbility = curStats.silverFastSpeed; valueStr = (string)NoTrailZeros(RoundMath(valueAbility * 100)) + "%"; }
	else if ( varKey == 'silverStrongAtkSpeed' ) { valueAbility = curStats.silverStrongSpeed; valueStr = (string)NoTrailZeros(RoundMath(valueAbility * 100)) + "%"; }
	else if ( varKey == 'steelFastAtkSpeed' ) { valueAbility = curStats.steelFastSpeed; valueStr = (string)NoTrailZeros(RoundMath(valueAbility * 100)) + "%"; }
	else if ( varKey == 'steelStrongAtkSpeed' ) { valueAbility = curStats.steelStrongSpeed; valueStr = (string)NoTrailZeros(RoundMath(valueAbility * 100)) + "%"; }
	else if (varKey == 'silverFastAP' ) 
	{ 
		valueAbility = 0;

		if( playerWitcher.GetCurrentMeleeWeaponType() == PW_Silver )
		{
			sp = playerWitcher.GetAttributeValue('armor_reduction');
			valueAbility = sp.valueMultiplicative - 1.f;
			sp = playerWitcher.GetAttributeValue('armor_reduction_fast_style');
			valueAbility += sp.valueMultiplicative;
			
			if( playerWitcher.IsSetBonusActive(EISB_Temerian) && Combat().Perk21Active )
				valueAbility += 0.2f;
			if( playerWitcher.HasBuff(EET_EnhancedWeapon) && (playerWitcher.HasAbility('Runeword 52 _Stats', true) || playerWitcher.HasAbility('Runeword 53 _Stats', true) || playerWitcher.HasAbility('Runeword 54 _Stats', true)) )
				valueAbility += 0.2f;
		}
		else if ( playerWitcher.GetItemEquippedOnSlot(EES_SilverSword, item) )
		{
			sp = thePlayer.inv.GetItemAttributeValue(item, 'armor_reduction');
			valueAbility = sp.valueMultiplicative;
			sp = thePlayer.inv.GetItemAttributeValue(item, 'armor_reduction_fast_style');
			valueAbility += sp.valueMultiplicative;
			
			if( playerWitcher.IsSetBonusActive(EISB_Temerian) && Combat().Perk21Active )
				valueAbility += 0.2f;
			if( thePlayer.inv.ItemHasAbility(item, 'Runeword 52 _Stats') || thePlayer.inv.ItemHasAbility(item, 'Runeword 53 _Stats') || thePlayer.inv.ItemHasAbility(item, 'Runeword 54 _Stats') )
			{
				itemBuffs = playerWitcher.GetBuffs(EET_EnhancedWeapon, thePlayer.inv.GetItemName(item));
				if( itemBuffs.Size() > 0 )
					valueAbility += 0.2f;
			}
		}
		
		valueAbility = MinF(valueAbility * Damage().pap, 1.f);
		valueStr =  NoTrailZeros(RoundMath(valueAbility * 100)) + "%";
	}
	else if (varKey == 'silverStrongAP' ) 
	{ 
		valueAbility = 0;

		if( playerWitcher.GetCurrentMeleeWeaponType() == PW_Silver )
		{
			sp = playerWitcher.GetAttributeValue('armor_reduction');
			valueAbility = sp.valueMultiplicative - 1.f;
			sp = playerWitcher.GetAttributeValue('armor_reduction_heavy_style');
			valueAbility += sp.valueMultiplicative;
			
			valueAbility += 0.25f;
			valueAbility += playerWitcher.GetSkillLevel(S_Sword_s08) * 0.03f;
			
			if( playerWitcher.IsSetBonusActive(EISB_Temerian) && Combat().Perk21Active )
				valueAbility += 0.2f;
			if( playerWitcher.HasBuff(EET_EnhancedWeapon) && (playerWitcher.HasAbility('Runeword 52 _Stats', true) || playerWitcher.HasAbility('Runeword 53 _Stats', true) || playerWitcher.HasAbility('Runeword 54 _Stats', true)) )
				valueAbility += 0.2f;
		}
		else if ( playerWitcher.GetItemEquippedOnSlot(EES_SilverSword, item) )
		{
			sp = thePlayer.inv.GetItemAttributeValue(item, 'armor_reduction');
			valueAbility = sp.valueMultiplicative;
			sp = thePlayer.inv.GetItemAttributeValue(item, 'armor_reduction_heavy_style');
			valueAbility += sp.valueMultiplicative;
			
			valueAbility += 0.25f;
			valueAbility += playerWitcher.GetSkillLevel(S_Sword_s08) * 0.03f;
			
			if( playerWitcher.IsSetBonusActive(EISB_Temerian) && Combat().Perk21Active )
				valueAbility += 0.2f;
			if( thePlayer.inv.ItemHasAbility(item, 'Runeword 52 _Stats') || thePlayer.inv.ItemHasAbility(item, 'Runeword 53 _Stats') || thePlayer.inv.ItemHasAbility(item, 'Runeword 54 _Stats') )
			{
				itemBuffs = playerWitcher.GetBuffs(EET_EnhancedWeapon, thePlayer.inv.GetItemName(item));
				if( itemBuffs.Size() > 0 )
					valueAbility += 0.2f;
			}
		}
		
		valueAbility = MinF(valueAbility * Damage().pap, 1.f);
		valueStr =  NoTrailZeros(RoundMath(valueAbility * 100)) + "%";
	}
	else if (varKey == 'steelFastAP' ) 
	{ 
		valueAbility = 0;

		if( playerWitcher.GetCurrentMeleeWeaponType() == PW_Steel )
		{
			sp = playerWitcher.GetAttributeValue('armor_reduction');
			valueAbility = sp.valueMultiplicative - 1.f;
			sp = playerWitcher.GetAttributeValue('armor_reduction_fast_style');
			valueAbility += sp.valueMultiplicative;
			
			if( playerWitcher.IsSetBonusActive(EISB_Temerian) && Combat().Perk21Active )
				valueAbility += 0.2f;
			if( playerWitcher.HasBuff(EET_EnhancedWeapon) && (playerWitcher.HasAbility('Runeword 52 _Stats', true) || playerWitcher.HasAbility('Runeword 53 _Stats', true) || playerWitcher.HasAbility('Runeword 54 _Stats', true)) )
				valueAbility += 0.2f;
		}
		else if ( playerWitcher.GetItemEquippedOnSlot(EES_SteelSword, item) )
		{
			sp = thePlayer.inv.GetItemAttributeValue(item, 'armor_reduction');
			valueAbility = sp.valueMultiplicative;
			sp = thePlayer.inv.GetItemAttributeValue(item, 'armor_reduction_fast_style');
			valueAbility += sp.valueMultiplicative;
			
			if( playerWitcher.IsSetBonusActive(EISB_Temerian) && Combat().Perk21Active )
				valueAbility += 0.2f;
			if( thePlayer.inv.ItemHasAbility(item, 'Runeword 52 _Stats') || thePlayer.inv.ItemHasAbility(item, 'Runeword 53 _Stats') || thePlayer.inv.ItemHasAbility(item, 'Runeword 54 _Stats') )
			{
				itemBuffs = playerWitcher.GetBuffs(EET_EnhancedWeapon, thePlayer.inv.GetItemName(item));
				if( itemBuffs.Size() > 0 )
					valueAbility += 0.2f;
			}
		}
		
		valueAbility = MinF(valueAbility * Damage().pap, 1.f);
		valueStr =  NoTrailZeros(RoundMath(valueAbility * 100)) + "%";
	}
	else if (varKey == 'steelStrongAP' ) 
	{ 
		valueAbility = 0;

		if( playerWitcher.GetCurrentMeleeWeaponType() == PW_Steel )
		{
			sp = playerWitcher.GetAttributeValue('armor_reduction');
			valueAbility = sp.valueMultiplicative - 1.f;
			sp = playerWitcher.GetAttributeValue('armor_reduction_heavy_style');
			valueAbility += sp.valueMultiplicative;
			
			valueAbility += 0.25f;
			valueAbility += playerWitcher.GetSkillLevel(S_Sword_s08) * 0.03f;
			
			if( playerWitcher.IsSetBonusActive(EISB_Temerian) && Combat().Perk21Active )
				valueAbility += 0.2f;
			if( playerWitcher.HasBuff(EET_EnhancedWeapon) && (playerWitcher.HasAbility('Runeword 52 _Stats', true) || playerWitcher.HasAbility('Runeword 53 _Stats', true) || playerWitcher.HasAbility('Runeword 54 _Stats', true)) )
				valueAbility += 0.2f;
		}
		else if ( playerWitcher.GetItemEquippedOnSlot(EES_SteelSword, item) )
		{
			sp = thePlayer.inv.GetItemAttributeValue(item, 'armor_reduction');
			valueAbility = sp.valueMultiplicative;
			sp = thePlayer.inv.GetItemAttributeValue(item, 'armor_reduction_heavy_style');
			valueAbility += sp.valueMultiplicative;
			
			valueAbility += 0.25f;
			valueAbility += playerWitcher.GetSkillLevel(S_Sword_s08) * 0.03f;
			
			if( playerWitcher.IsSetBonusActive(EISB_Temerian) && Combat().Perk21Active )
				valueAbility += 0.2f;
			if( thePlayer.inv.ItemHasAbility(item, 'Runeword 52 _Stats') || thePlayer.inv.ItemHasAbility(item, 'Runeword 53 _Stats') || thePlayer.inv.ItemHasAbility(item, 'Runeword 54 _Stats') )
			{
				itemBuffs = playerWitcher.GetBuffs(EET_EnhancedWeapon, thePlayer.inv.GetItemName(item));
				if( itemBuffs.Size() > 0 )
					valueAbility += 0.2f;
			}
		}
		
		valueAbility = MinF(valueAbility * Damage().pap, 1.f);
		valueStr =  NoTrailZeros(RoundMath(valueAbility * 100)) + "%";
	}
	else if (varKey == 'silverFlankingPower')
	{
		valueAbility = 1;
		
		if( playerWitcher.GetCurrentMeleeWeaponType() == PW_Silver )
		{
			sp = playerWitcher.GetAttributeValue('damage_from_behind_off');
			valueAbility += sp.valueMultiplicative;
			
			if( playerWitcher.CanUseSkill(S_Perk_16) )
				valueAbility += 0.1f;
			
			if( playerWitcher.HasBuff(EET_LynxSetAttack) )
				valueAbility += 0.1f * playerWitcher.GetSetPartsEquipped(EIST_Lynx);
		}
		else if( playerWitcher.GetItemEquippedOnSlot(EES_SilverSword, item) )
		{
			sp = thePlayer.inv.GetItemAttributeValue(item, 'damage_from_behind_off');
			valueAbility += sp.valueMultiplicative;
			
			if( playerWitcher.CanUseSkill(S_Perk_16) )
				valueAbility += 0.1f;
			
			if( playerWitcher.HasBuff(EET_LynxSetAttack) )
				valueAbility += 0.1f * playerWitcher.GetSetPartsEquipped(EIST_Lynx);
		}
		
		valueStr = RoundMath(valueAbility * 100) + "%";
	}
	else if (varKey == 'steelFlankingPower')
	{
		valueAbility = 1;
		
		if( playerWitcher.GetCurrentMeleeWeaponType() == PW_Steel )
		{
			sp = playerWitcher.GetAttributeValue('damage_from_behind_off');
			valueAbility += sp.valueMultiplicative;
			
			if( playerWitcher.CanUseSkill(S_Perk_16) )
				valueAbility += 0.1f;
			
			if( playerWitcher.HasBuff(EET_LynxSetAttack) )
				valueAbility += 0.1f * playerWitcher.GetSetPartsEquipped(EIST_Lynx);
		}
		else if( playerWitcher.GetItemEquippedOnSlot(EES_SteelSword, item) )
		{
			sp = thePlayer.inv.GetItemAttributeValue(item, 'damage_from_behind_off');
			valueAbility += sp.valueMultiplicative;
			
			if( playerWitcher.CanUseSkill(S_Perk_16) )
				valueAbility += 0.1f;
			
			if( playerWitcher.HasBuff(EET_LynxSetAttack) )
				valueAbility += 0.1f * playerWitcher.GetSetPartsEquipped(EIST_Lynx);
		}
		
		valueStr = RoundMath(valueAbility * 100) + "%";
	}
	else if (varKey == 'silverModVsMortal')
	{
		if( playerWitcher.GetItemEquippedOnSlot(EES_SilverSword, item) )
		{
			sp = thePlayer.inv.GetItemAttributeValue(item, 'SilverDamage');
			valueAbility = sp.valueBase;
			sp = thePlayer.inv.GetItemAttributeValue(item, 'SlashingDamage');
			valueAbility = sp.valueBase / valueAbility;
		}
		
		valueStr = RoundMath(valueAbility * 100) + "%";
	}
	else if (varKey == 'silverModVsMonster')
	{
		valueStr = "100%";
	}
	else if (varKey == 'silverModVsSuper')
	{
		valueStr = "100%";
	}
	else if (varKey == 'steelModVsMortal')
	{
		valueStr = "100%";
	}
	else if (varKey == 'steelModVsMonster')
	{
		if( playerWitcher.GetItemEquippedOnSlot(EES_SteelSword, item) )
		{
			sp = thePlayer.inv.GetItemAttributeValue(item, 'SlashingDamage');
			valueAbility = sp.valueBase;
			sp = thePlayer.inv.GetItemAttributeValue(item, 'SilverDamage');
			valueAbility = sp.valueBase / valueAbility;
		}
		
		valueStr = RoundMath(valueAbility * 100) + "%";
	}
	else if (varKey == 'steelModVsSuper')
	{
		if( playerWitcher.GetItemEquippedOnSlot(EES_SteelSword, item) )
		{
			sp = thePlayer.inv.GetItemAttributeValue(item, 'SlashingDamage');
			valueAbility = sp.valueBase;
			sp = thePlayer.inv.GetItemAttributeValue(item, 'SilverDamage');
			valueAbility = sp.valueBase / valueAbility;
			valueAbility *= 0.1f;
		}
		
		valueStr = RoundMath(valueAbility * 100) + "%";
	}
	else if ( varKey == 'crossbowCritChance' )
	{
		if( thePlayer.IsSetBonusActive(EISB_Elven_1) )
			valueStr = NoTrailZeros(RoundMath((curStats.crossbowCritChance + 0.1f) * 100)) + "%";
		else
			valueStr = NoTrailZeros(RoundMath(curStats.crossbowCritChance * 100)) + "%";
	}
	else if ( varKey == 'crossbowDmg' )				valueStr = "";
	else if ( varKey == 'crossbowSteelDmg' )				
	{ 
		if( isNigredo ) valueAbility *= nigredoLvl;
		valueStr = NoTrailZeros(RoundMath(curStats.crossbowSteelDmg * Damage().pdamc));
		switch (curStats.crossbowSteelDmgType)
		{
			case theGame.params.DAMAGE_NAME_BLUDGEONING: locKey = "attribute_name_bludgeoningdamage"; break;
			case theGame.params.DAMAGE_NAME_FIRE: locKey = "attribute_name_firedamage"; break;
			default : locKey = "attribute_name_piercingdamage"; break;
		}
	} 
	else if ( varKey == 'crossbowSilverDmg' )				
	{
		if( isNigredo ) valueAbility *= nigredoLvl; valueStr = NoTrailZeros(RoundMath(curStats.crossbowSilverDmg * Damage().pdamc));
	}
	else if (varKey == 'safe_dodge_angle' )
	{
		valueStr = Combat().GetSafeDodgeAngle();
	}
	//W3EE - End
	else if ( varKey == 'instant_kill_chance_mult') 
	{
		valueAbility = 0;
		//W3EE - Begin
		/*
		if (thePlayer.CanUseSkill(S_Sword_s03))
		{
			sp += playerWitcher.GetSkillAttributeValue(S_Sword_s03, 'instant_kill_chance', false, true);
			valueAbility = CalculateAttributeValue(sp);
			valueAbility *= thePlayer.GetSkillLevel(S_Sword_s03);
			valueAbility *= RoundF(thePlayer.GetStat(BCS_Focus));
		}
		*/
		//W3EE - End
		if (playerWitcher.GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(item, varKey)); 
		if (playerWitcher.GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(item, varKey)); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if (varKey == 'human_exp_bonus_when_fatal' || varKey == 'nonhuman_exp_bonus_when_fatal') 
	{
		sp = thePlayer.GetAttributeValue(varKey);

		valueStr = NoTrailZeros(RoundMath(CalculateAttributeValue(sp) * 100)) + " %";
	}
	else if (varKey == 'area_nml') 
	{
		if (!thePlayer.HasAbility(varKey))
			locKey = "";
		else
		{
			
			
		}
	}
	else if (varKey == 'area_novigrad') 
	{
		if (!thePlayer.HasAbility(varKey))
			locKey = "";
		else
		{
			
			
		}
	}
	else if (varKey == 'area_skellige') 
	{
		if (!thePlayer.HasAbility(varKey))
			locKey = "";
		else
		{
			
			
		}
	}
	
	final_name = GetLocStringByKeyExt(locKey); //W3EE

	//W3EE - Begin
	if ( final_name == "#" || final_name == "" )
		final_name = locKey;
	//W3EE - End
	
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr );
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", "Red");
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatU2(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var curStats:SPlayerOffenseStats;
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility, maxHealth, curHealth : float;
	var sp : SAbilityAttributeValue;
	var final_name : string;
	var item : SItemUniqueId;

	statObject = flashMaster.CreateTempFlashObject();
	
	if ( varKey == 'silver_desc_poinsonchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_poinsonchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_bleedingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_bleedingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_burningchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_burningchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_confusionchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_confusionchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_freezingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_freezingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_staggerchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_staggerchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	}
	else if ( varKey == 'steel_desc_poinsonchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_poinsonchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_bleedingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_bleedingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_burningchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_burningchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_confusionchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_confusionchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_freezingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_freezingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_staggerchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_staggerchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	}
	
	final_name = GetLocStringByKeyExt(locKey); if ( final_name == "#" ) { final_name = ""; }
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr );
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function GetEquippedCrossbowDamage():float
{
	var equippedBolt		  : SItemUniqueId;
	var equippedCrossbow	  : SItemUniqueId;
	var crossbowPower         : SAbilityAttributeValue;
	var crossbowStatValueMult : float;
	var primaryStatLabel      : string;
	var primaryStatValue      : float;
	var silverDamageValue	  : float;
	var min, max 			  : SAbilityAttributeValue;
	
	GetWitcherPlayer().GetItemEquippedOnSlot(EES_RangedWeapon, equippedCrossbow);
	if (!thePlayer.inv.IsIdValid(equippedCrossbow))
	{
		return 0;
	}
	
	crossbowPower = thePlayer.inv.GetItemAttributeValue(equippedCrossbow, 'attack_power');
	//W3EE - Begin
	if(thePlayer.CanUseSkill(S_Sword_s13))
	{				
		crossbowPower.valueMultiplicative += 0.05f * thePlayer.GetSkillLevel(S_Sword_s13);
	}
	//W3EE - End
	crossbowPower += thePlayer.GetPowerStatValue(CPS_AttackPower);
	
	if (crossbowStatValueMult == 0)
	{
		
		crossbowStatValueMult = 1;
	}
	GetWitcherPlayer().GetItemEquippedOnSlot(EES_Bolt, equippedBolt);
	if (thePlayer.inv.IsIdValid(equippedBolt))
	{
		thePlayer.inv.GetItemPrimaryStat(equippedBolt, primaryStatLabel, primaryStatValue);
		silverDamageValue = CalculateAttributeValue(GetWitcherPlayer().GetInventory().GetItemAttributeValue(equippedBolt, theGame.params.DAMAGE_NAME_SILVER));
	}
	else
	{
		//W3EE - Begin
		/*
		thePlayer.inv.GetItemStatByName('Bodkin Bolt', 'PiercingDamage', primaryStatValue);
		thePlayer.inv.GetItemStatByName('Bodkin Bolt', 'SilverDamage', silverDamageValue);
		*/
		primaryStatValue = 0;
		silverDamageValue = 0;
		//W3EE - End
	}
	
	//W3EE - Begin
	/*
	if( GetWitcherPlayer().IsMutationActive( EPMT_Mutation9 ) )
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation9', 'damage', min, max );
		primaryStatValue += min.valueAdditive;
		silverDamageValue += min.valueAdditive;
	}
	*/
	//W3EE - End
	primaryStatValue = (primaryStatValue + crossbowPower.valueBase) * crossbowPower.valueMultiplicative + crossbowPower.valueAdditive;
	silverDamageValue = (silverDamageValue + crossbowPower.valueBase) * crossbowPower.valueMultiplicative + crossbowPower.valueAdditive;
	
	return (primaryStatValue + silverDamageValue) / 2;
}