/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Potion_BlackBlood extends CBaseGameplayEffect //W3EE
{
	default effectType = EET_BlackBlood;
	default attributeName = 'return_damage';
	
	//W3EE - Begin
	public function GetReturnDamageValue( incomingDamage : float ) : float
	{
		return incomingDamage * effectValue.valueMultiplicative;
	}
	/*
	protected function ApplySpawnsOn(victimGE : CGameplayEntity)
	{
		var tmpBool : bool;
		var tmpName : name;
		var actor : CActor;
		var monsterCategory : EMonsterCategory;
		
		actor = (CActor)victimGE;
		if(!actor)
			return;
				
		theGame.GetMonsterParamsForActor(actor, monsterCategory, tmpName, tmpBool, tmpBool, tmpBool );
		
		if(GetBuffLevel() == 3 && (monsterCategory == MC_Vampire || monsterCategory == MC_Necrophage))
		{
			super.ApplySpawnsOn(victimGE);
		}
	}
	*/
	//W3EE - End
}