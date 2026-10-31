///////////////////////////////////////
//-- scripts\game\inputManager.ws --//
/////////////////////////////////////


/////////////////////////////////////////////////
//-- scripts\game\player\states\swimming.ws --//
///////////////////////////////////////////////

@wrapMethod(CR4PlayerStateSwimming)
function OnRunJumpEnd()
{
	var quenEntity : W3QuenEntity;
	
	quenEntity = (W3QuenEntity)GetWitcherPlayer().GetSignEntity(ST_Quen);
	
	if( GetWitcherPlayer().IsAnyQuenActive() )
	{
		quenEntity.WaterDestroysQuen();
	}
	wrappedMethod();
}

@wrapMethod(CR4PlayerStateSwimming)
function OnDiveAnimationEnd()
{
	var quenEntity : W3QuenEntity;

	quenEntity = (W3QuenEntity)GetWitcherPlayer().GetSignEntity(ST_Quen);
	
	if( GetWitcherPlayer().IsAnyQuenActive() )
	{
		quenEntity.WaterDestroysQuen();
	}
	wrappedMethod();
}

@wrapMethod(CR4PlayerStateSwimming)
function OnDivingStateStart()
{
	var quenEntity : W3QuenEntity;
	
	quenEntity = (W3QuenEntity)GetWitcherPlayer().GetSignEntity(ST_Quen);

	if( GetWitcherPlayer().IsAnyQuenActive() )
	{
		quenEntity.WaterDestroysQuen();
	}
	wrappedMethod();
}

@wrapMethod(CR4PlayerStateSwimming)
function OnSwimStart()
{
	var quenEntity : W3QuenEntity;
	
	quenEntity = (W3QuenEntity)GetWitcherPlayer().GetSignEntity(ST_Quen);

	if( GetWitcherPlayer().IsAnyQuenActive() )
	{
		quenEntity.WaterDestroysQuen();
	}
	wrappedMethod();
}

@wrapMethod(CR4PlayerStateSwimming)
function OnJumpToWaterStart()
{
	var quenEntity : W3QuenEntity;
	
	quenEntity = (W3QuenEntity)GetWitcherPlayer().GetSignEntity(ST_Quen);

	if( GetWitcherPlayer().IsAnyQuenActive() )
	{
		quenEntity.WaterDestroysQuen();
	}
	wrappedMethod();
}