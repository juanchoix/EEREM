/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state CharacterDevelopmentFastMenu in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	//private const var PANEL, CHAR_DEV_OPEN : name; //W3EE
	
		//default PANEL 				= 'TutorialCharDevPanel'; //W3EE
		//default CHAR_DEV_OPEN 		= 'TutorialCharDevOpen'; //W3EE
		
	event OnEnterState( prevStateName : name )
	{
		//W3EE - Begin
		QuitState();
		/*
		super.OnEnterState(prevStateName);
		
		theGame.GetTutorialSystem().HideTutorialHint( CHAR_DEV_OPEN );
		
		ShowHint(PANEL, 0.5, 0.7, ETHDT_Infinite, GetHighlightHubMenuCharDev() );
		*/
		//W3EE - End
	}

	event OnLeaveState( nextStateName : name )
	{		
		//CloseStateHint(PANEL); //W3EE
		
		super.OnLeaveState(nextStateName);
	}		
}