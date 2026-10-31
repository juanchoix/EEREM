/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state Oils in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var CAN_EQUIP, SELECT_TAB, EQUIP_OIL, ON_EQUIPPED, OILS_JOURNAL_ENTRY : name;
	private var isClosing : bool;
	
		default CAN_EQUIP 			= 'TutorialOilCanEquip1';
		default SELECT_TAB 			= 'TutorialOilCanEquip2';
		default EQUIP_OIL 			= 'TutorialOilCanEquip3';
		default ON_EQUIPPED 		= 'TutorialOilEquipped';
		default OILS_JOURNAL_ENTRY 	= 'TutorialJournalOils';	
		
	event OnEnterState( prevStateName : name )
	{
		//W3EE - Begin
		QuitState();
		/*
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		ShowHint(CAN_EQUIP, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input);
		theGame.GetTutorialSystem().ActivateJournalEntry(OILS_JOURNAL_ENTRY);
		*/
		//W3EE - End
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		//W3EE - Begin
		/*
		CloseStateHint(CAN_EQUIP);
		CloseStateHint(SELECT_TAB);
		CloseStateHint(EQUIP_OIL);
		CloseStateHint(ON_EQUIPPED);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
		theGame.GetTutorialSystem().MarkMessageAsSeen(ON_EQUIPPED);
		
		FactsAdd("tut_ui_prep_oils");
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
			theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
			ShowHint(EQUIP_OIL, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input);
		}
		if(hintName == EQUIP_OIL)
		{
			QuitState();
		}
		*/
		//W3EE - End
	}
	
	event OnOilTabSelected()
	{
		//CloseStateHint(SELECT_TAB); //W3EE
		//theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB); //W3EE
		//ShowHint(EQUIP_OIL, POS_INVENTORY_X, POS_INVENTORY_Y, ETHDT_Input); //W3EE
	}
	
	event OnOilApplied()
	{
		//CloseStateHint(EQUIP_OIL); //W3EE
		//ShowHint( ON_EQUIPPED, POS_INVENTORY_X, POS_INVENTORY_Y, , , , , true ); //W3EE
	}
}

exec function tut_oil()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('OilsPreparation', '');
}