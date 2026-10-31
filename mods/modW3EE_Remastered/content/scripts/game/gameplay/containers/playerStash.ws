/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Stash extends CInteractiveEntity
{
	editable var forceDiscoverable : bool;	default forceDiscoverable = false;

	event OnInteraction( actionName : string, activator : CEntity )
	{
		if(activator != thePlayer)
			return false;
			
		theGame.GameplayFactsAdd("inFixedStash", 1); //W3EE
		thePlayer.GetInputHandler().PushStashScreen(); //W3EE
	}
	
	public function  IsForcedToBeDiscoverable() : bool
	{
		return false; //W3EE
	}
}