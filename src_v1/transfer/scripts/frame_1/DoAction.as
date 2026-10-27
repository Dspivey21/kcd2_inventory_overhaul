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
function fc_open(mode, selectedInv, name)
{
   DebugTrace.log("mode " + mode,DebugTrace.C_DEBUG,"fc_open");
   InventoryData.s_CgModal = false;
   InventoryData.s_CgStoreKnown = false;
   InventoryData.s_CgStoreIsStash = true;
   g_Mode = mode + InvEnum.MODE_STORE;
   InventoryData.CgLog("open mode=" + mode + " inv=" + selectedInv + " name=" + name);
   g_NpcName = name;
   InitTabButtons(InvEnum.TRANSFER_IDX_FIRST);
   InitTabButtons(InvEnum.TRANSFER_IDX_SECOND);
   SetView(selectedInv,true);
   GetData(InvEnum.TRANSFER_IDX_FIRST).SetFilter(InvEnum.FILTER_ALL,UpdateTabButtons);
   GetData(InvEnum.TRANSFER_IDX_SECOND).SetFilter(InvEnum.FILTER_ALL,UpdateTabButtons);
   GetData(InvEnum.TRANSFER_IDX_FIRST).SetSort(InvEnum.SORT_NAME_ASC,false,UpdateSortButtons);
   GetData(InvEnum.TRANSFER_IDX_SECOND).SetSort(InvEnum.SORT_NAME_ASC,false,UpdateSortButtons);
   _root.main.gotoAndPlay(2);
   GetView(InvEnum.TRANSFER_IDX_FIRST).ScrollUp();
   GetView(InvEnum.TRANSFER_IDX_SECOND).ScrollUp();
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
   var _loc1_ = GetData(g_Idx).FocusedItem;
   if(_loc1_ && _loc1_.IsColourGroup)
   {
      return GetData(g_Idx).CgTransferIds(_loc1_);
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
   var _loc1_ = GetData(g_Idx).FocusPrev();
   if(_loc1_ == TreeData.E_FOCUS_RESULT_SUCCESS)
   {
      Audio.Play(Audio.APSE_FOCUS);
   }
}
function fc_focusNext()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_focusNext");
   var _loc1_ = GetData(g_Idx).FocusNext();
   if(_loc1_ == TreeData.E_FOCUS_RESULT_SUCCESS)
   {
      Audio.Play(Audio.APSE_FOCUS);
   }
}
function fc_sortPrev()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_sortPrev");
   GetData(g_Idx).SortPrev(UpdateSortButtons);
}
function fc_sortNext()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_sortNext");
   GetData(g_Idx).SortNext(UpdateSortButtons);
}
function fc_tabPrev()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_tabPrev");
   GetData(g_Idx).FilterPrev(UpdateTabButtons);
}
function fc_tabNext()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_tabNext");
   GetData(g_Idx).FilterNext(UpdateTabButtons);
}
function fc_viewPrev()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_viewPrev");
   CopyParams(InvEnum.TRANSFER_IDX_SECOND,InvEnum.TRANSFER_IDX_FIRST);
   SetView(InvEnum.TRANSFER_IDX_FIRST,false);
}
function fc_viewNext()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_viewNext");
   CopyParams(InvEnum.TRANSFER_IDX_FIRST,InvEnum.TRANSFER_IDX_SECOND);
   SetView(InvEnum.TRANSFER_IDX_SECOND,false);
}
function fc_toggleCategory()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_toggleCategory");
   if(g_CgTcPending != undefined)
   {
      clearInterval(g_CgTcPending);
      g_CgTcPending = undefined;
      GetData(g_Idx).CgHoldSignal();
      return undefined;
   }
   g_CgTcPending = setInterval(cgTcFire,120);
}
function cgTcFire()
{
   clearInterval(g_CgTcPending);
   g_CgTcPending = undefined;
   var data = GetData(g_Idx);
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
function fc_setItems(idx)
{
   DebugTrace.log("idx: " + idx + ", g_ItemsA: " + g_ItemsA.join(","),DebugTrace.C_DEBUG,"fc_setItems");
   GetData(idx).SetDataFromArray(g_ItemsA);
   GetData(idx).FocusFirst();
   g_ItemsA.length = 0;
   if(idx == InvEnum.TRANSFER_IDX_SECOND && g_Mode == InvEnum.MODE_STORE && !InventoryData.s_CgStoreKnown)
   {
      g_CgStoreInv = undefined;
      GetData(idx).Childrens.Call(function(child)
      {
         if(g_CgStoreInv == undefined && !child.IsHeading && child.InventoryId != undefined && child.InventoryId != InvEnum.INVALID)
         {
            g_CgStoreInv = child.InventoryId;
         }
      });
      InventoryData.CgLog("storeinv=" + (g_CgStoreInv != undefined ? g_CgStoreInv : "?"));
   }
   if(idx == InvEnum.TRANSFER_IDX_FIRST)
   {
      UpdateMoney();
   }
}
function fc_clearItems(idx)
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_clearItems");
   GetData(idx).Clear();
   if(idx == InvEnum.TRANSFER_IDX_FIRST)
   {
      UpdateMoney();
   }
}
function fc_addItem(idx)
{
   DebugTrace.log("idx: " + idx + ", g_ItemsA: " + g_ItemsA.join(","),DebugTrace.C_DEBUG,"fc_addItem");
   var _loc1_ = g_ItemsA[0];
   var _loc2_ = new InventoryItem(_loc1_);
   g_ItemsA.shift();
   _loc2_.Set(g_ItemsA);
   var _loc3_ = GetData(idx).Add(_loc2_);
   if(!_loc3_)
   {
      DebugTrace.log("Try to add item which  already is in list: " + _loc1_,DebugTrace.C_ERROR,"fc_addItem");
   }
   g_ItemsA.length = 0;
   if(idx == InvEnum.TRANSFER_IDX_FIRST)
   {
      UpdateMoney();
   }
}
function fc_removeItem(id, idx)
{
   DebugTrace.log("idx: " + idx + ", id: " + id,DebugTrace.C_DEBUG,"fc_removeItem");
   GetData(idx).Remove(id);
   if(idx == InvEnum.TRANSFER_IDX_FIRST)
   {
      UpdateMoney();
   }
}
function fc_changeItem(idx)
{
   DebugTrace.log("idx: " + idx + ", g_ItemsA: " + g_ItemsA.join(","),DebugTrace.C_DEBUG,"fc_changeItem");
   GetData(idx).ChangeItem(g_ItemsA);
   g_ItemsA.length = 0;
   if(idx == InvEnum.TRANSFER_IDX_FIRST)
   {
      UpdateMoney();
   }
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
   GetData(g_Idx).CgReportState(GetData(g_Idx).FocusedItem,true);
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
function fc_openQuestionDialog(question, actionConfirm, actionCancel, hintConfirm, hintCancel)
{
   DebugTrace.log(question + ", " + actionConfirm + ", " + actionCancel + ", " + hintConfirm + ", " + hintCancel,DebugTrace.C_DEBUG,"fc_openQuestionDialog");
   InventoryData.CgModal(true);
   if(g_ModalDialogQuestion)
   {
      if(!g_ModalDialogQuestion.IsClosing)
      {
         DebugTrace.log("Info Dialog is already open",DebugTrace.C_ERROR,"fc_openQuestionDialog");
         return undefined;
      }
      g_ModalDialogQuestion.Remove();
      g_ModalDialogQuestion = undefined;
   }
   g_ModalDialogQuestion = new ModalDialogQuestion("mc_modalDialogInfoQuestion",question,actionConfirm,actionCancel,hintConfirm,hintCancel);
   ShowBackgroundModal();
}
function fc_closeQuestionDialog()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_closeQuestionDialog");
   InventoryData.CgModal(false);
   GetData(g_Idx).CgReportState(GetData(g_Idx).FocusedItem,true);
   if(!g_ModalDialogQuestion)
   {
      DebugTrace.log("Info Dialog is not open",DebugTrace.C_ERROR,"fc_closeQuestionDialog");
      return undefined;
   }
   g_ModalDialogQuestion.Close();
   HideBackgroundModal();
}
function fc_setOutfitFlag(outfit)
{
   DebugTrace.log("outfit: " + outfit,DebugTrace.C_DEBUG,"fc_setOutfitFlag");
   g_CurrentOutfit = outfit;
   GetData(InvEnum.TRANSFER_IDX_FIRST).UpdateCurrentOutfit(g_CurrentOutfit);
   GetData(InvEnum.TRANSFER_IDX_SECOND).UpdateCurrentOutfit(g_CurrentOutfit);
}
function fc_updateOutfitFlag(newOutfit, oldOutfit)
{
   DebugTrace.log("newOutfit: " + newOutfit + "; oldOutfit: " + oldOutfit,DebugTrace.C_DEBUG,"fc_updateOutfitFlag");
   g_CurrentOutfit = newOutfit;
   GetData(InvEnum.TRANSFER_IDX_FIRST).UpdateCurrentOutfit(g_CurrentOutfit);
   GetData(InvEnum.TRANSFER_IDX_SECOND).UpdateCurrentOutfit(g_CurrentOutfit);
}
function fc_setUserConfig(tab, sort, heading, focusId)
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_setUserConfig");
   GetData(g_Idx).SetFilter(tab,_root.UpdateTabButtons);
   GetData(g_Idx).SetSort(sort,false,_root.UpdateSortButtons);
   GetData(g_Idx).SetHeadingVisibility(heading,_root.UpdateCategoryButton);
}
function fc_getCurrentTab()
{
   return GetData(g_Idx).CurrentFilter;
}
function fc_getCurrentSort()
{
   return GetData(g_Idx).CurrentSort;
}
function fc_getCurrentHeading()
{
   return GetData(g_Idx).HeadingVisibility;
}
function fc_getCurrentFocusId()
{
   return "";
}
function fc_leftDoubleClick(clientId)
{
   if(clientId != g_Idx)
   {
      return undefined;
   }
   if(g_ModalDialogAmount || g_ModalDialogInfo)
   {
      return undefined;
   }
   DebugTrace.log("clientId: " + clientId,DebugTrace.C_DEBUG,"fc_leftDoubleClick");
   var _loc1_ = GetView(g_Idx).GetIdOnMousePosition();
   if(_loc1_ != undefined && _loc1_ == GetData(g_Idx).FocusedItem.Id && GetData(g_Idx).FocusedItem.IsColourGroup)
   {
      return undefined;
   }
   if(_loc1_ != undefined && _loc1_ == GetData(g_Idx).FocusedItem.Id)
   {
      DebugTrace.log("ExternalInterface.call(onDoubleClicked, " + _loc1_ + "," + g_Idx + " )",DebugTrace.C_DEBUG,"onDoubleClicked");
      flash.external.ExternalInterface.call("onDoubleClicked",_loc1_,g_Idx);
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
   g_debug = new DebugTrace();
   DebugTrace.log("",DebugTrace.C_DEBUG,"Init");
   g_ItemsA = [];
   g_ItemInfoA = [];
   g_Content = _root.main.inside;
   GetMc(InvEnum.TRANSFER_IDX_FIRST)._visible = false;
   GetMc(InvEnum.TRANSFER_IDX_SECOND)._visible = false;
   g_Idx = InvEnum.TRANSFER_IDX_INVALID;
   g_ItemInfoVisible = false;
   g_AudioEnable = true;
   g_ItemInfo = new ItemInfo(g_Content.itemInfo.inside.content);
   g_DataFirst = new InventoryData(String(InvEnum.TRANSFER_IDX_FIRST));
   g_DataSecond = new InventoryData(String(InvEnum.TRANSFER_IDX_SECOND));
   g_ViewFirst = new ItemView(g_DataFirst,g_Content.first.parentList.inside,55,440);
   g_ViewSecond = new ItemView(g_DataSecond,g_Content.second.parentList.inside,55,440);
   g_ViewFirst.CreateScrollbar(g_Content.first.scrollbar);
   g_ViewSecond.CreateScrollbar(g_Content.second.scrollbar);
   InitTabButtons(InvEnum.TRANSFER_IDX_FIRST);
   InitTabButtons(InvEnum.TRANSFER_IDX_SECOND);
   InitSortButtons(InvEnum.TRANSFER_IDX_FIRST);
   InitSortButtons(InvEnum.TRANSFER_IDX_SECOND);
   InitCategoryToggleButton(InvEnum.TRANSFER_IDX_FIRST);
   InitCategoryToggleButton(InvEnum.TRANSFER_IDX_SECOND);
   g_InputIdObservable = new Observable();
   g_MouseScrollDisable = false;
   g_PlayerCarriedWeight = 0;
   g_PlayerCapacity = 0;
   UpdateMoney();
}
function IsMouseScrollDisable(scrollbarMc)
{
   if(g_MouseScrollDisable)
   {
      return true;
   }
   return !scrollbarMc._parent._visible;
}
function SetView(newIdx, force)
{
   if(newIdx == g_Idx && !force)
   {
      return undefined;
   }
   var _loc2_ = g_Idx;
   g_Idx = newIdx;
   InventoryData.s_CgLastState = undefined;
   GetData(g_Idx).CgReportState(GetData(g_Idx).FocusedItem,true);
   if(_loc2_ != InvEnum.TRANSFER_IDX_INVALID)
   {
      GetMc(_loc2_)._visible = false;
   }
   GetMc(newIdx)._visible = true;
   var _loc3_ = 1;
   if(g_Mode == InvEnum.MODE_STORE)
   {
      _loc3_ = 2;
   }
   g_Content.viewContainer["view" + InvEnum.TRANSFER_IDX_SECOND].gotoAndStop(_loc3_);
   g_Content.background.gotoAndStop(_loc3_);
   UpdateViewsButtons(_loc2_,newIdx);
   if(!force)
   {
      Audio.Play(Audio.HALF_CHANGE_SIDE);
   }
   var _loc1_ = GetData(g_Idx).FocusedItem;
   if(_loc1_)
   {
      flash.external.ExternalInterface.call("onFocusChanged",!_loc1_ ? "" : _loc1_.Id,false,false,g_Idx);
   }
}
function UpdateViewsButtons(oldIdx, newIdx)
{
   var SHOW = 2;
   var ON = 10;
   var HIDE = 11;
   var OFF = 20;
   var _loc3_ = 0;
   while(_loc3_ < InvEnum.TRANSFER_IDX_SECOND + 1)
   {
      g_Content.viewContainer["view" + _loc3_].frame.idx = _loc3_;
      g_Content.viewContainer["view" + _loc3_].frame.onPress = function()
      {
         _root.onViewChanged(this.idx);
      };
      g_Content.viewContainer["view" + _loc3_].frame.onRollOver = function()
      {
         this.background.gotoAndPlay(MathExtension.InvertFrameAnimation(this.background._currentframe,HIDE,OFF,SHOW,ON));
      };
      g_Content.viewContainer["view" + _loc3_].frame.onRollOut = function()
      {
         this.background.gotoAndPlay(MathExtension.InvertFrameAnimation(this.background._currentframe,SHOW,ON,HIDE,OFF));
      };
      _loc3_ = _loc3_ + 1;
   }
   if(oldIdx != InvEnum.TRANSFER_IDX_INVALID)
   {
      g_Content.viewContainer["view" + oldIdx].frame.gotoAndStop("unselect");
   }
   g_Content.viewContainer["view" + newIdx].frame.gotoAndStop("select");
   g_Content.viewContainer["view" + InvEnum.TRANSFER_IDX_FIRST].frame.tField.text = InvEnum.LOCALIZABLE_TOKEN + InvEnum.TEXT_MY;
   g_Content.viewContainer["view" + InvEnum.TRANSFER_IDX_SECOND].frame.tField.text = g_NpcName;
   if(!(g_NpcName != "" && g_Content.viewContainer["view" + InvEnum.TRANSFER_IDX_SECOND].frame.tField.textWidth < 270))
   {
      if(g_Mode == InvEnum.MODE_STORE)
      {
         g_Content.viewContainer["view" + InvEnum.TRANSFER_IDX_SECOND].frame.tField.text = InvEnum.LOCALIZABLE_TOKEN + InvEnum.TEXT_STORE;
      }
      else if(g_Mode == InvEnum.MODE_LOOT)
      {
         g_Content.viewContainer["view" + InvEnum.TRANSFER_IDX_SECOND].frame.tField.text = InvEnum.LOCALIZABLE_TOKEN + InvEnum.TEXT_LOOT;
      }
   }
}
function UpdateSortButtons(oldSort, newSort, idx)
{
   var _loc1_ = GetMc(Number(idx));
   if(oldSort != undefined)
   {
      _loc1_.sortContainer["sort" + Math.floor(oldSort / 2)].highlightFrame.gotoAndStop("unselect");
      if(g_AudioEnable)
      {
         Audio.Play(Audio.APSE_SORT);
      }
   }
   _loc1_.sortContainer["sort" + Math.floor(newSort / 2)].highlightFrame.gotoAndStop(InvEnum.GetSortFrame(newSort));
}
function InitSortButtons(idx)
{
   var _loc4_ = GetMc(idx);
   var _loc3_ = 0;
   while(_loc3_ < InvEnum.SORT_PRICE_ASC / 2 + 1)
   {
      _loc4_.sortContainer["sort" + _loc3_].sortId = _loc3_ * 2;
      _loc4_.sortContainer["sort" + _loc3_].idx = idx;
      _loc4_.sortContainer["sort" + _loc3_].tooltip = InvEnum.GetSortTooltip(_loc3_ * 2,g_Mode);
      _loc4_.sortContainer["sort" + _loc3_].onPress = function()
      {
         _root.GetData(this.idx).SetSort(this.sortId,true,_root.UpdateSortButtons);
      };
      _loc4_.sortContainer["sort" + _loc3_].onRollOver = function()
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
      _loc4_.sortContainer["sort" + _loc3_].onRollOut = function()
      {
         this.gotoAndStop(1);
      };
      _loc3_ = _loc3_ + 1;
   }
   UpdateSortButtons(undefined,GetData(this.idx).CurrentSort,String(idx));
}
function UpdateTabButtons(oldTab, newTab, idx)
{
   var _loc1_ = GetMc(Number(idx));
   if(oldTab != undefined)
   {
      _loc1_.tabContainer["tab" + oldTab].gotoAndStop("unselect");
      _loc1_.tabContainer["tab" + oldTab].tabText.tField.text = InvEnum.GetTabText(oldTab);
      _loc1_.tabContainer["tab" + oldTab].hover._alpha = 0;
      if(g_AudioEnable)
      {
         Audio.Play(Audio.APSE_TAB);
      }
   }
   _loc1_.tabContainer["tab" + newTab].gotoAndStop("select");
   _loc1_.tabContainer["tab" + newTab].tabText.tField.text = InvEnum.GetTabText(newTab);
}
function InitTabButtons(idx)
{
   var _loc4_ = GetMc(idx);
   var _loc3_ = 0;
   while(_loc3_ < InvEnum.FILTER_OTHER + 1)
   {
      if(_loc4_.tabContainer["tab" + _loc3_] != undefined)
      {
         _loc4_.tabContainer["tab" + _loc3_].tabText.tField.text = InvEnum.GetTabText(_loc3_);
         _loc4_.tabContainer["tab" + _loc3_].filterId = _loc3_;
         _loc4_.tabContainer["tab" + _loc3_].activeArea.onPress = function()
         {
            GetData(idx).SetFilter(this._parent.filterId,_root.UpdateTabButtons);
         };
         _loc4_.tabContainer["tab" + _loc3_].hover._alpha = 0;
         _loc4_.tabContainer["tab" + _loc3_].activeArea.onRollOver = function()
         {
            if(this._parent.hover)
            {
               this._parent.hover.onEnterFrame = function()
               {
                  this._alpha += 10;
                  if(this._alpha >= 100)
                  {
                     delete this.onEnterFrame;
                     this._alpha = 100;
                  }
               };
            }
            var _loc2_ = function()
            {
               if(this._parent.hover)
               {
                  this._parent.hover.onEnterFrame = function()
                  {
                     this._alpha -= 10;
                     if(this._alpha <= 0)
                     {
                        delete this.onEnterFrame;
                        this._alpha = 0;
                     }
                  };
               }
               delete this.onRollOut;
               delete this.onReleaseOutside;
               delete this.onReleaseOutsideAux;
            };
            this.onRollOut = _loc2_;
            this.onReleaseOutside = _loc2_;
            this.onReleaseOutsideAux = _loc2_;
         };
      }
      _loc3_ = _loc3_ + 1;
   }
   UpdateTabButtons(undefined,GetData(idx).CurrentFilter,String(idx));
}
function UpdateCategoryButton(oldState, newState, idx)
{
   var _loc1_ = GetMc(Number(idx));
   _loc1_.sortContainer.categoryToggle.highlightFrame.gotoAndStop(!newState ? "off" : "on");
   if(oldState != undefined)
   {
      if(g_AudioEnable)
      {
         Audio.Play(Audio.APSE_SORT);
      }
   }
}
function InitCategoryToggleButton(idx)
{
   var _loc3_ = GetMc(idx);
   _loc3_.sortContainer.categoryToggle.idx = idx;
   _loc3_.sortContainer.categoryToggle.onPress = function()
   {
      _root.GetData(this.idx).ToggleHeadingVisibility(_root.UpdateCategoryButton);
   };
   _loc3_.sortContainer.categoryToggle.onRollOver = function()
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
   UpdateCategoryButton(undefined,GetData(idx).HeadingVisibility,String(idx));
}
function UpdateMoney()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"UpdateMoney");
   var _loc1_ = GetData(InvEnum.TRANSFER_IDX_FIRST).GetMoney();
   TextExtension.setText(MathExtension.RoundBigNumber(_loc1_,1,MathExtension.INFINITY),g_Content.bottomContainer.money.tField,"",true);
}
function UpdateWeight()
{
   DebugTrace.log(g_PlayerCarriedWeight + "/" + g_PlayerCapacity,DebugTrace.C_DEBUG,"UpdateWeight");
   var _loc1_ = !g_PlayerIsEncumbered ? "" : ColorScheme.DARK_NEGATIVE;
   TextExtension.setText(MathExtension.RoundBigNumber(g_PlayerCarriedWeight) + "/" + MathExtension.RoundBigNumber(g_PlayerCapacity),g_Content.bottomContainer.weight.tField,_loc1_,true);
}
function GetData(idx)
{
   if(idx == undefined)
   {
      idx = g_Idx;
   }
   return idx != InvEnum.TRANSFER_IDX_FIRST ? g_DataSecond : g_DataFirst;
}
function GetView(idx)
{
   if(idx == undefined)
   {
      idx = g_Idx;
   }
   return idx != InvEnum.TRANSFER_IDX_FIRST ? g_ViewSecond : g_ViewFirst;
}
function GetMc(idx)
{
   if(idx == undefined)
   {
      idx = g_Idx;
   }
   return idx != InvEnum.TRANSFER_IDX_FIRST ? g_Content.second : g_Content.first;
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
function CopyParams(from, to)
{
   var _loc1_ = GetData(from);
   var _loc2_ = GetData(to);
   g_AudioEnable = false;
   _loc2_.SetFilter(_loc1_.CurrentFilter,UpdateTabButtons);
   _loc2_.SetSort(_loc1_.CurrentSort,false,UpdateSortButtons);
   _loc2_.SetHeadingVisibility(_loc1_.HeadingVisibility,UpdateCategoryButton);
   g_AudioEnable = true;
}
function onOpened()
{
   DebugTrace.log("ExternalInterface.call(onOpened)",DebugTrace.C_DEBUG,"onOpened");
   flash.external.ExternalInterface.call("onOpened");
}
function onClosed()
{
   g_DataFirst.Clear();
   g_DataSecond.Clear();
   DebugTrace.log("ExternalInterface.call(onOpened)",DebugTrace.C_DEBUG,"onClosed");
   flash.external.ExternalInterface.call("onClosed");
}
function onFocusedChanged(id, idRoot)
{
   DebugTrace.log("ExternalInterface.call(onFocusedChanged, " + id + ", " + Number(idRoot),DebugTrace.C_DEBUG,"onFocusedChanged");
   flash.external.ExternalInterface.call("onFocusChanged",id,false,false,Number(idRoot));
}
function onViewChanged(idx)
{
   var _loc2_;
   if(idx != g_Idx)
   {
      DebugTrace.log("ExternalInterface.call(onViewChanged, " + idx + " )",DebugTrace.C_DEBUG,"onViewChanged");
      flash.external.ExternalInterface.call("onViewChanged",idx);
      _loc2_ = GetData(idx).FocusedItem;
      flash.external.ExternalInterface.call("onFocusChanged",!_loc2_ ? "" : _loc2_.Id,false,false,idx);
   }
}
function onModalDialogAmountClosed()
{
   g_ModalDialogAmount.Remove();
   g_ModalDialogAmount = undefined;
}
function onModalDialogInfoQuestionClosed()
{
   g_ModalDialogQuestion.Remove();
   g_ModalDialogQuestion = undefined;
}
_global.gfxExtensions = true;
Selection.disableFocusKeys = true;
Selection.disableFocusRolloverEvent = true;
var g_DataFirst;
var g_DataSecond;
var g_ViewFirst;
var g_ViewSecond;
var g_ModalDialogAmount;
var g_ModalDialogQuestion;
var g_Idx;
var g_ItemsA;
var g_ItemInfoA;
var g_ItemInfo;
var g_NpcName;
var g_Content;
var g_CurrentOutfit;
var g_ItemInfoVisible;
var g_Mode;
var g_InputId;
var g_InputIdObservable;
var g_MouseScrollDisable;
var g_AudioEnable;
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
         fc_open(1,0);
         break;
      case 1:
         g_ItemsA.push(13);
         g_ItemsA.push("w01","Meč malý",1,"ShortSword",101,1,5.4,1,12,24,true,false,false,false,0,0.2,0,0);
         g_ItemsA.push("w02","Meč malý",1,"ShortSword",101,1,5.4,0.98,12,24,true,false,false,false,0,0.2,0,0);
         g_ItemsA.push("w03","Meč velký",2,"LongSword",102,1,7.4,1,14,28,true,false,false,false,0,0.3,0,0);
         g_ItemsA.push("w04","Luk",3,"Bow",103,1,3.4,1,12,24,true,true,false,false,0,0.7,0,0);
         g_ItemsA.push("w05","Jablko",4,"Food",104,1,1.4,1,2,1,true,false,false,false,0,0.2,0,0);
         g_ItemsA.push("w07","Kniha",6,"LoreBook",106,1,0,1,12,24,true,false,false,false,0,0.2,0,0);
         g_ItemsA.push("w08","Vzácná truhlička",7,"Common",107,1,0,1,1,2400000,true,false,true,false,0,0.2,0,0);
         g_ItemsA.push("w09","Šípy",8,"Arrow",108,10,1,1,12,21,true,false,false,false,0,0,0,0);
         g_ItemsA.push("w10","Jablko",4,"Food",109,1,3.4,0.5,2,1,true,false,false,false,0,0,0,0);
         g_ItemsA.push("w11","Mapka",10,"Map",110,1,0,1,12,2,true,false,false,false,0,0,0,0);
         g_ItemsA.push("w12","Mapka2",11,"Map",110,1,0,1,12,3,true,false,false,false,0,0,0,0);
         g_ItemsA.push("w13","Čokoláda",12,"GoodPotion",111,1,0.4,1,12,22,false,false,false,false,0,0,0,0);
         g_ItemsA.push("w14","Cokolada",13,"GoodPotion",111,1,0.4,0.2,12,24,true,false,false,false,0,0,0,0);
         fc_setItems(0);
         break;
      case 2:
         g_ItemsA.push(4);
         g_ItemsA.push("w01","Meč malý",1,1,101,1,5.4,1,12,24,true,false,false,false,0,0.2,0,0);
         g_ItemsA.push("w02","Meč malý",1,1,101,1,5.4,0.98,12,24,true,false,false,false,0,0.2,0,0);
         g_ItemsA.push("w03","Meč velký",2,1,102,1,7.4,1,14,28,true,false,false,false,0,0.3,0,0);
         g_ItemsA.push("w04","Luk",3,1,103,1,3.4,1,12,24,true,true,false,false,0,0.7,0,0);
         fc_setItems(1);
         break;
      case 3:
         fc_viewNext();
         break;
      case 4:
         fc_viewNext();
         break;
      case 5:
         fc_viewPrev();
         break;
      case 6:
         fc_viewPrev();
         break;
      case 7:
         fc_openAmountDialog(1,10,1,1,"confirm","cancel","Confirm","Cancel");
         break;
      case 8:
         fc_setMoreAmountDialog();
         break;
      case 9:
         fc_setMoreAmountDialog();
         fc_setMoreAmountDialog();
         fc_setMoreAmountDialog();
         fc_setMoreAmountDialog();
         break;
      case 10:
         fc_setLessAmountDialog();
         break;
      case 11:
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
   var _loc1_ = GetData(g_Idx).FocusedItem.Id;
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
   var data = _root.GetData(_root.g_Idx);
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
         var data = _root.GetData(_root.g_Idx);
         if(data.FocusedItem != undefined && data.FocusedItem.IsColourGroup)
         {
            data.CgToggle("key");
         }
      }
   }
};
Key.addListener(g_CgKeyListener);
function fc_cgStore(v)
{
   InventoryData.CgStoreAnswer(v);
   GetData(InvEnum.TRANSFER_IDX_SECOND).UpdateView();
   GetData(InvEnum.TRANSFER_IDX_FIRST).UpdateView();
}
var g_CgStoreInv;
