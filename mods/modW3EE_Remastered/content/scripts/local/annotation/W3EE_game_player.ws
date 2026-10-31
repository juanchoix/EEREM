//////////////////////////////////////////
//-- scripts\game\player\r4Player.ws --//
////////////////////////////////////////
@addMethod(CR4Player)
public function IsSetBonusActive( bonus : EItemSetBonus ) : bool
{
	return false;
}

@addField(CR4Player)
private var cancelReload : bool;

@addField(CR4Player)
private var isReloading : bool;

@addMethod(CR4Player)
public function SetCancelReload( b : bool )
{	cancelReload = b; }
	
@addMethod(CR4Player)
public function ShouldCancelReload() : bool
{	return cancelReload; }
	
@addMethod(CR4Player)
public function SetIsReloading( b : bool )
{	isReloading = b;	}
	
@addMethod(CR4Player)
public function IsReloading() : bool
{	return isReloading;	}
	
@addMethod(CR4Player)
public function IsImmuneToBuff( effect : EEffectType ) : bool
{
	var resPt, resPrc, chance : float;
	
	GetResistValue(theGame.effectMgr.GetBuffResistStat(effect), resPt, resPrc);
	
	return super.IsImmuneToBuff(effect) || resPrc >= 1.f;
}

@addMethod(CR4Player)
timer function ForceTaunt( dt : float, id : int )
{
	var chance : float = RandF();
	if( RandF() > 0.66f )
		thePlayer.PlayBattleCry('BattleCryHumansHit', 1.f, true, true);
	else
	if( RandF() > 0.33f )
		thePlayer.PlayBattleCry('BattleCryHumansEnd', 1.f, true, true);
	else
		thePlayer.PlayBattleCry('BattleCryTaunt', 1.f, true, true);
}

@addMethod(CR4Player)
timer function RemoveCameraEffect( dt : float, id : int )
{
	theGame.GetGameCamera().StopEffect('frost');
}

@addMethod(CR4Player)
timer function RemoveBloodEffects( dt : float, id : int )
{
	StopEffect('covered_blood');
}