/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state CharDevMutagens in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var DESCRIPTION, SELECT_TAB, EQUIP, BONUSES, MATCH_SKILL_COLOR, MULTIPLE_SKILLS, WRONG_COLOR, POTIONS, MUTAGENS_JOURNAL : name;
	private var isClosing : bool;
	private var savedEquippedSkills : array<STutorialSavedSkill>;					
	
		default DESCRIPTION 		= 'TutorialMutagenDescription';
		default SELECT_TAB			= 'TutorialMutagenSelectTab';
		default EQUIP				= 'TutorialMutagenEquip';
		default BONUSES				= 'TutorialMutagenBonuses';
		default MATCH_SKILL_COLOR	= 'TutorialMutagenMatchSkillColor';
		default MULTIPLE_SKILLS		= 'TutorialMutagenMultipleSkills';
		default WRONG_COLOR			= 'TutorialMutagenWrongColor';
		default POTIONS				= 'TutorialMutagenPotions';
		default MUTAGENS_JOURNAL	= 'TutorialJournalCharDevMutagens';

	private var cachedSlot : EEquipmentSlots;
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		ShowHint(DESCRIPTION, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input);		
		
		theGame.GetTutorialSystem().ActivateJournalEntry(MUTAGENS_JOURNAL);
	}
			
	event OnLeaveState( nextStateName : name )
	{		
		isClosing = true;
		
		CloseStateHint(DESCRIPTION);
		CloseStateHint(SELECT_TAB);
		CloseStateHint(EQUIP);
		CloseStateHint(BONUSES);
		CloseStateHint(MATCH_SKILL_COLOR);
		CloseStateHint(MULTIPLE_SKILLS);
		CloseStateHint(WRONG_COLOR);
		CloseStateHint(POTIONS);
		//W3EE - Begin
		theGame.GetTutorialSystem().MarkMessageAsSeen(DESCRIPTION);
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
		theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP);
		theGame.GetTutorialSystem().MarkMessageAsSeen(BONUSES);
		theGame.GetTutorialSystem().MarkMessageAsSeen(MATCH_SKILL_COLOR);
		theGame.GetTutorialSystem().MarkMessageAsSeen(MULTIPLE_SKILLS);
		theGame.GetTutorialSystem().MarkMessageAsSeen(WRONG_COLOR);
		theGame.GetTutorialSystem().MarkMessageAsSeen(POTIONS);
		//W3EE - End
		GetWitcherPlayer().TutorialMutagensCleanupTempSkills(savedEquippedSkills);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var highlights : array< STutorialHighlight >;
		
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == DESCRIPTION)
		{
			ShowHint(SELECT_TAB, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Infinite, GetHighlightCharDevTabMutagens() );
		}
		else if(hintName == EQUIP)
		{
			savedEquippedSkills = GetWitcherPlayer().TutorialMutagensUnequipPlayerSkills(); //W3EE
			
			ShowHint(BONUSES, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input, GetHighlightCharDevMutagenBonusString() ); //W3EE
		}
		else if(hintName == BONUSES)
		{
			//highlights = GetHighlightCharDevMutagenBonusString(); //W3EE
			//AddHighlight( highlights, .568f, .14f, .08f, .15f ); //W3EE
			
			GetWitcherPlayer().TutorialMutagensEquipOneGoodSkill();
			
			ShowHint(MATCH_SKILL_COLOR, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input); //W3EE
		}
		else if(hintName == MATCH_SKILL_COLOR)
		{
			//highlights = GetHighlightCharDevMutagenBonusString(); //W3EE
			//AddHighlight( highlights, .568f, .24f, .08f, .15f ); //W3EE
			
			GetWitcherPlayer().TutorialMutagensEquipOneGoodOneBadSkill();
			
			ShowHint(WRONG_COLOR, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input); //W3EE
		}
		else if(hintName == WRONG_COLOR)
		{
			GetWitcherPlayer().TutorialMutagensEquipThreeGoodSkills();
			
			ShowHint(MULTIPLE_SKILLS, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input); //W3EE
		}		
		else if(hintName == MULTIPLE_SKILLS)
		{
			ShowHint(POTIONS, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input);
		}
		else if(hintName == POTIONS)
		{
			QuitState();
		}
	}

	public final function SelectedMutagensTab()
	{
		var highlights : array<STutorialHighlight>;
		
		if(IsCurrentHint(SELECT_TAB))
		{
			CloseStateHint(SELECT_TAB);
			
			//highlights = GetHighlightCharDevSkills(); //W3EE
			//HighlightsCombine( highlights, GetHighlightCharDevTabMutagens() ); //W3EE
			AddHighlight( highlights, 0.085f, 0.25f, 0.27f, 0.37f ); //W3EE
			ShowHint(EQUIP, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Infinite); //W3EE
		}
	}
	
	public final function EquippedMutagen(slot : EEquipmentSlots)
	{
		CloseStateHint(EQUIP);
		ShowHint(BONUSES, POS_CHAR_DEV_X, POS_CHAR_DEV_Y, ETHDT_Input, GetHighlightCharDevMutagenBonusString(/*slot*/) ); //W3EE
		cachedSlot = slot;
	}
}




exec function tut_ch_m(optional color : ESkillColor, optional equipSkillsFirst : bool)
{
	GetWitcherPlayer().AddPoints(EExperiencePoint, 1500, false );
	
	if(equipSkillsFirst)
	{
		skilleq_internal(S_Alchemy_s01, 1);
		skilleq_internal(S_Alchemy_s02, 2);
		skilleq_internal(S_Sword_s01, 3);
	}
	
	if(color == SC_None || color == SC_Yellow)
		color = SC_Green;
		
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
		
	if(color == SC_Green)
		thePlayer.inv.AddAnItem('Ekimma mutagen',1);
	else if(color == SC_Blue)
		thePlayer.inv.AddAnItem('Fogling 1 mutagen',1);
	else if(color == SC_Red)
		thePlayer.inv.AddAnItem('Doppler mutagen',1);
	
	TutorialScript('charDevMutagens', '');
}