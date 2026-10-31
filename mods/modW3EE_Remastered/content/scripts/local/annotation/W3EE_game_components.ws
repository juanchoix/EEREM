////////////////////////////////////////////////////////
//-- scripts\game\components\inventoryComponent.ws --//
//////////////////////////////////////////////////////
@wrapMethod(CInventoryComponent)
function GetMoney() : int
{
	if( GetEntity() == thePlayer )
		return GetItemQuantityByName('Crowns') + GetWitcherPlayer().GetHorseManager().GetInventoryComponent().GetItemQuantityByName('Crowns');
		
	else if( this == GetWitcherPlayer().GetHorseManager().GetInventoryComponent() )
		return GetItemQuantityByName('Crowns') + GetWitcherPlayer().inv.GetItemQuantityByName('Crowns');
		
	else
		return wrappedMethod();
}

@addMethod(CInventoryComponent)
public final function GetItemLocNameByID( item : SItemUniqueId ) : string
{
	//Kolaris - Inventory Options
	if ( Options().DetailedItemNames() )
		return GetLocStringByKeyExt(GetItemLocalizedNameByUniqueID(item)) + " (" + GetItemName(item) + ")" ;
	
	if( !IsItemAnyArmor(item) && !IsItemWeapon(item) )
		return GetLocStringByKeyExt(GetItemLocalizedNameByUniqueID(item));
		
	return GetItemNameWithPrefix(item);
}

@addMethod(CInventoryComponent)
private function GetItemNameWithPrefix( item : SItemUniqueId ) : string
{
	var attributeValue : SAbilityAttributeValue;
	var abilityArray, arr : array<name>;
	var itemPrefix, itemName : string;
	var temp, textLanguage : string;
	var i : int;
		
	abilityArray.Clear();
	theGame.GetGameLanguageName(temp, textLanguage);
	if( IsItemWeapon(item) )
	{
		if( GetItemQuality(item) >= 1 )
		{
			arr = theGame.params.GetCommonWeaponAbilityArray();
			ArrayOfNamesAppend(abilityArray, arr);
		}
		if( GetItemQuality(item) >= 2 )
		{
			arr = theGame.params.GetMasterworkWeaponAbilityArray();
			ArrayOfNamesAppend(abilityArray, arr);
		}
		if( GetItemQuality(item) >= 3 )
		{
			arr = theGame.params.GetMagicalWeaponAbilityArray();
			ArrayOfNamesAppend(abilityArray, arr);
		}
	}
	else
	if( IsItemAnyArmor(item) )
	{
		if( GetItemCategory(item) == 'armor' )
		{
			if( GetItemQuality(item) >= 2 )
			{
				if( GetArmorType(item) == EAT_Light )
					arr = theGame.params.GetMasterLightArmorAbilityArray();
				else
				if( GetArmorType(item) == EAT_Medium )
					arr = theGame.params.GetMasterMediumArmorAbilityArray();
				else
				if( GetArmorType(item) == EAT_Heavy )
					arr = theGame.params.GetMasterHeavyArmorAbilityArray();
						
				ArrayOfNamesAppend(abilityArray, arr);
			}
			if( GetItemQuality(item) >= 3 )
			{
				if( GetArmorType(item) == EAT_Light )
					arr = theGame.params.GetMagicalLightArmorAbilityArray();
				else
				if( GetArmorType(item) == EAT_Medium )
					arr = theGame.params.GetMagicalMediumArmorAbilityArray();
				else
				if( GetArmorType(item) == EAT_Heavy )
					arr = theGame.params.GetMagicalHeavyArmorAbilityArray();
					
				ArrayOfNamesAppend(abilityArray, arr);
			}
		}
		else
		if( GetItemCategory(item) == 'boots' )
		{
			if( GetItemQuality(item) >= 2 )
			{
				if( GetArmorType(item) == EAT_Light )
					arr = theGame.params.GetMasterLightBootsAbilityArray();
				else
				if( GetArmorType(item) == EAT_Medium )
					arr = theGame.params.GetMasterMediumBootsAbilityArray();
				else
				if( GetArmorType(item) == EAT_Heavy )
					arr = theGame.params.GetMasterHeavyBootsAbilityArray();
						
				ArrayOfNamesAppend(abilityArray, arr);
			}
			if( GetItemQuality(item) >= 3 )
			{
				if( GetArmorType(item) == EAT_Light )
					arr = theGame.params.GetMagicalLightBootsAbilityArray();
				else
				if( GetArmorType(item) == EAT_Medium )
					arr = theGame.params.GetMagicalMediumBootsAbilityArray();
				else
				if( GetArmorType(item) == EAT_Heavy )
					arr = theGame.params.GetMagicalHeavyBootsAbilityArray();
						
				ArrayOfNamesAppend(abilityArray, arr);
			}
		}
		else
		if( GetItemCategory(item) == 'pants' )
		{
			if( GetItemQuality(item) >= 2 )
			{
				if( GetArmorType(item) == EAT_Light )
					arr = theGame.params.GetMasterLightPantsAbilityArray();
				else
				if( GetArmorType(item) == EAT_Medium )
					arr = theGame.params.GetMasterMediumPantsAbilityArray();
				else
				if( GetArmorType(item) == EAT_Heavy )
					arr = theGame.params.GetMasterHeavyPantsAbilityArray();
						
				ArrayOfNamesAppend(abilityArray, arr);
			}
			if( GetItemQuality(item) >= 3 )
			{
				if( GetArmorType(item) == EAT_Light )
					arr = theGame.params.GetMagicalLightPantsAbilityArray();
					else
				if( GetArmorType(item) == EAT_Medium )
					arr = theGame.params.GetMagicalMediumPantsAbilityArray();
				else
				if( GetArmorType(item) == EAT_Heavy )
					arr = theGame.params.GetMagicalHeavyPantsAbilityArray();
					
				ArrayOfNamesAppend(abilityArray, arr);
			}
		}
		else
		if( GetItemCategory(item) == 'gloves' )
		{
			if( GetItemQuality(item) >= 2 )
			{
				if( GetArmorType(item) == EAT_Light )
					arr = theGame.params.GetMasterLightGlovesAbilityArray();
				else
				if( GetArmorType(item) == EAT_Medium )
					arr = theGame.params.GetMasterMediumGlovesAbilityArray();
				else
				if( GetArmorType(item) == EAT_Heavy )
					arr = theGame.params.GetMasterHeavyGlovesAbilityArray();
						
				ArrayOfNamesAppend(abilityArray, arr);
			}
			if( GetItemQuality(item) >= 3 )
			{
				if( GetArmorType(item) == EAT_Light )
					arr = theGame.params.GetMagicalLightGlovesAbilityArray();
				else
				if( GetArmorType(item) == EAT_Medium )
					arr = theGame.params.GetMagicalMediumGlovesAbilityArray();
				else
				if( GetArmorType(item) == EAT_Heavy )
					arr = theGame.params.GetMagicalHeavyGlovesAbilityArray();
						
				ArrayOfNamesAppend(abilityArray, arr);
			}
		}
	}
		
	itemName = GetLocStringByKeyExt(GetItemLocalizedNameByUniqueID(item));
	for(i=0; i<abilityArray.Size(); i+=1)
	{
		attributeValue = GetItemAttributeValue(item, abilityArray[i]);
		if( attributeValue.valueBase > 0 )
		{
			itemPrefix = GetLocStringByKeyExt(NameToString(abilityArray[i]));
			if( itemPrefix != "" )
			{
				if( textLanguage == "IT" || textLanguage == "FR" || textLanguage == "BR" )
					return itemName + " " + itemPrefix;
				else
					return itemPrefix + " " + itemName;
			}
			
			break;
		}
	}
	
	return itemName;
}

@addMethod(CInventoryComponent)
	public function GetItemBasePrice( item : SItemUniqueId ) : int
	{
		var i : int;
		var price : int;
		var invItem : SInventoryItem;
		var baseAbilities : array<name>;
		var remainingAbilities, removedCrafted, removedBase : array<name>;
		var durabilityMult, categoryMult, qualityMult : float;
		
		durabilityMult = LFEGetDurabilityMult(GetItemDurabilityRatio(item));
		categoryMult = LFEGetCategoryMult(GetItemCategory(item));
		if( IsItemJewelry(item) )
			categoryMult = 1;
		qualityMult = LFEGetQualityMult(GetItemQuality(item));
		if( !IsItemAnyArmor(item) && (!IsItemWeapon(item) || IsItemCrossbow(item) || IsItemBolt(item)) )
			price = GetItemPrice(item);
		else
		{
			invItem = GetItem(item);
			GetItemAbilities(item, baseAbilities);
			for(i=0; i<baseAbilities.Size(); i+=1)
			{
				if( StrContains(baseAbilities[i], "Glyph") || StrContains(baseAbilities[i], "Rune") )
					continue;
					
				if( invItem.craftedAbilities.Contains(baseAbilities[i]) )
				{
					RemoveItemCraftedAbility(item, baseAbilities[i]);
					removedCrafted.PushBack(baseAbilities[i]);
				}
				else
				{
					RemoveItemBaseAbility(item, baseAbilities[i]);
					removedBase.PushBack(baseAbilities[i]);
				}
			}
			
			price = GetItemPrice(item);
			GetItemAbilities(item, remainingAbilities);
			for(i=0; i<removedBase.Size(); i+=1)
			{
				if( remainingAbilities.Contains(removedBase[i]) )
				{
					remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedBase[i]));
					continue;
				}
				
				AddItemBaseAbility(item, removedBase[i]);
			}
			
			for(i=0; i<removedCrafted.Size(); i+=1)
			{
				if( remainingAbilities.Contains(removedCrafted[i]) )
				{
					remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedCrafted[i]));
					continue;
				}
				
				AddItemCraftedAbility(item, removedCrafted[i], true);
			}
		}
		
		return CeilF(price * durabilityMult * categoryMult * qualityMult);
	}

@addMethod(CInventoryComponent)
	public function GetItemSellPrice( item : SItemUniqueId ) : int
	{
		var areaMult, sellingMult : float;
		
		areaMult = GetAreaPriceMult(item, GetItemQuality(item));
		//Kolaris - Difficulty Settings
		sellingMult = LFEGetSellingMult(false) * Options().GetDifficultySettingMod();
		
		return Max(1, CeilF(GetItemBasePrice(item) * areaMult * sellingMult));
	}
	
@addMethod(CInventoryComponent)
	public function GetItemBasePriceRepair( invItem : SInventoryItem, originalInventory : CInventoryComponent ) : int
	{
		var price : int;
		var repairMult : float;
		
		repairMult = LFEGetRepairMult();
		price = CeilF(originalInventory.GetItemBasePrice(invItem.uniqueId) * 0.4f * (1.f - originalInventory.GetItemDurability(invItem.uniqueId) / originalInventory.GetItemMaxDurability(invItem.uniqueId)));
		
		return Max(1, CeilF(price * repairMult));
	}
	
@addMethod(CInventoryComponent)
	public function GetItemBasePriceRemoveUpgrade( invItem : SInventoryItem, originalInventory : CInventoryComponent ) : int
	{
		var price : int;
		var removeUpgradeMult : float;
		var temp : array<name>;
		
		removeUpgradeMult = LFEGetRemoveUpgradeMult();
		originalInventory.GetItemEnhancementItems(invItem.uniqueId, temp);
		price = temp.Size() * 20;
		
		return Max(1, CeilF(price * removeUpgradeMult));
	}
	
@addMethod(CInventoryComponent)
	public function GetItemBasePriceAddSlot( invItem : SInventoryItem, originalInventory : CInventoryComponent ) : int
	{
		return 75;
	}
	
@addMethod(CInventoryComponent)
	public function GetItemBasePriceDisassemble( invItem : SInventoryItem, originalInventory : CInventoryComponent ) : int
	{
		var i : int;
		var price : int;
		var baseAbilities : array<name>;
		var unleveledItem : SInventoryItem;
		var remainingAbilities, removedCrafted, removedBase : array<name>;
		var disassembleMult : float;
		
		disassembleMult = LFEGetDisassembleMult();
		originalInventory.GetItemAbilities(invItem.uniqueId, baseAbilities);
		for(i=0; i<baseAbilities.Size(); i+=1)
		{
			if( StrContains(baseAbilities[i], "Glyph") || StrContains(baseAbilities[i], "Rune") )
				continue;
				
			if( invItem.craftedAbilities.Contains(baseAbilities[i]) )
			{
				originalInventory.RemoveItemCraftedAbility(invItem.uniqueId, baseAbilities[i]);
				removedCrafted.PushBack(baseAbilities[i]);
			}
			else
			{
				originalInventory.RemoveItemBaseAbility(invItem.uniqueId, baseAbilities[i]);
				removedBase.PushBack(baseAbilities[i]);
			}
		}
		
		unleveledItem = originalInventory.GetItem(invItem.uniqueId);
		price = GetItemPriceDisassemble(unleveledItem);
		originalInventory.GetItemAbilities(invItem.uniqueId, remainingAbilities);
		for(i=0; i<removedBase.Size(); i+=1)
		{
			if( remainingAbilities.Contains(removedBase[i]) )
			{
				remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedBase[i]));
				continue;
			}
			
			originalInventory.AddItemBaseAbility(invItem.uniqueId, removedBase[i]);
		}
		
		for(i=0; i<removedCrafted.Size(); i+=1)
		{
			if( remainingAbilities.Contains(removedCrafted[i]) )
			{
				remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedCrafted[i]));
				continue;
			}
			
			originalInventory.AddItemCraftedAbility(invItem.uniqueId, removedCrafted[i], true);
		}
		
		return Max(1, CeilF(price * disassembleMult));
	}
	
@addMethod(CInventoryComponent)
	public function GetItemBasePriceCrafting( invItem : SInventoryItem, originalInventory : CInventoryComponent ) : int
	{
		var i : int;
		var price : int;
		var baseAbilities : array<name>;
		var unleveledItem : SInventoryItem;
		var remainingAbilities, removedCrafted, removedBase : array<name>;
		var craftingMult : float;
		
		craftingMult = LFEGetCraftMult();
		originalInventory.GetItemAbilities(invItem.uniqueId, baseAbilities);
		for(i=0; i<baseAbilities.Size(); i+=1)
		{
			if( StrContains(baseAbilities[i], "Glyph") || StrContains(baseAbilities[i], "Rune") )
				continue;
				
			if( invItem.craftedAbilities.Contains(baseAbilities[i]) )
			{
				originalInventory.RemoveItemCraftedAbility(invItem.uniqueId, baseAbilities[i]);
				removedCrafted.PushBack(baseAbilities[i]);
			}
			else
			{
				originalInventory.RemoveItemBaseAbility(invItem.uniqueId, baseAbilities[i]);
				removedBase.PushBack(baseAbilities[i]);
			}
		}
		
		unleveledItem = originalInventory.GetItem(invItem.uniqueId);
		price = GetItemPriceCrafting(unleveledItem);
		originalInventory.GetItemAbilities(invItem.uniqueId, remainingAbilities);
		for(i=0; i<removedBase.Size(); i+=1)
		{
			if( remainingAbilities.Contains(removedBase[i]) )
			{
				remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedBase[i]));
				continue;
			}
			
			originalInventory.AddItemBaseAbility(invItem.uniqueId, removedBase[i]);
		}
		
		for(i=0; i<removedCrafted.Size(); i+=1)
		{
			if( remainingAbilities.Contains(removedCrafted[i]) )
			{
				remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedCrafted[i]));
				continue;
			}
			
			originalInventory.AddItemCraftedAbility(invItem.uniqueId, removedCrafted[i], true);
		}
		
		return Max(1, CeilF(price * craftingMult));
	}
	
@addMethod(CInventoryComponent)
	public function GetItemBasePriceModified( item : SItemUniqueId, optional playerSelling : bool ) : int
	{
		var i : int;
		var price : int;
		var invItem : SInventoryItem;
		var baseAbilities : array<name>;
		var remainingAbilities, removedCrafted, removedBase : array<name>;
		var durabilityMult, categoryMult, qualityMult, areaMult, sellingMult : float;
		
		durabilityMult = LFEGetDurabilityMult(GetItemDurabilityRatio(item));
		categoryMult = LFEGetCategoryMult(GetItemCategory(item));
		if( IsItemJewelry(item) )
			categoryMult = 1;
		qualityMult = LFEGetQualityMult(GetItemQuality(item));
		areaMult = GetAreaPriceMult(item, GetItemQuality(item));
		sellingMult = LFEGetSellingMult(playerSelling);
		if( playerSelling && GetWitcherPlayer().CanUseSkill(S_Perk_20) )
			sellingMult *= 1.25f;
		//Kolaris - Huntsman
		if( playerSelling && GetWitcherPlayer().CanUseSkill(S_Perk_19) && IsItemTrophy(item))
			sellingMult *= 1.5f;
		//Kolaris - Difficulty Settings
		if( playerSelling )
			sellingMult /= Options().GetDifficultySettingMod();
		else
			sellingMult *= Options().GetDifficultySettingMod();
			
		if( !IsItemAnyArmor(item) && (!IsItemWeapon(item) || IsItemCrossbow(item) || IsItemBolt(item)) )
			price = GetItemPriceModified(item, playerSelling);
		else
		{
			invItem = GetItem(item);
			GetItemAbilities(item, baseAbilities);
			for(i=0; i<baseAbilities.Size(); i+=1)
			{
				if( StrContains(baseAbilities[i], "Glyph") || StrContains(baseAbilities[i], "Rune") )
					continue;
					
				if( invItem.craftedAbilities.Contains(baseAbilities[i]) )
				{
					RemoveItemCraftedAbility(item, baseAbilities[i]);
					removedCrafted.PushBack(baseAbilities[i]);
				}
				else
				{
					RemoveItemBaseAbility(item, baseAbilities[i]);
					removedBase.PushBack(baseAbilities[i]);
				}
			}
			
			price = GetItemPriceModified(item, playerSelling);
			GetItemAbilities(invItem.uniqueId, remainingAbilities);
			for(i=0; i<removedBase.Size(); i+=1)
			{
				if( remainingAbilities.Contains(removedBase[i]) )
				{
					remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedBase[i]));
					continue;
				}
				
				AddItemBaseAbility(item, removedBase[i]);
			}
			
			for(i=0; i<removedCrafted.Size(); i+=1)
			{
				if( remainingAbilities.Contains(removedCrafted[i]) )
				{
					remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedCrafted[i]));
					continue;
				}
				
				AddItemCraftedAbility(item, removedCrafted[i], true);
			}
		}
		
		if( playerSelling )
			return Abs(FloorF(price * areaMult * durabilityMult * categoryMult * qualityMult * sellingMult));
		else
			return Abs(CeilF(price * areaMult * durabilityMult * categoryMult * qualityMult * sellingMult));
	}
	
@addMethod(CInventoryComponent)
	public function GetInventoryItemBasePriceModified( invItem : SInventoryItem, originalInventory : CInventoryComponent, optional playerSelling : bool, optional merchantEntity : CEntity ) : int
	{
		var i : int;
		var price : int;
		var baseAbilities : array<name>;
		var remainingAbilities, removedCrafted, removedBase : array<name>;
		var unleveledItem : SInventoryItem;
		var durabilityMult, categoryMult, qualityMult, areaMult, sellingMult, merchantMult : float;
		
		durabilityMult = LFEGetDurabilityMult(originalInventory.GetItemDurabilityRatio(invItem.uniqueId));
		categoryMult = LFEGetCategoryMult(originalInventory.GetItemCategory(invItem.uniqueId));
		if( originalInventory.IsItemJewelry(invItem.uniqueId) )
			categoryMult = 1;
		qualityMult = LFEGetQualityMult(originalInventory.GetItemQuality(invItem.uniqueId));
		areaMult = originalInventory.GetAreaPriceMult(invItem.uniqueId, originalInventory.GetItemQuality(invItem.uniqueId));
		sellingMult = LFEGetSellingMult(playerSelling);
		if( playerSelling && GetWitcherPlayer().CanUseSkill(S_Perk_20) )
			sellingMult *= 1.25f;
		//Kolaris - Huntsman
		if( playerSelling && GetWitcherPlayer().CanUseSkill(S_Perk_19) && originalInventory.IsItemTrophy(invItem.uniqueId))
			sellingMult *= 1.5f;
		//Kolaris - Difficulty Settings
		if( playerSelling )
			sellingMult /= Options().GetDifficultySettingMod();
		else
			sellingMult *= Options().GetDifficultySettingMod();
		if( playerSelling && merchantEntity )
			merchantMult = originalInventory.GetMerchantMult(invItem.uniqueId, merchantEntity);
		else
			merchantMult = 1;
			
		if( !originalInventory.IsItemAnyArmor(invItem.uniqueId) && (!originalInventory.IsItemWeapon(invItem.uniqueId) || originalInventory.IsItemCrossbow(invItem.uniqueId) || originalInventory.IsItemBolt(invItem.uniqueId)) )
			price = originalInventory.GetInventoryItemPriceModified(invItem, playerSelling);
		else
		{
			originalInventory.GetItemAbilities(invItem.uniqueId, baseAbilities);
			for(i=0; i<baseAbilities.Size(); i+=1)
			{
				if( StrContains(baseAbilities[i], "Glyph") || StrContains(baseAbilities[i], "Rune") )
					continue;
					
				if( invItem.craftedAbilities.Contains(baseAbilities[i]) )
				{
					originalInventory.RemoveItemCraftedAbility(invItem.uniqueId, baseAbilities[i]);
					removedCrafted.PushBack(baseAbilities[i]);
				}
				else
				{
					originalInventory.RemoveItemBaseAbility(invItem.uniqueId, baseAbilities[i]);
					removedBase.PushBack(baseAbilities[i]);
				}
			}
			
			unleveledItem = originalInventory.GetItem(invItem.uniqueId);
			price = originalInventory.GetInventoryItemPriceModified(unleveledItem, playerSelling);
			originalInventory.GetItemAbilities(invItem.uniqueId, remainingAbilities);
			for(i=0; i<removedBase.Size(); i+=1)
			{
				if( remainingAbilities.Contains(removedBase[i]) )
				{
					remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedBase[i]));
					continue;
				}
				
				originalInventory.AddItemBaseAbility(invItem.uniqueId, removedBase[i]);
			}
			
			for(i=0; i<removedCrafted.Size(); i+=1)
			{
				if( remainingAbilities.Contains(removedCrafted[i]) )
				{
					remainingAbilities.EraseFast(remainingAbilities.FindFirst(removedCrafted[i]));
					continue;
				}
				
				originalInventory.AddItemCraftedAbility(invItem.uniqueId, removedCrafted[i], true);
			}
		}
		
		if( playerSelling )
			return Abs(FloorF(price * areaMult * durabilityMult * categoryMult * qualityMult * sellingMult * merchantMult));
		else
			return Abs(CeilF(price * areaMult * durabilityMult * categoryMult * qualityMult * sellingMult * merchantMult));
	}
	
@addMethod(CInventoryComponent)
	public function GetAreaPriceMultByName( item : name ) : float
	{
		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var area : name = theGame.GetCommonMapManager().GetCurrentArea();
		var itemRarity : int;
		var worldPos : Vector;
		
		itemRarity = dm.GetItemQuality(item);
		switch(area)
		{
			case 'AN_NMLandNovigrad':
				worldPos = GetWitcherPlayer().GetWorldPosition();
				
				if( worldPos.X > 1650.f || worldPos.Y > 1400.f )
				{
					return 1;
				}
				else
				{
					if( dm.IsItemFood(item) )
						return 2;
					else
					if( dm.IsItemJewelry(item) )
						return 0.5;
					else
					if( dm.IsItemReadable(item) )
						return 0.5;
					else
					if( dm.IsItemTrophy(item) )
						return 0.5;
					else
					if( dm.IsItemHerb(item) )
						return 0.5;
					else
					if( dm.IsItemJunk(item) )
						return 0.5f;
					else
						return 1;
				}
			break;
			
			case 'AN_Skellige_ArdSkellig':
				if( dm.IsItemFood(item) )
					return 1.5;
				else
				if( dm.IsItemAlchemicalAlcohol(item) )
					return 1.5;
				else
				if( dm.IsItemTrophy(item) )
					return 1.5;
				else
				if( dm.IsItemJewelry(item) )
					return 0.5;
				else
				if( dm.IsItemHorseItem(item) )
					return 0.5;
				else
				if( dm.IsItemWeapon(item) )
				{
					switch( itemRarity )
					{
						case 1: return 0.7;
						case 2: return 0.85;
						case 3: return 1;
						case 4: return 1.2;
						case 5: return 1.2;
					}
				}
				else
					return 1;
			break;
			
			case 'AN_Prologue_Village':
				if( dm.IsItemHerb(item) )
					return 0.5;
				else
				if( dm.IsItemTrophy(item) )
					return 0.5;
				else
				if( dm.IsItemWeapon(item) )
					return 0.75;
				else
				if( dm.IsItemJewelry(item) )
					return 0.5f;
				else
				if( dm.IsItemUpgrade(item) )
					return 0.5f;
				else
				if( dm.IsItemFood(item) )
					return 1.5f;
				else
				if( dm.IsItemJunk(item) )
					return 0.5f;
				else
					return 1;
			break;
			
			case 'AN_Prologue_Village_Winter':
				if( dm.IsItemHerb(item) )
					return 0.5;
				else
				if( dm.IsItemTrophy(item) )
					return 0.5;
				else
				if( dm.IsItemWeapon(item) )
					return 0.75;
				else
				if( dm.IsItemJewelry(item) )
					return 0.5f;
				else
				if( dm.IsItemUpgrade(item) )
					return 0.5f;
				else
				if( dm.IsItemFood(item) )
					return 1.5f;
				else
				if( dm.IsItemJunk(item) )
					return 0.5f;
				else
					return 1;
			break;
			
			case 'AN_Dlc_Bob':
				if( dm.IsItemTrophy(item) )
					return 1.5;
				else
				if( dm.IsItemJewelry(item) )
					return 1.5;
				else
				if( dm.IsItemAlchemicalAlcohol(item) )
					return 0.5;
				else
				if( dm.IsItemFood(item) )
					return 0.5;
				else
				if( dm.IsItemHorseItem(item) )
					return 1.5;
				else
					return 1;
			break;
			
			default : return 1;
		}
	}
	
@addMethod(CInventoryComponent)
	private function GetAreaPriceMult( item : SItemUniqueId, itemRarity : int ) : float
	{
		var area : name = theGame.GetCommonMapManager().GetCurrentArea();
		var worldPos : Vector;
		
		switch(area)
		{
			case 'AN_NMLandNovigrad':
				worldPos = GetWitcherPlayer().GetWorldPosition();
				
				if( worldPos.X > 1650.f || worldPos.Y > 1400.f )
				{
					return 1;
				}
				else
				{
					if( IsItemFood(item) )
						return 2;
					else
					if( IsItemJewelry(item) )
						return 0.5;
					else
					if( IsItemReadable(item) )
						return 0.5;
					else
					if( IsItemTrophy(item) )
						return 0.5;
					else
					if( IsItemHerb(item) )
						return 0.5;
					else
					if( IsItemJunk(item) )
						return 0.5f;
					else
						return 1;
				}
			break;
			
			case 'AN_Skellige_ArdSkellig':
				if( IsItemFood(item) )
					return 1.5;
				else
				if( IsItemAlchemicalAlcohol(item) )
					return 1.5;
				else
				if( IsItemTrophy(item) )
					return 1.5;
				else
				if( IsItemJewelry(item) )
					return 0.5;
				else
				if( IsItemHorseItem(item) )
					return 0.5;
				else
				if( IsItemWeapon(item) )
				{
					switch( itemRarity )
					{
						case 1: return 0.7;
						case 2: return 0.85;
						case 3: return 1;
						case 4: return 1.2;
						case 5: return 1.2;
					}
				}
				else
					return 1;
			break;
			
			case 'AN_Prologue_Village':
				if( IsItemHerb(item) )
					return 0.5;
				else
				if( IsItemTrophy(item) )
					return 0.5;
				else
				if( IsItemWeapon(item) )
					return 0.75;
				else
				if( IsItemJewelry(item) )
					return 0.5f;
				else
				if( IsItemUpgrade(item) )
					return 0.5f;
				else
				if( IsItemFood(item) )
					return 1.5f;
				else
				if( IsItemDye(item) )
					return 0.5f;
				else
				if( IsItemJunk(item) )
					return 0.5f;
				else
					return 1;
			break;
			
			case 'AN_Prologue_Village_Winter':
				if( IsItemHerb(item) )
					return 0.5;
				else
				if( IsItemTrophy(item) )
					return 0.5;
				else
				if( IsItemWeapon(item) )
					return 0.75;
				else
				if( IsItemJewelry(item) )
					return 0.5f;
				else
				if( IsItemUpgrade(item) )
					return 0.5f;
				else
				if( IsItemFood(item) )
					return 1.5f;
				else
				if( IsItemDye(item) )
					return 0.5f;
				else
				if( IsItemJunk(item) )
					return 0.5f;
				else
					return 1;
			break;
			
			case 'AN_Dlc_Bob':
				if( IsItemTrophy(item) )
					return 1.5;
				else
				if( IsItemJewelry(item) )
					return 1.5;
				else
				if( IsItemAlchemicalAlcohol(item) )
					return 0.5;
				else
				if( IsItemFood(item) )
					return 0.5;
				else
				if( IsItemHorseItem(item) )
					return 1.5;
				else
					return 1;
			break;
			
			default : return 1;
		}
	}
	
@addMethod(CInventoryComponent)
	public function GetMerchantMult( item : SItemUniqueId, merchantEntity : CEntity ) : float
	{
		var merchantComponent : W3MerchantComponent;
		var merchantType : name;
		var merchant : CNewNPC;
		
		merchant = (CNewNPC)merchantEntity;
		merchantComponent = (W3MerchantComponent)merchant.GetComponentByClassName('W3MerchantComponent');
		merchantType = merchantComponent.GetMapPinType();
		if( GetItemName(item) == 'Honeycomb' && theGame.GetCommonMapManager().GetCurrentArea() == 'AN_Prologue_Village' && merchantType == 'Herbalist' )
			return 5.f;
		switch( merchantType )
		{
			case 'Shopkeeper':
				if( IsItemWeapon(item) )
					return 0.5f;
				else
				if( IsItemWeaponReapairKit(item) )
					return 0.5f;
				else
				if( IsItemChestArmor(item) )
					return 0.5f;
				else
				if( IsItemPants(item) )
					return 0.5f;
				else
				if( IsItemBoots(item) )
					return 0.5f;
				else
				if( IsItemGloves(item) )
					return 0.5f;
				else
				if( IsItemArmorReapairKit(item) )
					return 0.5f;
				else
				if( IsItemJewelry(item) )
					return 1.f;
				else
				if( IsItemCraftingIngredient(item) )
					return 0.5f;
				else
				if( IsItemHerb(item) )
					return 0.25f;
				else
				if( IsItemMonsterPart(item) )
					return 0.f;
				else
				if( IsItemAlchemicalAlcohol(item) )
					return 0.5f;
				else
				if( IsItemAlchemyIngredient(item) )
					return 0.25f;
				else
				if( IsItemFood(item) )
					return 0.5f;
				else
				if( IsItemAlchemyItem(item) )
					return 0.f;
				else
				if( IsItemDye(item) )
					return 1.f;
				else
				if( IsItemJunk(item) )
					return 1.f;
				else
				if( IsItemReadable(item) )
					return 1.f;
				else
				if( IsItemHorseItem(item) )
					return 1.f;
				else
				if( IsItemUpgrade(item) )
					return 0.5f;
				else
				if( IsItemTrophy(item) )
					return 1.f;
				else
					return 1.f;
			break;
			case 'Blacksmith':
				if( IsItemWeapon(item) )
					return 1.f;
				else
				if( IsItemWeaponReapairKit(item) )
					return 1.f;
				else
				if( IsItemChestArmor(item) )
					return 0.75f;
				else
				if( IsItemPants(item) )
					return 0.75f;
				else
				if( IsItemBoots(item) )
					return 0.75f;
				else
				if( IsItemGloves(item) )
					return 0.75f;
				else
				if( IsItemArmorReapairKit(item) )
					return 0.75f;
				else
				if( IsItemJewelry(item) )
					return 0.25f;
				else
				if( IsItemCraftingIngredient(item) )
					return 1.f;
				else
				if( IsItemHerb(item) )
					return 0.f;
				else
				if( IsItemMonsterPart(item) )
					return 0.f;
				else
				if( IsItemAlchemicalAlcohol(item) )
					return 0.f;
				else
				if( IsItemAlchemyIngredient(item) )
					return 0.f;
				else
				if( IsItemFood(item) )
					return 0.f;
				else
				if( IsItemAlchemyItem(item) )
					return 0.f;
				else
				if( IsItemDye(item) )
					return 0.25f;
				else
				if( IsItemJunk(item) )
					return 0.25f;
				else
				if( IsItemReadable(item) )
					return 0.f;
				else
				if( IsItemHorseItem(item) )
					return 0.5f;
				else
				if( IsItemUpgrade(item) )
					return 1.f;
				else
				if( IsItemTrophy(item) )
					return 0.f;
				else
					return 1.f;
			break;
			case 'Armorer':
				if( IsItemWeapon(item) )
					return 0.75f;
				else
				if( IsItemWeaponReapairKit(item) )
					return 0.75f;
				else
				if( IsItemChestArmor(item) )
					return 1.f;
				else
				if( IsItemPants(item) )
					return 1.f;
				else
				if( IsItemBoots(item) )
					return 1.f;
				else
				if( IsItemGloves(item) )
					return 1.f;
				else
				if( IsItemArmorReapairKit(item) )
					return 1.f;
				else
				if( IsItemJewelry(item) )
					return 0.25f;
				else
				if( IsItemCraftingIngredient(item) )
					return 1.f;
				else
				if( IsItemHerb(item) )
					return 0.f;
				else
				if( IsItemMonsterPart(item) )
					return 0.f;
				else
				if( IsItemAlchemicalAlcohol(item) )
					return 0.f;
				else
				if( IsItemAlchemyIngredient(item) )
					return 0.f;
				else
				if( IsItemFood(item) )
					return 0.f;
				else
				if( IsItemAlchemyItem(item) )
					return 0.f;
				else
				if( IsItemDye(item) )
					return 0.5f;
				else
				if( IsItemJunk(item) )
					return 0.25f;
				else
				if( IsItemReadable(item) )
					return 0.f;
				else
				if( IsItemHorseItem(item) )
					return 0.5f;
				else
				if( IsItemUpgrade(item) )
					return 1.f;
				else
				if( IsItemTrophy(item) )
					return 0.f;
				else
					return 1.f;
			break;
			case 'Herbalist':
				if( IsItemWeapon(item) )
					return 0.f;
				else
				if( IsItemWeaponReapairKit(item) )
					return 0.f;
				else
				if( IsItemChestArmor(item) )
					return 0.f;
				else
				if( IsItemPants(item) )
					return 0.f;
				else
				if( IsItemBoots(item) )
					return 0.f;
				else
				if( IsItemGloves(item) )
					return 0.f;
				else
				if( IsItemArmorReapairKit(item) )
					return 0.f;
				else
				if( IsItemJewelry(item) )
					return 0.f;
				else
				if( IsItemCraftingIngredient(item) )
					return 0.f;
				else
				if( IsItemHerb(item) )
					return 1.f;
				else
				if( IsItemMonsterPart(item) )
					return 0.5f;
				else
				if( IsItemAlchemicalAlcohol(item) )
					return 1.f;
				else
				if( IsItemAlchemyIngredient(item) )
					return 1.f;
				else
				if( IsItemFood(item) )
					return 0.5f;
				else
				if( IsItemAlchemyItem(item) )
					return 0.5f;
				else
				if( IsItemDye(item) )
					return 0.5f;
				else
				if( IsItemJunk(item) )
					return 0.f;
				else
				if( IsItemReadable(item) )
					return 0.f;
				else
				if( IsItemHorseItem(item) )
					return 0.f;
				else
				if( IsItemUpgrade(item) )
					return 0.f;
				else
				if( IsItemTrophy(item) )
					return 0.f;
				else
					return 1.f;
			break;
			case 'Alchemic':
				if( IsItemWeapon(item) )
					return 0.f;
				else
				if( IsItemWeaponReapairKit(item) )
					return 0.f;
				else
				if( IsItemChestArmor(item) )
					return 0.f;
				else
				if( IsItemPants(item) )
					return 0.f;
				else
				if( IsItemBoots(item) )
					return 0.f;
				else
				if( IsItemGloves(item) )
					return 0.f;
				else
				if( IsItemArmorReapairKit(item) )
					return 0.f;
				else
				if( IsItemJewelry(item) )
					return 0.f;
				else
				if( IsItemCraftingIngredient(item) )
					return 0.f;
				else
				if( IsItemHerb(item) )
					return 0.5f;
				else
				if( IsItemMonsterPart(item) )
					return 1.f;
				else
				if( IsItemAlchemicalAlcohol(item) )
					return 1.f;
				else
				if( IsItemAlchemyIngredient(item) )
					return 1.f;
				else
				if( IsItemFood(item) )
					return 0.f;
				else
				if( IsItemAlchemyItem(item) )
					return 1.f;
				else
				if( IsItemDye(item) )
					return 0.5f;
				else
				if( IsItemJunk(item) )
					return 0.f;
				else
				if( IsItemReadable(item) )
					return 0.5f;
				else
				if( IsItemHorseItem(item) )
					return 0.f;
				else
				if( IsItemUpgrade(item) )
					return 0.75f;
				else
				if( IsItemTrophy(item) )
					return 0.5f;
				else
					return 1.f;
			break;
			case 'Innkeeper':
				if( IsItemWeapon(item) )
					return 0.f;
				else
				if( IsItemWeaponReapairKit(item) )
					return 0.f;
				else
				if( IsItemChestArmor(item) )
					return 0.f;
				else
				if( IsItemPants(item) )
					return 0.f;
				else
				if( IsItemBoots(item) )
					return 0.f;
				else
				if( IsItemGloves(item) )
					return 0.f;
				else
				if( IsItemArmorReapairKit(item) )
					return 0.f;
				else
				if( IsItemJewelry(item) )
					return 0.f;
				else
				if( IsItemCraftingIngredient(item) )
					return 0.f;
				else
				if( IsItemHerb(item) )
					return 0.f;
				else
				if( IsItemMonsterPart(item) )
					return 0.f;
				else
				if( IsItemAlchemicalAlcohol(item) )
					return 1.f;
				else
				if( IsItemAlchemyIngredient(item) )
					return 0.f;
				else
				if( IsItemFood(item) )
					return 1.f;
				else
				if( IsItemAlchemyItem(item) )
					return 0.f;
				else
				if( IsItemDye(item) )
					return 0.f;
				else
				if( IsItemJunk(item) )
					return 0.f;
				else
				if( IsItemReadable(item) )
					return 0.f;
				else
				if( IsItemHorseItem(item) )
					return 0.f;
				else
				if( IsItemUpgrade(item) )
					return 0.f;
				else
				if( IsItemTrophy(item) )
					return 1.0f;
				else
					return 1.f;
			break;
			case 'Enchanter':
				if( IsItemWeapon(item) )
					return 0.5f;
				else
				if( IsItemWeaponReapairKit(item) )
					return 0.5f;
				else
				if( IsItemChestArmor(item) )
					return 0.5f;
				else
				if( IsItemPants(item) )
					return 0.5f;
				else
				if( IsItemBoots(item) )
					return 0.5f;
				else
				if( IsItemGloves(item) )
					return 0.5f;
				else
				if( IsItemArmorReapairKit(item) )
					return 0.5f;
				else
				if( IsItemJewelry(item) )
					return 1.f;
				else
				if( IsItemCraftingIngredient(item) )
					return 1.f;
				else
				if( IsItemHerb(item) )
					return 0.f;
				else
				if( IsItemMonsterPart(item) )
					return 1.f;
				else
				if( IsItemAlchemicalAlcohol(item) )
					return 0.f;
				else
				if( IsItemAlchemyIngredient(item) )
					return 0.f;
				else
				if( IsItemFood(item) )
					return 0.f;
				else
				if( IsItemAlchemyItem(item) )
					return 0.f;
				else
				if( IsItemDye(item) )
					return 0.5f;
				else
				if( IsItemJunk(item) )
					return 0.f;
				else
				if( IsItemReadable(item) )
					return 0.f;
				else
				if( IsItemHorseItem(item) )
					return 0.f;
				else
				if( IsItemUpgrade(item) )
					return 1.f;
				else
				if( IsItemTrophy(item) )
					return 0.f;
				else
					return 1.f;
			break;
			default : return 1.f;
		}
	}

@addMethod(CInventoryComponent)
public function AddAndEquipItem( item : name, slot : EEquipmentSlots, optional quantity : int ) : SItemUniqueId
{
	var items : array <SItemUniqueId>;
	
	if( quantity < 1 )
		quantity = 1;
	items = AddAnItem(item, quantity);
	if( this == thePlayer.GetInventory() )
		thePlayer.EquipItem(items[0], slot);
		
	return items[0];
}

@addMethod(CInventoryComponent)
public function GetCurrentlyHeldWeapon() : SItemUniqueId
{
	var w : array<SItemUniqueId> = GetHeldWeapons();
	
	return w[0];
}

@addMethod(CInventoryComponent)
public function HorseDropItemInBag( item : SItemUniqueId, quantity : int ) 
{
	var entities : array<CGameplayEntity>;
	var i : int;
	var owner : CActor;
	var bag : W3ActorRemains;
	var template : CEntityTemplate;
	var bagtags : array <name>;
	var bagPosition : Vector;
	var tracedPosition, tracedNormal : Vector;
		
	//Kolaris - Inventory Options
	if(ItemHasTag(item, 'NoDrop') && !(Options().DropQuestItems())) 
		return;		
		
	if(Options().DeleteDroppedItems())
	{
		RemoveItem(item, quantity);
		return;
	}
		
	owner = thePlayer;
	FindGameplayEntitiesInRange(entities, owner, 0.5, 100);
	for(i=0; i<entities.Size(); i+=1)
	{
		bag = (W3ActorRemains)entities[i];
		
		if(bag)
			break;
	}
	
	if(!bag)
	{
		template = (CEntityTemplate)LoadResource("lootbag");
		bagtags.PushBack('lootbag');
		
		
		bagPosition = owner.GetWorldPosition();
		if ( theGame.GetWorld().StaticTrace( bagPosition, bagPosition + Vector( 0.0f, 0.0f, -10.0f, 0.0f ), tracedPosition, tracedNormal ) )
		{
			bagPosition = tracedPosition;
		}
		bag = (W3ActorRemains)theGame.CreateEntity(template, bagPosition, owner.GetWorldRotation(), true, false, false, PM_Persist,bagtags);
	}
	
	GiveItemTo(bag.GetInventory(), item, quantity, false);
	if( bag.GetInventory().IsEmpty() )
	{
		delete bag;
		return;
	}		
	
	bag.LootDropped();		
	theTelemetry.LogWithLabelAndValue(TE_INV_ITEM_DROPPED, GetItemName(item), quantity);
	if( thePlayer.IsSwimming() )
	{
		bag.PlayPropertyAnimation( 'float', 0 );
	}
}

@addMethod(CInventoryComponent)
public function ShouldHorseLootItem( item : SItemUniqueId ) : bool
{
	return Options().HorseDestination() != 0 && (IsItemJunk(item) || IsItemAlchemyIngredient(item) || IsItemCraftingIngredient(item) || IsItemWeapon(item) || IsItemUpgrade(item) || IsItemMoney(item) || IsItemChestArmor(item) || IsItemBoots(item) || IsItemPants(item) || IsItemGloves(item)) && !ItemHasTag(item, 'Artifact_weapon') && !ItemHasTag(item, 'ThrowingKnife') && !ItemHasTag(item, 'FancyClothes') && !IsItemUniqueMutagen(item) && !IsItemQuest(item);
}

@addMethod(CInventoryComponent)
public final function IsItemGrandmasterItem( item : SItemUniqueId ) : bool
{
	return ItemHasTag(item, theGame.params.ITEM_SET_TAG_BONUS);
}

@addMethod(CInventoryComponent)
public function GetArmorTypeOriginal( item : SItemUniqueId ) : EArmorType
{
	var isItemEquipped : bool;
	
	if(ItemHasTag(item, 'LightArmor'))
		return EAT_Light;
	else if(ItemHasTag(item, 'MediumArmor'))
		return EAT_Medium;
	else if(ItemHasTag(item, 'HeavyArmor'))
		return EAT_Heavy;
		
	return EAT_Undefined;
}

@addMethod(CInventoryComponent)
private function GetCurrentWeight() : float
{
	var i: int;
	var currWeight : float;
	var items : array<SItemUniqueId>;
	
	GetAllItems(items);
	for(i=0; i<items.Size(); i+=1)
		if( !(IsItemHorseItem(items[i]) && GetWitcherPlayer().GetHorseManager().IsItemEquipped(items[i])) && IsItemEncumbranceItem(items[i]) ) //Kolaris - Trophy Weight Fix
			currWeight += GetItemEncumbrance( items[i] );
			
	return currWeight;
}
	
@addMethod(CInventoryComponent)
public function HorseCanTakeItem( item : SItemUniqueId, quantity : int, otherInventory : CInventoryComponent ) : bool
{
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	var curWeight, maxWeight : int;
	
	if( this != witcher.GetHorseManager().GetInventoryComponent() )
		return false;
		
	maxWeight = (int)CalculateAttributeValue(witcher.GetHorseManager().GetHorseAttributeValue('encumbrance', false)) + Options().BaseCWRoach();
	curWeight = (int)GetCurrentWeight();
	//Kolaris - Fixed Stashes
	if( otherInventory.GetItemEncumbrance(item, quantity) + curWeight <= maxWeight || GameplayFactsQuerySum("inFixedStash") > 0 )
		return true;
		
	return false;
}

@addMethod(CInventoryComponent)
	//Plasticmetal - LootTweak ++
	function AlchemyColor( item: SItemUniqueId ) :string
	{
		var msg : string;
		
		msg = this.GetItemLocNameByID(item);
		
		if(this.ItemHasTag(item, 'primer_vitriol'))
			msg = "<font color=\"#1595b0\">" +msg + "</font>";
		else if (this.ItemHasTag(item, 'primer_rebis'))
			msg = "<font color=\"#4db323\">" +msg + "</font>";
		else if (this.ItemHasTag(item, 'primer_aether'))
			msg = "<font color=\"#7764a9\">" +msg + "</font>";
		else if (this.ItemHasTag(item, 'primer_quebrith'))
			msg = "<font color=\"#be8728\">" +msg + "</font>";
		else if (this.ItemHasTag(item, 'primer_hydragenum'))
			msg = "<font color=\"#b0b0b0\">" +msg + "</font>";
		else if (this.ItemHasTag(item, 'primer_vermilion'))
			msg = "<font color=\"#d25212\">" +msg + "</font>";
		
		return msg;
		
	}
	
@addMethod(CInventoryComponent)
	function AlchemySecondary(item : SItemUniqueId ) :string
	{
		var msg: string;

		if(this.ItemHasTag(item, 'primer_albedo'))
			msg =" " + "<font color=\"#e0e0e0\">" + "[" + GetLocStringById(2116942407) + "]" + "</font>";
		else if (this.ItemHasTag(item, 'primer_rubedo'))
			msg = " " +"<font color=\"#C52C34\">" + "[" + GetLocStringById(2116942409) + "]" + "</font>";
		else if (this.ItemHasTag(item, 'primer_nigredo'))
			msg = " " +"<font color=\"#4F4F4F\">" + "[" + GetLocStringById(2116942408) + "]" + "</font>";

		return msg;
	}
	//Plasticmetal - LootTweak --