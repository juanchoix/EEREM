/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract state MeditationBase in W3PlayerWitcher extends ExtendedMovable
{
	protected var menuNotYetOpen : bool;						
	private var storedCameraHorTimeout : float;
	private var storedCameraVerTimeout : float;
	protected var UsedMeditationState : bool; //W3EE

	event OnEnterState( prevStateName : name )
	{
		//W3EE - Begin
		UsedMeditationState = Options().UsedMeditationState();
		if( !UsedMeditationState )
		{
		parent.AddAnimEventCallback('OpenUI','OnAnimEvent_OpenUI');

		storedCameraHorTimeout = theGame.GetGameCamera().GetManualRotationHorTimeout();
		storedCameraVerTimeout = theGame.GetGameCamera().GetManualRotationVerTimeout();

		theGame.GetGameCamera().SetManualRotationHorTimeout( 1.f );
		theGame.GetGameCamera().SetManualRotationVerTimeout( 1.f );

		theGame.GetGameCamera().ForceManualControlHorTimeout();
		theGame.GetGameCamera().ForceManualControlVerTimeout();
		}
		//W3EE - End
	}

	event OnLeaveState( nextStateName : name )
	{
		//W3EE - Begin
		if( !UsedMeditationState )
		{
		if ( nextStateName != 'MeditationWaiting' && nextStateName != 'Meditation' )
			virtual_parent.ResetMeditationPointHeading();

		theGame.GetGameCamera().SetManualRotationHorTimeout( storedCameraHorTimeout );
		theGame.GetGameCamera().SetManualRotationVerTimeout( storedCameraVerTimeout );
		}
		//W3EE - End
	}

	event OnGameCameraTick( out moveData : SCameraMovementData, dt : float )
	{
		var heading : float = virtual_parent.GetHeading();
		var distVec : Vector;

		var commonMenuRef 	: CR4CommonMenu;
		//W3EE - Begin
		if( !UsedMeditationState )
		{
		commonMenuRef = theGame.GetGuiManager().GetCommonMenu();
		if ( commonMenuRef && !commonMenuRef.m_had_meditation )
			return true;

		if ( virtual_parent.IsMeditationHeadingSet() )
			heading = virtual_parent.GetMeditationPointHeading();

		theGame.GetGameCamera().ChangePivotRotationController( 'Exploration' );
		theGame.GetGameCamera().ChangePivotDistanceController( 'Default' );
		theGame.GetGameCamera().ChangePivotPositionController( 'Default' );
		
		moveData.pivotDistanceController = theGame.GetGameCamera().GetActivePivotDistanceController();
		moveData.pivotPositionController = theGame.GetGameCamera().GetActivePivotPositionController();
		moveData.pivotRotationController = theGame.GetGameCamera().GetActivePivotRotationController();

		moveData.pivotRotationController.SetDesiredHeading( heading + 180.f, virtual_parent.GetMeditationCameraHeadingMult() );
		moveData.pivotRotationController.SetDesiredPitch( -15.f, virtual_parent.GetMeditationCameraHeadingMult() / 2.f );
		moveData.pivotDistanceController.SetDesiredDistance( 3.8f );

		if ( IsMenuOpen() || menuNotYetOpen )
			distVec = Vector( -2.f, 0.f, -0.75f );
		else
			distVec = Vector( 0, 0.f, -0.75f );

		DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, distVec, 0.75f, dt );

		return true;
		}
		//W3EE - End
	}

	event OnAnimEvent_OpenUI( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		//W3EE - Begin
		if( !UsedMeditationState )
		{
		virtual_parent.SetMeditationCameraHeadingMult( 1.f );
		}
		//W3EE - End
	}

	
	public function StopRequested(optional closeUI : bool);
	
	event OnReactToBeingHit( damageAction : W3DamageAction )
	{
		var ret : bool;
		var tox : W3Effect_Toxicity;
		
		ret = virtual_parent.OnReactToBeingHit(damageAction);
		
		
		tox = (W3Effect_Toxicity)damageAction.causer;
		if(!tox)		
			StopRequested(true);
			
		return ret;
	}

	public function IsMenuOpen() : bool
	{
		var commonMenuRef 	: CR4CommonMenu;
		commonMenuRef = theGame.GetGuiManager().GetCommonMenu();

		if ( commonMenuRef )
			return true;
		else
			return false;
	}

	protected function CloseUI()
	{
		var commonMenuRef 	: CR4CommonMenu;
		//W3EE - Begin
		if( !UsedMeditationState )
		{
		if ( parent.HideClockMenu() )
			return;

		commonMenuRef = theGame.GetGuiManager().GetCommonMenu();
		if (commonMenuRef)
		{
			commonMenuRef.SetSkipFadeOnClose( true );
			commonMenuRef.CloseMenu();
		}
		}
		//W3EE - End
	}

	public function OpenUI( fadeInTime : float )
	{
		var meditationInitData : W3MeditationTimeInitData;
		//W3EE - Begin
		if( !UsedMeditationState )
		{
		meditationInitData = new W3MeditationTimeInitData in this;
		meditationInitData.m_fadeInTime = fadeInTime;
		theGame.RequestMenuWithBackground( 'MeditationClockMenu', 'CommonMenu', meditationInitData );

		theGame.GetGameCamera().ForceManualControlHorTimeout();
		theGame.GetGameCamera().ForceManualControlVerTimeout();
		}
	}

	event OnPlayerTickTimer( deltaTime : float )
	{
		//W3EE - Begin
		if( !UsedMeditationState )
		{
		super.OnPlayerTickTimer( deltaTime );

		
		
		if ( thePlayer.IsHoldingItemInLHand() )
		{
			virtual_parent.HideUsableItem();
		}

		if ( menuNotYetOpen )
		{
			if ( IsMenuOpen() )
				menuNotYetOpen = false;
		}
		}
		//W3EE - End
	}
}