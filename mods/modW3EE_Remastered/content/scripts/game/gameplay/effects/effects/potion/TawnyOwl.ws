/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Potion_TawnyOwl extends CBaseGameplayEffect //W3EE
{
	default effectType = EET_TawnyOwl;
	
	public function OnTimeUpdated(deltaTime : float)
	{
		var currentHour, level : int;
		var toxicityThreshold : float;
		
		if( isActive ) //W3EE
		{
			timeActive += deltaTime;	
			if( duration != -1 )
			{
				
				//level = GetBuffLevel(); //W3EE
				currentHour = GetDayPart(GameTimeCreate()); //currentHour = GameTimeHours(theGame.GetGameTime()); //W3EE
				//if(level < 3 || (currentHour > GetHourForDayPart(EDP_Dawn) && currentHour < GetHourForDayPart(EDP_Dusk)) ) //W3EE
				if(currentHour != EDP_Midnight) //W3EE
					timeLeft -= deltaTime;
					
				if( timeLeft <= 0 )
				{
					//W3EE - Begin
					/*
					if ( thePlayer.CanUseSkill(S_Alchemy_s03) )
					{
						toxicityThreshold = thePlayer.GetStatMax(BCS_Toxicity);
						toxicityThreshold *= GetWitcherPlayer().GetAlchemyS03Threshold();
					}
					*/
					//W3EE - End
					isActive = false;
					
				}
			}
			OnUpdate(deltaTime);	
		}
	}
}