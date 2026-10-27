function cry_onResize(_intWidth, _intHeight, _intScreenWidth, _intScreenHeight)
{
   g_Width = _intScreenWidth;
   g_Height = _intScreenHeight;
   var _loc4_ = Math.min(g_Width / 1920,g_Height / 1080);
   var _loc2_ = 1920 / g_Width * _loc4_;
   var _loc3_ = 1080 / g_Height * _loc4_;
   _root.modalDialogAnchor._xscale = _loc2_ * 100;
   _root.modalDialogAnchor._yscale = _loc3_ * 100;
   _root.main._xscale = _loc2_ * 100;
   _root.main._yscale = _loc3_ * 100;
   _root.modalDialogAnchor._x = _root.main._width / 2 + 20 * _loc2_;
   _root.modalDialogAnchor._y = _root.main._y;
}
function fc_activate(animate)
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_activate");
}
function fc_deactivate(animate)
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_deactivate");
}
function fc_open(mode, heading)
{
   DebugTrace.log("mode " + mode,DebugTrace.C_DEBUG,"fc_open");
   InventoryData.s_CgModal = false;
   g_Mode = mode + InvEnum.MODE_FILTER;
   _root.main.gotoAndPlay(2);
   g_Content.gotoAndStop(InvEnum.GetFrameByMode(g_Mode));
   if(heading != "")
   {
      g_Content.tfHeading.text = heading;
   }
   else if(g_Mode == InvEnum.MODE_FILTER)
   {
      g_Content.tfHeading.text = InvEnum.TEXT_SELECT_ITEM_USE;
   }
   else if(g_Mode == InvEnum.MODE_MULTISELECT || g_Mode == InvEnum.MODE_MINIGAME || g_Mode == InvEnum.MODE_MINIGAME_NO_AMOUNT)
   {
      g_Content.tfHeading.text = InvEnum.TEXT_SELECT_ITEMS_USE;
   }
   else if(g_Mode == InvEnum.MODE_REPAIR)
   {
      g_Content.tfHeading.text = InvEnum.TEXT_SELECT_ITEMS_REPAIR;
   }
   else if(g_Mode == InvEnum.MODE_WASH)
   {
      g_Content.tfHeading.text = InvEnum.TEXT_SELECT_ITEMS_WASH;
   }
   if(g_Mode == InvEnum.MODE_REPAIR)
   {
      g_Content.additionalInfo.tfText.text = InvEnum.TEXT_REPAIR;
      InitAdditionalInfo();
   }
   else if(g_Mode == InvEnum.MODE_WASH)
   {
      g_Content.additionalInfo.tfText.text = InvEnum.TEXT_WASH;
      InitAdditionalInfo();
   }
   InitSortButtons();
   InitCategoryToggleButton();
   ShowBackground();
   Audio.Play(Audio.OPEN_HALF);
}
function fc_close(force)
{
   InventoryData.s_CgLastState = "none";
   InventoryData.CgLog("state=none");
   DebugTrace.log("force: " + force,DebugTrace.C_DEBUG,"fc_close");
   if(force)
   {
      _root.main.gotoAndStop(20);
   }
   else
   {
      _root.main.gotoAndPlay(10);
   }
   HideBackground();
   Audio.Play(Audio.CLOSE_HALF);
}
function fc_getFocusedItem()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_getFocusedItem");
   var _loc1_ = g_Data.FocusedItem;
   if(_loc1_ && _loc1_.IsColourGroup)
   {
      return g_Data.CgTransferIds(_loc1_);
   }
   if(_loc1_)
   {
      return _loc1_.GetStackIds();
   }
   return "";
}
function fc_focusPrev()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_focusPrev");
   var _loc1_ = g_Data.FocusPrev();
   if(_loc1_ == TreeData.E_FOCUS_RESULT_SUCCESS)
   {
      Audio.Play(Audio.APSE_FOCUS);
   }
}
function fc_focusNext()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_focusNext");
   var _loc1_ = g_Data.FocusNext();
   if(_loc1_ == TreeData.E_FOCUS_RESULT_SUCCESS)
   {
      Audio.Play(Audio.APSE_FOCUS);
   }
}
function fc_tabPrev()
{
}
function fc_tabNext()
{
}
function fc_sortPrev()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_sortPrev");
   g_Data.SortPrev(UpdateSortButtons);
}
function fc_sortNext()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_sortNext");
   g_Data.SortNext(UpdateSortButtons);
}
function fc_toggleCategory()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_toggleCategory");
   if(g_CgTcPending != undefined)
   {
      clearInterval(g_CgTcPending);
      g_CgTcPending = undefined;
      g_Data.CgHoldSignal();
      return undefined;
   }
   g_CgTcPending = setInterval(cgTcFire,120);
}
function cgTcFire()
{
   clearInterval(g_CgTcPending);
   g_CgTcPending = undefined;
   var data = g_Data;
   InventoryData.CgLog("toggle_category");
   if(!data.CgToggle("l3"))
   {
      if(getTimer() - InventoryData.s_CgLeftGroupAt < 400)
      {
         InventoryData.CgLog("l3 ignored: focus left a group row " + (getTimer() - InventoryData.s_CgLeftGroupAt) + " ms ago");
      }
      else
      {
         data.ToggleHeadingVisibility(UpdateCategoryButton);
      }
   }
}
var g_CgTcPending;
function fc_setAdditionalInfo(value, capacity)
{
   DebugTrace.log(value + "/" + capacity,DebugTrace.C_DEBUG,"fc_setAdditionalInfo");
   g_Content.additionalInfo.gotoAndStop(g_Mode != InvEnum.MODE_REPAIR ? 2 : 1);
   var _loc4_ = MathExtension.RoundBigNumber(value,1,MathExtension.INFINITY,true);
   var _loc2_ = MathExtension.RoundBigNumber(capacity,1,MathExtension.INFINITY,true);
   var _loc3_ = value <= capacity ? ColorScheme.DARK_EMPHASIS : ColorScheme.DARK_NEGATIVE;
   TextExtension.setText("<FONT COLOR=\'" + _loc3_ + "\'>" + _loc4_ + "/" + _loc2_ + "</FONT>",g_Content.additionalInfo.tfNumber);
   if(value == 0)
   {
      g_Content.additionalInfo.icon._x = -53 - g_Content.additionalInfo.tfNumber.textWidth * 1.4 - 10;
   }
}
function fc_setQuestInfo(mode, labels, currents, optimums, states)
{
   DebugTrace.log(currents.toString() + "/" + optimums.toString(),DebugTrace.C_DEBUG,"fc_setQuestInfo");
   var _loc7_ = labels.split(InvEnum.SPLIT_TOKEN);
   var _loc4_ = currents.split(InvEnum.SPLIT_TOKEN);
   var _loc2_ = optimums.split(InvEnum.SPLIT_TOKEN);
   var _loc3_ = states.split(InvEnum.SPLIT_TOKEN);
   var _loc5_ = Math.min(_loc7_.length,InvEnum.QUEST_DELIVERY_COUNT);
   g_Content.additionalInfo.gotoAndStop(_loc5_);
   var _loc6_ = true;
   var _loc1_ = 0;
   while(_loc1_ < _loc5_)
   {
      _loc6_ &= Number(_loc4_[_loc1_]) == 0;
      if(mode == InvEnum.DELIVERY_MODE_INF)
      {
         _loc2_[_loc1_] = "<font size=\'28\'> " + InvEnum.INF_SYMBOL + "</font>";
      }
      TextExtension.setText(_loc7_[_loc1_],g_Content.additionalInfo["tfLabel" + _loc1_],InvEnum.GetHtmlQuestInfoState(Number(_loc3_[_loc1_])));
      TextExtension.setText(_loc4_[_loc1_] + "/" + _loc2_[_loc1_],g_Content.additionalInfo["tfNumber" + _loc1_],InvEnum.GetHtmlQuestInfoState(Number(_loc3_[_loc1_])));
      _loc1_ = _loc1_ + 1;
   }
   var _loc9_;
   if(_loc6_)
   {
      if(_loc5_ == 1)
      {
         _loc9_ = g_Content.additionalInfo.tfLabel0.textWidth + g_Content.additionalInfo.tfNumber0.textWidth * 1.7;
         g_Content.additionalInfo.tfLabel0._x = 438 - _loc9_ / 2;
         g_Content.additionalInfo.tfNumber0._x = 438 + _loc9_ / 2 - g_Content.additionalInfo.tfNumber0._width;
      }
      else if(_loc5_ == 2)
      {
         g_Content.additionalInfo.tfLabel0._x = 408 - g_Content.additionalInfo.tfNumber0.textWidth * 1.7 - g_Content.additionalInfo.tfLabel0._width;
         g_Content.additionalInfo.tfNumber0._x = 408 - g_Content.additionalInfo.tfNumber0._width;
         g_Content.additionalInfo.tfLabel1._x = 468;
         g_Content.additionalInfo.tfNumber1._x = 468 + g_Content.additionalInfo.tfLabel1.textWidth + g_Content.additionalInfo.tfNumber1.textWidth * 1.7 - g_Content.additionalInfo.tfNumber1._width;
      }
      else if(_loc5_ == 3)
      {
         g_Content.additionalInfo.tfLabel0._x = 408 - g_Content.additionalInfo.tfNumber0.textWidth * 1.7 - g_Content.additionalInfo.tfLabel0._width;
         g_Content.additionalInfo.tfNumber0._x = 408 - g_Content.additionalInfo.tfNumber0._width;
         g_Content.additionalInfo.tfLabel1._x = 408 - g_Content.additionalInfo.tfNumber1.textWidth * 1.7 - g_Content.additionalInfo.tfLabel1._width;
         g_Content.additionalInfo.tfNumber1._x = 408 - g_Content.additionalInfo.tfNumber1._width;
         g_Content.additionalInfo.tfLabel2._x = 468;
         g_Content.additionalInfo.tfNumber2._x = 468 + g_Content.additionalInfo.tfLabel2.textWidth + g_Content.additionalInfo.tfNumber2.textWidth * 1.7 - g_Content.additionalInfo.tfNumber2._width;
      }
   }
}
function fc_setItems(idx)
{
   DebugTrace.log("g_ItemsA: " + g_ItemsA.join(","),DebugTrace.C_DEBUG,"fc_setItems");
   g_Data.SetDataFromArray(g_ItemsA);
   g_Data.FocusFirst();
   g_ItemsA.length = 0;
}
function fc_clearItems(idx)
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_clearItems");
   g_Data.Clear();
}
function fc_addItem(idx)
{
   DebugTrace.log("g_ItemsA: " + g_ItemsA.join(","),DebugTrace.C_DEBUG,"fc_addItem");
   var _loc1_ = g_ItemsA[0];
   var _loc2_ = new InventoryItem(_loc1_);
   g_ItemsA.shift();
   _loc2_.Set(g_ItemsA);
   var _loc3_ = g_Data.Add(_loc2_);
   if(!_loc3_)
   {
      DebugTrace.log("Try to add item which  already is in list: " + _loc1_,DebugTrace.C_ERROR,"fc_addItem");
   }
   g_ItemsA.length = 0;
}
function fc_removeItem(id, idx)
{
   DebugTrace.log(id,DebugTrace.C_DEBUG,"fc_removeItem");
   g_Data.Remove(id);
   UpdateMoney();
}
function fc_changeItem(idx)
{
   DebugTrace.log("g_ItemsA: " + g_ItemsA.join(","),DebugTrace.C_DEBUG,"fc_changeItem");
   g_Data.ChangeItem(g_ItemsA);
   g_ItemsA.length = 0;
}
function fc_changeSelection(id, isSelected)
{
   DebugTrace.log("is: " + id + ", isSelected: " + isSelected,DebugTrace.C_DEBUG,"fc_changeSelection");
   g_Data.ChangeSelection(id,isSelected);
}
function fc_setCarriedWeight(carriedWeight, inventoryId, isEncumbered)
{
   DebugTrace.log("carriedWeight: " + carriedWeight + ", inventoryId: " + inventoryId,DebugTrace.C_DEBUG,"fc_setCarriedWeight");
   g_PlayerCarriedWeight = carriedWeight;
   g_PlayerIsEncumbered = isEncumbered;
   UpdateWeight();
}
function fc_setCapacity(capacity, inventoryId, isEncumbered)
{
   DebugTrace.log("capacity: " + capacity + ", inventoryId: " + inventoryId,DebugTrace.C_DEBUG,"fc_setCapacity");
   g_PlayerCapacity = capacity;
   g_PlayerIsEncumbered = isEncumbered;
   UpdateWeight();
}
function fc_setMoney(money)
{
   DebugTrace.log("money: " + money,DebugTrace.C_DEBUG,"fc_setMoney");
   UpdateMoney(money);
}
function fc_openAmountDialog(min, max, def, step, actionConfirm, actionCancel, hintConfirm, hintCancel)
{
   DebugTrace.log(min + ", " + max + ", " + def + ", " + step + ", " + actionConfirm + ", " + actionCancel + ", " + hintConfirm + ", " + hintCancel,DebugTrace.C_DEBUG,"fc_openAmountDialog");
   InventoryData.CgModal(true);
   if(g_ModalDialogAmount)
   {
      if(!g_ModalDialogAmount.IsClosing)
      {
         DebugTrace.log("Amount Dialog is already open",DebugTrace.C_ERROR,"fc_openAmountDialog");
         return undefined;
      }
      g_ModalDialogAmount.Remove();
      g_ModalDialogAmount = undefined;
   }
   g_ModalDialogAmount = new ModalDialogAmount("mc_modalDialogAmount",min,max,def,step,actionConfirm,actionCancel,hintConfirm,hintCancel);
   ShowBackgroundModal();
}
function fc_closeAmountDialog()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_closeCountingDialog");
   InventoryData.CgModal(false);
   g_Data.CgReportState(g_Data.FocusedItem,true);
   if(!g_ModalDialogAmount)
   {
      DebugTrace.log("Amount Dialog is not open",DebugTrace.C_ERROR,"fc_closeAmountDialog");
      return undefined;
   }
   g_ModalDialogAmount.Close();
   HideBackgroundModal();
}
function fc_setMoreAmountDialog()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_setMoreCountingDialog");
   if(!g_ModalDialogAmount)
   {
      DebugTrace.log("Amount Dialog is not open",DebugTrace.C_ERROR,"fc_setMoreAmountDialog");
      return undefined;
   }
   g_ModalDialogAmount.SetMore();
}
function fc_setLessAmountDialog()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_setLessCountingDialog");
   if(!g_ModalDialogAmount)
   {
      DebugTrace.log("Amount Dialog is not open",DebugTrace.C_ERROR,"fc_setLessCountingDialog");
      return undefined;
   }
   g_ModalDialogAmount.SetLess();
}
function fc_setMaxAmountDialog()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_setMaxAmountDialog");
   if(!g_ModalDialogAmount)
   {
      DebugTrace.log("Amount Dialog is not open",DebugTrace.C_ERROR,"fc_setMaxAmountDialog");
      return undefined;
   }
   g_ModalDialogAmount.SetMax();
}
function fc_setMinAmountDialog()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_setMinAmountDialog");
   if(!g_ModalDialogAmount)
   {
      DebugTrace.log("Amount Dialog is not open",DebugTrace.C_ERROR,"fc_setMinAmountDialog");
      return undefined;
   }
   g_ModalDialogAmount.SetMin();
}
function fc_getAmountDialogValue()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_setLessCountingDialog");
   if(!g_ModalDialogAmount)
   {
      DebugTrace.log("Amount Dialog is not open",DebugTrace.C_ERROR,"fc_setLessCountingDialog");
      return undefined;
   }
   return g_ModalDialogAmount.Value;
}
function fc_openInfoDialog(info, action, hint)
{
   DebugTrace.log(info + ", " + action + ", " + hint,DebugTrace.C_DEBUG,"fc_openInfoDialog");
   InventoryData.CgModal(true);
   if(g_ModalDialogInfo)
   {
      DebugTrace.log("Info Dialog is already open",DebugTrace.C_ERROR,"fc_openInfoDialog");
      return undefined;
   }
   g_ModalDialogInfo = new ModalDialogInfo("mc_modalDialogInfoQuestion",info,action,hint);
   ShowBackgroundModal();
}
function fc_closeInfoDialog()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_closeInfoDialog");
   InventoryData.CgModal(false);
   g_Data.CgReportState(g_Data.FocusedItem,true);
   if(!g_ModalDialogInfo)
   {
      DebugTrace.log("Info Dialog is not open",DebugTrace.C_ERROR,"fc_closeInfoDialog");
      return undefined;
   }
   g_ModalDialogInfo.Close();
   HideBackgroundModal();
}
function fc_setItemInfo()
{
   DebugTrace.log("g_ItemInfoA: " + g_ItemInfoA.join(","),DebugTrace.C_DEBUG,"fc_setItemInfo");
   g_ItemInfo.Set(g_ItemInfoA);
   g_ItemInfoA.length = 0;
}
function fc_clearItemInfo()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_clearItemInfo");
   g_ItemInfo.Clear();
}
function fc_setItemInfoVisibility(visibity)
{
   var _loc6_ = 1;
   var _loc3_ = 2;
   var _loc4_ = 15;
   var _loc2_ = 16;
   var _loc1_ = 30;
   if(visibity == g_ItemInfoVisible)
   {
      return undefined;
   }
   if(visibity == false)
   {
      g_Content.itemInfo.gotoAndPlay(MathExtension.InvertFrameAnimation(g_Content.itemInfo._currentframe,_loc3_,_loc4_,_loc2_,_loc1_));
   }
   else
   {
      g_Content.itemInfo.gotoAndPlay(MathExtension.InvertFrameAnimation(g_Content.itemInfo._currentframe,_loc2_,_loc1_,_loc3_,_loc4_));
   }
   g_ItemInfoVisible = visibity;
   Audio.Play(!g_ItemInfoVisible ? Audio.HALF_INFO_HIDE : Audio.HALF_INFO_SHOW);
}
function fc_setOutfitFlag(outfit)
{
   DebugTrace.log("outfit: " + outfit,DebugTrace.C_DEBUG,"fc_setOutfitFlag");
   g_CurrentOutfit = outfit;
   g_Data.UpdateCurrentOutfit(g_CurrentOutfit);
}
function fc_updateOutfitFlag(newOutfit, oldOutfit)
{
   DebugTrace.log("newOutfit: " + newOutfit + "; oldOutfit: " + oldOutfit,DebugTrace.C_DEBUG,"fc_updateOutfitFlag");
   g_CurrentOutfit = newOutfit;
   g_Data.UpdateCurrentOutfit(g_CurrentOutfit);
}
function fc_setUserConfig(tab, sort, heading, focusId)
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_setUserConfig");
   g_Data.SetFilter(tab,_root.UpdateTabButtons);
   g_Data.SetSort(sort,false,_root.UpdateSortButtons);
   g_Data.SetHeadingVisibility(heading,_root.UpdateCategoryButton);
   g_FocusIdTemp = focusId;
}
function fc_getCurrentTab()
{
   return g_Data.CurrentFilter;
}
function fc_getCurrentSort()
{
   return g_Data.CurrentSort;
}
function fc_getCurrentHeading()
{
   return g_Data.HeadingVisibility;
}
function fc_getCurrentFocusId()
{
   return "";
}
function fc_leftDoubleClick(clientId)
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_leftDoubleClick");
   if(g_ModalDialogAmount || g_ModalDialogInfo)
   {
      return undefined;
   }
   var _loc1_ = g_View.GetIdOnMousePosition();
   if(_loc1_ != undefined && _loc1_ == g_Data.FocusedItem.Id && g_Data.FocusedItem.IsColourGroup)
   {
      return undefined;
   }
   if(_loc1_ != undefined && _loc1_ == g_Data.FocusedItem.Id)
   {
      DebugTrace.log("ExternalInterface.call(onDoubleClicked, " + _loc1_ + " )",DebugTrace.C_DEBUG,"onDoubleClicked");
      flash.external.ExternalInterface.call("onDoubleClicked",_loc1_,clientId);
   }
}
function fc_setInputId(InputId)
{
   DebugTrace.log("InputId: " + InputId,DebugTrace.C_DEBUG,"fc_setInputId");
   g_InputId = InputId;
   g_InputIdObservable.Update();
}
function Init()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"Init");
   g_ItemsA = [];
   g_ItemInfoA = [];
   g_Content = _root.main.inside;
   g_ItemInfoVisible = false;
   g_ItemInfo = new ItemInfo(g_Content.itemInfo.inside.content);
   g_Data = new InventoryData("0");
   g_View = new ItemView(g_Data,g_Content.parentList.inside,55,550);
   g_View.CreateScrollbar(g_Content.scrollbar);
   g_InputIdObservable = new Observable();
   g_MouseScrollDisable = false;
}
function IsMouseScrollDisable(scrollbarMc)
{
   if(g_MouseScrollDisable)
   {
      return true;
   }
   return !scrollbarMc._parent._visible;
}
function UpdateSortButtons(oldSort, newSort)
{
   if(oldSort != undefined)
   {
      g_Content.sortContainer["sort" + Math.floor(oldSort / 2)].highlightFrame.gotoAndStop("unselect");
      Audio.Play(Audio.APSE_SORT);
   }
   g_Content.sortContainer["sort" + Math.floor(newSort / 2)].highlightFrame.gotoAndStop(InvEnum.GetSortFrame(newSort));
}
function InitSortButtons()
{
   var _loc5_ = InvEnum.SORT_PRICE_ASC;
   if(g_Mode == InvEnum.MODE_REPAIR || g_Mode == InvEnum.MODE_WASH)
   {
      _loc5_ = InvEnum.SORT_COST_ASC;
   }
   var _loc3_ = 0;
   while(_loc3_ < _loc5_ / 2 + 1)
   {
      g_Content.sortContainer["sort" + _loc3_].sortId = _loc3_ * 2;
      g_Content.sortContainer["sort" + _loc3_].tooltip = InvEnum.GetSortTooltip(_loc3_ * 2,g_Mode);
      g_Content.sortContainer["sort" + _loc3_].onPress = function()
      {
         _root.g_Data.SetSort(this.sortId,true,_root.UpdateSortButtons);
      };
      g_Content.sortContainer["sort" + _loc3_].onRollOver = function()
      {
         flash.external.ExternalInterface.call("onShowTooltip",this.tooltip);
         this.gotoAndStop(2);
         var _loc2_ = function()
         {
            flash.external.ExternalInterface.call("onHideTooltip",this.tooltip);
            this.gotoAndStop(1);
            delete this.onRollOut;
            delete this.onReleaseOutside;
            delete this.onReleaseOutsideAux;
         };
         this.onRollOut = _loc2_;
         this.onReleaseOutside = _loc2_;
         this.onReleaseOutsideAux = _loc2_;
      };
      _loc3_ = _loc3_ + 1;
   }
   UpdateSortButtons(undefined,g_Data.CurrentSort);
}
function UpdateCategoryButton(oldState, newState)
{
   g_Content.sortContainer.categoryToggle.highlightFrame.gotoAndStop(!newState ? "off" : "on");
   if(oldState != undefined)
   {
      Audio.Play(Audio.APSE_SORT);
   }
}
function InitCategoryToggleButton()
{
   g_Content.sortContainer.categoryToggle.onPress = function()
   {
      _root.g_Data.ToggleHeadingVisibility(_root.UpdateCategoryButton);
   };
   g_Content.sortContainer.categoryToggle.onRollOver = function()
   {
      flash.external.ExternalInterface.call("onShowTooltip","ui_tip_category");
      this.gotoAndStop(2);
      var _loc2_ = function()
      {
         flash.external.ExternalInterface.call("onHideTooltip","ui_tip_category");
         this.gotoAndStop(1);
         delete this.onRollOut;
         delete this.onReleaseOutside;
         delete this.onReleaseOutsideAux;
      };
      this.onRollOut = _loc2_;
      this.onReleaseOutside = _loc2_;
      this.onReleaseOutsideAux = _loc2_;
   };
   UpdateCategoryButton(undefined,g_Data.HeadingVisibility);
}
function InitAdditionalInfo()
{
}
function UpdateMoney(money)
{
   TextExtension.setText(MathExtension.RoundBigNumber(money,1,MathExtension.INFINITY),g_Content.bottomContainer.money.tField,"",true);
}
function UpdateWeight()
{
   DebugTrace.log(g_PlayerCarriedWeight + "/" + g_PlayerCapacity,DebugTrace.C_DEBUG,"UpdateWeight");
   var _loc1_ = !g_PlayerIsEncumbered ? "" : ColorScheme.DARK_NEGATIVE;
   TextExtension.setText(MathExtension.RoundBigNumber(g_PlayerCarriedWeight) + "/" + MathExtension.RoundBigNumber(g_PlayerCapacity),g_Content.bottomContainer.weight.tField,_loc1_,true);
}
function ShowBackground()
{
   _root.popUp.gotoAndPlay("show");
}
function HideBackground()
{
   _root.popUp.gotoAndPlay("hide");
}
function ShowBackgroundModal()
{
   _root.popUp.gotoAndStop("off");
   _root.popUp2.gotoAndStop("on");
}
function HideBackgroundModal()
{
   _root.popUp.gotoAndStop("on");
   _root.popUp2.gotoAndStop("off");
}
function onOpened()
{
   DebugTrace.log("ExternalInterface.call(onOpened)",DebugTrace.C_DEBUG,"onOpened");
   flash.external.ExternalInterface.call("onOpened");
}
function onClosed()
{
   g_Data.Clear();
   DebugTrace.log("ExternalInterface.call(onClosed)",DebugTrace.C_DEBUG,"onClosed");
   flash.external.ExternalInterface.call("onClosed");
}
function onFocusedChanged(id, idRoot)
{
   DebugTrace.log("ExternalInterface.call(onFocusedChanged, " + id + " )",DebugTrace.C_DEBUG,"onFocusedChanged");
   flash.external.ExternalInterface.call("onFocusChanged",id,false,false,Number(idRoot));
}
function onModalDialogAmountClosed()
{
   g_ModalDialogAmount.Remove();
   g_ModalDialogAmount = undefined;
}
function onModalDialogInfoClosed()
{
   g_ModalDialogInfo.Remove();
   g_ModalDialogInfo = undefined;
}
_global.gfxExtensions = true;
Selection.disableFocusKeys = true;
Selection.disableFocusRolloverEvent = true;
var g_Data;
var g_View;
var g_ModalDialogAmount;
var g_ModalDialogInfo;
var g_ItemsA;
var g_ItemInfoA;
var g_ItemInfo;
var g_Content;
var g_CurrentOutfit;
var g_ItemInfoVisible;
var g_Mode;
var g_InputId;
var g_InputIdObservable;
var g_MouseScrollDisable;
var g_PlayerCarriedWeight;
var g_PlayerCapacity;
var g_PlayerIsEncumbered;
var g_Width;
var g_Height;
Init();
counter = 0;
nextTest.onPress = function()
{
   switch(counter)
   {
      case 0:
         fc_open(4);
         break;
      case 1:
         g_ItemsA.push(13);
         g_ItemsA.push("w01","Meč malý",1,1,101,1,5.4,1,12,24,true,false,false,false,0,0.2,0,false,0);
         g_ItemsA.push("w02","Meč malý",1,1,101,1,5.4,0.98,12,24,true,false,false,false,0,0.2,0,false,0);
         g_ItemsA.push("w03","Meč velký",2,1,102,1,7.4,1,14,28,true,false,false,false,0,0.3,0,false,0);
         g_ItemsA.push("w04","Luk",3,1,103,1,3.4,1,12,24,true,true,false,false,0,0.7,0,false,0);
         g_ItemsA.push("w05","Jablko",4,5,104,1,1.4,1,2,1,true,false,false,false,0,0.2,0,false,0);
         g_ItemsA.push("w07","Kniha",6,8,106,1,0,1,12,24,true,false,false,false,0,0.2,0,true,0);
         g_ItemsA.push("w08","Vzácná truhlička",7,0,107,1,0,1,1,2400000,true,false,true,false,0,0.2,0,false,0);
         g_ItemsA.push("w09","Šípy",8,3,108,10,1,1,12,21,true,false,false,false,0,0,0,false,0);
         g_ItemsA.push("w10","Jablko",4,5,109,1,3.4,0.5,2,1,true,false,false,false,0,0,0,false,0);
         g_ItemsA.push("w11","Mapka",10,8,110,1,0,1,12,2,true,false,false,false,0,0,0,false,0);
         g_ItemsA.push("w12","Mapka2",11,8,110,1,0,1,12,3,true,false,false,false,0,0,0,false,0);
         g_ItemsA.push("w13","Čokoláda",12,5,111,1,0.4,1,12,22,false,false,false,false,0,0,0,false,0);
         g_ItemsA.push("w14","Cokolada",13,5,111,1,0.4,0.2,12,24,true,false,false,false,0,0,0,false,0);
         fc_setItems();
         break;
      case 2:
         fc_setQuestInfo(4,"label 1|label 2","3|2","5|1","0|1");
         break;
      case 3:
         fc_openInfoDialog("fakt?","confirm","Ok");
         break;
      case 4:
         fc_setMoreAmountDialog();
         break;
      case 5:
         fc_setMoreAmountDialog();
         fc_setMoreAmountDialog();
         fc_setMoreAmountDialog();
         fc_setMoreAmountDialog();
         break;
      case 6:
         fc_setLessAmountDialog();
         break;
      case 7:
         fc_closeAmountDialog();
   }
   counter++;
};
focusPrev.onPress = function()
{
   fc_focusPrev();
};
focusNext.onPress = function()
{
   fc_focusNext();
};
remove.onPress = function()
{
   var _loc1_ = g_Data.FocusedItem.Id;
   fc_removeItem(_loc1_);
};
function fc_cgSetHave(data)
{
   InventoryData.HaveReceive(data);
}
var g_CgKeysDown = {};
var g_CgKeyListener = {};
g_CgKeyListener.onKeyDown = function()
{
   var code = Key.getCode();
   if(_root.g_CgKeysDown[code])
   {
      return undefined;
   }
   _root.g_CgKeysDown[code] = true;
   var data = _root.g_Data;
   var item = data.FocusedItem;
   if(item == undefined)
   {
      return undefined;
   }
   var ascii = Key.getAscii();
   if(code == 45 || code == 71 || ascii == 71 || ascii == 103)
   {
      data.CgToggleFlat("key");
      return undefined;
   }
   var isE = code == 69 || code == 101 || ascii == 69 || ascii == 101;
   var isV = code == 86 || code == 118 || ascii == 86 || ascii == 118;
   if((isE || code == 13) && item.IsColourGroup)
   {
      InventoryData.s_CgKeyDownAt = getTimer();
      _root.g_CgToggleKey = code;
   }
   else if((isV || code == 35) && (item.IsColourGroup || item.CgIndent))
   {
      data.CgToggle("key");
   }
};
g_CgKeyListener.onKeyUp = function()
{
   var code = Key.getCode();
   _root.g_CgKeysDown[code] = false;
   if(_root.g_CgToggleKey != undefined && code == _root.g_CgToggleKey)
   {
      _root.g_CgToggleKey = undefined;
      if(getTimer() - InventoryData.s_CgKeyDownAt < 300)
      {
         var data = _root.g_Data;
         if(data.FocusedItem != undefined && data.FocusedItem.IsColourGroup)
         {
            data.CgToggle("key");
         }
      }
   }
};
Key.addListener(g_CgKeyListener);
