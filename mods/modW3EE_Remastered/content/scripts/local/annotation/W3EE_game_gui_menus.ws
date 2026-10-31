///////////////////////////////////////////////
//-- scripts\game\gui\menus\commonMenu.ws --//
/////////////////////////////////////////////

@addField(CR4CommonMenu)
protected var stashHotkey : EInputKey;


@wrapMethod(CR4CommonMenu)
function OnConfigUI()
{
	Equipment().SetHorseDistance();

	wrappedMethod();
}

//////////////////////////////////////////////////
//-- scripts\game\gui\menus\inventoryMenu.ws --//
////////////////////////////////////////////////

@addField(CR4InventoryMenu)
private var _invStashContext : W3StashGridContext;

@addField(CR4InventoryMenu)
private var m_fxSetWeight			 : CScriptedFlashFunction;

@addField(CR4InventoryMenu)
private var m_fxSetStashText	     : CScriptedFlashFunction;
	
@addMethod(CR4InventoryMenu)
public function IsStashMode() : bool
{
	return _defaultInventoryState == IMS_Stash;
}


@addMethod(CR4InventoryMenu)
function StashUpdateEncumbrance()
{
	var currWeight 			: int;
	var maxWeight			: int;
		
	maxWeight = (int)CalculateAttributeValue( GetWitcherPlayer().GetHorseManager().GetHorseAttributeValue('encumbrance', false) ) + Options().BaseCWRoach();
	currWeight = (int)GetCurrentWeight( _horseInv.GetInventoryComponent() );
	if( GameplayFactsQuerySum("inFixedStash") > 0 )
		m_fxSetWeight.InvokeSelfOneArg(FlashArgString(GetLocStringByKeyExt("panel_stash_unlimited")));
	else
		m_fxSetWeight.InvokeSelfOneArg(FlashArgString(currWeight + " / " + maxWeight));
}


@addMethod(CR4InventoryMenu) //Kolaris - Fixed Stashes
function StashUpdateItem( item : SItemUniqueId )
{
	var tempFlashObject		: CScriptedFlashObject;
	var itemDataObject		: CScriptedFlashObject;

	if( !_inv.ItemHasTag(item, 'NoShow') || GameplayFactsQuerySum("inFixedStash") > 0 )
	{
		tempFlashObject = m_flashValueStorage.CreateTempFlashObject();
		itemDataObject = tempFlashObject.CreateFlashObject("red.game.witcher3.menus.common.ItemDataStub");
		_horseInv.SetInventoryFlashObjectForItem(item, itemDataObject);
		itemDataObject.SetMemberFlashInt("tabIndex", GetTabIndexForSlot(getTabFromFilter(_horseInv.GetInventoryComponent().GetFilterTypeByItem(item))));
		m_flashValueStorage.SetFlashObject( "inventory.grid.container.itemUpdate", itemDataObject );
	}
}


@addMethod(CR4InventoryMenu)
public function HorseDropItem( inv : CInventoryComponent, item : SItemUniqueId, quantity : int ) 
{
	if( inv.IsItemSingletonItem(item) )
		quantity = inv.SingletonItemGetAmmo(item);
		
	if( thePlayer.IsInCombat() )
	{
		showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
		OnPlaySoundEvent("gui_global_denied");
		return;
	}
	
	if( !inv.ItemHasTag(item, 'NoDrop') && !inv.ItemHasTag(item, 'Quest') )
	{
		if( quantity <= 1 )
		{
			inv.HorseDropItemInBag(item, quantity);
			OnPlaySoundEvent("gui_inventory_drop");
			ShopRemoveItem(item);
		}
		else
		{
			OpenQuantityPopup(item, QTF_DropHorse, quantity);
		}
	}
	else
	{
		OnPlaySoundEvent("gui_global_denied");
	}
}


@addMethod(CR4InventoryMenu)
public function SwitchShowStashItems()
{
	if( _currentState == IMS_Stash )
	{
		_horseInv.syncWithPlayer = !_horseInv.syncWithPlayer;
		_horseInv.playerTabIndex = currentlySelectedTab;
		UpdateHorseInventory();
	}
	else if( _currentState == IMS_Shop )
	{
		if( _playerInv.IsOwner() )
		{
			_playerInv.SwitchToHorse(true);
			_tooltipDataProvider.SwitchToHorse();
			_disableStashContext = true;
			ResetContext();
			createInventoryStashContext();
		}
		else
		{
			_playerInv.SwitchToOwner(false);
			_tooltipDataProvider.SwitchToOwner();
			_disableStashContext = false;
			ResetContext();
			createInventoryContext();
		}
		PopulateTabData(InventoryMenuTab_Weapons);
		PopulateTabData(InventoryMenuTab_Potions);
		PopulateTabData(InventoryMenuTab_Ingredients);
		PopulateTabData(InventoryMenuTab_QuestItems);
		PopulateTabData(InventoryMenuTab_Default);
		PopulateTabData(InventoryMenuTab_Books);
		m_fxSetCurrentModule.InvokeSelfOneArg(FlashArgInt(0));
	}
}


@addMethod(CR4InventoryMenu)
protected function createInventoryStashContext():void
{
	if (_invStashContext)
	{
		delete _invStashContext;
	}
	
	_invStashContext = new W3StashGridContext in this;
	_invStashContext.SetInventoryRef((CR4InventoryMenu)this);
	m_currentContext = _invStashContext;
	ActivateContext(m_currentContext);
}


@addMethod(CR4InventoryMenu)
function GetCurrentWeight( inv : CInventoryComponent ) : float
{
	var i: int;
	var currWeight : float;
	var items : array<SItemUniqueId>;
		
	inv.GetAllItems(items);
	for(i=0; i<items.Size(); i+=1)
		if( !(_horseInv.isHorseItem(items[i]) && GetWitcherPlayer().GetHorseManager().IsItemEquipped(items[i])) && inv.IsItemEncumbranceItem(items[i]) ) //Kolaris - Trophy Weight Fix
			currWeight += inv.GetItemEncumbrance( items[i] );
			
	return currWeight;
}
	

@addMethod(CR4InventoryMenu)
public function GetItemEncumbranceWithQuantity( invComponent : CInventoryComponent, item : SItemUniqueId, quantity : int ) : float
{
	return invComponent.GetItemEncumbrance(item, quantity);
}
	

@addMethod(CR4InventoryMenu)
public function TransferMiscItems()
{
	var mutagenSlots : array<SMutagenSlot>;
	var items : array<SItemUniqueId>;
	var mut, stop : bool;
	var i, j : int;
		
	//Kolaris - Transfer Misc Items Fix
	if( !Options().InvEverywhere() && Equipment().GetHorseDistance() > 81 )
	{
		theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("W3EE_HorseTooFar"));
										   
		return;
	}
		
	_inv.GetAllItems(items);
	mutagenSlots = ((W3PlayerAbilityManager)thePlayer.abilityManager).GetPlayerSkillMutagens();
	for(i=0; i<items.Size(); i+=1)
	{
		if( stop )
			break;
				
		if( _inv.IsItemEncumbranceItem(items[i]) )
		{
			if( _inv.IsItemUsable(items[i]) || _inv.IsItemQuickslotItem(items[i]) || _inv.IsItemMounted(items[i]) || _inv.IsItemHeld(items[i]) || _inv.IsItemFood(items[i]) )
				continue;
					
			if( _inv.IsItemAlchemyIngredient(items[i]) )
			{
				mut = false;
				for(j=0; j<mutagenSlots.Size(); j+=1)
					if( items[i] == mutagenSlots[j].item )
						mut = true;
					
				if( !mut )
					if ( !handleMoveToStashQuantity(items[i], _inv.GetItemQuantity(items[i])) )
						stop = true;
			}
			else
			if( _inv.IsItemCraftingIngredient(items[i]) || _inv.GetItemName(items[i]) == 'Florens' || _inv.GetItemName(items[i]) == 'Orens' || _inv.GetItemName(items[i]) == 'Crowns' )
			{
				if( !handleMoveToStashQuantity(items[i], _inv.GetItemQuantity(items[i])) )
					stop = true;
			}
			else
			if( !_inv.IsItemAnyArmor(items[i]) && !_inv.IsItemWeapon(items[i]) && !_inv.IsItemSingletonItem(items[i]) && !_inv.IsItemAlchemyItem(items[i]) && !_inv.IsItemQuest(items[i]) )
			{
				if( !handleMoveToStashQuantity(items[i], _inv.GetItemQuantity(items[i])) )
					stop = true;
			}
		}
	}
	UpdateHorseInventory();
}


// Fix for inventory not being fully updated with auto-transfert misc key
@wrapMethod(CR4InventoryMenu) 
function OnTabChanged(tabIndex:int)
{		
	wrappedMethod(tabIndex);
	
	if( _currentState == IMS_Stash && _horseInv.syncWithPlayer )
	{
		_horseInv.playerTabIndex = currentlySelectedTab;
		UpdateHorseInventory();
	}
	updateCurrentTab();
}
	

@wrapMethod(CR4InventoryMenu) 
function UpdateHorseInventory()
{		
	var currWeight : int;
	var maxWeight : int;
	
	wrappedMethod();
	
	maxWeight = (int)CalculateAttributeValue( GetWitcherPlayer().GetHorseManager().GetHorseAttributeValue('encumbrance', false) ) + Options().BaseCWRoach();
	currWeight = (int)GetCurrentWeight( _horseInv.GetInventoryComponent() );
	
	//Kolaris - Fixed Stashes
	if( GameplayFactsQuerySum("inFixedStash") > 0 ) 
	{
		m_fxSetWeight.InvokeSelfOneArg(FlashArgString(GetLocStringByKeyExt("panel_stash_unlimited")));
		//showNotification(GetLocStringByKeyExt("panel_title_stash") + " : " + GetLocStringByKeyExt("panel_stash_unlimited"), -1);
	}
	
	else 
	{
		m_fxSetWeight.InvokeSelfOneArg(FlashArgString(currWeight + " / " + maxWeight));
		//showNotification(GetLocStringById(1082500) + " : " + currWeight + " / " + maxWeight, -1);
	}
}
	
	
@wrapMethod(CR4InventoryMenu)
function GetInventoryComponent(_targetInv : W3GuiBaseInventoryComponent):CInventoryComponent
{
	if( m_currentContext == _invStashContext )
	{
		return GetWitcherPlayer().GetHorseManager().GetInventoryComponent();
	}
	return wrappedMethod(_targetInv);
}


@wrapMethod(CR4InventoryMenu)
function OnClosingMenu()
{
	wrappedMethod();

	if (_invStashContext)
	{
		delete _invStashContext;
	}
	theGame.GetGuiManager().RequestClearScene();
}


@wrapMethod(CR4InventoryMenu)
function OnCloseMenu()
{
	wrappedMethod();
		
	GetWitcherPlayer().UpdateEncumbrance();
}


@wrapMethod(CR4InventoryMenu)
function OnRepairItem( item : SItemUniqueId )
{
	if( thePlayer.IsInCombat() )
	{
		showNotification( GetLocStringByKeyExt( "menu_cannot_perform_action_combat" ) );
		OnPlaySoundEvent( "gui_global_denied" );
		return true;
	}
	wrappedMethod(item);
}


@wrapMethod(CR4InventoryMenu)
function TakeItem( item : SItemUniqueId, quantity : int  )
{
	var filterType : EInventoryFilterType;
	var newItemId : SItemUniqueId;
	
	if( _currentState == IMS_Stash )
	{
		newItemId = GetWitcherPlayer().GetHorseManager().MoveItemFromHorse(item, quantity);
		if( _horseInv.GetInventoryComponent().GetItemQuantity(item) <= 0 )
		{
			ShopRemoveItem(item);
			_horseInv.clearGridPosition(item);
		}
		else StashUpdateItem(item);
			
		filterType = _playerInv.GetFilterTypeByItem(newItemId);
		_playerInv.SetFilterType( filterType );
		m_fxInventoryUpdateFilter.InvokeSelfOneArg( FlashArgUInt( getTabFromFilter(filterType) ));
		InventoryUpdateItem( newItemId );
		UpdateEncumbranceInfo();
		StashUpdateEncumbrance();
	}
	else
		wrappedMethod(item, quantity);
}


@wrapMethod(CR4InventoryMenu)
function ShowSelectionMode( sourceItem : SItemUniqueId, targetSlotList : array< int > )
{
	wrappedMethod(sourceItem, targetSlotList);
	
	GetWitcherPlayer().SetSelectionActive(m_selectionModeActive);
}


@wrapMethod(CR4InventoryMenu)
function ApplyUpgrade(itemId : SItemUniqueId,  targetSlot : int) : void
{
	if (thePlayer.IsInCombat())
	{
		showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
		OnPlaySoundEvent("gui_global_denied");
		return;
	} 
	//Kolaris - Campfire Upgrade
	else if( !CampfireManager().CanPerformUpgrade() && !Options().GetUpgradeAnywhere() )
	{
		showNotification( GetLocStringByKeyExt( "menu_cannot_perform_action_now" ) );
		OnPlaySoundEvent( "gui_global_denied" );
		return;
	}
	
	wrappedMethod(itemId, targetSlot);
}

