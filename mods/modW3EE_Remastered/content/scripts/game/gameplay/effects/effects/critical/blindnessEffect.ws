/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3BlindnessEffect extends W3CriticalEffect
{
	var envID 							: int; //W3EE
	var fxEntity 						: CEntity; //W3EE
	
	default criticalStateType 	= ECST_Blindness;
	default effectType 			= EET_Blindness;
	default resistStat 			= CDS_WillRes;
	default attachedHandling 	= ECH_Abort;
	default onHorseHandling 	= ECH_Abort;
	
	public function CacheSettings()
	{
		super.CacheSettings();
		//blockedActions.PushBack(EIAB_Fists); //W3EE
		//blockedActions.PushBack(EIAB_Jump); //W3EE
		//blockedActions.PushBack(EIAB_RunAndSprint); //W3EE
		//blockedActions.PushBack(EIAB_ThrowBomb); //W3EE
		//blockedActions.PushBack(EIAB_Crossbow); //W3EE
		//blockedActions.PushBack(EIAB_UsableItem); //W3EE
		//blockedActions.PushBack(EIAB_Parry); //W3EE
		//blockedActions.PushBack(EIAB_Sprint); //W3EE
		blockedActions.PushBack(EIAB_Explorations);
		//blockedActions.PushBack(EIAB_Counter); //W3EE
		//blockedActions.PushBack(EIAB_QuickSlots); //W3EE

		
		
		
		
		
		
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var template : CEntityTemplate; //W3EE
		var environment : CEnvironmentDefinition; //W3EE
		
		super.OnEffectAdded(customParams);
		
		if(isOnPlayer)
		{
			thePlayer.HardLockToTarget( false );
			
			//W3EE - Begin
			if(!theSound.SoundIsBankLoaded("feverflash.bnk"))
				theSound.SoundLoadBank("feverflash.bnk", false);
			theSound.SoundEvent("play_feverflash");
			
			DisableCatViewFx( 0.5f );
			
			template = (CEntityTemplate)LoadResource("bies_fx");
			fxEntity = theGame.CreateEntity(template,thePlayer.GetWorldPosition());
			if ( fxEntity )
			{
				fxEntity.CreateAttachment(thePlayer);
				fxEntity.DestroyAfter(duration);
			}
			
			environment = (CEnvironmentDefinition)LoadResource("env_bies_hypnotize");
    		envID = ActivateEnvironmentDefinition( environment, 1000, 1, 1.f );
    		theGame.SetEnvironmentID(envID);
			//W3EE - End
		}
	}
	//W3EE - Begin
	event OnEffectRemoved()
	{
		if( isOnPlayer )
		{
			theSound.SoundEvent("stop_feverflash");
			DeactivateEnvironment( envID, 1 );
		}
		super.OnEffectRemoved();
	}
	//W3EE - End
}