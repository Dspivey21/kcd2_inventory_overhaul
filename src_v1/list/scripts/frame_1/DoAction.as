function fc_activate(animate)
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_activate");
   g_View.SetActiveState(true,animate);
   g_ActiveState = true;
   g_Data.CgReportState(g_Data.FocusedItem,true);
   UpdateTabButtons(undefined,g_Data.CurrentFilter);
   HighlightAfterActivate();
}
function fc_deactivate(animate)
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_deactivate");
   InventoryData.s_CgLastState = "none";
   InventoryData.CgLog("state=none");
   g_ActiveState = false;
   g_View.SetActiveState(false,animate);
   UpdateTabButtons(g_Data.CurrentFilter,undefined);
   UnhighlightAfterDeactivate();
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
function fc_tabPrev()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_tabPrev");
   g_Data.FilterPrev(UpdateTabButtons);
}
function fc_tabNext()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_tabNext");
   g_Data.FilterNext(UpdateTabButtons);
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
function fc_focusItem(id)
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_focusPrev");
   g_Data.FocusByKey(id);
}
function fc_setUserConfig(tab, sort, heading, focusId)
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_setUserConfig");
   g_FilterTemp = tab;
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
function fc_setItems(idx)
{
   DebugTrace.log("g_ItemsA: " + g_ItemsA.join(","),DebugTrace.C_DEBUG,"fc_setItems");
   g_Data.SetDataFromArray(g_ItemsA);
   g_ItemsA.length = 0;
   UpdateMoney();
   if(g_FocusIdTemp)
   {
      g_Data.FocusByKey(g_FocusIdTemp);
      g_FocusIdTemp = undefined;
   }
   else
   {
      g_Data.FocusFirst();
   }
}
function fc_clearItems(idx)
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_clearItems");
   g_Data.Clear();
   UpdateMoney();
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
   UpdateMoney();
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
   UpdateMoney();
}
function fc_changeSelection(id, isSelected)
{
   DebugTrace.log("is: " + id + ", isSelected: " + isSelected,DebugTrace.C_DEBUG,"fc_changeSelection");
   g_Data.ChangeSelection(id,isSelected);
}
function fc_setSums(moneyPlayer, moneyTrader)
{
   g_MoneyPlayer = moneyPlayer;
   g_MoneyTrader = moneyTrader;
   g_Content.bottomContainer.gotoAndStop(2);
   TextExtension.setText(InvEnum.TEXT_TRADER_MONEY,g_Content.bottomContainer.traderMoneyText,ColorScheme.DARK,false,TextExtension.E_BOLD);
   TextExtension.setText(MathExtension.RoundBigNumber(moneyPlayer,1,MathExtension.MILION),g_Content.bottomContainer.playerMoney.tField,ColorScheme.DARK_EMPHASIS,false,TextExtension.E_BOLD);
   TextExtension.setText(MathExtension.RoundBigNumber(moneyTrader,1,MathExtension.MILION),g_Content.bottomContainer.traderMoney.tField,ColorScheme.DARK,false,TextExtension.E_BOLD);
   g_Content.bottomContainer.traderMoney._x = g_Content.bottomContainer.traderMoneyText._x + g_Content.bottomContainer.traderMoneyText.textWidth + InvEnum.SHOP_TEXT_OFFSET_X;
   TextExtension.setText(InvEnum.TEXT_SELLING,g_Content.bottomContainer.tPlayerText,ColorScheme.DARK,false,TextExtension.E_BOLD);
   TextExtension.setText(InvEnum.TEXT_BUYING,g_Content.bottomContainer.tTraderText,ColorScheme.DARK,false,TextExtension.E_BOLD);
   TextExtension.setText(InvEnum.TEXT_TOTAL_PAY,g_Content.bottomContainer.tTotalText,ColorScheme.DARK_EMPHASIS,false,TextExtension.E_BOLD);
   TextExtension.setText(MathExtension.RoundBigNumber(0),g_Content.bottomContainer.sellMoney.tField,ColorScheme.DARK,false,TextExtension.E_BOLD);
   TextExtension.setText(MathExtension.RoundBigNumber(0),g_Content.bottomContainer.buyMoney.tField,ColorScheme.DARK,false,TextExtension.E_BOLD);
   TextExtension.setText(MathExtension.RoundBigNumber(0),g_Content.bottomContainer.sumMoney.tField,ColorScheme.DARK_EMPHASIS,false,TextExtension.E_BOLD);
   updatePosition();
   UpdateSums(0,0);
}
function updatePosition()
{
   var _loc2_ = 182;
   var _loc3_ = 1826;
   var _loc1_ = 35;
   g_Content.bottomContainer.sumMoney._x = _loc3_ - _loc2_;
   g_Content.bottomContainer.tTotalText._x = g_Content.bottomContainer.sumMoney._x - g_Content.bottomContainer.tTotalText.textWidth - InvEnum.SHOP_TEXT_OFFSET_X;
   g_Content.bottomContainer.sumRightOrnament._x = g_Content.bottomContainer.tTotalText._x - InvEnum.SHOP_TEXT_OFFSET_X - _loc1_ / 2;
   g_Content.bottomContainer.buyMoney._x = g_Content.bottomContainer.sumRightOrnament._x - _loc2_ - InvEnum.SHOP_TEXT_OFFSET_X - _loc1_ / 2;
   g_Content.bottomContainer.tTraderText._x = g_Content.bottomContainer.buyMoney._x - g_Content.bottomContainer.tTraderText.textWidth - InvEnum.SHOP_TEXT_OFFSET_X;
   g_Content.bottomContainer.sumLeftOrnament._x = g_Content.bottomContainer.tTraderText._x - InvEnum.SHOP_TEXT_OFFSET_X - _loc1_ / 2;
   g_Content.bottomContainer.sellMoney._x = g_Content.bottomContainer.sumLeftOrnament._x - InvEnum.SHOP_TEXT_OFFSET_X - _loc1_ / 2 - _loc2_;
   g_Content.bottomContainer.tPlayerText._x = g_Content.bottomContainer.sellMoney._x - g_Content.bottomContainer.tPlayerText.textWidth - InvEnum.SHOP_TEXT_OFFSET_X;
   g_Content.bottomContainer.centerOrnament._x = g_Content.bottomContainer.tPlayerText._x - InvEnum.SHOP_TEXT_OFFSET_X - _loc1_ / 2;
}
function fc_updateSums(sumPlayer, sumTrader)
{
   UpdateSums(sumPlayer,sumTrader);
}
function UpdateSums(sumPlayer, sumTrader)
{
   var _loc1_ = sumPlayer <= sumTrader ? InvEnum.TEXT_TOTAL_PAY : InvEnum.TEXT_TOTAL_GET;
   var _loc4_ = g_SumPlayer <= g_SumTrader ? InvEnum.TEXT_TOTAL_PAY : InvEnum.TEXT_TOTAL_GET;
   g_SumPlayer = sumPlayer;
   g_SumTrader = sumTrader;
   if(_loc4_ != _loc1_)
   {
      TextExtension.setText(_loc1_,g_Content.bottomContainer.tTotalText,ColorScheme.DARK_EMPHASIS,false,TextExtension.E_BOLD);
      updatePosition();
   }
   var _loc2_ = g_SumPlayer - g_SumTrader <= g_MoneyTrader ? ColorScheme.DARK : ColorScheme.DARK_NEGATIVE;
   var _loc5_ = g_SumTrader - g_SumPlayer <= g_MoneyPlayer ? ColorScheme.DARK : ColorScheme.DARK_NEGATIVE;
   var _loc3_ = Math.abs(g_SumPlayer - g_SumTrader);
   TextExtension.setText(MathExtension.RoundBigNumber(g_SumPlayer,1,MathExtension.MILION),g_Content.bottomContainer.sellMoney.tField,_loc2_,false,TextExtension.E_BOLD);
   TextExtension.setText(MathExtension.RoundBigNumber(g_SumTrader,1,MathExtension.MILION),g_Content.bottomContainer.buyMoney.tField,_loc5_,false,TextExtension.E_BOLD);
   TextExtension.setText(MathExtension.RoundBigNumber(_loc3_,1,MathExtension.MILION),g_Content.bottomContainer.sumMoney.tField,ColorScheme.DARK_EMPHASIS,true,TextExtension.E_BOLD);
}
function fc_leftDoubleClick(clientId)
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_leftDoubleClick");
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
function fc_setInventoriesId(playerId, horseId)
{
   DebugTrace.log("playerId: " + playerId + ", horseId: " + horseId,DebugTrace.C_DEBUG,"fc_setInventoriesId");
   g_PlayerId = playerId;
   g_HorseId = horseId;
   SetEnableTabButton(InvEnum.FILTER_HORSE,g_HorseId != InvEnum.INVALID);
   if(g_FilterTemp != undefined)
   {
      g_Data.SetFilter(g_FilterTemp,_root.UpdateTabButtons);
      g_FilterTemp = undefined;
   }
}
function fc_setCarriedWeight(carriedWeight, inventoryId, isEncumbered)
{
   DebugTrace.log("carriedWeight: " + carriedWeight + ", inventoryId: " + inventoryId,DebugTrace.C_DEBUG,"fc_setCarriedWeight");
   inventoryId != g_HorseId ? (g_PlayerCarriedWeight = carriedWeight) : (g_HorseCarriedWeight = carriedWeight);
   inventoryId != g_HorseId ? (g_PlayerIsEncumbered = isEncumbered) : (g_HorseIsEncumbered = isEncumbered);
   UpdateWeight();
}
function fc_setCapacity(capacity, inventoryId, isEncumbered)
{
   DebugTrace.log("capacity: " + capacity + ", inventoryId: " + inventoryId,DebugTrace.C_DEBUG,"fc_setCapacity");
   inventoryId != g_HorseId ? (g_PlayerCapacity = capacity) : (g_HorseCapacity = capacity);
   inventoryId != g_HorseId ? (g_PlayerIsEncumbered = isEncumbered) : (g_HorseIsEncumbered = isEncumbered);
   UpdateWeight();
}
function CgTradeColumn(isTrader)
{
   var box = g_Content.parentList.inside;
   var want = !isTrader ? InventoryData.CG_TRADE_DIV_X : InventoryData.CG_TRADE_COL_L;
   for(var k in box)
   {
      var c = box[k];
      if(typeof c == "movieclip" && c._width < 20 && c._height > 1000 && (Math.abs(c._x - InventoryData.CG_TRADE_DIV_X) < 1 || Math.abs(c._x - InventoryData.CG_TRADE_COL_L) < 1))
      {
         c._x = want;
      }
   }
   var hdr = g_Content.sortContainer.sort1;
   if(hdr != undefined)
   {
      hdr._x = !isTrader ? InventoryData.CG_TRADE_HDR_X : InventoryData.CG_TRADE_HDR_X - (InventoryData.CG_TRADE_DIV_X - InventoryData.CG_TRADE_COL_L) / 2;
   }
}
function fc_setShopMode(isTrader, playerId)
{
   g_Mode = !isTrader ? InvEnum.MODE_SHOP_PLAYER : InvEnum.MODE_SHOP_TRADER;
   CgTradeColumn(isTrader);
   g_PlayerId = playerId;
   if(g_Mode == InvEnum.MODE_SHOP_PLAYER)
   {
      g_Content.tabContainer["tab" + InvEnum.FILTER_HORSE]._visible = false;
   }
   else
   {
      g_Content.tabContainer["tab" + InvEnum.FILTER_HORSE].highlightFrame.tabText.tField.text = InvEnum.GetTabText(InvEnum.FILTER_BASKET);
   }
}
function fc_setReputation(reputationValue, reputationIcon)
{
   DebugTrace.log("reputationValue: " + reputationValue,DebugTrace.C_DEBUG,"fc_setReputation");
   SetReputation(reputationValue,reputationIcon);
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
function fc_openQAMSubmenu()
{
   DebugTrace.log("...",DebugTrace.C_DEBUG,"fc_openQAMSubmenu");
   g_QAMSubmenuOpen = true;
   g_Data.UpdateQAMSubmenu();
}
function fc_closeQAMSubmenu()
{
   DebugTrace.log("...",DebugTrace.C_DEBUG,"fc_closeQAMSubmenu");
   g_QAMSubmenuOpen = false;
   g_Data.UpdateQAMSubmenu();
}
function fc_setDropActiveAreas(activate)
{
   DebugTrace.log(active + ";",DebugTrace.C_DEBUG,"fc_setDropActiveTabs");
   var _loc6_;
   var _loc2_;
   var _loc3_;
   var _loc5_;
   if(activate)
   {
      _loc6_ = g_DropActiveAreasA.length;
      _loc2_ = 0;
      while(_loc2_ < _loc6_)
      {
         _loc3_ = g_DropActiveAreasA[_loc2_];
         _loc2_ = _loc2_ + 1;
         _loc5_ = g_DropActiveAreasA[_loc2_];
         g_Content.dropAreas[_loc3_].isDropActive = false;
         g_Content.dropAreas[_loc3_].isDropEnable = _loc5_;
         g_Content.dropAreas[_loc3_].onMouseMove = function()
         {
            var _loc2_ = Utils.HitTest(this,this._parent._xmouse,this._parent._ymouse);
            if(!this.isDropActive && _loc2_)
            {
               this.isDropActive = true;
               flash.external.ExternalInterface.call("onDropActiveAreaChanged",this._name,true,this.isDropEnable);
            }
            else if(this.isDropActive && !_loc2_)
            {
               this.isDropActive = false;
               flash.external.ExternalInterface.call("onDropActiveAreaChanged",this._name,false,this.isDropEnable);
            }
         };
         _loc2_ = _loc2_ + 1;
      }
      g_DropActiveAreasA.length = 0;
   }
   else
   {
      delete g_Content.dropAreas.playerShield.onMouseMove;
      delete g_Content.dropAreas.horseShield.onMouseMove;
      delete g_Content.dropAreas.list.onMouseMove;
   }
}
function Init()
{
   DebugTrace.log("",DebugTrace.C_DEBUG,"Init");
   g_ItemsA = [];
   g_DropActiveAreasA = [];
   g_ActiveState = false;
   g_Content = _root.main.inside;
   g_Mode = InvEnum.MODE_PLAYER;
   g_QAMSubmenuOpen = false;
   g_PlayerId = InvEnum.INVALID;
   g_HorseId = InvEnum.INVALID;
   g_Data = new InventoryData("0");
   g_View = new ItemView(g_Data,g_Content.parentList.inside,109,1526);
   g_View.SetActiveState(false,animate);
   g_View.CreateScrollbar(g_Content.scrollbar);
   InitTabButtons();
   InitSortButtons();
   InitCategoryToggleButton();
   UpdateMoney();
   g_MouseScrollDisable = false;
}
function IsMouseScrollDisable(scrollbarMc)
{
   return g_MouseScrollDisable;
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
   var _loc3_ = 0;
   while(_loc3_ < InvEnum.SORT_PRICE_ASC / 2 + 1)
   {
      g_Content.sortContainer["sort" + _loc3_].sortId = _loc3_ * 2;
      g_Content.sortContainer["sort" + _loc3_].tooltip = InvEnum.GetSortTooltip(_loc3_ * 2,g_Mode);
      g_Content.sortContainer["sort" + _loc3_].onPress = function()
      {
         if(_root.g_ActiveState)
         {
            _root.g_Data.SetSort(this.sortId,true,_root.UpdateSortButtons);
         }
      };
      g_Content.sortContainer["sort" + _loc3_].onRollOver = function()
      {
         if(_root.g_ActiveState)
         {
            this.gotoAndStop(2);
            flash.external.ExternalInterface.call("onShowTooltip",this.tooltip);
         }
         var _loc3_ = function()
         {
            this.gotoAndStop(1);
            flash.external.ExternalInterface.call("onHideTooltip",this.tooltip);
            delete this.onRollOut;
            delete this.onReleaseOutside;
            delete this.onReleaseOutsideAux;
         };
         this.onRollOut = _loc3_;
         this.onReleaseOutside = _loc3_;
         this.onReleaseOutsideAux = _loc3_;
      };
      _loc3_ = _loc3_ + 1;
   }
   UpdateSortButtons(undefined,g_Data.CurrentSort);
}
function UpdateTabButtons(oldFilter, newFilter)
{
   var _loc2_ = InvEnum.GetTabFromFilter(oldFilter,g_Mode);
   var _loc3_ = InvEnum.GetTabFromFilter(newFilter,g_Mode);
   if(_loc2_ != undefined && _loc3_ != undefined)
   {
      Audio.Play(Audio.APSE_TAB);
   }
   if(_loc2_ != undefined)
   {
      g_Content.tabContainer["tab" + _loc2_].highlightFrame.gotoAndStop("unselect");
      g_Content.tabContainer["tab" + _loc2_].highlightFrame.tabText.tField.text = InvEnum.GetTabText(oldFilter);
      DebugTrace.log("ExternalInterface.call(onUnfocusTab, " + _loc2_ + ")",DebugTrace.C_DEBUG,"UpdateTabButtons");
      flash.external.ExternalInterface.call("onUnfocusTab",_loc2_,0);
   }
   if(_loc3_ != undefined)
   {
      if(_root.g_ActiveState)
      {
         DebugTrace.log("ExternalInterface.call(onFocusTab, " + _loc3_ + ")",DebugTrace.C_DEBUG,"UpdateTabButtons");
         flash.external.ExternalInterface.call("onFocusTab",_loc3_,0);
         g_Content.tabContainer["tab" + _loc3_].highlightFrame.gotoAndStop("select");
         g_Content.tabContainer["tab" + _loc3_].highlightFrame.tabText.tField.text = InvEnum.GetTabText(newFilter);
      }
   }
   if(_loc3_ == InvEnum.FILTER_HORSE)
   {
      DebugTrace.log("ExternalInterface.call(onGeneralEvent, goInHorseTab)",DebugTrace.C_DEBUG,"UpdateTabButtons");
      flash.external.ExternalInterface.call("onGeneralEvent","goInHorseTab",0);
      UpdateMoney();
      UpdateWeight();
   }
   else if(_loc2_ == InvEnum.FILTER_HORSE || _loc2_ == undefined)
   {
      DebugTrace.log("ExternalInterface.call(onGeneralEvent, goOutHorseTab)",DebugTrace.C_DEBUG,"UpdateTabButtons");
      flash.external.ExternalInterface.call("onGeneralEvent","goOutHorseTab",0);
      UpdateMoney();
      UpdateWeight();
   }
}
function HighlightAfterActivate()
{
   var _loc1_ = 0;
   while(_loc1_ < InvEnum.FILTER_HORSE + 1)
   {
      if(g_Content.tabContainer["tab" + _loc1_].activeArea.onRollOver)
      {
         if(g_Content.tabContainer["tab" + _loc1_].activeArea.hitTest(_xmouse,_ymouse))
         {
            g_Content.tabContainer["tab" + _loc1_].activeArea.onRollOver();
            return undefined;
         }
      }
      _loc1_ = _loc1_ + 1;
   }
}
function UnhighlightAfterDeactivate()
{
   var _loc1_ = 0;
   while(_loc1_ < InvEnum.FILTER_HORSE + 1)
   {
      if(g_Content.tabContainer["tab" + _loc1_].activeArea.onRollOut)
      {
         g_Content.tabContainer["tab" + _loc1_].activeArea.onRollOut();
      }
      _loc1_ = _loc1_ + 1;
   }
}
function InitTabButtons()
{
   var _loc3_ = 0;
   while(_loc3_ < InvEnum.FILTER_HORSE + 1)
   {
      if(g_Content.tabContainer["tab" + _loc3_] != undefined)
      {
         g_Content.tabContainer["tab" + _loc3_].highlightFrame.tabText.tField.text = InvEnum.GetTabText(_loc3_);
         g_Content.tabContainer["tab" + _loc3_].tabId = _loc3_;
         g_Content.tabContainer["tab" + _loc3_].activeArea.onPress = function()
         {
            if(_root.g_ActiveState)
            {
               _root.g_Data.SetFilter(InvEnum.GetFilterFromTab(this._parent.tabId,_root.g_Mode),_root.UpdateTabButtons);
            }
         };
         g_Content.tabContainer["tab" + _loc3_].activeArea.onRollOver = function()
         {
            var _loc3_;
            if(_root.g_ActiveState && _root.g_Data.IsFilterEnable(InvEnum.GetFilterFromTab(this._parent.tabId,_root.g_Mode)))
            {
               this._parent.gotoAndStop(2);
               DebugTrace.log("ExternalInterface.call(onHighlightTab, " + this._parent.tabId + ")",DebugTrace.C_DEBUG,"InitTabButtons");
               flash.external.ExternalInterface.call("onHighlightTab",this._parent.tabId,0);
               _loc3_ = function()
               {
                  this._parent.gotoAndStop(1);
                  DebugTrace.log("ExternalInterface.call(onUnhighlightTab, " + this._parent.tabId + ")",DebugTrace.C_DEBUG,"InitTabButtons");
                  flash.external.ExternalInterface.call("onUnhighlightTab",this._parent.tabId,0);
                  delete this.onRollOut;
                  delete this.onReleaseOutside;
                  delete this.onReleaseOutsideAux;
               };
               this.onRollOut = _loc3_;
               this.onReleaseOutside = _loc3_;
               this.onReleaseOutsideAux = _loc3_;
            }
         };
      }
      _loc3_ = _loc3_ + 1;
   }
}
function SetEnableTabButton(tabId, enable)
{
   if(enable)
   {
      g_Content.tabContainer["tab" + tabId].highlightFrame.gotoAndStop(g_Data.CurrentFilter != tabId ? "unselect" : "select");
      g_Content.tabContainer["tab" + tabId].highlightFrame.tabText.tField.text = InvEnum.GetTabText(tabId);
   }
   else
   {
      g_Content.tabContainer["tab" + tabId].highlightFrame.gotoAndStop("disable");
   }
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
      if(_root.g_ActiveState)
      {
         _root.g_Data.ToggleHeadingVisibility(_root.UpdateCategoryButton);
      }
   };
   g_Content.sortContainer.categoryToggle.onRollOver = function()
   {
      if(_root.g_ActiveState)
      {
         flash.external.ExternalInterface.call("onShowTooltip","ui_tip_category");
         this.gotoAndStop(2);
      }
      var _loc3_ = function()
      {
         flash.external.ExternalInterface.call("onHideTooltip","ui_tip_category");
         this.gotoAndStop(1);
         delete this.onRollOut;
         delete this.onReleaseOutside;
         delete this.onReleaseOutsideAux;
      };
      this.onRollOut = _loc3_;
      this.onReleaseOutside = _loc3_;
      this.onReleaseOutsideAux = _loc3_;
   };
   UpdateCategoryButton(undefined,g_Data.HeadingVisibility);
}
function UpdateMoney()
{
   DebugTrace.log("...",DebugTrace.C_DEBUG,"UpdateMoney");
   var _loc4_ = g_PlayerId;
   if(g_Data.CurrentFilter == InvEnum.FILTER_HORSE)
   {
      _loc4_ = g_HorseId;
   }
   else if(g_Mode == InvEnum.MODE_SHOP_TRADER || g_Mode == InvEnum.MODE_SHOP_PLAYER)
   {
      return undefined;
   }
   var _loc5_ = g_Data.GetMoney(_loc4_);
   TextExtension.setText(MathExtension.RoundBigNumber(_loc5_,1,MathExtension.MILION),g_Content.bottomContainer.money.tField,"",false,TextExtension.E_BOLD);
   var tooltipText = g_Data.CurrentFilter != InvEnum.FILTER_HORSE ? "ui_tip_totalGold" : "ui_tip_totalHorseGold";
   g_Content.bottomContainer.moneyIcon.onRollOver = function()
   {
      if(_root.g_ActiveState)
      {
         flash.external.ExternalInterface.call("onShowTooltip",tooltipText);
      }
      var _loc3_ = function()
      {
         flash.external.ExternalInterface.call("onHideTooltip",tooltipText);
         delete this.onRollOut;
         delete this.onReleaseOutside;
         delete this.onReleaseOutsideAux;
      };
      this.onRollOut = _loc3_;
      this.onReleaseOutside = _loc3_;
      this.onReleaseOutsideAux = _loc3_;
   };
}
function UpdateWeight()
{
   if(g_Mode == InvEnum.MODE_SHOP_TRADER || g_Mode == InvEnum.MODE_SHOP_PLAYER)
   {
      return undefined;
   }
   DebugTrace.log("...",DebugTrace.C_DEBUG,"UpdateWeight");
   var _loc4_ = g_Data.CurrentFilter != InvEnum.FILTER_HORSE ? g_PlayerCarriedWeight : g_HorseCarriedWeight;
   var _loc7_ = g_Data.CurrentFilter != InvEnum.FILTER_HORSE ? g_PlayerCapacity : g_HorseCapacity;
   var _loc5_ = g_Data.CurrentFilter != InvEnum.FILTER_HORSE ? g_PlayerIsEncumbered : g_HorseIsEncumbered;
   var _loc6_ = !_loc5_ ? "" : ColorScheme.DARK_NEGATIVE;
   TextExtension.setText(MathExtension.RoundBigNumber(_loc4_) + "/" + MathExtension.RoundBigNumber(_loc7_),g_Content.bottomContainer.weight.tField,_loc6_,true,TextExtension.E_BOLD);
   var tooltipText = g_Data.CurrentFilter != InvEnum.FILTER_HORSE ? "ui_tip_totalWeight" : "ui_tip_totalHorseWeight";
   g_Content.bottomContainer.weightIcon.onRollOver = function()
   {
      if(_root.g_ActiveState)
      {
         flash.external.ExternalInterface.call("onShowTooltip",tooltipText);
      }
      var _loc3_ = function()
      {
         flash.external.ExternalInterface.call("onHideTooltip",tooltipText);
         delete this.onRollOut;
         delete this.onReleaseOutside;
         delete this.onReleaseOutsideAux;
      };
      this.onRollOut = _loc3_;
      this.onReleaseOutside = _loc3_;
      this.onReleaseOutsideAux = _loc3_;
   };
}
function onFocusedChanged(id, idRoot)
{
   DebugTrace.log("ExternalInterface.call(onFocusedChanged, " + id + ", " + Number(idRoot) + ")",DebugTrace.C_DEBUG,"onFocusedChanged");
   flash.external.ExternalInterface.call("onFocusChanged",id,false,false,Number(idRoot));
}
function onStartDrag()
{
   var _loc1_ = g_Data.FocusedItem;
   if(_loc1_)
   {
      DebugTrace.log("ExternalInterface.call(onStartDrag, " + id + ")",DebugTrace.C_DEBUG,"onStartDrag");
      flash.external.ExternalInterface.call("onStartDrag",_loc1_.GetStackIds(),0);
   }
}
var g_Data;
var g_View;
_global.gfxExtensions = true;
Selection.disableFocusKeys = true;
Selection.disableFocusRolloverEvent = true;
var g_ItemsA;
var g_DropActiveAreasA;
var g_Content;
var g_Mode;
var g_PlayerId;
var g_HorseId;
var g_FilterTemp;
var g_FocusIdTemp;
var g_PlayerCarriedWeight;
var g_PlayerCapacity;
var g_PlayerIsEncumbered;
var g_HorseCarriedWeight;
var g_HorseCapacity;
var g_HorseIsEncumbered;
var g_CurrentOutfit;
var g_QAMSubmenuOpen;
var g_ActiveState;
var g_MoneyPlayer;
var g_MoneyTrader;
var g_SumPlayer;
var g_SumTrader;
var g_MouseScrollDisable;
Init();
counter = 0;
nextTest.onPress = function()
{
   switch(counter)
   {
      case 0:
         fc_setOutfitFlag(0);
         g_ItemsA.push(3);
         g_ItemsA.push("w01","Meč malý",1,"Sword",101,1,5.4,1,12,24,true,0,false,false,0,0,0.2,0,"playerId",0);
         g_ItemsA.push("w02","Meč malý",1,"Sword",101,1,5.4,1,12,24,true,0,false,false,0,0,0.2,0,"playerId",0);
         g_ItemsA.push("w03","Meč malý",1,"Sword",101,1,5.4,1,12,24,true,0,false,false,0,0,0.2,0,"playerId",0);
         fc_setInventoriesId("playerId","horseId");
         fc_setItems();
         trace("----");
         break;
      case 1:
         fc_removeItem("w01");
         break;
      case 2:
         fc_removeItem("w02");
         break;
      case 3:
         fc_removeItem("w03");
   }
   counter++;
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
   if(!_root.g_ActiveState)
   {
      return undefined;
   }
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
         if(!_root.g_ActiveState)
   {
      return undefined;
   }
   var data = _root.g_Data;
         if(data.FocusedItem != undefined && data.FocusedItem.IsColourGroup)
         {
            data.CgToggle("key");
         }
      }
   }
};
Key.addListener(g_CgKeyListener);
