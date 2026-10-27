class ItemView extends TreeView
{
   var m_isActive;
   var START_FOCUS = 2;
   var END_FOCUS = 31;
   var START_UNFOCUS = 32;
   var END_UNFOCUS = 61;
   var ITEM = 1;
   var HEADING = 2;
   var ITEM_COST = 3;
   var NOT_SELECTED = 1;
   var SELECTED = 2;
   var NOT_EQUIPPED = 2;
   var EQUIPPED = 3;
   var NOT_QUEST = 1;
   var QUEST = 2;
   var OFF = 1;
   var ON = 2;
   var BAD = 2;
   var CRITICAL = 3;
   var FIRST_FRAME = 1;
   function ItemView(data, mcList, itemHeight, containerHeight)
   {
      super(data,mcList,"mc_item",itemHeight,containerHeight,0);
   }
   function m_setDataFunc(mc, dataO)
   {
      var _loc9_;
      var _loc5_;
      var _loc12_;
      var _loc8_;
      var _loc10_;
      var _loc6_;
      var _loc7_;
      var _loc11_;
      if(mc.cgHaveQ != undefined)
      {
         mc.cgHaveQ._visible = false;
      }
      if(mc.cgHaveTf != undefined)
      {
         mc.cgHaveTf._visible = false;
      }
      if(dataO instanceof InventoryHeading)
      {
         mc.IsEnable = true;
         mc.IsHeading = true;
         mc.gotoAndStop(this.HEADING);
         mc.activeArea._visible = false;
         mc.tfName.text = dataO.Name;
         TextExtension.setText(mc.tfName.text,mc.tfName,ColorScheme.HEADING);
      }
      else
      {
         mc.IsEnable = dataO.IsEnable;
         mc.IsHeading = false;
         mc.IsSelected = dataO.IsSelected;
         mc.IsFocused = dataO.IsFocused;
         mc.HealthState = dataO.HealthState;
         if(_root.g_Mode == InvEnum.MODE_REPAIR || _root.g_Mode == InvEnum.MODE_WASH)
         {
            mc.gotoAndStop(this.ITEM_COST);
         }
         else
         {
            mc.gotoAndStop(this.ITEM);
         }
         mc.activeArea._visible = true;
         mc.focuser.gotoAndStop(!(this.m_isActive && dataO.IsFocused) ? this.END_UNFOCUS : this.END_FOCUS);
         _loc9_ = _root.g_QAMSubmenuOpen && dataO.IsFocused;
         mc.outfitPresence.gotoAndStop(InvEnum.GetEquipMarker(dataO.OutfitPresence,_root.g_CurrentOutfit,_loc9_));
         if(_loc9_)
         {
            mc.outfitPresence.icon.gotoAndStop(!(dataO.OutfitPresence & 1 << _root.g_CurrentOutfit) ? this.NOT_EQUIPPED : this.EQUIPPED);
         }
         else if(mc.outfitPresence.icon)
         {
            mc.outfitPresence.icon.gotoAndStop(1);
         }
         _loc5_ = 700;
         if(_root.g_Mode >= InvEnum.MODE_STORE)
         {
            if(dataO.OutfitPresence != 0)
            {
               _loc5_ = 290;
            }
            else if(dataO.StackAmount > 1)
            {
               _loc5_ = 360;
            }
            else
            {
               _loc5_ = 430;
            }
            if(dataO.Quality != 0)
            {
               _loc5_ -= 25;
            }
         }
         else if(dataO.Quality == 0)
         {
            _loc5_ += 50;
         }
         var cgQs = mc.quality._xscale / 100;
         var cgCol = mc.outfitPresence != undefined && mc.outfitPresence._x > mc.name._x + 100;
         var cgBuy = InventoryData.HaveBuyList();
         var cgSell = InventoryData.HaveTrade() && !cgBuy;
         var cgNameCap = _loc5_;
         if(cgCol && cgBuy)
         {
            cgNameCap = InventoryData.CG_TRADE_COL_L - mc.name._x - 8 - (Number(dataO.Quality) != 0 ? 40 * cgQs : 0);
         }
         else if(cgCol && cgSell)
         {
            cgNameCap = mc.outfitPresence._x - mc.name._x - 40 - (Number(dataO.Quality) != 0 ? 40 * cgQs : 0);
         }
         ItemView.CgFit(mc,ItemView.CgRowName(dataO),"",cgNameCap);
         if(dataO.IsColourGroup && dataO.CgNameTail != undefined)
         {
            var cgGMax = _loc5_;
            if(cgCol)
            {
               cgGMax = cgBuy ? InventoryData.CG_TRADE_COL_L - mc.name._x - 8 : mc.outfitPresence._x - mc.name._x - 40;
            }
            ItemView.CgFit(mc,dataO.CgNameMain,dataO.CgNameTail,cgGMax);
         }
         mc.amount.tField.text = dataO.StackAmount <= 1 ? "" : MathExtension.RoundBigNumber(dataO.StackAmount,0);
         mc.stat.tField.text = dataO.MainStat <= 0 ? "" : MathExtension.RoundBigNumber(dataO.MainStat,0);
         _loc12_ = MathExtension.RoundBigNumber(dataO.Health * 100,0);
         _loc8_ = !mc.IsFocused ? (_root.g_Mode < InvEnum.MODE_STORE ? ColorScheme.T_LIGHT : ColorScheme.T_DARK) : ColorScheme.T_FOCUS;
         _loc8_ += dataO.HealthState != InvEnum.HEALTH_CRITICAL ? "" : ColorScheme.T_NEGATIVE;
         _loc8_ += dataO.HealthState != InvEnum.HEALTH_BAD ? "" : ColorScheme.T_WARNING;
         _loc10_ = ColorScheme.Get(_loc8_);
         TextExtension.setText(String(_loc12_),mc.health.tField,_loc10_);
         if(cgCol && !cgBuy && !cgSell && dataO.OutfitPresence == 0)
         {
            var cgFree = Math.min(ItemView.CgNextTextLeft(mc) - mc.name._x - 12 * cgQs,mc.name.tField._width - 6) - (Number(dataO.Quality) != 0 ? 40 * cgQs : 0);
            if(dataO.IsColourGroup && dataO.CgNameTail != undefined)
            {
               if(cgFree > cgGMax)
               {
                  ItemView.CgFit(mc,dataO.CgNameMain,dataO.CgNameTail,cgFree);
               }
            }
            else if(cgFree > cgNameCap)
            {
               ItemView.CgFit(mc,ItemView.CgRowName(dataO),"",cgFree);
            }
         }
         mc.quality.gotoAndStop(!dataO.IsRepainted ? dataO.Quality + 1 : 6);
         mc.quality._x = ItemView.CgMarkX(mc,true);
         var cgHave = InventoryData.HaveText(dataO);
         if(cgHave != "")
         {
            var cgGrade = InventoryData.s_HaveGrade;
            var cgNext = ItemView.CgNextTextLeft(mc);
            var cgDone = false;
            var cgTrade = InventoryData.HaveTrade();
            if(cgCol && (dataO.StackAmount <= 1 || cgTrade))
            {
               var cgHx = mc.outfitPresence._x + 36 * mc.outfitPresence._xscale / 100;
               if(mc.cgHaveTf == undefined)
               {
                  mc.name.duplicateMovieClip("cgHaveTf",mc.getNextHighestDepth());
               }
               var cgNeed = 0;
               if(mc.cgHaveTf != undefined)
               {
                  mc.cgHaveTf._xscale = 100;
                  mc.cgHaveTf._yscale = 100;
                  mc.cgHaveTf._y = mc.cgNameY;
                  mc.cgHaveTf.gotoAndStop(mc.name._currentframe);
                  mc.cgHaveTf.tField.selectable = false;
                  mc.cgHaveTf.tField.text = cgHave;
                  cgNeed = mc.cgHaveTf.tField.textWidth + (cgGrade > 0 ? 26 * cgQs : 0) + 4 * cgQs;
               }
               if(cgTrade && mc.cgHaveTf != undefined)
               {
                  mc.cgHaveTf.tField.text = "HAVE (1)";
                  var cgW1 = mc.cgHaveTf.tField.textWidth;
                  mc.cgHaveTf.tField.text = cgHave;
                  cgHx = InventoryData.CG_TRADE_COL_L + (InventoryData.CG_TRADE_COL_R - InventoryData.CG_TRADE_COL_L - cgW1 - (cgGrade > 0 ? 30 * cgQs : 0)) / 2 - mc.cgHaveTf.tField._x;
               }
               else if(cgHx + cgNeed > cgNext && dataO.OutfitPresence == 0)
               {
                  cgHx = Math.max(cgNext - cgNeed,mc.outfitPresence._x - 8);
               }
               if(mc.cgHaveTf != undefined && (cgTrade || cgHx + cgNeed <= cgNext + 3))
               {
                  mc.cgHaveTf._x = cgHx;
                  mc.cgHaveTf._visible = true;
                  if(!cgTrade)
                  {
                     ItemView.CgFit(mc,ItemView.CgRowName(dataO),"",mc.outfitPresence._x - mc.name._x - 40);
                     mc.quality._x = ItemView.CgMarkX(mc,true);
                  }
                  if(cgGrade > 0 && !ItemView.CgHaveMark(mc,cgGrade,mc.cgHaveTf._x + mc.cgHaveTf.tField._x + mc.cgHaveTf.tField.textWidth + 4 * cgQs))
                  {
                     mc.cgHaveTf.tField.text = cgHave + " " + ["","I","II","III","IV"][cgGrade];
                  }
                  cgDone = true;
               }
            }
            if(!cgDone)
            {
               var cgMax = _loc5_;
               if(cgCol && dataO.OutfitPresence != 0)
               {
                  cgMax = mc.outfitPresence._x - mc.name._x - 40;
               }
               else if(cgNext > mc.name._x + 100)
               {
                  cgMax = Math.min(cgNext - mc.name._x - 12 * cgQs,mc.name.tField._width - 6);
               }
               ItemView.CgFit(mc,ItemView.CgRowName(dataO),"      " + cgHave,cgMax - (cgGrade > 0 ? 26 * cgQs : 0));
               mc.quality._x = ItemView.CgMarkX(mc,false);
               if(cgGrade > 0 && !ItemView.CgHaveMark(mc,cgGrade,ItemView.CgMarkX(mc,true)))
               {
                  mc.name.tField.text = mc.name.tField.text + " " + ["","I","II","III","IV"][cgGrade];
               }
            }
         }
         mc.weight.tField.text = MathExtension.RoundBigNumber(dataO.Weight);
         mc.price.tField.text = !dataO.IsMoney ? MathExtension.RoundBigNumber(dataO.Price,1,MathExtension.TEN_THOUSAND) : MathExtension.RoundBigNumber(dataO.StackAmount,1,MathExtension.TEN_THOUSAND);
         if(dataO.Cost != undefined)
         {
            mc.cost.tField.text = MathExtension.RoundBigNumber(dataO.Cost);
         }
         mc.selector.gotoAndStop(!dataO.IsSelected ? this.NOT_SELECTED : this.SELECTED);
         mc.quest.gotoAndStop(!dataO.IsQuestItem ? this.NOT_QUEST : this.QUEST);
         mc.newBook.gotoAndStop(!dataO.IsNew ? this.OFF : this.ON);
         _loc6_ = dataO.Blood > InvEnum.BLOOD_THRESHOLD;
         _loc7_ = dataO.Dirt >= InvEnum.DIRT_THRESHOLD;
         if(_loc6_ && _loc7_)
         {
            _loc6_ = dataO.Blood > dataO.Dirt;
            _loc7_ = dataO.Dirt > dataO.Blood;
            if(dataO.Blood == dataO.Dirt)
            {
               _loc6_ = true;
            }
         }
         mc.blood.gotoAndStop(!_loc6_ ? this.OFF : this.ON);
         mc.dirt.gotoAndStop(!_loc7_ ? this.OFF : this.ON);
         mc.stolen.gotoAndStop(dataO.Stolen + this.FIRST_FRAME);
         mc.poison.gotoAndStop(!InvEnum.IsPoison(dataO.BuffIcon) ? this.OFF : this.ON);
         mc.buffs.gotoAndStop(!InvEnum.IsBuffed(dataO.BuffIcon) ? this.OFF : this.ON);
         _loc11_ = new MovieClipLoader();
         _loc11_.loadClip("img://Libs/UI/Textures/Icons/Items/" + dataO.IconId + "_icon.dds",mc.icon);
         this.colorizeName(mc);
         if(dataO.IsMoney)
         {
            mc.weight.tField.text = "";
            mc.health.tField.text = "";
            mc.amount.tField.text = "";
         }
      }
   }
   static function CgFit(mc, main, tail, cap)
   {
      if(mc.cgNameY == undefined)
      {
         mc.cgNameY = mc.name._y;
      }
      mc.name._xscale = 100;
      mc.name._yscale = 100;
      mc.name._y = mc.cgNameY;
      var tailW = 0;
      if(tail != "")
      {
         mc.name.tField.text = tail;
         tailW = mc.name.tField.textWidth;
      }
      mc.name.tField.text = main;
      var mainW = mc.name.tField.textWidth;
      var sc = 1;
      if(mainW + tailW > cap)
      {
         sc = cap / (mainW + tailW);
         if(sc < 0.85)
         {
            sc = 0.85;
            main = TextExtension.getShortenedText(main,mc.name.tField,cap / 0.85 - tailW);
            mc.name.tField.text = main;
            mainW = mc.name.tField.textWidth;
         }
      }
      mc.cgMainW = mainW;
      mc.cgFullW = mainW + tailW;
      mc.name.tField.text = main + tail;
      if(sc < 1)
      {
         mc.name._xscale = sc * 100;
         mc.name._yscale = sc * 100;
         mc.name._y = mc.cgNameY + mc.name.tField.textHeight * (1 - sc) / 2;
      }
   }
   static function CgRowName(d)
   {
      return !d.CgIndent ? d.Name : "  -   " + d.Name;
   }
   static function CgMarkX(mc, full)
   {
      return mc.name._x + (full ? mc.cgFullW : mc.cgMainW) * mc.name._xscale / 100 + 13 * mc.quality._xscale / 100;
   }
   static function CgNextTextLeft(mc)
   {
      var cells = [mc.amount,mc.stat,mc.health];
      var i = 0;
      while(i < cells.length)
      {
         var c = cells[i];
         if(c != undefined && c.tField != undefined && c.tField.text != "")
         {
            return c._x + c.tField._x + c.tField._width / 2 - c.tField.textWidth / 2 - 3;
         }
         i++;
      }
      return mc.name._x + mc.name.tField._width;
   }
   static function CgHaveMark(mc, grade, x)
   {
      if(mc.cgHaveQ == undefined)
      {
         mc.quality.duplicateMovieClip("cgHaveQ",mc.getNextHighestDepth());
      }
      if(mc.cgHaveQ == undefined)
      {
         return false;
      }
      mc.cgHaveQ.gotoAndStop(grade + 1);
      mc.cgHaveQ._x = x;
      mc.cgHaveQ._y = mc.quality._y;
      mc.cgHaveQ._visible = true;
      return true;
   }
   function m_highlightFunc(mc)
   {
      mc.IsHiglight = true;
      this.colorizeName(mc);
   }
   function m_unhighlightFunc(mc)
   {
      mc.IsHiglight = false;
      this.colorizeName(mc);
   }
   function m_focusFunc(mc, animate)
   {
      this.updateFocuser(mc,true,animate);
   }
   function m_unfocusFunc(mc, animate)
   {
      this.updateFocuser(mc,false,animate);
   }
   function m_dragFunc(mc)
   {
      if(_root.g_Mode != InvEnum.MODE_PLAYER || !mc.IsFocused)
      {
         return undefined;
      }
      mc.origDrag = new flash.geom.Point(mc._xmouse,mc._ymouse);
      var _loc3_ = function()
      {
         var _loc2_ = new flash.geom.Point(mc.activeArea._xmouse - mc.origDrag.x,mc.activeArea._ymouse - mc.origDrag.y);
         if(_loc2_.length > 5)
         {
            _root.onStartDrag();
            delete mc.activeArea.onMouseMove;
            delete mc.activeArea.onRelease;
            delete mc.activeArea.onReleaseOutside;
            delete mc.origDrag;
         }
      };
      var _loc2_ = function()
      {
         delete mc.activeArea.onMouseMove;
         delete mc.origDrag;
         delete mc.activeArea.onRelease;
         delete mc.activeArea.onReleaseOutside;
      };
      mc.activeArea.onMouseMove = _loc3_;
      mc.activeArea.onRelease = _loc2_;
      mc.activeArea.onReleaseOutside = _loc2_;
   }
   function updateFocuser(mc, isFocused, animated)
   {
      mc.IsFocused = isFocused;
      if(!mc.focuser)
      {
         return undefined;
      }
      var _loc3_ = mc.focuser._currentframe;
      var _loc5_ = _loc3_ >= this.START_FOCUS && _loc3_ <= this.END_FOCUS;
      var _loc6_ = _loc3_ >= this.START_UNFOCUS && _loc3_ <= this.END_FOCUS;
      var _loc8_;
      if(_loc5_ && !isFocused)
      {
         if(animated)
         {
            _loc8_ = MathExtension.InvertFrameAnimation(_loc3_,this.START_FOCUS,this.END_FOCUS,this.START_UNFOCUS,this.END_UNFOCUS);
            mc.focuser.gotoAndPlay(_loc8_);
         }
         else
         {
            mc.focuser.gotoAndStop(this.END_UNFOCUS);
         }
      }
      else if(_loc6_ && isFocused)
      {
         if(animated)
         {
            _loc8_ = MathExtension.InvertFrameAnimation(_loc3_,this.START_UNFOCUS,this.END_UNFOCUS,this.START_FOCUS,this.END_FOCUS);
            mc.focuser.gotoAndPlay(_loc8_);
         }
         else
         {
            mc.focuser.gotoAndStop(this.END_FOCUS);
         }
      }
      else if(!_loc5_ && isFocused)
      {
         if(animated)
         {
            _loc8_ = MathExtension.InvertFrameAnimation(_loc3_,this.START_UNFOCUS,this.END_UNFOCUS,this.START_FOCUS,this.END_FOCUS);
            mc.focuser.gotoAndPlay(_loc8_);
         }
         else
         {
            mc.focuser.gotoAndStop(this.END_FOCUS);
         }
      }
      this.colorizeName(mc);
   }
   function colorizeName(mc)
   {
      if(mc.IsHeading)
      {
         return undefined;
      }
      var _loc11_ = _root.g_Mode >= InvEnum.MODE_STORE;
      var _loc6_;
      var _loc14_;
      var _loc10_;
      var _loc7_;
      var _loc13_;
      var _loc4_;
      var _loc9_;
      var _loc5_;
      var _loc12_;
      var _loc8_;
      var _loc3_;
      if(_loc11_)
      {
         _loc6_ = mc.name.tField.text;
         _loc14_ = mc.amount.tField.text;
         _loc10_ = mc.stat.tField.text;
         _loc7_ = mc.price.tField.text;
         _loc13_ = mc.weight.tField.text;
         _loc4_ = mc.health.tField.text;
         if(mc.cost)
         {
            _loc9_ = mc.cost.tField.text;
         }
         if(!mc.IsFocused)
         {
            mc.name.gotoAndStop(2);
            mc.amount.gotoAndStop(2);
            mc.health.gotoAndStop(2);
            mc.stat.gotoAndStop(2);
            mc.price.gotoAndStop(2);
            mc.weight.gotoAndStop(2);
            if(mc.cost)
            {
               mc.cost.gotoAndStop(2);
            }
         }
         else
         {
            mc.name.gotoAndStop(1);
            mc.amount.gotoAndStop(1);
            mc.health.gotoAndStop(1);
            mc.stat.gotoAndStop(1);
            mc.price.gotoAndStop(1);
            mc.weight.gotoAndStop(1);
            if(mc.cost)
            {
               mc.cost.gotoAndStop(1);
            }
         }
         _loc5_ = !mc.IsFocused ? ColorScheme.T_DARK : ColorScheme.T_FOCUS;
         _loc12_ = _loc5_;
         _loc5_ += !mc.IsSelected ? "" : ColorScheme.T_EMPHASIS;
         _loc5_ += mc.IsEnable ? "" : ColorScheme.T_DISABLE;
         _loc5_ += !mc.IsHiglight ? "" : ColorScheme.T_HIGHLIGHTED;
         _loc8_ = ColorScheme.Get(_loc5_);
         _loc3_ = ColorScheme.Get(_loc12_);
         TextExtension.setText(_loc6_,mc.name.tField,_loc8_);
         if(mc.cgHaveTf != undefined && mc.cgHaveTf._visible)
         {
            var cgHaveTxt = mc.cgHaveTf.tField.text;
            mc.cgHaveTf.gotoAndStop(mc.name._currentframe);
            TextExtension.setText(cgHaveTxt,mc.cgHaveTf.tField,_loc8_);
         }
         if(mc.HealthState == InvEnum.HEALTH_CRITICAL)
         {
            _loc5_ = !mc.IsFocused ? ColorScheme.T_DARK : ColorScheme.T_FOCUS;
            TextExtension.setText(_loc4_,mc.health.tField,ColorScheme.Get(_loc5_ + ColorScheme.T_NEGATIVE));
         }
         else if(mc.HealthState == InvEnum.HEALTH_BAD)
         {
            _loc5_ = !mc.IsFocused ? ColorScheme.T_DARK : ColorScheme.T_FOCUS;
            TextExtension.setText(_loc4_,mc.health.tField,ColorScheme.Get(_loc5_ + ColorScheme.T_WARNING));
         }
         else
         {
            TextExtension.setText(_loc4_,mc.health.tField,_loc3_);
         }
         TextExtension.setText(_loc14_,mc.amount.tField,_loc3_);
         TextExtension.setText(_loc10_,mc.stat.tField,_loc3_);
         TextExtension.setText(_loc7_,mc.price.tField,_loc3_);
         TextExtension.setText(_loc13_,mc.weight.tField,_loc3_);
         if(mc.cost)
         {
            TextExtension.setText(_loc9_,mc.cost.tField,_loc3_);
         }
      }
      else
      {
         _loc5_ = !mc.IsFocused ? ColorScheme.T_LIGHT : ColorScheme.T_FOCUS;
         _loc5_ += mc.IsEnable ? "" : ColorScheme.T_DISABLE;
         _loc5_ += !mc.IsHiglight ? "" : ColorScheme.T_HIGHLIGHTED;
         TextExtension.setText(mc.name.tField.text,mc.name.tField,ColorScheme.Get(_loc5_));
      }
   }
}
