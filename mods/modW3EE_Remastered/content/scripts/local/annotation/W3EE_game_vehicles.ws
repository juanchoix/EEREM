////////////////////////////////////////////////////
//-- scripts\game\vehicles\vehicleComponent.ws --//
//////////////////////////////////////////////////
@wrapMethod(CVehicleComponent)
function IssueCommandToDismount( dismountType : EDismountType )
{
	var boatComponent : CBoatComponent;
	boatComponent = (CBoatComponent)this;

	if( (CBoatComponent)this )
		boatComponent.StopDismountBoat();
	
	wrappedMethod( dismountType );
}

//////////////////////////////////////////////////////
//-- scripts\game\vehicles\boat\boatComponent.ws --//
////////////////////////////////////////////////////
@addField(CBoatComponent) private var currentGear		  : int;
@addField(CBoatComponent) private var destGear			  : int;
@addField(CBoatComponent) private var currentSpeed		  : float;
@addField(CBoatComponent) private var destSpeed			  : float;
@addField(CBoatComponent) private var backGearSpeed		  : float;
@addField(CBoatComponent) private var neutralGearSpeed	  : float;
@addField(CBoatComponent) private var firstGearSpeed	  : float;
@addField(CBoatComponent) private var secondGearSpeed	  : float;
@addField(CBoatComponent) private var thirdGearSpeed 	  : float;
@addField(CBoatComponent) private var accelPressTimestamp : float;
@addField(CBoatComponent) private var decelPressTimestamp : float;
@addField(CBoatComponent) private var movementAccel		  : bool;

@addMethod(CBoatComponent)
public function StopDismountBoat()
{
	StopBoat();
	theInput.UnregisterListener(this, 'GI_Accelerate');
	theInput.UnregisterListener(this, 'GI_Decelerate');
	theInput.UnregisterListener(this, 'GI_AxisLeftY');
}
	
@addMethod(CBoatComponent)
private function StopBoat()
{
	destSpeed = 0;
	destGear = 0;
}
	
@addMethod(CBoatComponent)
private function ControlBoat( dt : float )
{
	var x, y : float;
	var inputHeading, min, max, dampener : float;
	var headingVector : Vector;
	var inputVector, velocity : Vector;
	var boat : CBoatBodyComponent;
		
	if( !((CR4Player)user) )
		return;
			
	if( IsColliding() )
	{
		if( (currentSpeed > 1.2 || currentSpeed < -1.2) )
		{
			destSpeed = ClampF(destSpeed, -1.2, 1.2);
			currentSpeed = MaxF(currentSpeed - dt * 3.f, destSpeed);
		}
	}
	else destSpeed = destGear * baseSpeed;
		
	if( currentSpeed < 0 )
		dampener = 0.7f;
	else
		dampener = 0.6f;
	if( currentSpeed < destSpeed )
		currentSpeed = MinF(currentSpeed + dt * dampener, destSpeed);
	else
		currentSpeed = MaxF(currentSpeed - dt * dampener, destSpeed);
			
	min = currentSpeed - RandRangeF(currentSpeed * 0.05f, 0);
	max = currentSpeed + RandRangeF(currentSpeed * 0.05f, 0);
		
	x = theInput.GetActionValue('GI_AxisLeftX');
	y = theInput.GetActionValue('GI_AxisLeftY');
	inputVector = VecNormalize2D(Vector(x, y, 0, 1));
	inputHeading = AngleDistance(theCamera.GetCameraHeading(), -VecHeading(inputVector));
	inputVector = VecFromHeading(inputHeading);
	headingVector = VecNormalize2D(inputVector * 0.05f + GetHeadingVector());
	velocity = VecConeRand(VecHeading(headingVector), 5.f, min, max);
		
	boat = (CBoatBodyComponent)boatEntity.GetComponentByClassName('CBoatBodyComponent');
	boat.SetPhysicalObjectLinearVelocity(velocity);
	if( currentSpeed <= backGearSpeed )
		currentGear = -1;
	else
	if( currentSpeed < firstGearSpeed )
		currentGear = 0;
	else
	if( currentSpeed < secondGearSpeed )
		currentGear = 1;
	else
	if( currentSpeed < thirdGearSpeed )
		currentGear = 2;
	else
		currentGear = 3;
}
	
@addMethod(CBoatComponent)
private function IsColliding() : bool
{
	var pointA, pointB, pointC, normal, pos : Vector;
	var collisionGroups : array<name>;
	var radius : float;
		
	pointA = GetWorldPosition();
	pointB = GetHeadingVector();
	pointC = pointA - pointB * 15.f;
	pointB = pointA + pointB * 25.f;
	pointA.Z += 0.3f;
	pointB.Z += 0.3f;
	pointC.Z += 0.3f;
		
	collisionGroups.PushBack('Static');		
	collisionGroups.PushBack('Terrain');
	collisionGroups.PushBack('BoatDocking');
		
	return theGame.GetWorld().SweepTest(pointA, pointB, 0.5f, pos, normal, collisionGroups) || theGame.GetWorld().SweepTest(pointA, pointC, 0.5f, pos, normal, collisionGroups);
}

@wrapMethod(CBoatComponent)
function OnMountFinished( entity : CEntity )
{
	if( Options().UseModifedBoatHandling() )
	{
		backGearSpeed = 0.f - baseSpeed / 2.5f;
		neutralGearSpeed = 0;
		firstGearSpeed = baseSpeed / 2.5f;
		secondGearSpeed = baseSpeed + baseSpeed / 2.5f;
		thirdGearSpeed = baseSpeed * 2.f + baseSpeed / 2.5f;
		theInput.RegisterListener(this, 'OnAccelerate', 'GI_Accelerate');
		theInput.RegisterListener(this, 'OnDecelerate', 'GI_Decelerate');
		theInput.RegisterListener(this, 'OnAxisInput', 'GI_AxisLeftY');
	}
	wrappedMethod( entity );
}

@wrapMethod(CBoatComponent)
function OnDismountStarted( entity : CEntity )
{
	StopDismountBoat();

	wrappedMethod( entity );
}

////////////////////////////////////////////////////////
//-- scripts\game\vehicles\horse\horseComponent.ws --//
//////////////////////////////////////////////////////

@wrapMethod(W3HorseComponent)
function OnDismountFinished( entity : CEntity, vehicleSlot : EVehicleSlot )
{
	var riderActor 	: CActor;
	riderActor	= (CActor)entity;
	
	wrappedMethod( entity, vehicleSlot );
	
	((W3PlayerWitcher)riderActor).UpdateWoundedState();
}

/////////////////////////////////////////////////////////
//-- scripts\game\vehicles\horse\horseManager.ws.ws --//
///////////////////////////////////////////////////////

@addMethod(W3HorseManager)
public function ShouldRest() : bool
{
	if( Equipment().GetHorseDistance() > 81 )
		return true;
	else
	if( !shouldHorseRest )
		return false;
	else
	if( Equipment().GetHorseDistance() <= 81 && shouldHorseRest )
	{
		shouldHorseRest = false;
		AddTimer('SetHorseRest', 60.f, false);
		return false;
	}
	else
		return true;
}
	
@addMethod(W3HorseManager)
private timer function SetHorseRest( dt : float, id : int )
{
	shouldHorseRest = true;
}