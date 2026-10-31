/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state Potions in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	//W3EE - Begin
	/*
	private const var CAN_EQUIP, SELECT_TAB, EQUIP_POTION, EQUIP_POTION_THUNDERBOLT, ON_EQUIPPED, CAN_EQUIP_FLOWY : name;
	private var isClosing, isForcedThunderbolt, skippingTabSelection : bool;
	
		default CAN_EQUIP 		= 'TutorialPotionCanEquip1';
		default SELECT_TAB 		= 'TutorialPotionCanEquip2';
		default EQUIP_POTION 	= 'TutorialPotionCanEquip3';
		default EQUIP_POTION_THUNDERBOLT = 'TutorialPotionCanEquip3Thunderbolt';
		default ON_EQUIPPED 	= 'TutorialPotionEquipped';
		default CAN_EQUIP_FLOWY = 'TutorialPotionCanEquip1';
	*/
	//W3EE - End
	event OnEnterState( prevStateName : name )
	{
		//super.OnEnterState(prevStateName); //W3EE

		//Execute(prevStateName); //W3EE
	}
	//W3EE - Begin
	/*
	entry function Execute(prevStateName : name ):void
	{
		var witcher : W3PlayerWitcher;
		var currentTab : int;
		var itemOne, itemTwo, itemThree, itemFour : SItemUniqueId;

		var menu 	: CR4MenuBase;
		var inventoryMenu : CR4InventoryMenu;
		
		isClosing = false;
		skippingTabSelection = false;
		isForcedThunderbolt = (FactsQuerySum("tut_forced_preparation") > 0);
		
		if(!isForcedThunderbolt) 
		{		
			
		}
		else	
		{
			theGame.GetTutorialSystem().uiHandler.LockLeaveMenu(false);
			
			
			thePlayer.BlockAction(EIAB_OpenAlchemy, 'tut_forced_preparation');
			theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP_POTION_THUNDERBOLT);
			
			
			
		}
	}
	*/
	//W3EE - End
	event OnLeaveState( nextStateName : name )
	{
		//W3EE - Begin
		/*
		isClosing = true;
		
		CloseStateHint(CAN_EQUIP);
		CloseStateHint(SELECT_TAB);
		CloseStateHint(EQUIP_POTION);
		CloseStateHint(EQUIP_POTION_THUNDERBOLT);
		CloseStateHint(ON_EQUIPPED);
		
		if(!skippingTabSelection)
			theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
			
		theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP_POTION);
		
		if(isForcedThunderbolt)
		{
			theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP_POTION_THUNDERBOLT);
			theGame.GetTutorialSystem().ForcedAlchemyCleanup();
		}
		*/
		//W3EE - End
		super.OnLeaveState(nextStateName);
	}
		
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		//W3EE - Begin
		/*
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == CAN_EQUIP)
		{
			
			{
				theGame.GetTutorialSystem().MarkMessageAsSeen(CAN_EQUIP);
				theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
				theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP_POTION);
				theGame.GetTutorialSystem().MarkMessageAsSeen(ON_EQUIPPED);

				QuitState();
			}
		}
		else if (hintName == CAN_EQUIP_FLOWY)
		{
			
		}
		else if(hintName == ON_EQUIPPED)
		{
			
			if(isForcedThunderbolt)
			{
				theGame.GetTutorialSystem().ForcedAlchemyCleanup();
			}
			
			QuitState();
		}
		*/
		//W3EE - End
	}
	//W3EE - Begin
	/*
	event OnPotionTabSelected()
	{
		CloseStateHint(SELECT_TAB);
		
		if(isForcedThunderbolt)
			ShowHint(EQUIP_POTION_THUNDERBOLT, POS_INVENTORY_X, POS_INVENTORY_Y);
		else
			ShowHint(CAN_EQUIP_FLOWY, POS_INVENTORY_X, POS_INVENTORY_Y);
	}
	
	event OnPotionEquipped(potionItemName : name)
	{
		
		if(isForcedThunderbolt && potionItemName != 'Thunderbolt 1')
			return false;
	
		CloseStateHint(EQUIP_POTION);
		CloseStateHint(EQUIP_POTION_THUNDERBOLT);
		CloseStateHint(CAN_EQUIP_FLOWY);
		theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP_POTION);
		theGame.GetTutorialSystem().ForcedAlchemyCleanup();
		
	}
	*/
	//W3EE - End
}

exec function tut_pot()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('PotionsPreparation', '');
}