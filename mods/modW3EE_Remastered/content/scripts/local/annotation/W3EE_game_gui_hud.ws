//////////////////////////////////////
//-- scripts\game\gui\hud\hud.ws --//
////////////////////////////////////

@addMethod(CR4ScriptedHud) 
	function QuestFixes( questEntry : CJournalQuest )
	{
		var i, j : int;
		var questPhase : CJournalQuestPhase;
		var objective : CJournalQuestObjective;
		var objectiveStatus : EJournalStatus;
		var journalManager : CWitcherJournalManager;
		var objectiveTag, questName : string;
		
		questName = NameToString(questEntry.GetUniqueScriptTag());
		if( questName == "Q103 Family Issues DB024D36-4E9AE35E-FB098D89-C8E7AB0F" || questName == "q603getinman 0B8961C8-4338EB48-B2D635A5-C49FAA38" || questName == "Q001 Find Yennefer" || questName == "sq701_tournament" )
		{
			journalManager = theGame.GetJournalManager();
			for( i = 0; i < questEntry.GetNumChildren(); i += 1 )
			{
				questPhase = (CJournalQuestPhase)questEntry.GetChild(i);
				if( questPhase )
				{				
					for( j = 0; j < questPhase.GetNumChildren(); j += 1 )
					{
						objective = (CJournalQuestObjective)questPhase.GetChild(j);
						objectiveStatus = journalManager.GetEntryStatus( objective );
						objectiveTag = NameToString(objective.GetUniqueScriptTag());
						if( objectiveStatus == JS_Active )
						{
							if( objectiveTag == "Protect Baron from wraiths" || objectiveTag == "Protect Baron from wraiths once more" || objectiveTag == "kill ghouls" )
							{
								theGame.SaveGame( SGT_CheckPoint, -1 );
								if( objectiveTag == "kill ghouls" )
									Equipment().SetStartingGear();
							}
							else
							if( objectiveTag == "Geralt's Score" || objectiveTag == "Perform a circus trick 69B9EE26-46A64DE3-5872089E-5FE280BC" || objectiveTag == "Shoot all six targets." )
							{
								GetWitcherPlayer().GetInventory().AddAndEquipItem('Bodkin Bolt', EES_Bolt, 25);
							}
						}
					}
				}
			}
		}
	}