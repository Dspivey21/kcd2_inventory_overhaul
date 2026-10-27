function Init()
{
   SetStage();
   DummyLoadIconSwf();
   g_DialogState = Enum.DIALOG_HIDE;
   g_TrespassState = Enum.TRESPASS_NOTHING;
   g_CrimeState = Enum.CRIME_NOTHING;
   g_WantedState = Enum.WANTED_NOTHING;
   g_SequencesA = [];
   g_QAMSlotsA = [];
   g_SkillChecksA = [];
   g_CrimeListDataA = [];
   g_ActionHintsA = [];
   g_CompassMarkersA = [];
   g_RatioPreset = Enum.RATIO_PRESET_GAME;
   g_QAMWeapon = new QAM(Enum.QAM_TYPE_WEAPON,_root.bc.mc_StatsContainer.qamWeapon);
   g_QAMFood = new QAM(Enum.QAM_TYPE_FOOD,_root.bc.mc_StatsContainer.qamFood);
   g_QAMType = Enum.QAM_TYPE_NONE;
   g_PeridicalObservable = new Observable();
   g_CountingInterval = setInterval(this,"Update",1000 / _root.g_Framerate);
   g_InputIdObservable = new Observable();
   g_FancyNotifMngr = FancyNotificationManager.Create(_root.tc.fancyEvent);
   g_FancyNotifMngr.FadeInDuration = 200;
   g_FancyNotifMngr.FadeOutDuration = 500;
   g_FancyNotifMngr.SetStaticSlots(NotificationSlots.E_X,0,[0]);
   g_FancyNotifMngr.MergeEnable = true;
   g_FancyNotifMngr.CooldownEnable = true;
   g_PeridicalObservable.AttachListener(g_FancyNotifMngr,"PeriodicalUpdate");
   g_InfoTextNotifMngr = InfoTextNotificationManager.Create(_root.cccursor.infoText);
   g_InfoTextNotifMngr.FadeInDuration = 100;
   g_InfoTextNotifMngr.FadeOutDuration = 300;
   g_InfoTextNotifMngr.MergeEnable = true;
   g_InfoTextNotifMngr.SetStaticSlots(NotificationSlots.E_X,0,[0]);
   g_PeridicalObservable.AttachListener(g_InfoTextNotifMngr,"PeriodicalUpdate");
   g_ItemTransferNotifMngr = ItemTransferNotificationManager.Create(_root.bl.itemTransfer);
   g_ItemTransferNotifMngr.FadeInDuration = 100;
   g_ItemTransferNotifMngr.FadeOutDuration = 300;
   g_ItemTransferNotifMngr.MoveDuration = 300;
   g_ItemTransferNotifMngr.MergeEnable = true;
   g_ItemTransferNotifMngr.SetStaticSlots(NotificationSlots.E_Y,0,[0,60,120]);
   g_PeridicalObservable.AttachListener(g_ItemTransferNotifMngr,"PeriodicalUpdate");
   g_SkillCheckNotifMngr = SkillCheckNotificationManager.Create(_root.bc.skillCheck);
   g_SkillCheckNotifMngr.FadeInDuration = 100;
   g_SkillCheckNotifMngr.FadeOutDuration = 300;
   g_SkillCheckNotifMngr.SetStaticSlots(NotificationSlots.E_X,0,[0]);
   g_PeridicalObservable.AttachListener(g_SkillCheckNotifMngr,"PeriodicalUpdate");
   g_CommonNotifMngr = CommonNotificationManager.Create(_root.tr.commonEvent);
   g_CommonNotifMngr.FadeInDuration = 100;
   g_CommonNotifMngr.FadeOutDuration = 300;
   g_CommonNotifMngr.MoveDuration = 300;
   g_CommonNotifMngr.CooldownEnable = true;
   g_CommonNotifMngr.MergeEnable = true;
   g_CommonNotifMngr.SetStaticSlots(NotificationSlots.E_Y,0,[0,60,120]);
   g_PeridicalObservable.AttachListener(g_CommonNotifMngr,"PeriodicalUpdate");
   g_BuffLeftNotifMngr = BuffNotificationManager.Create(_root.bc.buffs.leftBuffs);
   g_BuffLeftNotifMngr.FadeInDuration = 500;
   g_BuffLeftNotifMngr.FadeOutDuration = 1000;
   g_BuffLeftNotifMngr.MoveDuration = 330;
   g_BuffLeftNotifMngr.MergeEnable = true;
   g_BuffLeftNotifMngr.InsertInto = true;
   g_BuffLeftNotifMngr.SetStaticSlots(NotificationSlots.E_X,0,[-50,-110,-170,-230,-290,-350,-410,-470,-530,-590]);
   g_PeridicalObservable.AttachListener(g_BuffLeftNotifMngr,"PeriodicalUpdate");
   g_BuffRightNotifMngr = BuffNotificationManager.Create(_root.bc.buffs.rightBuffs);
   g_BuffRightNotifMngr.FadeInDuration = 500;
   g_BuffRightNotifMngr.FadeOutDuration = 1000;
   g_BuffRightNotifMngr.MoveDuration = 330;
   g_BuffRightNotifMngr.MergeEnable = true;
   g_BuffRightNotifMngr.InsertInto = true;
   g_BuffRightNotifMngr.SetStaticSlots(NotificationSlots.E_X,0,[0,60,120,180,240,300,360,420,480,540]);
   g_PeridicalObservable.AttachListener(g_BuffRightNotifMngr,"PeriodicalUpdate");
   g_TutorialNotifMngr = TutorialNotificationManager.Create(_root.tl.tutorial);
   g_TutorialNotifMngr.FadeInDuration = 100;
   g_TutorialNotifMngr.FadeOutDuration = 500;
   g_TutorialNotifMngr.MergeEnable = true;
   g_TutorialNotifMngr.InsertInto = true;
   g_TutorialNotifMngr.SetStaticSlots(NotificationSlots.E_X,0,[0]);
   g_PeridicalObservable.AttachListener(g_TutorialNotifMngr,"PeriodicalUpdate");
   g_TutorialInDialogNotifMngr = TutorialNotificationManager.Create(_root.tutorialInDialog);
   g_TutorialInDialogNotifMngr.FadeInDuration = 200;
   g_TutorialInDialogNotifMngr.FadeOutDuration = 200;
   g_TutorialInDialogNotifMngr.SetStaticSlots(NotificationSlots.E_X,0,[0]);
   g_PeridicalObservable.AttachListener(g_TutorialInDialogNotifMngr,"PeriodicalUpdate");
   g_TutorialInDialogNotifMngr.Pause();
   g_GameLogNotifMngr = GameLogNotificationManager.Create(_root.tr.gameLog);
   g_GameLogNotifMngr.FadeInDuration = 100;
   g_GameLogNotifMngr.FadeOutDuration = 300;
   g_GameLogNotifMngr.MoveDuration = 330;
   g_GameLogNotifMngr.InsertInto = true;
   g_GameLogNotifMngr.SetStaticSlots(NotificationSlots.E_Y,0,[0,40,80,120,160,200,240,280,320,360,400]);
   g_PeridicalObservable.AttachListener(g_GameLogNotifMngr,"PeriodicalUpdate");
   g_ActionHintNotifMngr = ActionHintNotificationManager.Create(_root.br.actionHints,Enum.HINT_CLASS_BASIC);
   g_ActionHintNotifMngr.FadeInDuration = 0;
   g_ActionHintNotifMngr.FadeOutDuration = 0;
   g_ActionHintNotifMngr.MoveDuration = 0;
   g_ActionHintNotifMngr.InsertInto = true;
   g_ActionHintNotifMngr.SetDynamicSlots(NotificationSlots.E_Y,0,0,10,8,-1);
   g_PeridicalObservable.AttachListener(g_ActionHintNotifMngr,"PeriodicalUpdate");
   g_ApseTopLeftActionHintNotifMngr = ActionHintNotificationManager.Create(_root.ratioStrips.topStrip.inside.left,Enum.HINT_CLASS_APSE_TOP_LEFT);
   g_ApseTopLeftActionHintNotifMngr.FadeInDuration = 0;
   g_ApseTopLeftActionHintNotifMngr.FadeOutDuration = 0;
   g_ApseTopLeftActionHintNotifMngr.MoveDuration = 0;
   g_ApseTopLeftActionHintNotifMngr.InsertInto = true;
   g_ApseTopLeftActionHintNotifMngr.SetDynamicSlots(NotificationSlots.E_X,12,0,8,0,1);
   g_PeridicalObservable.AttachListener(g_ApseTopLeftActionHintNotifMngr,"PeriodicalUpdate");
   g_ApseTopRightActionHintNotifMngr = ActionHintNotificationManager.Create(_root.ratioStrips.topStrip.inside.right,Enum.HINT_CLASS_APSE_TOP_RIGHT);
   g_ApseTopRightActionHintNotifMngr.FadeInDuration = 0;
   g_ApseTopRightActionHintNotifMngr.FadeOutDuration = 0;
   g_ApseTopRightActionHintNotifMngr.MoveDuration = 0;
   g_ApseTopRightActionHintNotifMngr.InsertInto = true;
   g_ApseTopRightActionHintNotifMngr.SetDynamicSlots(NotificationSlots.E_X,-12,0,8,0,-1);
   g_PeridicalObservable.AttachListener(g_ApseTopRightActionHintNotifMngr,"PeriodicalUpdate");
   g_ApseBottomLeftActionHintNotifMngr = ActionHintNotificationManager.Create(_root.ratioStrips.bottomStrip.inside.left,Enum.HINT_CLASS_APSE_BOTTOM_LEFT);
   g_ApseBottomLeftActionHintNotifMngr.FadeInDuration = 0;
   g_ApseBottomLeftActionHintNotifMngr.FadeOutDuration = 0;
   g_ApseBottomLeftActionHintNotifMngr.MoveDuration = 0;
   g_ApseBottomLeftActionHintNotifMngr.InsertInto = true;
   g_ApseBottomLeftActionHintNotifMngr.SetDynamicSlots(NotificationSlots.E_X,12,0,8,0,1);
   g_PeridicalObservable.AttachListener(g_ApseBottomLeftActionHintNotifMngr,"PeriodicalUpdate");
   g_ApseTopCenterActionHintNotifMngr = ActionHintNotificationManager.Create(_root.ratioStrips.topStrip.inside.center,Enum.HINT_CLASS_APSE_TOP_CENTER);
   g_ApseTopCenterActionHintNotifMngr.FadeInDuration = 0;
   g_ApseTopCenterActionHintNotifMngr.FadeOutDuration = 0;
   g_ApseTopCenterActionHintNotifMngr.MoveDuration = 0;
   g_ApseTopCenterActionHintNotifMngr.InsertInto = true;
   g_ApseTopCenterActionHintNotifMngr.SetDynamicSlots(NotificationSlots.E_X,40,0,8,0,1);
   g_PeridicalObservable.AttachListener(g_ApseTopCenterActionHintNotifMngr,"PeriodicalUpdate");
   g_ApseBottomCenterActionHintNotifMngr = ActionHintNotificationManager.Create(_root.ratioStrips.bottomStrip.inside.center,Enum.HINT_CLASS_APSE_BOTTOM_CENTER);
   g_ApseBottomCenterActionHintNotifMngr.FadeInDuration = 0;
   g_ApseBottomCenterActionHintNotifMngr.FadeOutDuration = 0;
   g_ApseBottomCenterActionHintNotifMngr.MoveDuration = 0;
   g_ApseBottomCenterActionHintNotifMngr.InsertInto = true;
   g_ApseBottomCenterActionHintNotifMngr.SetDynamicSlots(NotificationSlots.E_X,40,0,8,0,-1);
   g_PeridicalObservable.AttachListener(g_ApseBottomCenterActionHintNotifMngr,"PeriodicalUpdate");
   g_ApseBottomRightActionHintNotifMngr = ActionHintNotificationManager.Create(_root.ratioStrips.bottomStrip.inside.right,Enum.HINT_CLASS_APSE_BOTTOM_RIGHT);
   g_ApseBottomRightActionHintNotifMngr.FadeInDuration = 0;
   g_ApseBottomRightActionHintNotifMngr.FadeOutDuration = 0;
   g_ApseBottomRightActionHintNotifMngr.MoveDuration = 0;
   g_ApseBottomRightActionHintNotifMngr.InsertInto = true;
   g_ApseBottomRightActionHintNotifMngr.SetDynamicSlots(NotificationSlots.E_X,-12,0,8,0,-1);
   g_PeridicalObservable.AttachListener(g_ApseBottomRightActionHintNotifMngr,"PeriodicalUpdate");
   g_DialogIconLeftNotifMngr = DialogIconNotificationManager.Create(_root.cl.interactiveDialog.icons);
   g_DialogIconLeftNotifMngr.FadeInDuration = 0;
   g_DialogIconLeftNotifMngr.FadeOutDuration = 0;
   g_DialogIconLeftNotifMngr.MoveDuration = 0;
   g_DialogIconRightNotifMngr.InsertInto = true;
   g_DialogIconLeftNotifMngr.SetSide(Enum.DIALOG_LEFT_DIALOG);
   g_DialogIconLeftNotifMngr.SetDynamicSlots(NotificationSlots.E_X,0,0,8,0,1);
   g_PeridicalObservable.AttachListener(g_DialogIconLeftNotifMngr,"PeriodicalUpdate");
   g_DialogIconRightNotifMngr = DialogIconNotificationManager.Create(_root.cr.interactiveDialog.icons);
   g_DialogIconRightNotifMngr.FadeInDuration = 0;
   g_DialogIconRightNotifMngr.FadeOutDuration = 0;
   g_DialogIconRightNotifMngr.MoveDuration = 0;
   g_DialogIconRightNotifMngr.InsertInto = true;
   g_DialogIconRightNotifMngr.SetSide(Enum.DIALOG_RIGHT_DIALOG);
   g_DialogIconRightNotifMngr.SetDynamicSlots(NotificationSlots.E_X,0,0,8,0,-1);
   g_PeridicalObservable.AttachListener(g_DialogIconRightNotifMngr,"PeriodicalUpdate");
   DrawExtension.drawRepetitiveBackground(_root.tc.compass.compassStrip.inside.background,"Textures/compass_strip","Textures/compass_strip","Textures/compass_strip",false,2880);
   var _loc3_ = cccursor.actioncursor.ActionCursorOutline;
   _loc3_.up.counter = 0;
   _loc3_.up.frames = 10;
   _loc3_.bottom.counter = 0;
   _loc3_.bottom.frames = 10;
   g_MarkersO = {};
   g_QuestAreaCounter = 0;
   g_QuestLockedCounter = 0;
   g_DialogSequencesA = [];
   g_DialogSequenceSelected = 0;
   g_CooldownManager = new CooldownManager();
   g_ForgeCameraScale = -1;
   hideAllBubbles();
}
function Update()
{
   g_PeridicalObservable.ForceUpdate();
}
function SetStage()
{
   SetupElements(Stage.width,Stage.height);
}
function cry_onResize(_intWidth, _intHeight, _intScreenWidth, _intScreenHeight)
{
   SetupElements(_intScreenWidth,_intScreenHeight);
}
function cry_onLanguageChanged()
{
   setCompassNames();
   g_TutorialNotifMngr.LanguageChanged();
}
function SetupElements(screenWidth, screenHeight)
{
   g_currSizeX = screenWidth;
   g_currSizeY = screenHeight;
   var _loc3_ = g_currSizeX - Enum.SCREEN_WIDTH;
   var _loc2_ = g_currSizeY - Enum.SCREEN_HEIGHT;
   var _loc1_ = g_currSizeY / Enum.SCREEN_HEIGHT * 100;
   tl._xscale = _loc1_;
   tl._yscale = _loc1_;
   tr._x = Enum.SCREEN_WIDTH + _loc3_;
   tr._xscale = _loc1_;
   tr._yscale = _loc1_;
   tc._x = g_currSizeX / 2;
   tc._xscale = _loc1_;
   tc._yscale = _loc1_;
   tutorialInDialog._xscale = _loc1_;
   tutorialInDialog._yscale = _loc1_;
   tutorialInDialog._y = 246 * (_loc1_ / 100);
   br._x = Enum.SCREEN_WIDTH + _loc3_;
   br._y = Enum.SCREEN_HEIGHT + _loc2_;
   br._xscale = _loc1_;
   br._yscale = _loc1_;
   cl._y = g_currSizeY / 2;
   cl._xscale = _loc1_;
   cl._yscale = _loc1_;
   cr._x = Enum.SCREEN_WIDTH + _loc3_;
   cr._y = g_currSizeY / 2;
   cr._xscale = _loc1_;
   cr._yscale = _loc1_;
   bl._y = Enum.SCREEN_HEIGHT + _loc2_;
   bl._xscale = _loc1_;
   bl._yscale = _loc1_;
   bc._x = g_currSizeX / 2;
   bc._y = Enum.SCREEN_HEIGHT + _loc2_;
   bc._xscale = _loc1_;
   bc._yscale = _loc1_;
   bbc._x = g_currSizeX / 2;
   bbc._y = Enum.SCREEN_HEIGHT + _loc2_;
   bbc._xscale = _loc1_;
   bbc._yscale = _loc1_;
   cc._x = g_currSizeX / 2;
   cc._y = g_currSizeY / 2;
   cc._xscale = _loc1_;
   cc._yscale = _loc1_;
   cccursor._x = g_currSizeX / 2;
   cccursor._y = g_currSizeY / 2;
   cccursor._xscale = _loc1_;
   cccursor._yscale = _loc1_;
   popUpVisual._x = g_currSizeX / 2;
   popUpVisual._y = g_currSizeY / 2;
   popUpVisual._xscale = _loc1_;
   popUpVisual._yscale = _loc1_;
   popUp._xscale = g_currSizeX / Enum.SCREEN_WIDTH * 100;
   popUp._yscale = g_currSizeY / Enum.SCREEN_HEIGHT * 100;
   fader._xscale = g_currSizeX / Enum.SCREEN_WIDTH * 100;
   fader._yscale = g_currSizeY / Enum.SCREEN_HEIGHT * 100;
   vignette._xscale = g_currSizeX / Enum.SCREEN_WIDTH * 100;
   vignette._yscale = g_currSizeY / Enum.SCREEN_HEIGHT * 100;
   ratioStrips.topStrip._x = g_currSizeX / 2;
   ratioStrips.topStrip._xscale = g_currSizeX / Enum.SCREEN_WIDTH * 100;
   ratioStrips.bottomStrip._x = g_currSizeX / 2;
   ratioStrips.bottomStrip._xscale = g_currSizeX / Enum.SCREEN_WIDTH * 100;
   ratioStrips.leftStrip._y = g_currSizeY / 2;
   ratioStrips.leftStrip._yscale = g_currSizeY / Enum.SCREEN_HEIGHT * 100;
   ratioStrips.rightStrip._y = g_currSizeY / 2;
   ratioStrips.rightStrip._yscale = g_currSizeY / Enum.SCREEN_HEIGHT * 100;
   ratioStrips.rightDialog._x = g_currSizeX;
   ratioStrips.rightDialog._xscale = g_currSizeX / Enum.SCREEN_WIDTH * 100;
   ratioStrips.rightDialog._y = g_currSizeY / 2;
   ratioStrips.rightDialog._yscale = g_currSizeY / Enum.SCREEN_HEIGHT * 100;
   cccursor.actioncursor.ActionCursorCross.state7._visible = false;
   cccursor.actioncursor.ActionCursorOutline.up._visible = false;
   cccursor.actioncursor.ActionCursorOutline.bottom._visible = false;
   cccursor.actioncursor.CombatCursorCross._visible = false;
   testFrame._xscale = _loc1_;
   testFrame._yscale = _loc1_;
   fc_setRatioPreset(g_RatioPreset);
}
function resolutionScaleMC(mc)
{
   var _loc1_ = resolutionScale();
   mc._xscale = _loc1_;
   mc._yscale = _loc1_;
}
function resolutionScale()
{
   if(g_currSizeX / g_currSizeY < Enum.SCREEN_WIDTH / Enum.SCREEN_HEIGHT)
   {
      return g_currSizeX / Enum.SCREEN_WIDTH * 100;
   }
   return g_currSizeY / Enum.SCREEN_HEIGHT * 100;
}
function setCompassNames()
{
   var _loc2_ = _root.tc.compass.compassStrip.inside;
   var _loc3_ = g_GameMode == Enum.GAME_MODE_HARD;
   _loc2_.east.tField.text = !_loc3_ ? "@ui_east_shortcut" : Enum.COMPASS_MARK;
   _loc2_.south.tField.text = !_loc3_ ? "@ui_south_shortcut" : Enum.COMPASS_MARK;
   _loc2_.west.tField.text = !_loc3_ ? "@ui_west_shortcut" : Enum.COMPASS_MARK;
   _loc2_.north.tField.text = !_loc3_ ? "@ui_north_shortcut" : Enum.COMPASS_MARK;
   _loc2_.east2.tField.text = !_loc3_ ? "@ui_east_shortcut" : Enum.COMPASS_MARK;
   _loc2_.south2.tField.text = !_loc3_ ? "@ui_south_shortcut" : Enum.COMPASS_MARK;
   _loc2_.west2.tField.text = !_loc3_ ? "@ui_west_shortcut" : Enum.COMPASS_MARK;
   _loc2_.southeast.tField.text = !_loc3_ ? "@ui_southeast_shortcut" : Enum.COMPASS_MARK;
   _loc2_.southwest.tField.text = !_loc3_ ? "@ui_southwest_shortcut" : Enum.COMPASS_MARK;
   _loc2_.northwest.tField.text = !_loc3_ ? "@ui_northwest_shortcut" : Enum.COMPASS_MARK;
   _loc2_.northeast.tField.text = !_loc3_ ? "@ui_northeast_shortcut" : Enum.COMPASS_MARK;
   _loc2_.southeast2.tField.text = !_loc3_ ? "@ui_southeast_shortcut" : Enum.COMPASS_MARK;
   _loc2_.southwest2.tField.text = !_loc3_ ? "@ui_southwest_shortcut" : Enum.COMPASS_MARK;
}
function DummyLoadIconSwf()
{
   g_dummyLoader.loadClip("buttons.swf",_root.dummyLoader);
}
function fc_showWatermark(userId)
{
   var _loc3_ = "This build is played by <" + userId + ">. Confidential, do not share!";
   var _loc2_ = "This is beta, visual quality is not representative of the final build.";
   _root.tl.watermark.text = _loc3_;
   _root.br.watermark.text = _loc3_;
   _root.tr.watermark.text = _loc2_;
   _root.bl.watermark.text = _loc2_;
   return userId;
}
function fc_setInputId(InputId)
{
   g_InputId = InputId;
   g_InputIdObservable.Update();
}
function fc_setGameMode(Mode)
{
   g_GameMode = Mode;
   setGameMode();
}
function fc_setGameDude(Dude)
{
   g_GameDude = Dude;
}
function setGameMode()
{
   setCompassNames();
   var _loc2_ = g_GameMode == Enum.GAME_MODE_HARD;
   _root.bc.mc_StatsContainer.qamWeapon._x = !_loc2_ ? -141 : 0;
   _root.bc.mc_StatsContainer.qamFood._x = !_loc2_ ? 141 : 0;
   _root.bc.buffs.leftBuffs._x = !_loc2_ ? Enum.C_BUFF_LEFT_ORIGIN : Enum.C_BUFF_LEFT_ORIGIN_HC;
   _root.bc.buffs.rightBuffs._x = !_loc2_ ? Enum.C_BUFF_RIGHT_ORIGIN : Enum.C_BUFF_RIGHT_ORIGIN_HC;
   g_QAMWeapon.Close(true);
   g_QAMFood.Close(true);
}
function fc_resetAll()
{
   resetCrimeState();
   resetTrespassState();
   resetWantedState();
   resetBuffs();
   resetCommonEvents();
   resetFancyEvents();
   resetGameLog();
   resetItemHint();
   fc_hideTooltip();
   fc_hideQAMArrows();
   fc_hideDraggedAlternate();
   fc_clearSubtitles();
   resetInfoText();
   fc_setActionHints("","","",0,0,0,0,0,0);
   resetTutorial();
   resetItemTransfer();
   resetSkillCheck();
   resetQAM();
   removeShootingContestTable();
   removeDiceScore();
   setGameMode();
   popUpVisual.gotoAndStop(1);
   popUp.gotoAndStop(1);
}
function fc_clearNotificationQueue()
{
   resetItemTransfer();
   resetCommonEvents();
   resetFancyEvents();
}
function fc_resetAfterGameStart()
{
   g_FancyNotifMngr.RemoveAndFlush(Enum.GetPriorityByDiscoveredType(Enum.LOCATION_EVENT));
   resetItemTransfer();
}
function fc_setRatioPreset(preset)
{
   g_RatioPreset = preset;
   var _loc6_ = g_currSizeX / g_currSizeY;
   var _loc10_;
   var _loc4_;
   var _loc3_;
   var _loc5_;
   var _loc7_;
   var _loc9_;
   var _loc8_;
   if(preset == Enum.RATIO_PRESET_APSE || preset == Enum.RATIO_PRESET_DIALOG_EXTENSION)
   {
      _loc10_ = Enum.APSE_HINTSTRIP_HEIGHT * (g_currSizeY / Enum.SCREEN_HEIGHT);
      _loc4_ = Math.min(Enum.APSE_HINTSTRIP_HEIGHT / (Enum.SCREEN_WIDTH / g_currSizeX),_loc10_);
      _loc3_ = _loc4_ / Enum.APSE_HINTSTRIP_HEIGHT * 100;
      _loc5_ = _loc3_ / ratioStrips.bottomStrip._xscale * 100;
      ratioStrips.topStrip.inside.center._yscale = _loc3_;
      ratioStrips.topStrip.inside.left._yscale = _loc3_;
      ratioStrips.topStrip.inside.right._yscale = _loc3_;
      ratioStrips.topStrip.inside.center._xscale = _loc5_;
      ratioStrips.topStrip.inside.left._xscale = _loc5_;
      ratioStrips.topStrip.inside.right._xscale = _loc5_;
      ratioStrips.bottomStrip.inside.center._yscale = _loc3_;
      ratioStrips.bottomStrip.inside.left._yscale = _loc3_;
      ratioStrips.bottomStrip.inside.right._yscale = _loc3_;
      ratioStrips.bottomStrip.inside.center._xscale = _loc5_;
      ratioStrips.bottomStrip.inside.left._xscale = _loc5_;
      ratioStrips.bottomStrip.inside.right._xscale = _loc5_;
      ratioStrips.topStrip.inside.center._y = 0;
      ratioStrips.topStrip.inside.left._y = 0;
      ratioStrips.topStrip.inside.right._y = 0;
      if(preset == Enum.RATIO_PRESET_DIALOG_EXTENSION || _loc6_ >= Enum.SCREEN_MIN_APSE_WIDTH / Enum.SCREEN_MIN_APSE_HEIGHT)
      {
         if(preset == Enum.RATIO_PRESET_DIALOG_EXTENSION)
         {
            ratioStrips.topStrip._y = _loc4_ * 2;
            _loc7_ = (- _loc4_) * 0.5;
            ratioStrips.topStrip.inside.center._y = _loc7_;
            ratioStrips.topStrip.inside.left._y = _loc7_;
            ratioStrips.topStrip.inside.right._y = _loc7_;
         }
         else
         {
            ratioStrips.topStrip._y = _loc4_;
         }
         ratioStrips.bottomStrip._y = g_currSizeY - _loc4_;
      }
      else
      {
         _loc9_ = (g_currSizeY - g_currSizeX * Enum.SCREEN_MIN_APSE_HEIGHT / Enum.SCREEN_MIN_APSE_WIDTH) * 0.5;
         ratioStrips.topStrip._y = _loc9_ + _loc4_;
         ratioStrips.bottomStrip._y = g_currSizeY - _loc4_ - _loc9_;
      }
      ratioStrips.leftStrip._x = 0;
      ratioStrips.rightStrip._x = g_currSizeX;
   }
   else if(preset == Enum.RATIO_PRESET_CUTSCENE || preset == Enum.RATIO_PRESET_DIALOG)
   {
      ratioStrips.topStrip._y = (Enum.CINEMATIC_RATIO - _loc6_) / Enum.CINEMATIC_RATIO * g_currSizeY * 0.5;
      ratioStrips.bottomStrip._y = g_currSizeY - (Enum.CINEMATIC_RATIO - _loc6_) / Enum.CINEMATIC_RATIO * g_currSizeY * 0.5;
      if(preset == Enum.RATIO_PRESET_CUTSCENE)
      {
         _loc8_ = 0.5 * (g_currSizeX - g_currSizeY * Enum.CINEMATIC_RATIO);
         ratioStrips.leftStrip._x = _loc8_;
         ratioStrips.rightStrip._x = g_currSizeX - _loc8_;
      }
      else
      {
         ratioStrips.leftStrip._x = 0;
         ratioStrips.rightStrip._x = g_currSizeX;
      }
   }
   else if(preset == Enum.RATIO_PRESET_MAIN_MENU)
   {
      ratioStrips.topStrip._y = 0;
      ratioStrips.bottomStrip._y = g_currSizeY;
      ratioStrips.leftStrip._x = 0;
      ratioStrips.rightStrip._x = g_currSizeX;
   }
   if((_root.ratioStrips.rightDialog._currentframe == 1 || _root.ratioStrips.rightDialog._currentframe > 20) && preset == Enum.RATIO_PRESET_DIALOG_EXTENSION)
   {
      _root.ratioStrips.rightDialog.gotoAndPlay("show");
   }
   else if(_root.ratioStrips.rightDialog._currentframe > 1 && _root.ratioStrips.rightDialog._currentframe <= 20)
   {
      _root.ratioStrips.rightDialog.gotoAndPlay("hide");
   }
}
function fc_setBubbleText(bubbleId, bubbleText, speakerName, playerDistance)
{
   var _loc8_ = 12;
   var _loc3_ = cccursor.bubbles[Enum.BUBBLE_NAME_CORE + bubbleId];
   var _loc1_ = _loc3_.inside.tfText;
   if(!_loc3_ || bubbleText.length == 0)
   {
      return undefined;
   }
   _loc3_.inside.tfText.text = bubbleText;
   bubbleText = _loc3_.inside.tfText.text;
   bubbleText = stringHelperHandleBreak(bubbleText);
   if(bubbleText == "")
   {
      _loc3_.inside.tfText.text = "";
      setBubblesBackground();
      return undefined;
   }
   var _loc4_;
   var _loc6_;
   var _loc9_;
   if(bubbleText.indexOf("<br/>") == -1)
   {
      if(_loc1_.numLines == 1)
      {
         if(_loc1_.getLineMetrics(0).width > _loc1_._width / 2)
         {
            bubbleText = TextExtension.SplitText2Lines(bubbleText);
         }
      }
      else
      {
         _loc4_ = -1;
         if(_loc1_.getLineMetrics(1).width > _loc1_.getLineMetrics(0).width)
         {
            _loc6_ = _loc1_.getLineText(0);
            _loc9_ = _loc1_.getLineText(1);
            _loc4_ = _loc9_.lastIndexOf(" ",_loc6_.length - _loc8_);
            if(_loc4_ > 0)
            {
               _loc4_ += _loc6_.length;
            }
         }
         else if(_loc1_.getLineMetrics(1).width < _loc1_.getLineMetrics(0).width / 3)
         {
            _loc6_ = _loc1_.getLineText(0);
            _loc4_ = _loc6_.lastIndexOf(" ",_loc6_.length - _loc8_);
         }
         if(_loc4_ > 0)
         {
            bubbleText = TextExtension.SplitText(bubbleText,_loc4_);
         }
      }
   }
   var _loc5_;
   var _loc10_;
   if(g_IsSpeakerNameEnabled && speakerName.length > 0)
   {
      _loc1_.text = speakerName;
      speakerName = _loc1_.text;
      _loc10_ = "<font color=\'" + ColorScheme.DARK_EMPHASIS + "\'>" + speakerName + "</font>";
      _loc5_ = _loc10_ + "\n" + bubbleText;
   }
   else
   {
      _loc5_ = bubbleText;
   }
   TextExtension.setText(_loc5_,_loc1_);
   _loc3_.inside._y = - _loc1_.textHeight;
   _loc3_.swapDepths(Math.floor(10000 + playerDistance * -100));
   setTextSize(_loc1_,g_SpeachFontSize);
   setBubblesBackground();
}
function fc_showGameLog(type, level, text)
{
   g_GameLogNotifMngr.Insert(Enum.GAME_LOG_EVENT,0,Enum.DEFAULT_NOTIFICATION_DURATION,[type,level,text]);
}
function fc_setPlayingGameLogEvent(play, flush)
{
   setPlayingNotificationManager(g_GameLogNotifMngr,play,flush);
}
function resetGameLog()
{
   g_GameLogNotifMngr.RemoveAndFlush();
}
function fc_showItemHint(name, amount, mainStat, health, weight, price, quality, isRepainted)
{
   var _loc2_ = cccursor.actioncursor.ActionCursorOutline;
   _loc2_.up.tfHintFlag.html = true;
   _loc2_.up.tfHintFlag.autoSize = "left";
   _loc2_.up.tfHintFlag.text = name;
   _loc2_.up.iconQuality.gotoAndStop(0);
   var _loc3_ = _loc2_.up.tfHintFlag.textWidth + _loc2_.up.tfHintFlag._x;
   if(quality > 0 || isRepainted)
   {
      _loc3_ += 22;
      _loc2_.up.iconQuality._x = _loc3_;
      _loc2_.up.iconQuality.gotoAndStop(!isRepainted ? 1 + quality : 6);
   }
   _loc3_ += 67;
   if(_loc2_.up.counter > 0)
   {
      _loc2_.up.initWidth = _loc2_.up.currentWidth;
   }
   else
   {
      _loc2_.up.currentWidth = _loc2_.up.initWidth = Enum.C_FLAG_MIN_WIDTH;
   }
   _loc2_.up.finalWidth = _loc3_ - Enum.C_FLAG_START_X;
   _loc2_.up.frames = Math.max(1,Math.round(Math.abs(_loc2_.up.finalWidth - _loc2_.up.initWidth) / Enum.C_FLAG_UP_ONE_FRAME_STEP));
   _loc2_.up.counter = 0;
   updateFlag(_loc2_.up,"top");
   _loc2_.up.onEnterFrame = function()
   {
      this._visible = true;
      this.counter = this.counter + 1;
      updateFlag(this,"top");
      if(this.counter >= this.frames)
      {
         delete this.onEnterFrame;
      }
   };
   var _loc4_;
   if(mainStat == 0 && health == 0 && weight == 0 && price == 0)
   {
      _loc2_.bottom._visible = false;
   }
   else
   {
      _loc3_ = 75;
      _loc2_.bottom._visible = true;
      if(amount <= 1)
      {
         _loc2_.bottom.tfAmount.text = "";
         _loc2_.bottom.iconAmount._visible = false;
      }
      else
      {
         _loc2_.bottom.tfAmount.text = amount;
         _loc2_.bottom.iconAmount._visible = true;
         _loc2_.bottom.iconAmount._x = _loc3_;
         _loc3_ += 10;
         _loc2_.bottom.tfAmount._x = _loc3_;
         _loc3_ += _loc2_.bottom.tfAmount.textWidth + 20;
      }
      if(mainStat <= 0)
      {
         _loc2_.bottom.tfMainStat.text = "";
         _loc2_.bottom.iconMainStat._visible = false;
      }
      else
      {
         _loc2_.bottom.tfMainStat.text = MathExtension.RoundBigNumber(mainStat,0);
         _loc2_.bottom.iconMainStat._visible = true;
         _loc2_.bottom.iconMainStat._x = _loc3_;
         _loc3_ += 10;
         _loc2_.bottom.tfMainStat._x = _loc3_;
         _loc3_ += _loc2_.bottom.tfMainStat.textWidth + 20;
      }
      _loc4_ = MathExtension.RoundBigNumber(health * 100,0) + "<FONT SIZE=\"16\">%</FONT>";
      TextExtension.setText(_loc4_,_loc2_.bottom.tfHealth);
      _loc2_.bottom.tfWeight.text = MathExtension.RoundBigNumber(weight,1);
      _loc2_.bottom.tfPrice.text = MathExtension.RoundBigNumber(price,1,MathExtension.MILION);
      _loc2_.bottom.iconHealth._x = _loc3_;
      _loc3_ += 10;
      _loc2_.bottom.tfHealth._x = _loc3_;
      _loc3_ += _loc2_.bottom.tfHealth.textWidth + 20;
      _loc2_.bottom.iconWeight._x = _loc3_;
      _loc3_ += 10;
      _loc2_.bottom.tfWeight._x = _loc3_;
      _loc3_ += _loc2_.bottom.tfWeight.textWidth + 20;
      _loc2_.bottom.iconPrice._x = _loc3_;
      _loc3_ += 10;
      _loc2_.bottom.tfPrice._x = _loc3_;
      _loc3_ += _loc2_.bottom.tfPrice.textWidth + 40;
      if(_loc2_.bottom.counter > 0)
      {
         _loc2_.bottom.currentWidth = _loc2_.bottom.initWidth + _loc2_.bottom.counter / _loc2_.bottom.frames * (_loc2_.bottom.finalWidth - _loc2_.bottom.initWidth);
         _loc2_.bottom.initWidth = _loc2_.bottom.currentWidth;
         _loc2_.bottom.delay = 0;
      }
      else
      {
         _loc2_.bottom.initWidth = Enum.C_FLAG_BOTTOM_INIT_WIDTH;
         _loc2_.bottom.delay = Enum.C_FLAG_BOTTOM_DELAY;
      }
      _loc2_.bottom.finalWidth = _loc3_ - Enum.C_FLAG_START_X;
      _loc2_.bottom.frames = Math.max(1,Math.round(Math.abs(_loc2_.bottom.finalWidth - _loc2_.bottom.initWidth) / Enum.C_FLAG_BOTTOM_ONE_FRAME_STEP));
      _loc2_.bottom.counter = 0;
      _loc2_.bottom.counter = _loc2_.up.counter;
      updateFlag(_loc2_.bottom,"bottom");
      _loc2_.bottom._visible = false;
      _loc2_.bottom.onEnterFrame = function()
      {
         if(this.delay > 0)
         {
            this.delay = this.delay - 1;
            return undefined;
         }
         this._visible = true;
         this.counter = this.counter + 1;
         updateFlag(this,"bottom");
         if(this.counter >= this.frames)
         {
            delete this.onEnterFrame;
         }
      };
   }
}
function fc_hideItemHint()
{
   var _loc2_ = cccursor.actioncursor.ActionCursorOutline;
   if(_loc2_.up._visible)
   {
      _loc2_.up.initWidth = Enum.C_FLAG_MIN_WIDTH;
      _loc2_.up.finalWidth = _loc2_.up.currentWidth;
      _loc2_.up.frames = Math.max(1,Math.round(Math.abs(_loc2_.up.finalWidth - _loc2_.up.initWidth) / Enum.C_FLAG_UP_ONE_FRAME_STEP));
      _loc2_.up.counter = _loc2_.up.frames;
      _loc2_.up.onEnterFrame = function()
      {
         this.counter = this.counter - 1;
         this.counter = Math.max(0,this.counter);
         updateFlag(this,"top");
         if(this.counter == 0)
         {
            delete this.onEnterFrame;
            this._visible = false;
         }
      };
   }
   else
   {
      delete _loc2_.up.onEnterFrame;
   }
   if(_loc2_.bottom._visible)
   {
      _loc2_.bottom.initWidth = Enum.C_FLAG_BOTTOM_INIT_WIDTH;
      _loc2_.bottom.frames = Math.max(1,Math.min(_loc2_.up.frames,Math.round(Math.abs(_loc2_.bottom.finalWidth - _loc2_.bottom.initWidth) / Enum.C_FLAG_BOTTOM_ONE_FRAME_STEP)));
      _loc2_.bottom.counter = _loc2_.bottom.frames;
      _loc2_.bottom.onEnterFrame = function()
      {
         this.counter = this.counter - 1;
         this.counter = Math.max(0,this.counter);
         updateFlag(this,"bottom");
         if(this.counter == 0)
         {
            delete this.onEnterFrame;
            this._visible = false;
         }
      };
   }
   else
   {
      delete _loc2_.bottom.onEnterFrame;
   }
}
function resetItemHint()
{
   var _loc1_ = cccursor.actioncursor.ActionCursorOutline;
   _loc1_.up._visible = false;
   _loc1_.bottom._visible = false;
}
function updateFlag(flag, name)
{
   flag.currentWidth = flag.initWidth + flag.counter / flag.frames * (flag.finalWidth - flag.initWidth);
   DrawExtension.drawRepetitiveBackground(flag.itemHint,"Textures/item_hint_" + name + "_begin","Textures/item_hint_" + name + "_middle","Textures/item_hint_" + name + "_end",false,2 * flag.currentWidth);
   flag.endScroll._x = flag.currentWidth - Enum.C_FLAG_MASK_CROP_X - flag.endScroll._width + Enum.C_FLAG_START_X;
   flag.mask._width = flag.currentWidth - Enum.C_FLAG_MASK_CROP_WIDTH;
}
function fc_showTooltip(text, x, y)
{
   if(!g_TooltipMC)
   {
      g_TooltipMC = Tooltip.Show(_root,text,x,y,resolutionScale(),g_currSizeX);
   }
}
function fc_updateTooltip(x, y)
{
   if(g_TooltipMC)
   {
      Tooltip.Update(g_TooltipMC,x,y);
   }
}
function fc_hideTooltip()
{
   if(g_TooltipMC)
   {
      Tooltip.Hide(g_TooltipMC);
      g_TooltipMC = null;
   }
}
function fc_showDraggedAlternate(iconPath)
{
   if(!g_DraggedMC)
   {
      g_DraggedMC = _root.attachMovie("mc_DraggedAlternate","draggedAlternate",_root.getNextHighestDepth());
   }
   resolutionScaleMC(g_DraggedMC);
   var _loc3_ = new MovieClipLoader();
   _loc3_.loadClip("img://Libs/UI/Textures/Icons/" + iconPath + "_icon.dds",g_DraggedMC.icon);
   g_DraggedMC._x = _xmouse;
   g_DraggedMC._y = _ymouse;
   g_DraggedMC.icon._alpha = 70;
   g_DraggedMC.onEnterFrame = function()
   {
      this._x = _xmouse;
      this._y = _ymouse;
   };
}
function fc_hideDraggedAlternate()
{
   if(g_DraggedMC)
   {
      g_DraggedMC.removeMovieClip();
   }
}
function fc_setDraggedAlternateState(state)
{
   if(g_DraggedMC)
   {
      g_DraggedMC.icon._alpha = state != Enum.DRAGGED_STATE_ACTIVE ? 70 : 100;
      g_DraggedMC.state.gotoAndStop(state + 1);
   }
}
function fc_showQAMArrows(x, y, isLeft, isRight, isTop, isBottom)
{
   if(!g_QAMArrowsMC)
   {
      g_QAMArrowsMC = _root.attachMovie("mc_QAMArrows","qamArrows",_root.getNextHighestDepth());
   }
   g_QAMArrowsMC._x = x;
   g_QAMArrowsMC._y = y;
   resolutionScaleMC(g_QAMArrowsMC);
   g_QAMArrowsMC.leftArrow._visible = isLeft;
   g_QAMArrowsMC.rightArrow._visible = isRight;
   g_QAMArrowsMC.topArrow._visible = isTop;
   g_QAMArrowsMC.bottomArrow._visible = isBottom;
}
function fc_hideQAMArrows()
{
   if(g_QAMArrowsMC)
   {
      g_QAMArrowsMC.removeMovieClip();
   }
}
function fc_setActionHints(chatName, followName, entityName, separatorBeforeFollow, separatorBeforeEntity, separatorBeforePlayer, chatCategory, followCategory, entityCategory)
{
   g_CgItemHints = {};
   var _loc2_ = 7;
   var _loc12_ = g_ActionHintsA.length / _loc2_;
   var _loc9_ = [];
   _loc9_.push(Enum.NPC_NAME + Enum.NPC_NAME_TYPE_CHAT);
   _loc9_.push(Enum.NPC_NAME + Enum.NPC_NAME_TYPE_FOLLOW);
   _loc9_.push(Enum.NPC_NAME + Enum.NPC_NAME_TYPE_ENTITY);
   _loc9_.push(Enum.SEPARATOR + Enum.SEPARATOR_TYPE_FOLLOW);
   _loc9_.push(Enum.SEPARATOR + Enum.SEPARATOR_TYPE_ENTITY);
   _loc9_.push(Enum.SEPARATOR + Enum.SEPARATOR_TYPE_PLAYER);
   var _loc1_ = 0;
   var _loc3_;
   var _loc8_;
   var _loc10_;
   var _loc7_;
   var _loc5_;
   var _loc6_;
   var _loc11_;
   var _loc4_;
   while(_loc1_ < _loc12_)
   {
      _loc3_ = g_ActionHintsA[_loc1_ * _loc2_];
      _loc8_ = g_ActionHintsA[_loc1_ * _loc2_ + 1];
      _loc10_ = g_ActionHintsA[_loc1_ * _loc2_ + 2];
      _loc7_ = g_ActionHintsA[_loc1_ * _loc2_ + 3];
      _loc5_ = g_ActionHintsA[_loc1_ * _loc2_ + 4];
      _loc6_ = g_ActionHintsA[_loc1_ * _loc2_ + 5];
      _loc11_ = g_ActionHintsA[_loc1_ * _loc2_ + 6];
      if(cgIsItemHint(_loc3_,_loc7_,_loc10_))
      {
         cgRememberItemHint(_loc3_,_loc10_,_loc11_,[_loc8_,_loc7_,_loc5_,_loc6_]);
         if(cgOnTitleRow() && !g_CgOtherScreen)
         {
            _loc1_ = _loc1_ + 1;
            continue;
         }
      }
      if(cgIsCloseHint(_loc3_,_loc7_,_loc10_))
      {
         g_CgCloseId = _loc3_;
         g_CgCloseClass = _loc10_;
         g_CgCloseData = [_loc8_,_loc7_,_loc5_,_loc6_];
         _loc5_ = cgCloseText(_loc5_);
      }
      _loc9_.push(_loc3_);
      _loc4_ = getActionHintMngrByClass(_loc10_);
      if(_loc4_.Contain(_loc3_))
      {
         _loc4_.Change(_loc3_,[_loc8_,_loc7_,_loc5_,_loc6_]);
         if(_loc4_ == g_ApseTopCenterActionHintNotifMngr && g_RatioPreset == Enum.RATIO_PRESET_DIALOG_EXTENSION)
         {
            g_ApseTopCenterActionHintNotifMngr.UpdateHighlighter();
         }
      }
      else
      {
         _loc4_.Insert(_loc3_,_loc11_,-1,[_loc8_,_loc7_,_loc5_,_loc6_]);
      }
      _loc1_ = _loc1_ + 1;
   }
   cgApplyHints(_loc9_);
   g_ApseTopLeftActionHintNotifMngr.RemoveExcept(_loc9_,NotificationManager.E_REMOVE_HIDE);
   g_ApseTopRightActionHintNotifMngr.RemoveExcept(_loc9_,NotificationManager.E_REMOVE_HIDE);
   g_ApseBottomLeftActionHintNotifMngr.RemoveExcept(_loc9_,NotificationManager.E_REMOVE_HIDE);
   g_ApseTopCenterActionHintNotifMngr.RemoveExcept(_loc9_,NotificationManager.E_REMOVE_HIDE);
   g_ApseBottomCenterActionHintNotifMngr.RemoveExcept(_loc9_,NotificationManager.E_REMOVE_HIDE);
   g_ApseBottomRightActionHintNotifMngr.RemoveExcept(_loc9_,NotificationManager.E_REMOVE_HIDE);
   g_ActionHintNotifMngr.RemoveExcept(_loc9_,NotificationManager.E_REMOVE_HIDE);
   setNpcName(Enum.NPC_NAME_TYPE_CHAT,chatCategory != Enum.ENTITY_DOG ? Enum.NPC_NAME_TYPE_CHAT : Enum.NPC_NAME_TYPE_DOG,chatName);
   setNpcName(Enum.NPC_NAME_TYPE_FOLLOW,followCategory != Enum.ENTITY_DOG ? Enum.NPC_NAME_TYPE_FOLLOW : Enum.NPC_NAME_TYPE_DOG,followName);
   setNpcName(Enum.NPC_NAME_TYPE_ENTITY,entityCategory != Enum.ENTITY_DOG ? Enum.NPC_NAME_TYPE_ENTITY : Enum.NPC_NAME_TYPE_DOG,entityName);
   setSeparator(Enum.SEPARATOR_TYPE_FOLLOW,separatorBeforeFollow);
   setSeparator(Enum.SEPARATOR_TYPE_ENTITY,separatorBeforeEntity);
   setSeparator(Enum.SEPARATOR_TYPE_PLAYER,separatorBeforePlayer);
   g_ActionHintsA.length = 0;
   setActionHintsPosition();
}
var CG_TEXT_EXPAND = "Expand";
var CG_TEXT_COLLAPSE = "Collapse";
var CG_TEXT_EXPAND_ALL = "Expand all";
var CG_TEXT_COLLAPSE_ALL = "Collapse all";
var g_CgMode = "none";
var g_CgFlat = false;
var g_CgNoGroups = false;
var g_CgOtherScreen = false;
function cgLeftMngr()
{
   return !g_CgOtherScreen ? g_ApseBottomLeftActionHintNotifMngr : g_ActionHintNotifMngr;
}
function cgCenterMngr()
{
   return !g_CgOtherScreen ? g_ApseBottomCenterActionHintNotifMngr : g_ActionHintNotifMngr;
}
function cgRemoveAll()
{
   var mngrs = [g_ApseBottomLeftActionHintNotifMngr,g_ApseBottomCenterActionHintNotifMngr,g_ActionHintNotifMngr];
   var ids = ["cg_expand","cg_collapse","cg_expand_all"];
   var i = 0;
   var j;
   while(i < mngrs.length)
   {
      j = 0;
      while(j < ids.length)
      {
         if(mngrs[i].Contain(ids[j]))
         {
            mngrs[i].Remove(ids[j],NotificationManager.E_REMOVE_HIDE);
         }
         j = j + 1;
      }
      i = i + 1;
   }
}
var g_CgCloseId = null;
var g_CgCloseClass = null;
var g_CgCloseData = null;
var g_CgItemHints = {};
function cgOnTitleRow()
{
   return g_CgMode == "group" || g_CgMode == "groupopen";
}
function cgRememberItemHint(id, hintClass, order, data)
{
   var o = {};
   o.cls = hintClass;
   o.order = order;
   o.data = data;
   g_CgItemHints[id] = o;
}
function cgShowItemHints(show)
{
   var id;
   var o;
   var mngr;
   for(id in g_CgItemHints)
   {
      o = g_CgItemHints[id];
      mngr = getActionHintMngrByClass(o.cls);
      if(mngr == undefined)
      {
         continue;
      }
      if(!show && mngr.Contain(id))
      {
         mngr.Remove(id,NotificationManager.E_REMOVE_HIDE);
      }
      else if(show && !mngr.Contain(id))
      {
         mngr.Insert(id,o.order,-1,o.data);
      }
   }
}
function cgIsItemHint(id, control, hintClass)
{
   if(hintClass != Enum.HINT_CLASS_APSE_BOTTOM_LEFT && hintClass != Enum.HINT_CLASS_APSE_BOTTOM_CENTER && hintClass != Enum.HINT_CLASS_APSE_BOTTOM_RIGHT)
   {
      return false;
   }
   if(control == undefined || control < 0)
   {
      return false;
   }
   var names = ["action","secondary_action","move_item","drop_item"];
   var i = 0;
   var b;
   while(i < names.length)
   {
      b = ActionButton.getButtonId(names[i]);
      if(b != undefined && b >= 0 && b == control)
      {
         return true;
      }
      i = i + 1;
   }
   return false;
}
function cgOnKeyboard()
{
   return _root.g_InputId == ControlsEnum.E_INPUT_KEYBOARD;
}
function cgInsideGroup()
{
   return g_CgMode == "member" || g_CgMode == "groupopen";
}
function cgIsCloseHint(id, control, hintClass)
{
   if(id == "close" || (g_CgCloseId != null && id == g_CgCloseId))
   {
      return true;
   }
   return hintClass == Enum.HINT_CLASS_APSE_BOTTOM_RIGHT && control >= 0 && control == ActionButton.getButtonId("close");
}
function cgCloseText(engineText)
{
   if(cgInsideGroup() && !cgOnKeyboard())
   {
      return CG_TEXT_COLLAPSE;
   }
   return engineText;
}
function cgCollapseKey()
{
   var btn = ActionButton.getButtonId("companion_bond");
   if(btn == undefined || btn < 0)
   {
      btn = ActionButton.getButtonId("toggle_category");
   }
   return btn;
}
function cgSetHint(mngr, id, order, control, text, wanted, keepA)
{
   var data;
   if(wanted)
   {
      data = [0,control,text,Enum.UNDEFINED_CONTROL];
      if(mngr.Contain(id))
      {
         mngr.Change(id,data);
      }
      else
      {
         mngr.Insert(id,order,-1,data);
      }
      if(keepA != undefined)
      {
         keepA.push(id);
      }
   }
   else if(mngr.Contain(id))
   {
      mngr.Remove(id,NotificationManager.E_REMOVE_HIDE);
   }
}
function cgExpandAllHint(keepA)
{
   var kb = cgOnKeyboard();
   var control = kb ? ActionButton.getButtonId("distract_init") : ActionButton.getButtonId("next_outfit");
   var wanted = g_CgMode != "none" && !g_CgNoGroups;
   var mngr = cgLeftMngr();
   var data;
   if(wanted)
   {
      data = [!kb ? Enum.HINT_HOLD : 0,control,!g_CgFlat ? CG_TEXT_EXPAND_ALL : CG_TEXT_COLLAPSE_ALL,Enum.UNDEFINED_CONTROL];
      if(mngr.Contain("cg_expand_all"))
      {
         mngr.Change("cg_expand_all",data);
      }
      else
      {
         mngr.Insert("cg_expand_all",8,-1,data);
      }
      if(keepA != undefined)
      {
         keepA.push("cg_expand_all");
      }
   }
   else if(mngr.Contain("cg_expand_all"))
   {
      mngr.Remove("cg_expand_all",NotificationManager.E_REMOVE_HIDE);
   }
}
function cgApplyHints(keepA)
{
   cgExpandAllHint(keepA);
   var onGroup = g_CgMode == "group" || g_CgMode == "groupopen";
   cgSetHint(cgLeftMngr(),"cg_expand",10,ActionButton.getButtonId("action"),g_CgMode != "group" ? CG_TEXT_COLLAPSE : CG_TEXT_EXPAND,onGroup,keepA);
   cgSetHint(cgCenterMngr(),"cg_collapse",50,cgCollapseKey(),CG_TEXT_COLLAPSE,cgInsideGroup() && cgOnKeyboard(),keepA);
}
var g_CgHoldIv;
var g_CgHoldAt;
function fc_cgHold(state)
{
   if(g_CgHoldIv != undefined)
   {
      clearInterval(g_CgHoldIv);
      g_CgHoldIv = undefined;
   }
   if(state == "start")
   {
      g_CgHoldAt = getTimer();
      g_CgHoldIv = setInterval(cgHoldTick,33);
      cgHoldTick();
   }
   else
   {
      cgLeftMngr().SetHoldProgress("cg_expand_all",0);
   }
}
function cgHoldTick()
{
   var pct = (getTimer() - g_CgHoldAt) / 22.5;
   if(pct >= 100)
   {
      pct = 100;
      clearInterval(g_CgHoldIv);
      g_CgHoldIv = undefined;
   }
   cgLeftMngr().SetHoldProgress("cg_expand_all",pct);
}
function fc_cgSetMode(mode)
{
   var flat = mode.indexOf(":flat") >= 0;
   var noGroups = mode.indexOf(":ng") >= 0;
   var other = mode.indexOf(":t") >= 0;
   var cut = mode.indexOf(":");
   if(cut >= 0)
   {
      mode = mode.substring(0,cut);
   }
   if(mode != "group" && mode != "groupopen" && mode != "member" && mode != "item")
   {
      mode = "none";
   }
   if(mode == g_CgMode && flat == g_CgFlat && noGroups == g_CgNoGroups && other == g_CgOtherScreen)
   {
      return undefined;
   }
   if(other != g_CgOtherScreen)
   {
      cgRemoveAll();
      g_CgOtherScreen = other;
   }
   var wasTitle = cgOnTitleRow();
   g_CgMode = mode;
   g_CgFlat = flat;
   g_CgNoGroups = noGroups;
   if(wasTitle != cgOnTitleRow() && !g_CgOtherScreen && g_CgMode != "none")
   {
      cgShowItemHints(!cgOnTitleRow());
   }
   cgApplyHints(undefined);
   var mngr;
   if(g_CgCloseId != null)
   {
      mngr = getActionHintMngrByClass(g_CgCloseClass);
      if(mngr.Contain(g_CgCloseId))
      {
         mngr.Change(g_CgCloseId,[g_CgCloseData[0],g_CgCloseData[1],cgCloseText(g_CgCloseData[2]),g_CgCloseData[3]]);
      }
   }
   setActionHintsPosition();
}
function fc_setProgress(val, actionId, hintClass)
{
   var _loc1_ = getActionHintMngrByClass(hintClass);
   _loc1_.SetHoldProgress(actionId,val);
}
function setNpcName(idNum, type, name)
{
   var _loc1_ = Enum.NPC_NAME + idNum;
   var _loc3_;
   if(g_ActionHintNotifMngr.Contain(_loc1_))
   {
      _loc3_ = g_ActionHintNotifMngr.Remove(_loc1_,NotificationManager.E_REMOVE_HIDE);
   }
   if(name != "")
   {
      g_ActionHintNotifMngr.Insert(_loc1_,Enum.GetNpcNameOrderByType(idNum),-1,[name,type]);
   }
}
function setSeparator(type, style)
{
   var _loc1_ = Enum.SEPARATOR + type;
   if(g_ActionHintNotifMngr.Contain(_loc1_))
   {
      if(style == Enum.SEPARATOR_STYLE_NONE)
      {
         g_ActionHintNotifMngr.Remove(_loc1_,NotificationManager.E_REMOVE_HIDE);
      }
      else
      {
         g_ActionHintNotifMngr.Change(_loc1_,[style]);
      }
   }
   else if(style != Enum.SEPARATOR_STYLE_NONE)
   {
      g_ActionHintNotifMngr.Insert(_loc1_,Enum.GetSeparatorOrderByType(type),-1,[style]);
   }
}
function getActionHintMngrByClass(hintClass)
{
   switch(hintClass)
   {
      case Enum.HINT_CLASS_APSE_TOP_LEFT:
         return g_ApseTopLeftActionHintNotifMngr;
      case Enum.HINT_CLASS_APSE_TOP_RIGHT:
         return g_ApseTopRightActionHintNotifMngr;
      case Enum.HINT_CLASS_APSE_BOTTOM_LEFT:
         return g_ApseBottomLeftActionHintNotifMngr;
      case Enum.HINT_CLASS_APSE_TOP_CENTER:
         return g_ApseTopCenterActionHintNotifMngr;
      case Enum.HINT_CLASS_APSE_BOTTOM_CENTER:
         return g_ApseBottomCenterActionHintNotifMngr;
      case Enum.HINT_CLASS_APSE_BOTTOM_RIGHT:
         return g_ApseBottomRightActionHintNotifMngr;
      case Enum.HINT_CLASS_BASIC:
      default:
         return g_ActionHintNotifMngr;
   }
}
function repositionApseCenterActionHints()
{
   var _loc3_ = g_ApseTopCenterActionHintNotifMngr.GetWidth() + 80;
   _loc3_ *= _root.ratioStrips.topStrip.inside.center._xscale / 100;
   _root.ratioStrips.topStrip.inside.center._x = (- _loc3_) / 2;
   var _loc2_ = g_ApseBottomCenterActionHintNotifMngr.GetWidth() + 80;
   _loc2_ *= _root.ratioStrips.bottomStrip.inside.center._xscale / 100;
   _root.ratioStrips.bottomStrip.inside.center._x = _loc2_ / 2;
   if(g_RatioPreset == Enum.RATIO_PRESET_DIALOG_EXTENSION)
   {
      g_ApseTopCenterActionHintNotifMngr.UpdateHighlighter();
   }
   else
   {
      g_ApseTopCenterActionHintNotifMngr.ClearHighlighter();
   }
}
function setActionHintsPosition()
{
   var _loc3_ = 86;
   var _loc2_ = 20;
   var _loc1_ = getBottomStripPosition();
   if(g_RatioPreset == Enum.RATIO_PRESET_DIALOG)
   {
      br.actionHints._y = - _loc2_;
   }
   else if(g_RatioPreset == Enum.RATIO_PRESET_CUTSCENE)
   {
      _loc1_ = getBottomStripPosition();
      if(_loc1_ > _loc3_ + _loc2_)
      {
         br.actionHints._y = - Math.floor((_loc1_ - _loc3_) / 2);
      }
      else
      {
         br.actionHints._y = - _loc1_ - _loc2_;
      }
   }
   else
   {
      br.actionHints._y = -120;
   }
}
function fc_addCompassMarker(markerId, markerType, markerState, questColor, objectiveNumber, distance, angle, isInsideArea, isInsideArea2D, nearThreshold, layerThreshold, farThreshold)
{
   if(g_MarkersO[Enum.MARKER + markerId])
   {
      return undefined;
   }
   var _loc2_ = new CompassMarker(markerId,_root.tc.compass,markerType,markerState,angle,distance,nearThreshold,layerThreshold,farThreshold,questColor,objectiveNumber,isInsideArea,isInsideArea || isInsideArea2D);
   _loc2_.CreateMC(true);
   updateAreaEffect(!_loc2_.IsInside ? 0 : 1,!_loc2_.IsLocked ? 0 : 1);
   g_MarkersO[Enum.MARKER + markerId] = _loc2_;
}
function fc_removeCompassMarker(markerId)
{
   var _loc1_ = g_MarkersO[Enum.MARKER + markerId];
   if(_loc1_)
   {
      _loc1_.RemoveMC(true);
      updateAreaEffect(!_loc1_.IsInside ? 0 : -1,!_loc1_.IsLocked ? 0 : -1);
      delete g_MarkersO[Enum.MARKER + markerId];
   }
}
function fc_changeCompassMarkerState(markerId, markerState)
{
   var _loc1_ = g_MarkersO[Enum.MARKER + markerId];
   if(_loc1_)
   {
      _loc1_.ChangeState(markerState);
   }
}
function fc_resetCompassMarkers()
{
   for(var _loc1_ in g_MarkersO)
   {
      g_MarkersO[_loc1_].RemoveMC(false);
   }
   g_MarkersO = {};
   g_QuestAreaCounter = 0;
   g_QuestLockedCounter = 0;
   tc.compass.fillQuestArea.gotoAndStop(1);
}
function fc_updateCompass(angle)
{
   tc.compass.compassStrip.gotoAndStop(angle);
   tc.compass.compassMarkersOver.gotoAndStop(angle);
   tc.compass.compassMarkersUnder.gotoAndStop(angle);
   updateCompassMarkers(angle);
}
function updateCompassMarkers(currentAngle)
{
   var _loc3_ = 0;
   var _loc20_ = g_CompassMarkersA[_loc3_++];
   var _loc11_ = 0;
   var _loc9_;
   var _loc16_;
   var _loc10_;
   var _loc14_;
   var _loc5_;
   var _loc18_;
   var _loc7_;
   var _loc4_;
   var _loc15_;
   var _loc17_;
   while(_loc11_ < _loc20_)
   {
      _loc9_ = g_CompassMarkersA[_loc3_++];
      _loc3_ = _loc3_ + 1;
      _loc16_ = g_CompassMarkersA[_loc3_++];
      _loc10_ = g_CompassMarkersA[_loc3_++];
      _loc14_ = g_CompassMarkersA[_loc3_++];
      _loc5_ = g_CompassMarkersA[_loc3_++];
      _loc18_ = g_CompassMarkersA[_loc3_++];
      _loc3_ = _loc3_ + 1;
      _loc7_ = _loc5_ || _loc18_;
      if(g_MarkersO[Enum.MARKER + _loc9_])
      {
         _loc4_ = g_MarkersO[Enum.MARKER + _loc9_];
         _loc15_ = !(_loc5_ && !_loc4_.IsInside) ? (!(!_loc5_ && _loc4_.IsInside) ? 0 : -1) : 1;
         _loc17_ = !(_loc7_ && !_loc4_.IsLocked) ? (!(!_loc7_ && _loc4_.IsLocked) ? 0 : -1) : 1;
         updateAreaEffect(_loc15_,_loc17_);
         _loc4_.Update(_loc10_,_loc14_,_loc16_,_loc5_,_loc7_);
      }
      _loc11_ = _loc11_ + 1;
   }
   g_CompassMarkersA.length = 0;
   var _loc19_ = 0;
   var _loc2_ = 5;
   var _loc6_ = -2;
   var _loc13_;
   var _loc8_;
   var _loc1_;
   for(var _loc21_ in g_MarkersO)
   {
      _loc4_ = g_MarkersO[_loc21_];
      if(_loc4_.IsLocked)
      {
         _loc13_ = 25;
         _loc10_ = currentAngle + 90 - (g_QuestLockedCounter - 1) * _loc13_ * 0.5 + _loc19_ * _loc13_;
         _loc19_ = _loc19_ + 1;
      }
      else
      {
         _loc10_ = _loc4_.Angle;
      }
      _loc8_ = 2 * _loc10_;
      _loc1_ = _loc10_ - currentAngle;
      if(_loc1_ >= _loc2_ + _loc6_ && _loc1_ <= 180 - _loc2_ || _loc1_ <= -180 - _loc2_ && _loc1_ >= -360 + _loc2_ + _loc6_)
      {
         if(_loc1_ > 0)
         {
            _loc4_.SetPos(_loc8_);
         }
         else
         {
            _loc4_.SetPos(_loc8_ + 720);
         }
      }
      else if(_loc1_ > 180 - _loc2_ && _loc1_ <= 270 || _loc1_ > -180 - _loc2_ && _loc1_ <= -90)
      {
         _loc4_.SetPos(2 * (currentAngle - _loc2_ + 180));
      }
      else if(_loc1_ > 270 || _loc1_ > -90 && _loc1_ < _loc2_ + _loc6_ || _loc1_ < -360 + _loc2_ + _loc6_)
      {
         _loc4_.SetPos(2 * (currentAngle + _loc2_ + _loc6_));
      }
   }
}
function updateAreaEffect(changeInside, changeLocked)
{
   g_QuestAreaCounter += changeInside;
   g_QuestLockedCounter += changeLocked;
   tc.compass.fillQuestArea.gotoAndStop(g_QuestAreaCounter != 0 ? 2 : 1);
   if(changeInside == 1)
   {
      if(!g_CooldownManager.Evaluate("questAreaEntry",60000))
      {
         Audio.Play(Audio.QUEST_AREA_ENTRY);
      }
   }
}
function fc_setDialogSequences(isOnRightSide)
{
   hideDialog(!isOnRightSide ? Enum.DIALOG_LEFT_DIALOG : Enum.DIALOG_RIGHT_DIALOG);
   var _loc8_ = !isOnRightSide ? _root.cl.interactiveDialog.sequences.content : _root.cr.interactiveDialog.sequences.content;
   var _loc6_ = 5;
   var _loc2_ = 0;
   var _loc3_;
   var _loc4_;
   while(_loc2_ * _loc6_ < g_SequencesA.length)
   {
      _loc3_ = _loc2_ * _loc6_;
      _loc4_ = new DialogSequence(_loc2_,_loc8_,isOnRightSide,g_SequencesA[_loc3_],g_SequencesA[_loc3_ + 1],g_SequencesA[_loc3_ + 2],g_SequencesA[_loc3_ + 3],g_SequencesA[_loc3_ + 4]);
      g_DialogSequencesA.push(_loc4_);
      _loc2_ = _loc2_ + 1;
   }
   g_SequencesA.length = 0;
   _loc8_._y = 0;
   g_DialogSequencesA[0].Select(true);
   g_DialogSequenceSelected = 0;
   var _loc5_ = 0;
   _loc2_ = 0;
   while(_loc2_ < g_DialogSequencesA.length)
   {
      g_DialogSequencesA[_loc2_].SetY(_loc5_);
      _loc5_ += g_DialogSequencesA[_loc2_].GetHeight();
      _loc2_ = _loc2_ + 1;
   }
   showDialog(!isOnRightSide ? Enum.DIALOG_LEFT_DIALOG : Enum.DIALOG_RIGHT_DIALOG);
   updateDialogPosition();
}
function fc_activeSequenceChanged(index, stopper)
{
   var _loc1_;
   if(g_DialogState == Enum.DIALOG_RIGHT_DIALOG || g_DialogState == Enum.DIALOG_LEFT_DIALOG || g_DialogState == Enum.DIALOG_BARBER || g_DialogState == Enum.DIALOG_SHIELDS || g_DialogState == Enum.DIALOG_FORGE)
   {
      g_DialogSequencesA[g_DialogSequenceSelected].Select(false);
      g_DialogSequencesA[index].Select(true);
      g_DialogSequenceSelected = index;
      updateDialogPosition();
      if(g_DialogState == Enum.DIALOG_RIGHT_DIALOG || g_DialogState == Enum.DIALOG_LEFT_DIALOG)
      {
         _loc1_ = 0;
         while(_loc1_ < g_DialogSequencesA.length)
         {
            g_DialogSequencesA[_loc1_].UpdateChatButtonAfterChangeSelect(g_DialogSequenceSelected == 0);
            _loc1_ = _loc1_ + 1;
         }
      }
   }
   else if(g_DialogState == Enum.DIALOG_RIGHT_HAGGLE || g_DialogState == Enum.DIALOG_LEFT_HAGGLE)
   {
      g_DialogHaggle.SetPosition(index,stopper);
      if(stopper == Enum.HAGGLE_OVER_PLAYER)
      {
         g_InfoTextNotifMngr.Insert("NotEnoughMoneyYou",1,NotificationManager.C_DURATION_DEFAULT_MARKER,[Enum.LOCALIZABLE_TOKEN + "ui_NotEnoughMoneyYou",false]);
      }
      else if(stopper == Enum.HAGGLE_OVER_TRADER)
      {
         g_InfoTextNotifMngr.Insert("NotEnoughMoneyTrader",1,NotificationManager.C_DURATION_DEFAULT_MARKER,[Enum.LOCALIZABLE_TOKEN + "ui_NotEnoughMoneyTrader",false]);
      }
   }
}
function fc_enableSequenceChanged(index, isEnable)
{
   if(g_DialogState == Enum.DIALOG_RIGHT_DIALOG || g_DialogState == Enum.DIALOG_LEFT_DIALOG)
   {
      g_DialogSequencesA[index].SetEnable(isEnable);
   }
}
function fc_clearDialogSequences()
{
   if(g_DialogState == Enum.DIALOG_RIGHT_HAGGLE || g_DialogState == Enum.DIALOG_LEFT_HAGGLE || g_DialogState == Enum.DIALOG_RIGHT_DIALOG || g_DialogState == Enum.DIALOG_LEFT_DIALOG)
   {
      clearDialogSequences();
   }
}
function clearDialogSequences()
{
   if(g_DialogState == Enum.DIALOG_HIDE)
   {
      return undefined;
   }
   hideTutorialInDialog();
   if(Enum.IsDialogOnRightSide(g_DialogState))
   {
      _root.cr.gotoAndPlay("off");
   }
   else
   {
      _root.cl.gotoAndPlay("off");
   }
   var _loc2_;
   if(g_DialogState == Enum.DIALOG_RIGHT_HAGGLE || g_DialogState == Enum.DIALOG_LEFT_HAGGLE)
   {
      g_DialogHaggle.Remove();
      g_DialogHaggle = undefined;
   }
   else
   {
      _loc2_ = 0;
      while(_loc2_ < g_DialogSequencesA.length)
      {
         g_DialogSequencesA[_loc2_].Remove();
         _loc2_ = _loc2_ + 1;
      }
      g_DialogSequencesA.length = 0;
   }
   if(g_DialogState == Enum.DIALOG_FORGE && _root.bbc.infoHolder.infoContainer)
   {
      _root.bbc.infoHolder.infoContainer.removeMovieClip();
      delete g_ForgeInfoMoneyTextExtension;
      delete g_ForgeInfoPrestigeTextExtension;
   }
   g_DialogState = Enum.DIALOG_HIDE;
}
function hideDialog(dialogState)
{
   if(g_DialogState == Enum.DIALOG_HIDE)
   {
      return undefined;
   }
   hideTutorialInDialog();
   if(dialogState != g_DialogState)
   {
      if(Enum.IsDialogOnRightSide(g_DialogState))
      {
         _root.cr.gotoAndPlay("off");
      }
      else
      {
         _root.cl.gotoAndPlay("off");
      }
   }
   if(g_DialogState == Enum.DIALOG_RIGHT_HAGGLE || g_DialogState == Enum.DIALOG_LEFT_HAGGLE)
   {
      g_DialogHaggle.Remove();
      g_DialogHaggle = undefined;
   }
   else
   {
      removeDialogSequences();
   }
}
function showDialog(dialogState)
{
   g_DialogState = dialogState;
   if(Enum.IsDialogOnRightSide(g_DialogState))
   {
      _root.cr.gotoAndPlay("on");
   }
   else
   {
      _root.cl.gotoAndPlay("on");
   }
   showTutorialInDialog();
}
function fc_setDialogShiftMovieClips(enable)
{
   _root.bl.itemTransfer._y = !enable ? Enum.ITEM_TRANSFER_Y_BASIC : Enum.ITEM_TRANSFER_Y_DIALOG;
}
function fc_showMoney(money)
{
   if(!isDialogIconsNotifMngr())
   {
      return undefined;
   }
   if(!getDialogIconsNotifMngr().Contain(Enum.DIALOG_ICON_MONEY))
   {
      getDialogIconsNotifMngr().Insert(Enum.DIALOG_ICON_MONEY,Enum.DIALOG_ICON_MONEY_PRIORITY,-1,[money]);
      updateDialogPosition();
   }
   else
   {
      getDialogIconsNotifMngr().Change(Enum.DIALOG_ICON_MONEY,[money]);
   }
}
function fc_hideMoney()
{
   if(!isDialogIconsNotifMngr())
   {
      return undefined;
   }
   if(getDialogIconsNotifMngr().Contain(Enum.DIALOG_ICON_MONEY))
   {
      getDialogIconsNotifMngr().Remove(Enum.DIALOG_ICON_MONEY,NotificationManager.E_REMOVE_HIDE);
   }
   updateDialogPosition();
}
function fc_setDialogTimeLimit()
{
   if(!isDialogIconsNotifMngr())
   {
      return undefined;
   }
   getDialogIconsNotifMngr().Insert(Enum.DIALOG_ICON_TIME,Enum.DIALOG_ICON_TIME_PRIORITY,-1,[0]);
   updateDialogPosition();
}
function fc_updateDialogTimeLimit(limit)
{
   limit = 1 - limit;
   getDialogIconsNotifMngr().Change(Enum.DIALOG_ICON_TIME,[limit]);
}
function fc_clearDialogTimeLimit()
{
   if(!isDialogIconsNotifMngr())
   {
      return undefined;
   }
   if(getDialogIconsNotifMngr().Contain(Enum.DIALOG_ICON_TIME))
   {
      getDialogIconsNotifMngr().Remove(Enum.DIALOG_ICON_TIME,NotificationManager.E_REMOVE_HIDE);
   }
   updateDialogPosition();
}
function fc_setSkillChecks(reputation)
{
   if(!isDialogIconsNotifMngr())
   {
      return undefined;
   }
   var _loc4_ = getDialogIconsNotifMngr();
   if(reputation != undefined)
   {
      _loc4_.Insert(Enum.DIALOG_ICON_REPUTATION,Enum.DIALOG_ICON_REPUTATION_PRIORITY,-1,[reputation]);
      updateDialogPosition();
   }
   var _loc5_ = g_SkillChecksA.length / 2;
   var _loc2_ = 0;
   var _loc1_;
   var _loc3_;
   while(_loc2_ < _loc5_)
   {
      _loc1_ = g_SkillChecksA[_loc2_ * 2];
      _loc3_ = g_SkillChecksA[_loc2_ * 2 + 1];
      if(_loc4_.Contain(_loc1_))
      {
         _loc4_.Change(_loc1_,[_loc1_,_loc3_]);
      }
      else
      {
         _loc4_.Insert(_loc1_,Enum.DIALOG_ICON_SKILLCHECK_PRIORITY,-1,[_loc1_,_loc3_]);
      }
      _loc2_ = _loc2_ + 1;
   }
   g_SkillChecksA.length = 0;
   updateDialogPosition();
}
function fc_clearSkillChecks()
{
   if(!isDialogIconsNotifMngr())
   {
      return undefined;
   }
   getDialogIconsNotifMngr().RemoveAndFlush();
   updateDialogPosition();
}
function removeDialogSequences()
{
   var _loc1_ = 0;
   while(_loc1_ < g_DialogSequencesA.length)
   {
      g_DialogSequencesA[_loc1_].Remove();
      _loc1_ = _loc1_ + 1;
   }
   g_DialogSequencesA.length = 0;
}
function getDialogIconsNotifMngr()
{
   if(g_DialogState == Enum.DIALOG_RIGHT_DIALOG || g_DialogState == Enum.DIALOG_FORGE)
   {
      return g_DialogIconRightNotifMngr;
   }
   if(g_DialogState == Enum.DIALOG_LEFT_DIALOG)
   {
      return g_DialogIconLeftNotifMngr;
   }
   DebugTrace.log("g_DialogState in invalid state: " + g_DialogState,DebugTrace.C_WARRNING,"getDialogIconsNotifMngr");
   return undefined;
}
function isDialogIconsNotifMngr()
{
   return g_DialogState == Enum.DIALOG_RIGHT_DIALOG || g_DialogState == Enum.DIALOG_LEFT_DIALOG || g_DialogState == Enum.DIALOG_FORGE;
}
function updateDialogPosition()
{
   if(g_DialogState == Enum.DIALOG_HIDE)
   {
      return undefined;
   }
   var _loc3_ = !Enum.IsDialogOnRightSide(g_DialogState) ? _root.cl.interactiveDialog : _root.cr.interactiveDialog;
   var _loc8_ = isDialogIconsNotifMngr() && !getDialogIconsNotifMngr().IsEmpty;
   var _loc7_ = !_loc8_ ? 0 : Enum.C_DIALOG_ICONS_HEIGHT;
   var _loc6_ = (!_loc8_ ? Enum.C_DIALOG_SEQUENCE_COUNT : Enum.C_DIALOG_SEQUENCE_COUNT_WITH_ICON) * Enum.C_DEFAULT_SEQUENCE_HEIGHT;
   _loc3_.sequences.mask._height = _loc6_;
   var _loc4_ = 0;
   var _loc2_ = 0;
   while(_loc2_ < g_DialogSequencesA.length)
   {
      _loc4_ += g_DialogSequencesA[_loc2_].GetHeight();
      _loc2_ = _loc2_ + 1;
   }
   var _loc5_;
   if(_loc4_ > _loc6_)
   {
      _loc3_.sequences._y = _loc7_ - (_loc6_ + _loc7_) * 0.5;
      _loc3_.icons._y = _loc3_.sequences._y - _loc7_;
      _loc3_.sequences.lineUp._visible = true;
      _loc3_.sequences.lineDown._visible = true;
      _loc3_.sequences.lineDown._y = _loc6_ - 4;
      _loc5_ = g_DialogSequencesA[g_DialogSequenceSelected];
      if(_loc5_.GetY() + _loc3_.sequences.content._y < 0)
      {
         _loc3_.sequences.content._y = - _loc5_.GetY();
      }
      else if(_loc5_.GetY() + _loc5_.GetHeight() + _loc3_.sequences.content._y > _loc6_)
      {
         _loc3_.sequences.content._y = _loc6_ - (_loc5_.GetY() + _loc5_.GetHeight());
      }
   }
   else
   {
      _loc3_.sequences._y = _loc7_ - (_loc4_ + _loc7_) * 0.5;
      _loc3_.icons._y = _loc3_.sequences._y - _loc7_;
      _loc3_.sequences.lineUp._visible = false;
      _loc3_.sequences.lineDown._visible = false;
      _loc3_.sequences.content._y = 0;
   }
}
function fc_setDialogHaggle(min, max, npcValue, playerValue, prevNpcValue, originalValue, anger, prevAnger, money, isOnRightSide)
{
   hideDialog(!isOnRightSide ? Enum.DIALOG_LEFT_HAGGLE : Enum.DIALOG_RIGHT_HAGGLE);
   var _loc2_ = !isOnRightSide ? _root.cl.interactiveDialog : _root.cr.interactiveDialog;
   var _loc4_ = !isOnRightSide ? "mc_DialogHaggleLeft" : "mc_DialogHaggleRight";
   g_DialogHaggle = new DialogHaggle(_loc2_,_loc4_,min,max,npcValue,playerValue,prevNpcValue,originalValue,anger,prevAnger,money);
   _loc2_.sequences.lineUp._visible = false;
   _loc2_.sequences.lineDown._visible = false;
   showDialog(!isOnRightSide ? Enum.DIALOG_LEFT_HAGGLE : Enum.DIALOG_RIGHT_HAGGLE);
}
function fc_setBarber()
{
   removeDialogSequences();
   var _loc7_ = _root.cr.interactiveDialog.sequences.content;
   var _loc6_ = 1;
   var _loc2_ = 0;
   var _loc4_;
   var _loc3_;
   while(_loc2_ * _loc6_ < g_SequencesA.length)
   {
      _loc4_ = _loc2_ * _loc6_;
      _loc3_ = new DialogSequence(_loc2_,_loc7_,true,g_SequencesA[_loc4_],false,"",0,0);
      g_DialogSequencesA.push(_loc3_);
      _loc2_ = _loc2_ + 1;
   }
   g_SequencesA.length = 0;
   _loc7_._y = 0;
   g_DialogSequencesA[0].Select(true);
   g_DialogSequenceSelected = 0;
   var _loc5_ = 0;
   _loc2_ = 0;
   while(_loc2_ < g_DialogSequencesA.length)
   {
      g_DialogSequencesA[_loc2_].SetY(_loc5_);
      _loc5_ += g_DialogSequencesA[_loc2_].GetHeight();
      _loc2_ = _loc2_ + 1;
   }
   showDialog(Enum.DIALOG_BARBER);
   updateDialogPosition();
}
function fc_clearBarber()
{
   if(g_DialogState == Enum.DIALOG_BARBER)
   {
      clearDialogSequences();
   }
}
function fc_setShieldPainting()
{
   removeDialogSequences();
   var _loc7_ = _root.cr.interactiveDialog.sequences.content;
   var _loc6_ = 2;
   var _loc2_ = 0;
   var _loc3_;
   var _loc4_;
   while(_loc2_ * _loc6_ < g_SequencesA.length)
   {
      _loc3_ = _loc2_ * _loc6_;
      _loc4_ = new DialogSequence(_loc2_,_loc7_,true,g_SequencesA[_loc3_],false,!g_SequencesA[_loc3_ + 1] ? "" : "Trigger",0,0);
      g_DialogSequencesA.push(_loc4_);
      _loc2_ = _loc2_ + 1;
   }
   g_SequencesA.length = 0;
   _loc7_._y = 0;
   g_DialogSequencesA[0].Select(true);
   g_DialogSequenceSelected = 0;
   var _loc5_ = 0;
   _loc2_ = 0;
   while(_loc2_ < g_DialogSequencesA.length)
   {
      g_DialogSequencesA[_loc2_].SetY(_loc5_);
      _loc5_ += g_DialogSequencesA[_loc2_].GetHeight();
      _loc2_ = _loc2_ + 1;
   }
   showDialog(Enum.DIALOG_SHIELDS);
   updateDialogPosition();
}
function fc_clearShieldPainting()
{
   if(g_DialogState == Enum.DIALOG_SHIELDS)
   {
      clearDialogSequences();
   }
}
function fc_setForgeBuilderSlots()
{
   removeDialogSequences();
   var _loc7_ = _root.cr.interactiveDialog.sequences.content;
   var _loc6_ = 4;
   var _loc2_ = 0;
   var _loc3_;
   var _loc4_;
   while(_loc2_ * _loc6_ < g_SequencesA.length)
   {
      _loc3_ = _loc2_ * _loc6_;
      _loc4_ = new DialogSequenceForgeSlot(_loc2_,_loc7_,g_SequencesA[_loc3_],g_SequencesA[_loc3_ + 1],g_SequencesA[_loc3_ + 2],g_SequencesA[_loc3_ + 3]);
      g_DialogSequencesA.push(_loc4_);
      _loc2_ = _loc2_ + 1;
   }
   g_SequencesA.length = 0;
   _loc7_._y = 0;
   g_DialogSequencesA[0].Select(true);
   g_DialogSequenceSelected = 0;
   var _loc5_ = 0;
   _loc2_ = 0;
   while(_loc2_ < g_DialogSequencesA.length)
   {
      g_DialogSequencesA[_loc2_].SetY(_loc5_);
      _loc5_ += g_DialogSequencesA[_loc2_].GetHeight();
      _loc2_ = _loc2_ + 1;
   }
   showDialog(Enum.DIALOG_FORGE);
   updateDialogPosition();
}
function fc_clearForgeBuilder()
{
   if(g_DialogState == Enum.DIALOG_FORGE)
   {
      clearDialogSequences();
   }
}
function fc_setForgeBuilderAssets()
{
   var _loc7_ = _root.cr.interactiveDialog.sequences.content;
   var _loc10_ = 0;
   var _loc9_ = 0;
   if(g_DialogSequencesA.length != 0)
   {
      _loc10_ = _loc7_._y;
      _loc9_ = g_DialogSequenceSelected;
   }
   removeDialogSequences();
   var _loc8_ = _root.bbc.infoHolder.attachMovie("mc_ForgeText","infoContainer",_root.bc.getNextHighestDepth());
   g_ForgeInfoMoneyTextExtension = TextExtension.createSimpleMode(_loc8_.inside.money);
   g_ForgeInfoMoneyTextExtension.setEnableAllFeatures(false);
   g_ForgeInfoMoneyTextExtension.EnabledStyles = true;
   g_ForgeInfoMoneyTextExtension.setStylesA([{tagName:"unavailable",color:ColorScheme.DARK_NEGATIVE}]);
   g_ForgeInfoPrestigeTextExtension = TextExtension.createSimpleMode(_loc8_.inside.prestige);
   g_ForgeInfoPrestigeTextExtension.setEnableAllFeatures(false);
   g_ForgeInfoPrestigeTextExtension.EnabledStyles = true;
   g_ForgeInfoPrestigeTextExtension.setStylesA([{tagName:"unavailable",color:ColorScheme.DARK_NEGATIVE}]);
   var _loc6_ = 7;
   var _loc2_ = 0;
   var _loc3_;
   var _loc4_;
   while(_loc2_ * _loc6_ < g_SequencesA.length)
   {
      _loc3_ = _loc2_ * _loc6_;
      _loc4_ = new DialogSequenceForgeAsset(_loc2_,_loc7_,_loc8_,g_SequencesA[_loc3_],g_SequencesA[_loc3_ + 1],g_SequencesA[_loc3_ + 2],g_SequencesA[_loc3_ + 3],g_SequencesA[_loc3_ + 4],g_SequencesA[_loc3_ + 5],g_SequencesA[_loc3_ + 6],g_ForgeInfoMoneyTextExtension,g_ForgeInfoPrestigeTextExtension,g_ForgeCameraScale);
      g_DialogSequencesA.push(_loc4_);
      _loc2_ = _loc2_ + 1;
   }
   g_SequencesA.length = 0;
   var _loc5_ = 0;
   _loc2_ = 0;
   while(_loc2_ < g_DialogSequencesA.length)
   {
      g_DialogSequencesA[_loc2_].SetY(_loc5_);
      _loc5_ += g_DialogSequencesA[_loc2_].GetHeight();
      _loc2_ = _loc2_ + 1;
   }
   if(_loc9_ >= g_DialogSequencesA.length)
   {
      _loc9_ = g_DialogSequencesA.length - 1;
   }
   g_DialogSequencesA[_loc9_].Select(true);
   g_DialogSequenceSelected = _loc9_;
   showDialog(Enum.DIALOG_FORGE);
   updateDialogPosition();
   var _loc11_;
   if(_loc10_ != 0)
   {
      _loc11_ = Enum.C_DIALOG_SEQUENCE_COUNT_WITH_ICON * Enum.C_DEFAULT_SEQUENCE_HEIGHT;
      if(_loc10_ < _loc11_ - _loc5_)
      {
         _loc7_._y = _loc11_ - _loc5_;
      }
      else
      {
         _loc7_._y = _loc10_;
      }
   }
}
function fc_showForgeBuilderVignette(time, scale)
{
   var _loc4_ = 0.8;
   var _loc3_ = 0.99;
   var _loc5_ = 100 / (_loc3_ - _loc4_);
   g_ForgeCameraScale = scale;
   var _loc2_ = _root.bbc.vignetteHolder.infoVignette;
   if(!_loc2_)
   {
      _loc2_ = _root.bbc.vignetteHolder.attachMovie("mc_ForgeVignette","infoVignette",_root.bbc.vignetteHolder.getNextHighestDepth());
   }
   var _loc6_ = Math.min(Math.max(0,(_loc3_ - scale) * _loc5_),100);
   _loc2_._alpha = 0;
   _loc2_.tweenTo(time,{_alpha:_loc6_},C_EASING_FUNCTION_LINEAR);
}
function fc_hideForgeBuilderVignette(time)
{
   var _loc2_ = _root.bbc.vignetteHolder.infoVignette;
   if(_loc2_)
   {
      _loc2_.tweenTo(time,{_alpha:0},C_EASING_FUNCTION_LINEAR);
   }
}
function fc_removeForgeVignette()
{
   g_ForgeCameraScale = -1;
   if(_root.bbc.vignetteHolder.infoVignette)
   {
      _root.bbc.vignetteHolder.infoVignette.removeMovieClip();
   }
}
function fc_showForgeBuilderBuyNotification()
{
   g_FancyNotifMngr.Insert(Enum.FORGE_BUILDER_EVENT,0,Enum.SHORT_NOTIFICATION_DURATION,[]);
}
function fc_clearNotificationsAfterCloseMinigame()
{
   g_FancyNotifMngr.FadeOutAndFlush();
   g_InfoTextNotifMngr.FadeOutAndFlush();
}
function fc_showCrimeList(totalFine)
{
   if(g_DialogState == Enum.DIALOG_RIGHT_DIALOG)
   {
      g_DialogCrimeListMC = _root.cr.attachMovie("mc_DialogCrimeListRight","CrimeList",_root.cr.getNextHighestDepth());
      _root.cr.interactiveDialog._visible = false;
   }
   else
   {
      g_DialogCrimeListMC = _root.cl.attachMovie("mc_DialogCrimeListLeft","CrimeList",_root.cl.getNextHighestDepth());
      _root.cl.interactiveDialog._visible = false;
   }
   g_DialogCrimeListMC.crimeList.title.text = Enum.LOCALIZABLE_TOKEN + "ui_crime_list_title";
   g_DialogCrimeListMC.crimeList.victim.text = Enum.LOCALIZABLE_TOKEN + "ui_crime_list_victim";
   g_DialogCrimeListMC.crimeList.fine.text = Enum.LOCALIZABLE_TOKEN + "ui_crime_list_fine";
   g_DialogCrimeListMC.crimeList.totalNumber.text = MathExtension.RoundBigNumber(totalFine,1,MathExtension.MILION);
   g_DialogCrimeListMC.crimeList.totalText.text = Enum.LOCALIZABLE_TOKEN + "ui_crime_list_total_fine";
   g_DialogCrimeListMC.crimeList.totalText._x = 545 - g_DialogCrimeListMC.crimeList.totalNumber.textWidth / 2 - 20 - g_DialogCrimeListMC.crimeList.totalText._width;
   g_CrimeListData = new CrimeListData("crimeListData");
   g_CrimeListView = new CrimeListView(g_CrimeListData,g_DialogCrimeListMC.crimeList.parentList.inside);
   g_CrimeListView.CreateScrollbar(g_DialogCrimeListMC.crimeList.scrollbar);
   g_CrimeListData.SetDataFromArray(g_CrimeListDataA);
   g_CrimeListDataA.length = 0;
}
function fc_hideCrimeList()
{
   if(g_DialogCrimeListMC)
   {
      g_CrimeListData = undefined;
      g_CrimeListView = undefined;
      g_DialogCrimeListMC._parent.interactiveDialog._visible = true;
      g_DialogCrimeListMC.removeMovieClip();
   }
}
function fc_scrollCrimeList(dir)
{
   g_CrimeListView.Scroll(dir);
}
function stringHelperHandleBreak(text)
{
   var _loc6_ = text.split("<br/>");
   var _loc7_ = _loc6_.length;
   var _loc4_ = 0;
   var _loc2_;
   var _loc5_;
   var _loc1_;
   var _loc3_;
   while(_loc4_ < _loc7_)
   {
      _loc2_ = _loc6_[_loc4_].split("<");
      _loc5_ = _loc2_.length;
      _loc1_ = 0;
      while(_loc1_ < _loc5_)
      {
         _loc3_ = _loc2_[_loc1_].indexOf(">");
         _loc2_[_loc1_] = _loc2_[_loc1_].substring(_loc3_ + 1);
         _loc1_ = _loc1_ + 1;
      }
      _loc6_[_loc4_] = _loc2_.join("");
      _loc4_ = _loc4_ + 1;
   }
   return _loc6_.join("<br/>");
}
function fc_setSubtitles(text, speakerName, isPlayer)
{
   bc.subtitles.inside.tField.text = text;
   text = bc.subtitles.inside.tField.text;
   text = stringHelperHandleBreak(text);
   if(text == "")
   {
      bc.subtitles.inside.tField.text = "";
      updateSubtitlePosition();
      setSubtitlesBackground();
      return undefined;
   }
   bc.subtitles.inside._visible = true;
   var _loc2_;
   var _loc4_;
   var _loc5_;
   if(g_IsSpeakerNameEnabled && speakerName.length > 0)
   {
      bc.subtitles.inside.tField.text = speakerName;
      speakerName = bc.subtitles.inside.tField.text;
      _loc4_ = !isPlayer ? ColorScheme.DARK_EMPHASIS : ColorScheme.DARK_POSITIVE;
      _loc5_ = "<font color=\'" + _loc4_ + "\'>" + speakerName + "</font>";
      _loc2_ = _loc5_ + "\n" + text;
   }
   else
   {
      _loc2_ = text;
   }
   TextExtension.setText(_loc2_,bc.subtitles.inside.tField);
   setTextSize(bc.subtitles.inside.tField,g_SpeachFontSize);
   updateSubtitlePosition();
   setSubtitlesBackground();
}
function getBottomStripPosition()
{
   var _loc1_ = (g_currSizeY - ratioStrips.bottomStrip._y) * (100 / bc._yscale);
   _loc1_ = Math.max(_loc1_,0);
   return _loc1_;
}
function updateSubtitlePosition()
{
   var _loc1_ = bc.subtitles.inside.tField.textHeight;
   var _loc2_;
   if(g_RatioPreset == Enum.RATIO_PRESET_GAME)
   {
      bc.subtitles._y = -120 - _loc1_;
   }
   else if(g_RatioPreset == Enum.RATIO_PRESET_DIALOG || g_RatioPreset == Enum.RATIO_PRESET_CUTSCENE)
   {
      _loc2_ = getBottomStripPosition();
      if(_loc1_ + 10 > _loc2_)
      {
         bc.subtitles._y = - _loc1_ - _loc1_ * 0.3;
      }
      else
      {
         bc.subtitles._y = - _loc2_ + (_loc2_ - _loc1_) * 0.5;
      }
   }
}
function fc_setSubtitleSpeakerNameEnable(isEnable)
{
   g_IsSpeakerNameEnabled = isEnable;
}
function fc_setSubtitleBgEnable(isEnable)
{
   this.g_IsSpeechBackgroundVisible = isEnable;
   setBubblesBackground();
   setSubtitlesBackground();
}
function fc_setSubtitleSize(size)
{
   g_SpeachFontSize = Enum.GetFontSize(size);
   setTextSize(bc.subtitles.inside.tField,g_SpeachFontSize);
   var _loc2_ = 1;
   var _loc1_;
   while(_loc2_ <= Enum.BUBBLE_COUNT)
   {
      _loc1_ = cccursor.bubbles[Enum.BUBBLE_NAME_CORE + _loc2_];
      if(_loc1_ && _loc1_.inside.tfText.text.length > 0)
      {
         setTextSize(_loc1_.inside.tfText,g_SpeachFontSize);
      }
      _loc2_ = _loc2_ + 1;
   }
   setBubblesBackground();
   setSubtitlesBackground();
}
function fc_clearSubtitles()
{
   bc.subtitles.inside.tField.text = "";
   bc.subtitles.inside._visible = false;
   bc.subtitles.inside.mc_textBgHolder._visible = false;
}
function fc_setNarrativeSubtitles(text, layout, fadeIn)
{
   var _loc3_ = 0.05;
   var _loc7_ = 0.75;
   var _loc8_ = 0.25;
   bc.narrativeSubtitles._visible = true;
   var _loc1_ = bc.narrativeSubtitles.tField;
   _loc1_._width = 500;
   _loc1_.autoSize = true;
   TextExtension.setText(text,_loc1_);
   var _loc5_;
   var _loc2_;
   var _loc6_;
   var _loc4_;
   switch(layout)
   {
      case Enum.LAYOUT_CENTER_BIG:
         setTextFormatOptional(_loc1_,Enum.NARRATIVE_SUBTITLES_FONT_SIZE_LARGE,"center",ColorScheme.DARK_EMPHASIS);
         bc.narrativeSubtitles.C._y = (- g_currSizeY * 0.5) * (100 / bc._yscale);
         _loc1_._width = g_currSizeX - g_currSizeX / 8;
         _loc1_._x = bc.narrativeSubtitles.C._x - _loc1_._width * 0.5;
         _loc1_._y = bc.narrativeSubtitles.C._y - _loc1_.textHeight * 0.5;
         break;
      case Enum.LAYOUT_CENTER:
         setTextFormatOptional(_loc1_,Enum.NARRATIVE_SUBTITLES_FONT_SIZE,"center",ColorScheme.DARK);
         bc.narrativeSubtitles.C._y = (- g_currSizeY * 0.5) * (100 / bc._yscale);
         _loc1_._x = bc.narrativeSubtitles.C._x - _loc1_._width * 0.5;
         _loc1_._y = bc.narrativeSubtitles.C._y - _loc1_.textHeight * 0.5;
         break;
      case Enum.LAYOUT_CENTER_BOTTOM:
         setTextFormatOptional(_loc1_,Enum.NARRATIVE_SUBTITLES_FONT_SIZE,"center",ColorScheme.DARK);
         bc.narrativeSubtitles.C._y = (- g_currSizeY * _loc8_) * (100 / bc._yscale);
         _loc1_._x = bc.narrativeSubtitles.CB._x - _loc1_._width * 0.5;
         _loc1_._y = bc.narrativeSubtitles.CB._y - _loc1_.textHeight;
         break;
      case Enum.LAYOUT_TOP_RIGHT:
         setTextFormatOptional(_loc1_,Enum.NARRATIVE_SUBTITLES_FONT_SIZE,"right",ColorScheme.DARK);
         _loc5_ = g_currSizeY * Enum.CINEMATIC_RATIO;
         _loc2_ = tr._x - bc._x;
         _loc2_ -= _loc5_ * _loc3_;
         _loc6_ = _loc2_ * (100 / bc._yscale);
         bc.narrativeSubtitles.TR._x = _loc6_;
         _loc4_ = (- g_currSizeY) * _loc7_;
         bc.narrativeSubtitles.TR._y = _loc4_ * (100 / bc._yscale);
         _loc1_._x = bc.narrativeSubtitles.TR._x - _loc1_._width;
         _loc1_._y = bc.narrativeSubtitles.TR._y - _loc1_.textHeight * 0.5;
   }
   if(fadeIn > 0)
   {
      bc.narrativeSubtitles._alpha = 0;
      bc.narrativeSubtitles.tweenTo(fadeIn / 1000,{_alpha:100},C_EASING_FUNCTION_LINEAR);
   }
   else
   {
      bc.narrativeSubtitles._alpha = 100;
   }
}
function fc_hideNarrativeSubtitles(fadeOut)
{
   if(fadeOut > 0)
   {
      bc.narrativeSubtitles.tweenTo(fadeOut / 1000,{_alpha:0},C_EASING_FUNCTION_LINEAR);
   }
   else
   {
      bc.narrativeSubtitles.tField.text = "";
      bc.narrativeSubtitles._visible = false;
   }
}
function fc_showTutorial(id, text, duration, inDialog, priority, layout, actionHintEnable, overlayLink)
{
   if(inDialog)
   {
      g_TutorialInDialogNotifMngr.Insert(id,priority,-1,[text,layout,actionHintEnable,overlayLink]);
   }
   else
   {
      if(priority > 0)
      {
         g_TutorialNotifMngr.RemoveAndFlush(priority - 1);
      }
      g_TutorialNotifMngr.Insert(id,priority,duration,[text,layout,actionHintEnable,overlayLink]);
   }
}
function fc_hideTutorial(id)
{
   if(g_TutorialNotifMngr.Contain(id))
   {
      g_TutorialNotifMngr.Remove(id,NotificationManager.E_REMOVE_FADE);
   }
   else if(g_TutorialInDialogNotifMngr.Contain(id))
   {
      g_TutorialInDialogNotifMngr.Remove(id,NotificationManager.E_REMOVE_FADE);
   }
}
function fc_hideCurrentTutorial()
{
   hideTutorial(false);
}
function fc_hideAllTutorials()
{
   resetTutorial();
}
function fc_setPlayingTutorialEvent(play, flush)
{
   setPlayingNotificationManager(g_TutorialNotifMngr,play,flush);
   if(g_TutorialNotifMngr.HasVisibleNotificationWithActionHint())
   {
      flash.external.ExternalInterface.call("onShowTutorialActionHint",play,g_TutorialNotifMngr.GetOverlayLink());
   }
}
function hideTutorial(fading)
{
   if(fading)
   {
      g_TutorialNotifMngr.FadeOutVisible();
      g_TutorialInDialogNotifMngr.FadeOutVisible();
   }
   else
   {
      g_TutorialNotifMngr.Hide();
      g_TutorialNotifMngr.RemoveVisible();
      g_TutorialInDialogNotifMngr.RemoveVisible();
   }
}
function resetTutorial()
{
   g_TutorialNotifMngr.RemoveAndFlush();
   g_TutorialInDialogNotifMngr.RemoveAndFlush();
}
function showTutorialInDialog()
{
   var _loc3_ = g_TutorialInDialogNotifMngr.Layout != Enum.TUTORIAL_LAYOUT_WIDE ? 345 : 460;
   var _loc2_ = g_currSizeX / Enum.SCREEN_WIDTH;
   if(g_DialogState == Enum.DIALOG_RIGHT_DIALOG || g_DialogState == Enum.DIALOG_RIGHT_HAGGLE)
   {
      _root.tutorialInDialog._x = 25 * _loc2_;
   }
   else
   {
      _root.tutorialInDialog._x = g_currSizeX - _loc3_ * (_root.tutorialInDialog._xscale * 0.01) - 25 * _loc2_;
   }
   g_TutorialInDialogNotifMngr.Play();
}
function hideTutorialInDialog()
{
   g_TutorialInDialogNotifMngr.FadeOutAndPause();
}
function fc_showDiscoveredCodex(eventName, iconId, perkId)
{
   g_CommonNotifMngr.Insert(Enum.CODEX_EVENT,Enum.GetPriorityByDiscoveredType(Enum.CODEX_EVENT),Enum.LONG_NOTIFICATION_DURATION,[eventName,iconId,perkId]);
}
function fc_showDiscoveredPoi(type, eventName, iconId, perkId)
{
   g_CommonNotifMngr.Insert(Enum.POI_EVENT,Enum.GetPriorityByDiscoveredType(Enum.POI_EVENT),Enum.LONG_NOTIFICATION_DURATION,[type,eventName,iconId,perkId]);
}
function fc_showDiscoveredLocation(type, eventName, iconId, perkId)
{
   if(type == Enum.DISCOVERED_LOCATION_UNIQUE)
   {
      g_FancyNotifMngr.Insert(Enum.LOCATION_EVENT,1,Enum.LONG_NOTIFICATION_DURATION,[eventName,iconId,perkId]);
   }
   else
   {
      g_CommonNotifMngr.Insert(Enum.LOCATION_EVENT,Enum.GetPriorityByDiscoveredType(Enum.LOCATION_EVENT),Enum.LONG_NOTIFICATION_DURATION,[eventName,iconId,perkId]);
   }
}
function fc_hideCodexActionHint()
{
   if(g_CodexActionHintPerkId != "")
   {
      flash.external.ExternalInterface.call("onShowCodexActionHint",false,g_CodexActionHintPerkId);
      g_CodexActionHintPerkId = "";
   }
}
function onShowCodexActionHint(show, perkId)
{
   if(show)
   {
      g_CodexActionHintPerkId = perkId;
      flash.external.ExternalInterface.call("onShowCodexActionHint",show,g_CodexActionHintPerkId);
   }
   else if(g_CodexActionHintPerkId == perkId)
   {
      flash.external.ExternalInterface.call("onShowCodexActionHint",show,g_CodexActionHintPerkId);
      g_CodexActionHintPerkId = "";
   }
}
function fc_showUnlockedShieldPaintingIngredient(type, name)
{
   if(type == Enum.SHIELD_INGREDIENT_CATEGORY)
   {
      return undefined;
   }
   g_CommonNotifMngr.Insert(Enum.SHIELD_PAINTING_EVENT,Enum.GetPriorityByEventType(Enum.SHIELD_PAINTING_EVENT),Enum.LONG_NOTIFICATION_DURATION,[type,name]);
}
function fc_addBuff(buffId, iconId, type, order, progress, secondProgress, perkUIName, perkIconId)
{
   var _loc1_ = false;
   if(order < 0)
   {
      _loc1_ = g_BuffLeftNotifMngr.Insert(buffId,Math.abs(order),-1,[iconId,type,progress,secondProgress,perkIconId]);
   }
   else
   {
      _loc1_ = g_BuffRightNotifMngr.Insert(buffId,order,-1,[iconId,type,progress,secondProgress,perkIconId]);
   }
   if(_loc1_ && type == Enum.BUFF_TYPE_PERK && perkUIName != undefined && perkUIName != "")
   {
      g_CommonNotifMngr.Insert(perkIconId,Enum.GetPriorityByEventType(Enum.PERK_EVENT),Enum.LONG_NOTIFICATION_DURATION,[Enum.PERK_EVENT,Enum.PERK_ACTIVATED,perkIconId,perkUIName]);
   }
}
function fc_updateBuff(buffId, progress, secondProgress)
{
   if(g_BuffLeftNotifMngr.Contain(buffId))
   {
      g_BuffLeftNotifMngr.Change(buffId,[progress,secondProgress]);
   }
   else if(g_BuffRightNotifMngr.Contain(buffId))
   {
      g_BuffRightNotifMngr.Change(buffId,[progress,secondProgress]);
   }
}
function fc_removeBuff(buffId)
{
   var _loc2_;
   var _loc3_ = false;
   if(g_BuffLeftNotifMngr.Contain(buffId))
   {
      _loc2_ = g_BuffLeftNotifMngr.GetPerkIconId(buffId);
      _loc3_ = g_BuffLeftNotifMngr.RemoveRefcount(buffId,NotificationManager.E_REMOVE_FADE);
   }
   else if(g_BuffRightNotifMngr.Contain(buffId))
   {
      _loc2_ = g_BuffRightNotifMngr.GetPerkIconId(buffId);
      _loc3_ = g_BuffRightNotifMngr.RemoveRefcount(buffId,NotificationManager.E_REMOVE_FADE);
   }
   if(_loc3_ && _loc2_)
   {
      g_CommonNotifMngr.Remove(_loc2_,NotificationManager.E_REMOVE_FADE);
   }
}
function fc_swapBuffId(oldBuffId, newBuffId)
{
   var _loc1_ = false;
   if(g_BuffLeftNotifMngr.Contain(oldBuffId))
   {
      _loc1_ = g_BuffLeftNotifMngr.SwapId(oldBuffId,newBuffId);
   }
   else if(g_BuffRightNotifMngr.Contain(oldBuffId))
   {
      _loc1_ = g_BuffRightNotifMngr.SwapId(oldBuffId,newBuffId);
   }
}
function resetBuffs()
{
   g_BuffLeftNotifMngr.RemoveAndFlush();
   g_BuffRightNotifMngr.RemoveAndFlush();
}
function setBuffFade(enable, type)
{
   var _loc2_ = 250;
   var _loc3_;
   var _loc4_;
   var _loc6_;
   if(type == Enum.QAM_TYPE_WEAPON || type == Enum.QAM_TYPE_BOTH)
   {
      _loc3_ = _root.bc.buffs.leftBuffs;
      _loc4_ = g_GameMode != Enum.GAME_MODE_HARD ? Enum.C_BUFF_LEFT_ORIGIN : Enum.C_BUFF_LEFT_ORIGIN_HC;
      _loc6_ = -200;
      if(enable)
      {
         _loc3_.tweenTo(_loc2_ / 1000,{_alpha:100,_x:_loc4_},C_EASING_FUNCTION_CUBIC);
      }
      else
      {
         _loc3_.tweenTo(_loc2_ / 1000,{_alpha:0,_x:_loc4_ + _loc6_},C_EASING_FUNCTION_CUBIC);
      }
   }
   if(type == Enum.QAM_TYPE_FOOD || type == Enum.QAM_TYPE_BOTH)
   {
      _loc3_ = _root.bc.buffs.rightBuffs;
      _loc4_ = g_GameMode != Enum.GAME_MODE_HARD ? Enum.C_BUFF_RIGHT_ORIGIN : Enum.C_BUFF_RIGHT_ORIGIN_HC;
      _loc6_ = 200;
      if(enable)
      {
         _loc3_.tweenTo(_loc2_ / 1000,{_alpha:100,_x:_loc4_},C_EASING_FUNCTION_CUBIC);
      }
      else
      {
         _loc3_.tweenTo(_loc2_ / 1000,{_alpha:0,_x:_loc4_ + _loc6_},C_EASING_FUNCTION_CUBIC);
      }
   }
}
function fc_showLevelUp(stat, statName, type, level, perkPoints)
{
   if(type == Enum.STAT_TYPE_MAIN)
   {
      g_FancyNotifMngr.Insert(Enum.LEVEL_UP_EVENT,0,Enum.DEFAULT_NOTIFICATION_DURATION,[type,stat,statName,level,perkPoints]);
   }
   else
   {
      g_CommonNotifMngr.Insert(Enum.LEVEL_UP_EVENT,0,Enum.LONG_NOTIFICATION_DURATION,[type,stat,statName,level,perkPoints]);
   }
}
function fc_setPlayingCommonEvent(play, flush)
{
   setPlayingNotificationManager(g_CommonNotifMngr,play,flush);
}
function resetCommonEvents()
{
   g_CommonNotifMngr.RemoveAndFlush();
}
function fc_showLevelXpGain(stat, statName, type)
{
   g_CommonNotifMngr.Insert(Enum.XP_EVENT,0,Enum.LONG_NOTIFICATION_DURATION,[type,stat,statName]);
}
function fc_showReputationChanged(id, msg)
{
   g_CommonNotifMngr.Insert(Enum.REPUTATION_EVENT,0,Enum.LONG_NOTIFICATION_DURATION,[id,msg]);
}
function fc_setCrimeState(state)
{
   var _loc12_ = 1;
   var _loc8_ = 2;
   var _loc9_ = 5;
   var _loc2_ = 6;
   var _loc6_ = 6;
   var _loc3_ = 11;
   var _loc11_ = 12;
   var _loc13_ = 13;
   var _loc10_ = 14;
   var _loc14_ = 15;
   if(state == Enum.CRIME_DETECTED)
   {
      tc.crime[Enum.GetIconNameByCrimeState(state)].gotoAndPlay(2);
      setCrimeIconVisible(false);
      Audio.Play(Audio.CRIME_DETECTED);
      return undefined;
   }
   var _loc7_ = tc.crime[Enum.GetIconNameByCrimeState(g_CrimeState)];
   var _loc1_ = tc.crime[Enum.GetIconNameByCrimeState(state)];
   if(state == g_CrimeState)
   {
      return undefined;
   }
   var _loc5_;
   if(state == Enum.CRIME_NOTHING)
   {
      _loc7_.gotoAndPlay(_loc2_);
   }
   else if(g_CrimeState == Enum.CRIME_NOTHING)
   {
      hideStateIcon(tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_LOOKING)],_loc1_,_loc2_,_loc3_);
      hideStateIcon(tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_REPORTING)],_loc1_,_loc2_,_loc3_);
      hideStateIcon(tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_INVESTIGATING)],_loc1_,_loc2_,_loc3_);
      hideStateIcon(tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_RECOGNIZING)],_loc1_,_loc2_,_loc3_);
      hideStateIcon(tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_CHECKING)],_loc1_,_loc2_,_loc3_);
      hideStateIcon(tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_CONFRONTING_TRESPASS)],_loc1_,_loc2_,_loc3_);
      hideStateIcon(tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_CONFRONTING_GENERAL)],_loc1_,_loc2_,_loc3_);
      hideStateIcon(tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_PASIVE_COMBAT)],_loc1_,_loc2_,_loc3_);
      hideStateIcon(tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_ACTIVE_COMBAT)],_loc1_,_loc2_,_loc3_);
      _loc5_ = _loc1_._currentframe;
      if(_loc5_ >= _loc2_ && _loc5_ < _loc6_)
      {
         _loc5_ = _loc6_;
      }
      _loc1_.gotoAndPlay(MathExtension.InvertFrameAnimation(_loc5_,_loc2_,_loc3_,_loc8_,_loc9_));
      if(_loc1_.icon)
      {
         _loc1_.icon.gotoAndPlay(2);
      }
   }
   else
   {
      _loc7_.gotoAndPlay(_loc11_);
      _loc1_.gotoAndPlay(_loc10_);
      if(_loc1_.icon)
      {
         _loc1_.icon.gotoAndPlay(2);
      }
   }
   g_CrimeState = state;
}
function fc_setCrimeRecognizingValue(value)
{
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_RECOGNIZING)].progress.gotoAndStop(value + 1);
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_CHECKING)].progress.gotoAndStop(value + 1);
}
function onCrimeDetectedEnd()
{
   setCrimeIconVisible(true);
}
function setCrimeIconVisible(visible)
{
   var _loc1_ = !visible ? 0 : 100;
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_LOOKING)]._alpha = _loc1_;
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_REPORTING)]._alpha = _loc1_;
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_INVESTIGATING)]._alpha = _loc1_;
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_RECOGNIZING)]._alpha = _loc1_;
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_CHECKING)]._alpha = _loc1_;
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_CONFRONTING_TRESPASS)]._alpha = _loc1_;
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_CONFRONTING_GENERAL)]._alpha = _loc1_;
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_PASIVE_COMBAT)]._alpha = _loc1_;
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_ACTIVE_COMBAT)]._alpha = _loc1_;
}
function resetCrimeState()
{
   var _loc1_ = 1;
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_LOOKING)].gotoAndStop(_loc1_);
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_REPORTING)].gotoAndStop(_loc1_);
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_INVESTIGATING)].gotoAndStop(_loc1_);
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_RECOGNIZING)].gotoAndStop(_loc1_);
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_CHECKING)].gotoAndStop(_loc1_);
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_CONFRONTING_TRESPASS)].gotoAndStop(_loc1_);
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_CONFRONTING_GENERAL)].gotoAndStop(_loc1_);
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_PASIVE_COMBAT)].gotoAndStop(_loc1_);
   tc.crime[Enum.GetIconNameByCrimeState(Enum.CRIME_ACTIVE_COMBAT)].gotoAndStop(_loc1_);
   g_CrimeState = Enum.CRIME_NOTHING;
}
function hideStateIcon(oldIcon, newIcon, hide, off)
{
   if(oldIcon == newIcon)
   {
      return undefined;
   }
   if(oldIcon._currentframe >= hide && oldIcon._currentframe < off)
   {
      oldIcon.gotoAndStop(off);
   }
}
function fc_setTrespassState(state)
{
   var _loc10_ = 1;
   var _loc4_ = 2;
   var _loc7_ = 10;
   var _loc3_ = 11;
   var _loc2_ = 20;
   var _loc9_ = 21;
   var _loc11_ = 25;
   var _loc5_ = tc.trespassing[Enum.GetIconNameByTrespassState(g_TrespassState)];
   var _loc1_ = tc.trespassing[Enum.GetIconNameByTrespassState(state)];
   if(state == g_TrespassState)
   {
      return undefined;
   }
   var _loc8_;
   if(state == Enum.TRESPASS_NOTHING)
   {
      _loc5_.gotoAndPlay(MathExtension.InvertFrameAnimation(_loc5_._currentframe,_loc4_,_loc7_,_loc3_,_loc2_));
      if(g_CommonNotifMngr.Contain(Enum.TRESPASS_EVENT))
      {
         g_CommonNotifMngr.Remove(Enum.TRESPASS_EVENT,NotificationManager.E_REMOVE_FADE);
      }
   }
   else
   {
      if(g_TrespassState == Enum.TRESPASS_NOTHING)
      {
         hideStateIcon(tc.trespassing[Enum.GetIconNameByCrimeState(Enum.TRESPASS_PRIVATE)],_loc1_,_loc3_,_loc2_);
         hideStateIcon(tc.trespassing[Enum.GetIconNameByCrimeState(Enum.TRESPASS_TRESPASS)],_loc1_,_loc3_,_loc2_);
         _loc1_.gotoAndPlay(MathExtension.InvertFrameAnimation(_loc1_._currentframe,_loc3_,_loc2_,_loc4_,_loc7_));
      }
      else
      {
         _loc5_.gotoAndPlay(_loc9_);
         _loc1_.gotoAndPlay(_loc4_);
         if(g_CommonNotifMngr.Contain(Enum.TRESPASS_EVENT))
         {
            g_CommonNotifMngr.Remove(Enum.TRESPASS_EVENT,NotificationManager.E_REMOVE_HIDE);
         }
      }
      _loc8_ = [];
      _loc8_.push(state);
      g_CommonNotifMngr.Insert(Enum.TRESPASS_EVENT,Enum.GetPriorityByEventType(Enum.TRESPASS_EVENT),Enum.DEFAULT_NOTIFICATION_DURATION,_loc8_);
   }
   g_TrespassState = state;
}
function resetTrespassState()
{
   var _loc1_ = 1;
   tc.trespassing[Enum.GetIconNameByTrespassState(Enum.TRESPASS_PRIVATE)].gotoAndStop(_loc1_);
   tc.trespassing[Enum.GetIconNameByTrespassState(Enum.TRESPASS_TRESPASS)].gotoAndStop(_loc1_);
   g_TrespassState = Enum.TRESPASS_NOTHING;
}
function fc_setWantedState(state)
{
   var _loc7_ = 1;
   var _loc4_ = 2;
   var _loc5_ = 10;
   var _loc3_ = 11;
   var _loc2_ = 20;
   var _loc1_ = tc.wanted.wanted;
   if(state == g_WantedState)
   {
      return undefined;
   }
   if(state == Enum.WANTED_NOTHING)
   {
      _loc1_.gotoAndPlay(MathExtension.InvertFrameAnimation(_loc1_._currentframe,_loc4_,_loc5_,_loc3_,_loc2_));
   }
   else
   {
      _loc1_.gotoAndPlay(MathExtension.InvertFrameAnimation(_loc1_._currentframe,_loc3_,_loc2_,_loc4_,_loc5_));
   }
   g_WantedState = state;
}
function resetWantedState()
{
   var _loc1_ = 1;
   g_WantedState = Enum.WANTED_NOTHING;
   tc.wanted.wanted.gotoAndStop(_loc1_);
}
function fc_showDenialAttack()
{
   if(hideCursor)
   {
      return undefined;
   }
   actionCursorHidden = cccursor.actioncursor.ActionCursorCross._visible;
   cccursor.actioncursor.ActionCursorCross._visible = true;
   hideCursor = true;
   if(cccursor.actioncursor.ActionCursorCross._currentframe == 1)
   {
      cccursor.actioncursor.ActionCursorCross.state0._visible = false;
   }
   else
   {
      cccursor.actioncursor.ActionCursorCross.state1._visible = false;
      cccursor.actioncursor.ActionCursorCross.state2._visible = false;
      cccursor.actioncursor.ActionCursorCross.state3._visible = false;
      cccursor.actioncursor.ActionCursorCross.state4._visible = false;
      cccursor.actioncursor.ActionCursorCross.state5._visible = false;
      cccursor.actioncursor.ActionCursorCross.state6._visible = false;
   }
   cccursor.actioncursor.ActionCursorCross.state7._visible = true;
   if(cccursor.actioncursor.ActionCursorCross.state7._currentframe == 1 || cccursor.actioncursor.ActionCursorCross.state7._currentframe == 10)
   {
      cccursor.actioncursor.ActionCursorCross.state7.gotoAndStop("on");
   }
}
function hideDenialAttack()
{
   cccursor.actioncursor.ActionCursorCross._visible = actionCursorHidden;
   hideCursor = false;
   if(cccursor.actioncursor.ActionCursorCross._currentframe == 1)
   {
      cccursor.actioncursor.ActionCursorCross.state0._visible = true;
   }
   else
   {
      cccursor.actioncursor.ActionCursorCross.state1._visible = true;
      cccursor.actioncursor.ActionCursorCross.state2._visible = true;
      cccursor.actioncursor.ActionCursorCross.state3._visible = true;
      cccursor.actioncursor.ActionCursorCross.state4._visible = true;
      cccursor.actioncursor.ActionCursorCross.state5._visible = true;
      cccursor.actioncursor.ActionCursorCross.state6._visible = true;
   }
   cccursor.actioncursor.ActionCursorCross.state7._visible = false;
}
function fc_showInfoText(message, priority, duration, background)
{
   g_InfoTextNotifMngr.Insert(message,priority,duration,[message,background]);
}
function fc_hideInfoText()
{
   g_InfoTextNotifMngr.FadeOutAndFlush();
}
function fc_setPlayingInfoText(play, flush)
{
   setPlayingNotificationManager(g_InfoTextNotifMngr,play,flush);
}
function resetInfoText()
{
   g_InfoTextNotifMngr.RemoveAndFlush();
}
function fc_showObjectiveEvent(eventType, eventName, questType, questTrackingId, questId, questUiName, objectiveIndex, tracker)
{
   var _loc2_ = Enum.GetPriorityByQuestEventType(eventType);
   var _loc1_ = Enum.LONG_NOTIFICATION_DURATION;
   g_FancyNotifMngr.Insert(questId,_loc2_,_loc1_,[eventType,eventName,questType,questTrackingId,_loc2_,_loc1_,questUiName,tracker,objectiveIndex]);
}
function fc_showQuestEvent(questId, eventType, eventName, questType, questTrackingId)
{
   var _loc2_ = Enum.GetPriorityByQuestEventType(eventType);
   var _loc1_ = Enum.LONG_NOTIFICATION_DURATION;
   g_FancyNotifMngr.Insert(questId,_loc2_,_loc1_,[eventType,eventName,questType,questTrackingId,_loc2_,_loc1_]);
}
function fc_setPlayingFancyEvent(play, flush)
{
   var _loc1_;
   if(flush)
   {
      _loc1_ = function(notif)
      {
         return Enum.IsNotifByEventTypeFlush(notif.EventType);
      };
      g_FancyNotifMngr.RemoveAndFlushWithTest(_loc1_);
   }
   setPlayingNotificationManager(g_FancyNotifMngr,play,false);
}
function resetFancyEvents()
{
   g_FancyNotifMngr.RemoveAndFlush();
}
function fc_showPerkUsed(iconName, uiName)
{
   g_CommonNotifMngr.Insert(iconName,Enum.GetPriorityByEventType(Enum.PERK_EVENT),Enum.LONG_NOTIFICATION_DURATION,[Enum.PERK_EVENT,Enum.PERK_USED,iconName,uiName]);
}
function fc_showPerkGained(iconName, uiName)
{
   g_FancyNotifMngr.Insert(Enum.PERK_EVENT,Enum.GetPriorityByEventType(Enum.PERK_EVENT),Enum.LONG_NOTIFICATION_DURATION,[Enum.PERK_EVENT,iconName,uiName]);
}
function fc_showComboLearned(iconName, uiName)
{
   g_CommonNotifMngr.Insert(iconName,Enum.GetPriorityByEventType(Enum.PERK_EVENT),Enum.LONG_NOTIFICATION_DURATION,[Enum.PERK_EVENT,Enum.COMBO_LEARNED,iconName,uiName]);
}
function fc_showNotification(infoText)
{
   g_CommonNotifMngr.Insert(Enum.GENERAL_EVENT,Enum.GetPriorityByEventType(Enum.GENERAL_EVENT),Enum.LONG_NOTIFICATION_DURATION,[infoText]);
}
function fc_showSkillCheckResult(name, res)
{
   g_SkillCheckNotifMngr.Insert(Enum.SKILL_CHECK_EVENT,1,Enum.SHORT_NOTIFICATION_DURATION,[name,res]);
}
function fc_setPlayingSkillCheckEvent(play, flush)
{
   setPlayingNotificationManager(g_SkillCheckNotifMngr,play,flush);
}
function resetSkillCheck()
{
   g_SkillCheckNotifMngr.RemoveAndFlush();
}
function fc_showItemCount(id, uiName, iconId, count)
{
   if(g_ItemTransferNotifMngr.Contain(id))
   {
      g_ItemTransferNotifMngr.Change(id,[count]);
   }
   else
   {
      g_ItemTransferNotifMngr.Insert(id,0,-1,[id,uiName,iconId,count,Enum.TRANSFER_PLAYER_HAS]);
   }
}
function fc_hideItemCount(id)
{
   g_ItemTransferNotifMngr.Remove(id,NotificationManager.E_REMOVE_FADE);
}
function fc_showItemTransfer(classId, uiName, iconId, count, dir)
{
   g_ItemTransferNotifMngr.Insert(Enum.ITEM_TRANSFER_EVENT,0,Enum.LONG_NOTIFICATION_DURATION,[classId,uiName,iconId,count,dir]);
}
function fc_setPlayingItemTransferEvent(play, flush)
{
   setPlayingNotificationManager(g_ItemTransferNotifMngr,play,flush);
}
function resetItemTransfer()
{
   g_ItemTransferNotifMngr.RemoveAndFlush();
}
function fc_openQAM(type)
{
   setBuffFade(false,type);
   if(g_QAMType == Enum.QAM_TYPE_NONE)
   {
      Audio.Play(Audio.QAM_OPEN);
   }
   g_QAMType = type;
   if(g_QAMType == Enum.QAM_TYPE_WEAPON || g_QAMType == Enum.QAM_TYPE_BOTH)
   {
      g_QAMWeapon.Open();
   }
   if(g_QAMType == Enum.QAM_TYPE_FOOD || g_QAMType == Enum.QAM_TYPE_BOTH)
   {
      g_QAMFood.Open();
   }
}
function fc_closeQAM(weaponSlotId, foodSlotId)
{
   setBuffFade(true,g_QAMType);
   if(g_QAMType == Enum.QAM_TYPE_WEAPON || g_QAMType == Enum.QAM_TYPE_BOTH)
   {
      if(weaponSlotId != Enum.QAM_SLOT_INVALID_ID)
      {
         g_QAMWeapon.SetSelectedSlot(weaponSlotId);
      }
      g_QAMWeapon.Close();
   }
   if(g_QAMType == Enum.QAM_TYPE_FOOD || g_QAMType == Enum.QAM_TYPE_BOTH)
   {
      if(foodSlotId != Enum.QAM_SLOT_INVALID_ID)
      {
         g_QAMFood.SetSelectedSlot(foodSlotId);
      }
      g_QAMFood.Close();
   }
   if(g_QAMType != Enum.QAM_TYPE_NONE)
   {
      Audio.Play(Audio.QAM_CLOSE);
   }
   g_QAMType = Enum.QAM_TYPE_NONE;
}
function fc_setSelectedQAMSlot(type, slotId)
{
   if(type == Enum.QAM_TYPE_WEAPON)
   {
      g_QAMWeapon.SetSelectedSlot(slotId);
      if(g_QAMType == Enum.QAM_TYPE_WEAPON || g_QAMType == Enum.QAM_TYPE_BOTH)
      {
         g_QAMWeapon.SetFocusedSlot(slotId);
      }
   }
   else if(type == Enum.QAM_TYPE_FOOD)
   {
      g_QAMFood.SetSelectedSlot(slotId);
      if(g_QAMType == Enum.QAM_TYPE_FOOD || g_QAMType == Enum.QAM_TYPE_BOTH)
      {
         g_QAMFood.SetFocusedSlot(slotId);
      }
   }
}
function fc_setFocusedQAMSlot(type, slotId)
{
   if(type == Enum.QAM_TYPE_WEAPON)
   {
      g_QAMWeapon.SetFocusedSlot(slotId);
   }
   else if(type == Enum.QAM_TYPE_FOOD)
   {
      g_QAMFood.SetFocusedSlot(slotId);
   }
}
function fc_setQAMSlots(type)
{
   if(type == Enum.QAM_TYPE_WEAPON)
   {
      g_QAMWeapon.SetSlots(g_QAMSlotsA);
   }
   else if(type == Enum.QAM_TYPE_FOOD)
   {
      g_QAMFood.SetSlots(g_QAMSlotsA);
   }
   g_QAMSlotsA.length = 0;
}
function fc_updateQAMHoldProgress(type, progress)
{
   if(type == Enum.QAM_TYPE_WEAPON)
   {
      g_QAMWeapon.SetHoldProgress(progress);
   }
   else if(type == Enum.QAM_TYPE_FOOD)
   {
      g_QAMFood.SetHoldProgress(progress);
   }
}
function resetQAM()
{
   g_QAMWeapon.Clear();
   g_QAMFood.Clear();
   g_QAMType = Enum.QAM_TYPE_NONE;
}
function fc_showDiceScore(targetScore, playerName, currentPlayer, totalPlayer, selectedPlayer, badgePlayerName, badgePlayerCurrent, badgePlayerTotal, currentNPC, totalNPC, selectedNPC, badgeNPCName, badgeNPCCurrent, badgeNPCTotal)
{
   var _loc3_;
   if(!_root.bl.diceScoreContainer.score)
   {
      _loc3_ = _root.bl.diceScoreContainer.attachMovie("mc_DiceScore","score",bl.diceScoreContainer.getNextHighestDepth());
   }
   else
   {
      _loc3_ = _root.bl.diceScoreContainer.score;
   }
   var _loc11_;
   var _loc9_;
   var _loc10_;
   var _loc8_;
   var _loc6_;
   var _loc7_;
   var _loc2_;
   var _loc5_;
   var _loc4_;
   if(badgePlayerName == "" && badgeNPCName == "")
   {
      _loc3_.inside.gotoAndStop(2);
      _loc3_.inside.line0.gotoAndStop("short");
      _loc3_.inside.line1.gotoAndStop("short");
   }
   else
   {
      _loc3_.inside.gotoAndStop(1);
      _loc3_.inside.line0.gotoAndStop("long");
      _loc3_.inside.line1.gotoAndStop("long");
      _loc3_.inside.badgeLabel.text = Enum.LOCALIZABLE_TOKEN + "ui_dice_badge";
      _loc3_.inside.badgePlayerName.text = badgePlayerName;
      _loc3_.inside.badgeNPCName.text = badgeNPCName;
      _loc11_ = 200 + (_loc3_.inside.badgePlayerName.numLines - 1) * 26;
      _loc9_ = 200 + (_loc3_.inside.badgeNPCName.numLines - 1) * 26;
      _loc10_ = 3;
      _loc8_ = 1;
      _loc6_ = 2;
      _loc7_ = 3;
      _loc2_ = 0;
      while(_loc2_ < _loc10_)
      {
         _loc5_ = _loc2_ < badgePlayerTotal ? (_loc2_ < badgePlayerCurrent ? _loc6_ : _loc7_) : _loc8_;
         _loc4_ = _loc2_ < badgeNPCTotal ? (_loc2_ < badgeNPCCurrent ? _loc6_ : _loc7_) : _loc8_;
         _loc3_.inside["playerBadgeMark" + _loc2_]._y = _loc11_;
         _loc3_.inside["npcBadgeMark" + _loc2_]._y = _loc9_;
         _loc3_.inside["playerBadgeMark" + _loc2_].gotoAndStop(_loc5_);
         _loc3_.inside["npcBadgeMark" + _loc2_].gotoAndStop(_loc4_);
         _loc2_ = _loc2_ + 1;
      }
   }
   _loc3_.inside.goalLabel.text = Enum.LOCALIZABLE_TOKEN + "ui_dice_goal";
   _loc3_.inside.playerLabel.text = playerName;
   _loc3_.inside.NPCLabel.text = Enum.LOCALIZABLE_TOKEN + "ui_dice_opponent";
   _loc3_.inside.totalNumber.text = targetScore;
   _loc3_.inside.totalPlayerNumber.text = totalPlayer;
   _loc3_.inside.totalNPCNumber.text = totalNPC;
   _loc3_.inside.roundLabel.text = Enum.LOCALIZABLE_TOKEN + "ui_dice_round";
   _loc3_.inside.roundPlayerNumber.text = currentPlayer;
   _loc3_.inside.roundNPCNumber.text = currentNPC;
   _loc3_.inside.selectedLabel.text = Enum.LOCALIZABLE_TOKEN + "ui_dice_selected";
   _loc3_.inside.selectedPlayerNumber.text = selectedPlayer;
   _loc3_.inside.selectedNPCNumber.text = selectedNPC;
   if(_loc3_._currentframe == 1 || _loc3_._currentframe > 15)
   {
      _loc3_.gotoAndPlay("show");
   }
}
function fc_hideDiceScore()
{
   _root.bl.diceScoreContainer.score.gotoAndPlay("hide");
}
function removeDiceScore()
{
   if(_root.bl.diceScoreContainer.score)
   {
      _root.bl.diceScoreContainer.score.removeMovieClip();
   }
}
function fc_addDiceSelector(selectorId, xPos, yPos, isPlayer)
{
   var _loc2_;
   if(_root.cccursor.dice["selector" + selectorId])
   {
      _loc2_ = _root.cccursor.dice["selector" + selectorId];
   }
   else
   {
      _loc2_ = _root.cccursor.dice.attachMovie("mc_DiceSelector","selector" + selectorId,cccursor.dice.getNextHighestDepth());
      _root.cccursor.dice.flag.swapDepths(_loc2_.getDepth() + 1);
   }
   _loc2_.gotoAndStop(!isPlayer ? 2 : 1);
   _loc2_._x = xPos;
   _loc2_._y = yPos;
}
function fc_removeDiceSelector(selectorId)
{
   if(_root.cccursor.dice["selector" + selectorId])
   {
      _root.cccursor.dice["selector" + selectorId].removeMovieClip();
   }
}
function fc_showDiceCursor(xPos, yPos)
{
   _root.cccursor.dice.flag._x = _root.cccursor.dice.cursor._x = xPos;
   _root.cccursor.dice.flag._y = _root.cccursor.dice.cursor._y = yPos;
   if(_root.cccursor.dice.cursor._currentframe == 1)
   {
      _root.cccursor.dice.cursor.gotoAndStop(2);
   }
}
function fc_hideDiceCursor()
{
   _root.cccursor.dice.cursor.gotoAndStop(1);
   _root.cccursor.dice.flag.gotoAndStop(1);
}
function fc_showDiceProperties(diceName, diceValue)
{
   var _loc2_ = _root.cccursor.dice.flag;
   _loc2_.gotoAndPlay("show");
   _loc2_.inside.icon.gotoAndStop(diceValue + 1);
   _loc2_.inside.tField.text = diceName;
   var _loc3_ = 10;
   var _loc4_ = _loc2_.inside.icon._width + _loc2_.inside.tField.textWidth + (diceName == "" ? 0 : _loc3_);
   _loc2_.inside.icon._x = - _loc4_ / 2;
   _loc2_.inside.tField._x = _loc2_.inside.icon._x + _loc2_.inside.icon._width + _loc3_;
}
function fc_hideDiceProperties()
{
   if(_root.cccursor.dice.flag._currentframe < 6 && _root.cccursor.dice.flag._currentframe != 1)
   {
      _root.cccursor.dice.flag.gotoAndPlay("hide");
   }
}
function fc_showShootingContestTable(playerName, opponentName1, opponentName2, playerArrows, opponentArrows1, opponentArrows2, isTargetVisible)
{
   var _loc2_;
   if(_root.bl.shootingContest.mc_ShootingContest)
   {
      DebugTrace.log("mc_ShootingContest already set",DebugTrace.C_WARRNING,"fc_hideShootingContestTable");
      _loc2_ = _root.bl.shootingContest.mc_ShootingContest;
   }
   else
   {
      _loc2_ = _root.bl.shootingContest.attachMovie("mc_ShootingContest","mc_ShootingContest",bl.shootingContest.getNextHighestDepth());
   }
   _loc2_.inside.gotoAndStop(!isTargetVisible ? Enum.SHOOTING_BIRD : Enum.SHOOTING_TARGET);
   _loc2_.inside.tfPlayerName.text = playerName;
   _loc2_.inside.numbers.tfPlayerArrows.text = playerArrows;
   _loc2_.inside.numbers.tfPlayerPoints.text = "0";
   _loc2_.inside.tfOpponentName1.text = opponentName1;
   _loc2_.inside.numbers.tfOpponentArrows1.text = opponentArrows1;
   _loc2_.inside.numbers.tfOpponentPoints1.text = "0";
   if(opponentName2 != "")
   {
      _loc2_.inside.tfOpponentName2.text = opponentName2;
      _loc2_.inside.numbers.tfOpponentArrows2.text = opponentArrows2;
      _loc2_.inside.numbers.tfOpponentPoints2.text = "0";
   }
   else
   {
      _loc2_.inside.tfOpponentName2.text = "";
      _loc2_.inside.numbers.tfOpponentArrows2.text = "";
      _loc2_.inside.numbers.tfOpponentPoints2.text = "";
   }
   if(isTargetVisible)
   {
      _loc2_.inside.targetArea.cross.gotoAndStop(1);
   }
   var _loc3_ = 0;
   var _loc4_ = _loc2_.inside.numbers._x - _loc2_.inside.tfPlayerName._x;
   _loc3_ = _loc2_.inside.tfPlayerName.textWidth;
   _loc3_ = _loc3_ >= _loc2_.inside.tfOpponentName1.textWidth ? _loc3_ : _loc2_.inside.tfOpponentName1.textWidth;
   _loc3_ = _loc3_ >= _loc2_.inside.tfOpponentName2.textWidth ? _loc3_ : _loc2_.inside.tfOpponentName2.textWidth;
   if(_loc3_ > _loc4_)
   {
      _loc2_.inside.numbers._x += _loc3_ - _loc4_;
   }
   _loc2_.gotoAndPlay("on");
}
function fc_hideShootingContestTable()
{
   if(!_root.bl.shootingContest.mc_ShootingContest)
   {
      DebugTrace.log("No mc_ShootingContest",DebugTrace.C_WARRNING,"fc_hideShootingContestTable");
      return undefined;
   }
   _root.bl.shootingContest.mc_ShootingContest.gotoAndPlay("off");
}
function removeShootingContestTable()
{
   if(_root.bl.shootingContest.mc_ShootingContest)
   {
      flash.external.ExternalInterface.call("onShootingContestRemoved");
      _root.bl.shootingContest.mc_ShootingContest.removeMovieClip();
   }
}
function fc_updateShootingContestTable(playerArrows, opponentArrows1, opponentArrows2, playerPoints, opponentPoints1, opponentPoints2)
{
   var _loc2_ = _root.bl.shootingContest.mc_ShootingContest;
   if(!_loc2_)
   {
      DebugTrace.log("No mc_ShootingContest",DebugTrace.C_WARRNING,"fc_updateShootingContestTable");
      return undefined;
   }
   _loc2_.inside.numbers.tfPlayerArrows.text = playerArrows;
   _loc2_.inside.numbers.tfPlayerPoints.text = playerPoints;
   if(opponentArrows1 >= 0)
   {
      _loc2_.inside.numbers.tfOpponentArrows1.text = opponentArrows1;
      _loc2_.inside.numbers.tfOpponentPoints1.text = opponentPoints1;
   }
   else
   {
      _loc2_.inside.numbers.tfOpponentArrows1.text = "";
      _loc2_.inside.numbers.tfOpponentPoints1.text = "";
   }
   if(opponentArrows2 >= 0)
   {
      _loc2_.inside.numbers.tfOpponentArrows2.text = opponentArrows2;
      _loc2_.inside.numbers.tfOpponentPoints2.text = opponentPoints2;
   }
   else
   {
      _loc2_.inside.numbers.tfOpponentArrows2.text = "";
      _loc2_.inside.numbers.tfOpponentPoints2.text = "";
   }
}
function fc_showShootingHit(xPos, yPos)
{
   var _loc2_ = _root.bl.shootingContest.mc_ShootingContest;
   if(!_loc2_)
   {
      DebugTrace.log("No mc_ShootingContest",DebugTrace.C_WARRNING,"fc_showShootingHit");
      return undefined;
   }
   _loc2_.inside.targetArea.cross._x = xPos * 55;
   _loc2_.inside.targetArea.cross._y = yPos * 55 * -1;
   _loc2_.inside.targetArea.cross.gotoAndPlay("show");
}
function fc_showHorseShootingContestTable(playerName, opponentName, playerScore, opponentScore, trackName)
{
   var _loc2_;
   if(_root.bl.shootingContest.mc_ShootingContest)
   {
      DebugTrace.log("mc_ShootingContest already set",DebugTrace.C_WARRNING,"fc_hideShootingContestTable");
      _loc2_ = _root.bl.shootingContest.mc_ShootingContest;
   }
   else
   {
      _loc2_ = _root.bl.shootingContest.attachMovie("mc_ShootingContest","mc_ShootingContest",bl.shootingContest.getNextHighestDepth());
   }
   _loc2_.inside.gotoAndStop(Enum.SHOOTING_HORSE);
   _loc2_.inside.tfPlayerName.text = playerName;
   _loc2_.inside.numbers.tfPlayerPoints.text = playerScore;
   _loc2_.inside.tfOpponentName.text = opponentName;
   _loc2_.inside.numbers.tfOpponentPoints.text = opponentScore;
   _loc2_.inside.tfTrackName.text = trackName;
   var _loc3_ = 0;
   var _loc4_ = _loc2_.inside.numbers._x - _loc2_.inside.tfPlayerName._x;
   _loc3_ = _loc2_.inside.tfPlayerName.textWidth;
   _loc3_ = _loc3_ >= _loc2_.inside.tfOpponentName.textWidth ? _loc3_ : _loc2_.inside.tfOpponentName.textWidth;
   if(_loc3_ > _loc4_)
   {
      _loc2_.inside.numbers._x += _loc3_ - _loc4_;
   }
   _loc2_.gotoAndPlay("on");
}
function fc_hideHorseShootingContestTable()
{
   fc_hideShootingContestTable();
}
function fc_updateHorseShootingContestTable(playerScore)
{
   var _loc2_ = _root.bl.shootingContest.mc_ShootingContest;
   if(!_loc2_)
   {
      DebugTrace.log("No mc_ShootingContest",DebugTrace.C_WARRNING,"fc_updateHorseShootingContestTable");
      return undefined;
   }
   _loc2_.inside.numbers.tfPlayerPoints.text = playerScore;
}
function fc_setFaderState(state, layout)
{
   var _loc2_;
   if(state == Enum.FADER_LAYOUT_START)
   {
      popUpVisual.gotoAndStop("layoutInit");
      if(layout != "")
      {
         _loc2_ = new MovieClipLoader();
         _loc2_.loadClip("img://Libs/UI/Textures/Overlays/" + layout + "_ui.dds",popUpVisual.image);
      }
      popUpVisual.gotoAndPlay(Enum.GetFaderState(state));
   }
   else if(state == Enum.FADER_LAYOUT_STOP)
   {
      popUpVisual.gotoAndPlay(Enum.GetFaderState(state));
   }
   else
   {
      if(popUp._currentframe == 1 && (state == Enum.FADER_STOP || state == Enum.FADER_OFF || state == Enum.FADER_FAST_OFF || state == Enum.FADER_INACTIVE))
      {
         return undefined;
      }
      popUp.gotoAndPlay(Enum.GetFaderState(state));
   }
}
function fc_setFullModeVignette(value)
{
   var _loc1_ = Enum.SCREEN_WIDTH * 0.5 * value;
   vignette.left._x = _loc1_;
   vignette.right._x = Enum.SCREEN_WIDTH - _loc1_;
}
function setBubblesBackground()
{
   var _loc3_ = 1;
   var _loc4_;
   var _loc2_;
   var _loc5_;
   while(_loc3_ <= Enum.BUBBLE_COUNT)
   {
      _loc4_ = this.cccursor.bubbles[Enum.BUBBLE_NAME_CORE + _loc3_];
      _loc2_ = _loc4_.inside.mc_textBgHolder;
      if(!_loc2_)
      {
         return undefined;
      }
      _loc5_ = this.g_IsSpeechBackgroundVisible;
      _loc2_._visible = _loc5_;
      if(_loc5_)
      {
         TextBackground.Set(_loc4_.inside.tfText,"mc_textBg",_loc2_);
      }
      _loc3_ = _loc3_ + 1;
   }
}
function setSubtitlesBackground()
{
   if(bc.subtitles.inside.tField.length == 0)
   {
      return undefined;
   }
   bc.subtitles.inside._visible = true;
   var _loc1_ = bc.subtitles.inside.mc_textBgHolder;
   if(!_loc1_)
   {
      return undefined;
   }
   var _loc2_ = g_IsSpeechBackgroundVisible;
   var _loc3_;
   if(g_IsSpeechBackgroundVisible == false)
   {
      if(g_RatioPreset == Enum.RATIO_PRESET_DIALOG || g_RatioPreset == Enum.RATIO_PRESET_CUTSCENE)
      {
         _loc3_ = getBottomStripPosition();
         if(_loc3_ <= 0 || bc.subtitles.inside.tField.textHeight > _loc3_)
         {
            _loc2_ = true;
         }
      }
   }
   _loc1_._visible = _loc2_;
   if(_loc2_)
   {
      TextBackground.Set(bc.subtitles.inside.tField,"mc_textBg",_loc1_);
   }
}
function setTextSize(tf, size)
{
   var _loc1_ = new TextFormat();
   _loc1_.size = size;
   tf.setTextFormat(_loc1_);
}
function setTextFormatOptional(tf, size, optionalAlign, color)
{
   var _loc1_ = new TextFormat();
   _loc1_.align = optionalAlign;
   _loc1_.size = size;
   _loc1_.color = ColorScheme.GetHexNumber(color);
   tf.setTextFormat(_loc1_);
}
function hideAllBubbles()
{
   var _loc1_ = 1;
   var _loc2_;
   while(_loc1_ <= Enum.BUBBLE_COUNT)
   {
      _loc2_ = cccursor.bubbles[Enum.BUBBLE_NAME_CORE + _loc1_];
      _loc2_._visible = false;
      _loc1_ = _loc1_ + 1;
   }
}
function setPlayingNotificationManager(manager, play, flush, priority)
{
   if(play)
   {
      manager.Play();
   }
   else
   {
      if(flush)
      {
         manager.RemoveAndFlush(priority);
      }
      manager.RemoveVisitedAndPause(Enum.C_NOTIFICATION_DURATION_LEFT,priority);
   }
}
_global.gfxExtensions = true;
Stage.scaleMode = "noScale";
Stage.align = "TL";
TextExtension.ButtonsScale = 1.2;
var C_EASING_FUNCTION_CUBIC = Easing.cubicInOut;
var C_EASING_FUNCTION_LINEAR = Easing.linear;
var g_Framerate = 60;
var g_PeridicalObservable;
var g_InputIdObservable;
var g_CountingInterval;
var g_CooldownManager;
var g_FancyNotifMngr;
var g_InfoTextNotifMngr;
var g_ItemTransferNotifMngr;
var g_SkillCheckNotifMngr;
var g_CommonNotifMngr;
var g_BuffLeftNotifMngr;
var g_BuffRightNotifMngr;
var g_TutorialNotifMngr;
var g_TutorialInDialogNotifMngr;
var g_GameLogNotifMngr;
var g_ActionHintNotifMngr;
var g_ApseTopLeftActionHintNotifMngr;
var g_ApseTopRightActionHintNotifMngr;
var g_ApseBottomLeftActionHintNotifMngr;
var g_ApseTopCenterActionHintNotifMngr;
var g_ApseBottomCenterActionHintNotifMngr;
var g_ApseBottomRightActionHintNotifMngr;
var g_DialogIconLeftNotifMngr;
var g_DialogIconRightNotifMngr;
var g_CrimeListData;
var g_CrimeListView;
var g_currSizeX;
var g_currSizeY;
var g_InputId;
var g_GameMode;
var g_GameDude;
var g_RatioPreset;
var g_DialogState;
var g_TrespassState;
var g_CrimeState;
var g_WantedState;
var g_QAMWeapon;
var g_QAMFood;
var g_QAMType;
var g_MarkersO;
var g_QuestAreaCounter;
var g_QuestLockedCounter;
var g_DialogSequencesA;
var g_DialogSequenceSelected;
var g_DialogCrimeListMC;
var g_DialogHaggle;
var g_TooltipMC;
var g_QAMArrowsMC;
var g_DraggedMC;
var g_IsSpeechBackgroundVisible;
var g_IsSpeakerNameEnabled;
var g_CodexActionHintPerkId = "";
var g_SpeachFontSize = Enum.FONT_SIZE_DEFAULT;
var hideCursor = false;
var actionCursorHidden = false;
var g_SequencesA;
var g_QAMSlotsA;
var g_SkillChecksA;
var g_CrimeListDataA;
var g_ActionHintsA;
var g_CompassMarkersA;
var g_dummyLoader = new MovieClipLoader();
var g_ForgeInfoMoneyTextExtension;
var g_ForgeInfoPrestigeTextExtension;
var g_ForgeCameraScale;
Init();
