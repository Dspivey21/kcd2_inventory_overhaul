class InventoryData extends TreeData
{
   var Childrens;
   var m_CurrentFilter;
   var m_CurrentSort;
   var m_FocusedItem;
   var m_HeadingPrototypes;
   var m_HeadingVisibility;
   var m_CgOpenKey;
   var m_CgRows;
   var m_CgBase;
   var m_CgView;
   var m_CgFlat;
   var m_CgViewFlat;
   var m_CgCanExpand;
   var m_CgGroupCount;
   var m_CgHoldStart;
   var m_CgHoldTimer;
   var m_CgHoldDone;
   var m_CgLastToggle;
   var m_CgFocusTime;
   var m_FocusedItemViewIndex;
   function InventoryData(id)
   {
      super(id);
      InvEnum.InitFilterBeginEndConsts();
      this.m_CurrentFilter = InvEnum.FILTER_ALL;
      this.m_CurrentSort = InvEnum.SORT_NAME_ASC;
      this.m_HeadingVisibility = true;
      this.m_HeadingPrototypes = [];
      var _loc4_ = InvEnum.CATEGORY_NAMES.length;
      var _loc3_ = 0;
      while(_loc3_ < _loc4_)
      {
         this.m_HeadingPrototypes[_loc3_] = new InventoryHeading(InvEnum.CATEGORY_NAMES[_loc3_],_loc3_);
         if(InvEnum.CATEGORY_NAMES[_loc3_] == InvEnum.CATEGORY_SELLING)
         {
            this.m_HeadingPrototypes[_loc3_].IsPlayerInventoryId = true;
         }
         _loc3_ = _loc3_ + 1;
      }
      this.m_HeadingPrototypes[_loc3_] = new InventoryHeading(InvEnum.CATEGORY_UNKNOWN,_loc4_);
      this.AddHeading();
   }
   function get CurrentFilter()
   {
      return this.m_CurrentFilter;
   }
   function get CurrentSort()
   {
      return this.m_CurrentSort;
   }
   function get HeadingVisibility()
   {
      return this.m_HeadingVisibility;
   }
   function m_SetDataFunc(dataA, startIndex)
   {
      return startIndex;
   }
   function GetViewArray()
   {
      if(InventoryData.s_HaveDirty)
      {
         InventoryData.s_HaveDirty = false;
         InventoryData.HaveRequest();
      }
      var cgGetVie2 = super.GetViewArray();
      if(this.m_CgView != undefined && this.m_CgBase == cgGetVie2 && this.m_CgViewFlat == this.m_CgFlat)
      {
         return this.m_CgView;
      }
      this.m_CgBase = cgGetVie2;
      this.m_CgViewFlat = this.m_CgFlat;
      var i;
      if(this.m_CgFlat)
      {
         i = 0;
         while(i < cgGetVie2.length)
         {
            cgGetVie2[i].ColourGroupKey = undefined;
            cgGetVie2[i].CgIndent = false;
            i = i + 1;
         }
         this.m_CgView = cgGetVie2;
      }
      else
      {
         this.m_CgView = this.CgBuild(cgGetVie2);
      }
      var can = this.m_CgFlat || this.m_CgGroupCount > 0;
      if(can != this.m_CgCanExpand)
      {
         this.m_CgCanExpand = can;
         this.CgReportState(this.m_FocusedItem,false);
      }
      return this.m_CgView;
   }
   function GetViewArrayLength()
   {
      return this.GetViewArray().length;
   }
   function CgEligible(item)
   {
      if(item == undefined || item.IsHeading || item.IsMoney || item.IsColourGroup)
      {
         return false;
      }
      if(_root.g_Mode == InvEnum.MODE_FILTER)
      {
         return false;
      }
      return true;
   }
   function CgIsWeapon(item)
   {
      var cat = item.Category;
      return cat >= InvEnum.FILTER_WEAPONS_BEGIN && cat <= InvEnum.FILTER_WEAPONS_END;
   }
   function CgIsArmour(item)
   {
      var cat = item.Category;
      return cat >= InvEnum.FILTER_ARMOUR_BEGIN && cat <= InvEnum.FILTER_ARMOUR_END;
   }
   function CgMesh(item)
   {
      var icon = item.IconId;
      if(icon == undefined || typeof icon != "string")
      {
         return undefined;
      }
      var cut = icon.indexOf("_m");
      if(cut <= 0)
      {
         return undefined;
      }
      return icon.substring(0,cut).toLowerCase();
   }
   function CgGetKey(item)
   {
      var mesh = this.CgIsArmour(item) ? this.CgMesh(item) : undefined;
      if(mesh == undefined)
      {
         mesh = "n:" + String(item.NameKey);
      }
      return mesh + "|" + String(item.Category) + "|" + String(item.InventoryId);
   }
   function CgTitle(membersA)
   {
      var key = String(this.CgGetKey(membersA[0]));
      var mesh = key.substring(0,key.indexOf("|"));
      var title = InvEnum.GROUP_TITLES[mesh];
      if(title == undefined)
      {
         title = String(membersA[0].Name);
      }
      var i = 0;
      while(i < membersA.length)
      {
         if(InvEnum.IsUniqueKey(membersA[i].NameKey))
         {
            return title + "*";
         }
         i = i + 1;
      }
      return title;
   }
   function CgBuild(baseA)
   {
      var cgCgBuil11 = baseA.length;
      var cgCgBuil5 = {};
      var cgCgBuil2;
      var cgCgBuil3;
      var cgCgBuil4;
      cgCgBuil2 = 0;
      while(cgCgBuil2 < cgCgBuil11)
      {
         cgCgBuil3 = baseA[cgCgBuil2];
         cgCgBuil3.ColourGroupKey = undefined;
         cgCgBuil3.CgIndent = false;
         if(this.CgEligible(cgCgBuil3))
         {
            cgCgBuil4 = this.CgGetKey(cgCgBuil3);
            cgCgBuil3.ColourGroupKey = cgCgBuil4;
            if(cgCgBuil5[cgCgBuil4] == undefined)
            {
               cgCgBuil5[cgCgBuil4] = [];
            }
            cgCgBuil5[cgCgBuil4].push(cgCgBuil3);
         }
         cgCgBuil2 = cgCgBuil2 + 1;
      }
      if(this.m_CgRows == undefined)
      {
         this.m_CgRows = {};
      }
      if(this.m_CgOpenKey != undefined && (cgCgBuil5[this.m_CgOpenKey] == undefined || cgCgBuil5[this.m_CgOpenKey].length < 1))
      {
         this.m_CgOpenKey = undefined;
      }
      var units = [];
      var seen = {};
      this.m_CgGroupCount = 0;
      var item;
      var key;
      var i = 0;
      while(i < cgCgBuil11)
      {
         item = baseA[i];
         key = item.ColourGroupKey;
         if(key == undefined || cgCgBuil5[key].length < 2 && key != this.m_CgOpenKey)
         {
            item.ColourGroupKey = undefined;
            units.push(item);
         }
         else if(seen[key] != true)
         {
            seen[key] = true;
            units.push(this.CgRow(key,cgCgBuil5[key]));
            this.m_CgGroupCount = this.m_CgGroupCount + 1;
         }
         i = i + 1;
      }
      if(this.m_CgGroupCount == 0)
      {
         return baseA;
      }
      this.CgNameGroups(units);
      units = this.m_SortFunc(units);
      var cgCgBuil8 = [];
      var members;
      var j;
      i = 0;
      while(i < units.length)
      {
         item = units[i];
         cgCgBuil8.push(item);
         if(item.IsColourGroup && this.m_CgOpenKey == item.CgKey)
         {
            members = cgCgBuil5[item.CgKey];
            j = 0;
            while(j < members.length)
            {
               members[j].CgIndent = true;
               cgCgBuil8.push(members[j]);
               j = j + 1;
            }
         }
         i = i + 1;
      }
      return cgCgBuil8;
   }
   function CgRow(key, membersA)
   {
      var cgCgRow2 = this.m_CgRows[key];
      if(cgCgRow2 == undefined)
      {
         cgCgRow2 = new InventoryItem("cg|" + key);
         cgCgRow2.IsColourGroup = true;
         cgCgRow2.CgKey = key;
         cgCgRow2.m_Parent = this;
         cgCgRow2.GetStackIds = function()
         {
            return "";
         };
         this.m_CgRows[key] = cgCgRow2;
      }
      var cgCgRow4 = membersA[0];
      var worst = cgCgRow4;
      var outfit = 0;
      var anyNew = false;
      var count = 0;
      var weight = 0;
      var price = 0;
      var health = 0;
      var stat = cgCgRow4.MainStat;
      var equip = cgCgRow4.EquipOrder;
      var m;
      var n;
      var k = 0;
      while(k < membersA.length)
      {
         m = membersA[k];
         n = m.StackAmount > 0 ? m.StackAmount : 1;
         count += n;
         weight += n * m.Weight;
         price += n * m.Price;
         health += n * m.Health;
         if(m.Health < worst.Health)
         {
            worst = m;
         }
         if(m.MainStat > stat)
         {
            stat = m.MainStat;
         }
         if(m.EquipOrder < equip)
         {
            equip = m.EquipOrder;
         }
         outfit |= m.OutfitPresence;
         if(m.IsNew)
         {
            anyNew = true;
         }
         k = k + 1;
      }
      cgCgRow2.CgTop = cgCgRow4;
      cgCgRow2.CgMembers = membersA;
      var seenIcon = {};
      var variants = 0;
      k = 0;
      while(k < membersA.length)
      {
         if(seenIcon[String(membersA[k].IconId)] != true)
         {
            seenIcon[String(membersA[k].IconId)] = true;
            variants = variants + 1;
         }
         k = k + 1;
      }
      cgCgRow2.CgCount = variants;
      cgCgRow2.CgTitleText = this.CgTitle(membersA);
      cgCgRow2.IconId = cgCgRow4.IconId;
      cgCgRow2.MainStat = stat;
      cgCgRow2.Weight = weight;
      cgCgRow2.TotalWeight = weight;
      cgCgRow2.Price = price;
      cgCgRow2.TotalPrice = price;
      cgCgRow2.Cost = cgCgRow4.Cost;
      var bestQ = 0;
      k = 0;
      while(k < membersA.length)
      {
         if(Number(membersA[k].Quality) > bestQ)
         {
            bestQ = Number(membersA[k].Quality);
         }
         k = k + 1;
      }
      cgCgRow2.Quality = bestQ;
      cgCgRow2.Health = health / count;
      cgCgRow2.HealthState = worst.HealthState;
      cgCgRow2.OutfitPresence = outfit;
      cgCgRow2.IsNew = anyNew;
      cgCgRow2.IsEnable = true;
      cgCgRow2.IsRepainted = false;
      cgCgRow2.IsQuestItem = false;
      var anySel = false;
      k = 0;
      while(k < membersA.length)
      {
         if(membersA[k].IsSelected)
         {
            anySel = true;
         }
         k = k + 1;
      }
      cgCgRow2.IsSelected = anySel;
      cgCgRow2.IsMoney = false;
      cgCgRow2.Amount = count;
      cgCgRow2.StackAmount = count;
      cgCgRow2.Stolen = 0;
      cgCgRow2.Dirt = 0;
      cgCgRow2.Blood = 0;
      cgCgRow2.BuffIcon = 0;
      cgCgRow2.Category = cgCgRow4.Category;
      cgCgRow2.MainCategory = cgCgRow4.MainCategory;
      cgCgRow2.InventoryId = cgCgRow4.InventoryId;
      cgCgRow2.EquipOrder = equip;
      cgCgRow2.HashName = cgCgRow4.HashName;
      cgCgRow2.ClassId = cgCgRow4.ClassId;
      cgCgRow2.IsPlayerInventoryId = cgCgRow4.IsPlayerInventoryId;
      cgCgRow2.IsHorseEquip = cgCgRow4.IsHorseEquip;
      return cgCgRow2;
   }
   function CgNameGroups(units)
   {
      var byTitle = {};
      var row;
      var tk;
      var i = 0;
      while(i < units.length)
      {
         row = units[i];
         if(row.IsColourGroup)
         {
            tk = String(row.Category) + "|" + row.CgTitleText;
            if(byTitle[tk] == undefined)
            {
               byTitle[tk] = [];
            }
            byTitle[tk].push(row);
         }
         i = i + 1;
      }
      var list;
      var n;
      var suffix;
      for(var t in byTitle)
      {
         list = byTitle[t];
         list.sortOn("CgKey");
         n = 0;
         while(n < list.length)
         {
            row = list[n];
            suffix = list.length > 1 ? " V" + (n + 1) : "";
            row.CgNameMain = (this.m_CgOpenKey != row.CgKey ? "+ " : "- ") + row.CgTitleText + suffix;
            row.CgNameTail = "   (" + row.CgCount + ")";
            row.Name = row.CgNameMain + row.CgNameTail;
            n = n + 1;
         }
      }
   }
   static var s_CgKeyDownAt = -10000;
   function CgTransferIds(row)
   {
      var root = _root;
      if(root.GetData == undefined || row.CgMembers == undefined)
      {
         return "";
      }
      if(getTimer() - InventoryData.s_CgKeyDownAt < 300)
      {
         return "";
      }
      var ids = "";
      var i = 0;
      while(i < row.CgMembers.length)
      {
         ids = ids + (i > 0 ? "|" : "") + row.CgMembers[i].GetStackIds();
         i = i + 1;
      }
      return ids;
   }
   static function CgLog(msg)
   {
      flash.external.ExternalInterface.call("onGeneralEvent","cg:" + msg,0);
   }
   function CgToggle(source)
   {
      var f = this.m_FocusedItem;
      var k;
      if(f == undefined)
      {
         return false;
      }
      if(f.IsColourGroup)
      {
         k = f.CgKey;
      }
      else if(f.CgIndent && f.ColourGroupKey != undefined)
      {
         k = f.ColourGroupKey;
      }
      else
      {
         return false;
      }
      var g = this.m_CgRows[k];
      if(g == undefined)
      {
         return false;
      }
      var now = getTimer();
      if(this.m_CgLastToggle != undefined && now - this.m_CgLastToggle < 350)
      {
         return true;
      }
      this.m_CgLastToggle = now;
      this.m_CgOpenKey = this.m_CgOpenKey != k ? k : undefined;
      this.UpdateView();
      if(this.m_FocusedItem != g)
      {
         this.Focus(g);
      }
      else
      {
         this.m_FocusFunc(g);
      }
      this.m_FocusedItemViewIndex = this.GetIndexInViewArray(g);
      Audio.Play(Audio.APSE_SORT);
      InventoryData.CgLog("toggle " + source + " open=" + (this.m_CgOpenKey != undefined) + " cid=" + String(g.ClassId) + " key=" + String(g.CgTop.NameKey));
      return true;
   }
   static var s_CgLastState;
   static var s_CgModal = false;
   static function CgModal(open)
   {
      InventoryData.s_CgModal = open;
      if(open)
      {
         InventoryData.s_CgLastState = "none";
         InventoryData.CgLog("state=none");
      }
   }
   function CgIsActiveList()
   {
      var root = _root;
      if(root.GetData == undefined || root.g_Idx == undefined)
      {
         return true;
      }
      return root.GetData(root.g_Idx) == this;
   }
   function CgReportState(child, force)
   {
      if(!this.CgIsActiveList())
      {
         return undefined;
      }
      var st = "item";
      if(child == undefined || InventoryData.s_CgModal)
      {
         st = "none";
      }
      else if(child.IsColourGroup)
      {
         st = this.m_CgOpenKey != child.CgKey ? "group" : "groupopen";
      }
      else if(child.CgIndent)
      {
         st = "member";
      }
      if(this.m_CgFlat && st != "none")
      {
         st = st + ":flat";
      }
      if(!this.m_CgCanExpand && st != "none")
      {
         st = st + ":ng";
      }
      if(st.indexOf("item") == 0 && InventoryData.s_CgLastState != undefined && InventoryData.s_CgLastState.indexOf("item") != 0 && InventoryData.s_CgLastState != "none")
      {
         InventoryData.s_CgLeftGroupAt = getTimer();
      }
      if(force || st != InventoryData.s_CgLastState)
      {
         InventoryData.s_CgLastState = st;
         InventoryData.CgLog("state=" + st);
      }
   }
   function CgToggleFlat(source)
   {
      if(!this.m_CgFlat && !this.m_CgCanExpand)
      {
         return undefined;
      }
      var f = this.m_FocusedItem;
      this.m_CgFlat = !this.m_CgFlat;
      this.m_CgOpenKey = undefined;
      this.UpdateView();
      if(f != undefined && f.IsColourGroup && f.CgTop != undefined)
      {
         f = f.CgTop;
      }
      if(f != undefined)
      {
         this.Focus(f);
      }
      this.CgReportState(this.m_FocusedItem,true);
      Audio.Play(Audio.APSE_SORT);
      InventoryData.CgLog("expand all " + source + " flat=" + this.m_CgFlat);
   }
   function CgHoldSignal()
   {
      var now = getTimer();
      if(this.m_CgHoldStart != undefined)
      {
         clearInterval(this.m_CgHoldTimer);
         this.m_CgHoldStart = undefined;
         InventoryData.CgLog("hold=cancel");
         return undefined;
      }
      if(this.m_CgHoldDone != undefined && now - this.m_CgHoldDone < 600)
      {
         return undefined;
      }
      if(!this.m_CgFlat && !this.m_CgCanExpand)
      {
         return undefined;
      }
      this.m_CgHoldStart = now;
      this.m_CgHoldTimer = setInterval(this,"CgHoldComplete",2250);
      InventoryData.CgLog("hold=start");
   }
   function CgHoldComplete()
   {
      clearInterval(this.m_CgHoldTimer);
      this.m_CgHoldStart = undefined;
      this.m_CgHoldDone = getTimer();
      InventoryData.CgLog("hold=done");
      this.CgToggleFlat("pad");
   }
   function CgCloseAll()
   {
      this.m_CgOpenKey = undefined;
   }
   function FocusByKey(key)
   {
      var cgFocusB3;
      var cgFocusB4;
      if(typeof key == "string" && key.substring(0,3) == "cg|")
      {
         cgFocusB3 = this.m_CgRows[key.substring(3)];
         if(cgFocusB3 == undefined)
         {
            return TreeData.E_FOCUS_RESULT_UNDEFINED;
         }
         var res = this.Focus(cgFocusB3);
         this.CgToggle("click");
         return res;
      }
      this.GetViewArray();
      cgFocusB4 = this.GetByKey(key,true);
      if(cgFocusB4 != undefined && cgFocusB4.ColourGroupKey != undefined && this.m_CgOpenKey != cgFocusB4.ColourGroupKey && this.m_CgRows[cgFocusB4.ColourGroupKey] != undefined)
      {
         return this.Focus(this.m_CgRows[cgFocusB4.ColourGroupKey]);
      }
      return super.FocusByKey(key);
   }
   static var s_HaveIndex;
   static var s_HaveKeys = 0;
   static var s_HaveDirty = true;
   static var s_HaveTimer;
   static var s_HaveApplyTimer;
   static var s_HaveIncoming;
   static var s_HaveIncomingBest;
   static var s_HaveBest;
   static var s_HaveGrade = 0;
   static var s_HaveIncomingKeys = 0;
   function DataChanged()
   {
      InventoryData.s_HaveDirty = true;
      super.DataChanged();
   }
   static function HaveMine()
   {
      var root = _root;
      if(root.GetData != undefined)
      {
         return root.GetData(InvEnum.TRANSFER_IDX_FIRST);
      }
      if(root.g_Data != undefined && root.g_PlayerId != undefined && root.g_PlayerId != InvEnum.INVALID)
      {
         return root.g_Data;
      }
      return undefined;
   }
   static function HaveIsMine(item)
   {
      var root = _root;
      if(root.GetData != undefined)
      {
         return item.Root == root.GetData(InvEnum.TRANSFER_IDX_FIRST);
      }
      return item.InventoryId == root.g_PlayerId;
   }
   static function HaveKey(item)
   {
      var k = String(item.NameKey);
      if(k.charAt(0) == "@")
      {
         k = k.substring(1);
      }
      return k + "|" + String(item.IconId) + "|" + String(item.Quality);
   }
   static function HaveRequest()
   {
      if(InventoryData.s_HaveTimer != undefined)
      {
         return undefined;
      }
      InventoryData.s_HaveTimer = setInterval(InventoryData.HaveRequestNow,1);
   }
   static var s_CgLeftGroupAt = 0;
   static var s_CgStoreKnown = false;
   static var s_CgStoreIsStash = true;
   static function CgStoreAnswer(v)
   {
      InventoryData.s_CgStoreKnown = true;
      InventoryData.s_CgStoreIsStash = String(v) != "0";
      InventoryData.s_HaveDirty = true;
   }
   static function HaveScreen()
   {
      var mode = _root.g_Mode;
      if(mode == InvEnum.MODE_STORE)
      {
         return InventoryData.s_CgStoreKnown && !InventoryData.s_CgStoreIsStash;
      }
      return mode == InvEnum.MODE_SHOP_TRADER || mode == InvEnum.MODE_SHOP_PLAYER || mode == InvEnum.MODE_LOOT;
   }
   static function HaveTrade()
   {
      var mode = _root.g_Mode;
      return mode == InvEnum.MODE_SHOP_TRADER || mode == InvEnum.MODE_SHOP_PLAYER;
   }
   static function HaveBuyList()
   {
      return _root.g_Mode == InvEnum.MODE_SHOP_TRADER;
   }
   static var CG_TRADE_COL_L = 900;
   static var CG_TRADE_COL_R = 1140.6;
   static var CG_TRADE_DIV_X = 1000;
   static var CG_TRADE_HDR_X = 1072.9;
   static function HaveRequestNow()
   {
      clearInterval(InventoryData.s_HaveTimer);
      InventoryData.s_HaveTimer = undefined;
      if(!InventoryData.HaveScreen() || InventoryData.HaveMine() == undefined)
      {
         return undefined;
      }
      InventoryData.CgLog("haveget");
   }
   static function HaveReceive(data)
   {
      var d = String(data);
      if(d == "!begin")
      {
         InventoryData.s_HaveIncoming = {};
         InventoryData.s_HaveIncomingBest = {};
         InventoryData.s_HaveIncomingKeys = 0;
         return undefined;
      }
      if(d == "!end")
      {
         InventoryData.s_HaveIndex = InventoryData.s_HaveIncoming;
         InventoryData.s_HaveBest = InventoryData.s_HaveIncomingBest;
         InventoryData.s_HaveKeys = InventoryData.s_HaveIncomingKeys;
         InventoryData.s_HaveIncoming = undefined;
         InventoryData.s_HaveIncomingBest = undefined;
         if(InventoryData.s_HaveApplyTimer == undefined)
         {
            InventoryData.s_HaveApplyTimer = setInterval(InventoryData.HaveApply,1);
         }
         return undefined;
      }
      if(InventoryData.s_HaveIncoming == undefined)
      {
         return undefined;
      }
      var parts = d.split(";");
      var i = 0;
      var eq;
      while(i < parts.length)
      {
         eq = parts[i].lastIndexOf("=");
         if(eq > 0)
         {
            var val = parts[i].substring(eq + 1);
            var colon = val.indexOf(":");
            if(colon > 0)
            {
               InventoryData.s_HaveIncomingBest[parts[i].substring(0,eq)] = Number(val.substring(colon + 1));
               val = val.substring(0,colon);
            }
            InventoryData.s_HaveIncoming[parts[i].substring(0,eq)] = Number(val);
            InventoryData.s_HaveIncomingKeys = InventoryData.s_HaveIncomingKeys + 1;
         }
         i = i + 1;
      }
   }
   static function HaveApply()
   {
      clearInterval(InventoryData.s_HaveApplyTimer);
      InventoryData.s_HaveApplyTimer = undefined;
      var root = _root;
      if(root.GetData != undefined)
      {
         root.GetData(InvEnum.TRANSFER_IDX_FIRST).UpdateView();
         root.GetData(InvEnum.TRANSFER_IDX_SECOND).UpdateView();
      }
      else if(root.g_Data != undefined)
      {
         root.g_Data.UpdateView();
      }
   }
   static function HaveText(item)
   {
      if(item == undefined || item.IsHeading || item.IsMoney || item.IsColourGroup || !InventoryData.HaveScreen())
      {
         return "";
      }
      if(InventoryData.HaveMine() == undefined || InventoryData.HaveIsMine(item) || InventoryData.s_HaveIndex == undefined)
      {
         return "";
      }
      InventoryData.s_HaveGrade = 0;
      var key = InventoryData.HaveKey(item);
      if(Number(item.Quality) > 0)
      {
         key = key.substring(0,key.lastIndexOf("|")) + "|*";
      }
      var n = InventoryData.s_HaveIndex[key];
      if(n == undefined || n <= 0)
      {
         return "";
      }
      if(Number(item.Quality) > 0 && InventoryData.s_HaveBest != undefined && InventoryData.s_HaveBest[key] != undefined)
      {
         InventoryData.s_HaveGrade = Number(InventoryData.s_HaveBest[key]);
      }
      return "HAVE (" + n + ")";
   }

   function m_CreateChildFunc(id)
   {
      return new InventoryItem(id);
   }
   function m_SortFunc(arr)
   {
      var _loc3_ = [];
      var _loc4_ = [];
      if(this.m_HeadingVisibility)
      {
         if(this.m_CurrentFilter == InvEnum.FILTER_HORSE)
         {
            _loc3_.push("IsHorseEquip");
            _loc4_.push(Array.NUMERIC | Array.DESCENDING);
         }
         if(this.m_CurrentFilter == InvEnum.FILTER_BASKET)
         {
            _loc3_.push("IsPlayerInventoryId");
            _loc4_.push(Array.NUMERIC);
         }
         else
         {
            _loc3_.push("Category");
            _loc4_.push(Array.NUMERIC);
         }
         _loc3_.push("IsHeading");
         _loc4_.push(Array.NUMERIC | Array.DESCENDING);
      }
      if(_root.g_Mode == InvEnum.MODE_STORE || _root.g_Mode == InvEnum.MODE_LOOT)
      {
         _loc3_.push("IsQuestItem");
         _loc4_.push(Array.NUMERIC | Array.DESCENDING);
      }
      switch(this.m_CurrentSort)
      {
         case InvEnum.SORT_EQUIP_ASC:
         case InvEnum.SORT_EQUIP_DES:
            _loc3_.push("EquipOrder");
            break;
         case InvEnum.SORT_AMOUNT_ASC:
         case InvEnum.SORT_AMOUNT_DES:
            _loc3_.push("StackAmount");
            break;
         case InvEnum.SORT_STAT_ASC:
         case InvEnum.SORT_STAT_DES:
            _loc3_.push("MainStat");
            break;
         case InvEnum.SORT_HEALTH_ASC:
         case InvEnum.SORT_HEALTH_DES:
            _loc3_.push("Health");
            break;
         case InvEnum.SORT_WEIGHT_ASC:
         case InvEnum.SORT_WEIGHT_DES:
            _loc3_.push("Weight");
            break;
         case InvEnum.SORT_PRICE_ASC:
         case InvEnum.SORT_PRICE_DES:
            _loc3_.push("Price");
            break;
         case InvEnum.SORT_COST_ASC:
         case InvEnum.SORT_COST_DES:
            _loc3_.push("Cost");
      }
      switch(this.m_CurrentSort)
      {
         case InvEnum.SORT_EQUIP_ASC:
         case InvEnum.SORT_AMOUNT_ASC:
         case InvEnum.SORT_STAT_ASC:
         case InvEnum.SORT_HEALTH_ASC:
         case InvEnum.SORT_WEIGHT_ASC:
         case InvEnum.SORT_PRICE_ASC:
         case InvEnum.SORT_COST_ASC:
            _loc4_.push(Array.NUMERIC);
            break;
         case InvEnum.SORT_EQUIP_DES:
         case InvEnum.SORT_AMOUNT_DES:
         case InvEnum.SORT_STAT_DES:
         case InvEnum.SORT_HEALTH_DES:
         case InvEnum.SORT_WEIGHT_DES:
         case InvEnum.SORT_PRICE_DES:
         case InvEnum.SORT_COST_DES:
            _loc4_.push(Array.NUMERIC | Array.DESCENDING);
      }
      if(this.m_CurrentSort == InvEnum.SORT_NAME_DES)
      {
         _loc3_.push("HashName");
         _loc4_.push(Array.CASEINSENSITIVE | Array.DESCENDING);
      }
      else
      {
         _loc3_.push("HashName");
         _loc4_.push(Array.CASEINSENSITIVE);
      }
      _loc3_.push("ClassId");
      _loc4_.push(Array.NUMERIC);
      var _loc5_ = arr.concat().sortOn(_loc3_,_loc4_);
      return _loc5_;
   }
   function m_FilterFunc(child)
   {
      var _loc5_;
      var _loc4_;
      if(child.IsHeading)
      {
         if(_root.g_Mode == InvEnum.MODE_SHOP_TRADER)
         {
            _loc5_ = child.UsedPerInventory[InvEnum.INVALID] || child.UsedPerInventory[_root.g_PlayerId];
            if(!this.m_HeadingVisibility || !_loc5_)
            {
               return false;
            }
            if(child.IsBasketHeading && this.m_CurrentFilter != InvEnum.FILTER_BASKET || !child.IsBasketHeading && this.m_CurrentFilter == InvEnum.FILTER_BASKET)
            {
               return false;
            }
            if(child.IsBasketHeading && this.m_CurrentFilter == InvEnum.FILTER_BASKET && _loc5_)
            {
               return true;
            }
         }
         else
         {
            _loc4_ = this.m_CurrentFilter != InvEnum.FILTER_HORSE ? _root.g_PlayerId : _root.g_HorseId;
            if(_root.g_PlayerId == undefined)
            {
               _loc4_ = InvEnum.INVALID;
            }
            if(!this.m_HeadingVisibility || !child.UsedPerInventory[_loc4_])
            {
               return false;
            }
         }
      }
      else if(_root.g_Mode == InvEnum.MODE_SHOP_TRADER)
      {
         if(this.m_CurrentFilter != InvEnum.FILTER_BASKET && this.IsOwnerPlayer(child.InventoryId))
         {
            return false;
         }
      }
      else
      {
         if(this.m_CurrentFilter == InvEnum.FILTER_HORSE && this.IsOwnerPlayer(child.InventoryId))
         {
            return false;
         }
         if(this.m_CurrentFilter != InvEnum.FILTER_HORSE && !this.IsOwnerPlayer(child.InventoryId))
         {
            return false;
         }
      }
      if(child.IsMoney && (_root.g_Mode == InvEnum.MODE_SHOP_PLAYER || _root.g_Mode == InvEnum.MODE_SHOP_TRADER))
      {
         return false;
      }
      switch(this.m_CurrentFilter)
      {
         case InvEnum.FILTER_ALL:
            return true;
         case InvEnum.FILTER_WEAPONS:
            return child.Category >= InvEnum.FILTER_WEAPONS_BEGIN && child.Category <= InvEnum.FILTER_WEAPONS_END;
         case InvEnum.FILTER_ARMOUR:
            return child.Category >= InvEnum.FILTER_ARMOUR_BEGIN && child.Category <= InvEnum.FILTER_ARMOUR_END;
         case InvEnum.FILTER_FOOD:
            return child.Category >= InvEnum.FILTER_FOOD_BEGIN && child.Category <= InvEnum.FILTER_FOOD_END;
         case InvEnum.FILTER_DOCUMENT:
            return child.Category >= InvEnum.FILTER_DOCUMENT_BEGIN && child.Category <= InvEnum.FILTER_DOCUMENT_END;
         case InvEnum.FILTER_CRAFTING:
            return child.Category >= InvEnum.FILTER_CRAFTING_BEGIN && child.Category <= InvEnum.FILTER_CRAFTING_END;
         case InvEnum.FILTER_QUEST:
            return child.IsQuestItem;
         case InvEnum.FILTER_OTHER:
            return child.Category >= InvEnum.FILTER_OTHER_BEGIN && child.Category <= InvEnum.FILTER_OTHER_END && !(child.Category == InvEnum.GetCategoryId(InvEnum.CATEGORY_COMMON) && child.IsQuestItem);
         case InvEnum.FILTER_HORSE:
            return true;
         case InvEnum.FILTER_BASKET:
            return child.IsSelected;
         default:
            return;
      }
   }
   function m_StackFunc(childA, childB)
   {
      if(childB instanceof InventoryHeading || childA instanceof InventoryHeading)
      {
         return false;
      }
      if(_root.g_Mode == InvEnum.MODE_FILTER)
      {
         return false;
      }
      if(childA.IsRepainted || childB.IsRepainted)
      {
         return false;
      }
      if(childA.ClassId == childB.ClassId && childA.Health - childB.Health <= InvEnum.ACCURACY && childB.Health - childA.Health <= InvEnum.ACCURACY && this.IsOwnerPlayer(childA.InventoryId) == this.IsOwnerPlayer(childB.InventoryId) && childA.Quality == childB.Quality && childA.IsSelected == childB.IsSelected && childA.OutfitPresence == childB.OutfitPresence && childA.IsQuestItem == childB.IsQuestItem && childA.IsNew == childB.IsNew && childA.Stolen == childB.Stolen && childA.Dirt == childB.Dirt && childA.Blood == childB.Blood && childA.BuffIcon == childB.BuffIcon && childA.BuffDefId == childB.BuffDefId)
      {
         return true;
      }
      return false;
   }
   function m_ResetFunc(child)
   {
      child.StackAmount = child.Amount;
      child.StackIds = [];
   }
   function m_ModifyFunc(child, stackedChild)
   {
      stackedChild.StackAmount += child.Amount;
      stackedChild.StackIds.push(child.Id);
      if(child.IsFocused)
      {
         this.m_FocusedItem = stackedChild;
      }
   }
   function m_GetStackHelperFuncName(child)
   {
      return String(child.ClassId);
   }
   function m_ResetHeadingFunc()
   {
      var _loc3_ = InvEnum.CATEGORY_NAMES.length;
      var _loc2_ = 0;
      while(_loc2_ < _loc3_)
      {
         this.m_HeadingPrototypes[_loc2_].UsedPerInventory = [];
         _loc2_ = _loc2_ + 1;
      }
   }
   function m_UpdateHeadingFunc(child)
   {
      if(child.IsMoney && (_root.g_Mode == InvEnum.MODE_SHOP_PLAYER || _root.g_Mode == InvEnum.MODE_SHOP_TRADER || _root.g_Mode >= InvEnum.MODE_FILTER))
      {
         return undefined;
      }
      if(!child.IsHeading && _root.g_Mode == InvEnum.MODE_SHOP_TRADER)
      {
         if(child.IsSelected)
         {
            if(this.IsOwnerPlayer(child.InventoryId))
            {
               this.m_HeadingPrototypes[InvEnum.GetCategoryId(InvEnum.CATEGORY_SELLING)].UsedPerInventory[child.InventoryId] = true;
            }
            else
            {
               this.m_HeadingPrototypes[InvEnum.GetCategoryId(InvEnum.CATEGORY_BUYING)].UsedPerInventory[InvEnum.INVALID] = true;
            }
         }
         if(!this.IsOwnerPlayer(child.InventoryId) && this.m_HeadingPrototypes[child.Category].UsedPerInventory[InvEnum.INVALID] == undefined)
         {
            this.m_HeadingPrototypes[child.Category].UsedPerInventory[InvEnum.INVALID] = true;
         }
      }
      else if(!child.IsHeading && this.m_HeadingPrototypes[child.Category].UsedPerInventory[child.InventoryId] == undefined)
      {
         this.m_HeadingPrototypes[child.Category].UsedPerInventory[child.InventoryId] = true;
      }
   }
   function m_AfterClearFunc()
   {
      this.m_CgOpenKey = undefined;
      this.m_CgFlat = false;
      this.AddHeading();
   }
   function AddHeading()
   {
      var _loc3_ = InvEnum.CATEGORY_NAMES.length;
      var _loc2_ = 0;
      while(_loc2_ < _loc3_)
      {
         this.Add(this.m_HeadingPrototypes[_loc2_]);
         _loc2_ = _loc2_ + 1;
      }
   }
   function m_FocusFunc(child)
   {
      this.CgReportState(child,false);
      if(child == undefined)
      {
         _root.onFocusedChanged("",this.Root.Id);
      }
      else if(child.IsColourGroup)
      {
         this.m_CgFocusTime = getTimer();
         flash.external.ExternalInterface.call("onFocusChanged",child.CgTop != undefined ? child.CgTop.GetStackIds() : "",true,this.m_CgOpenKey == child.CgKey,Number(this.Root.Id));
      }
      else
      {
         _root.onFocusedChanged(child.GetStackIds(),this.Root.Id);
      }
   }
   function SetSort(sortParam, toggle, callback)
   {
      if(sortParam < InvEnum.SORT_NAME_ASC || sortParam > InvEnum.SORT_COST_ASC)
      {
         DebugTrace.log("SortParam is invalid: " + sortParam,DebugTrace.C_FATAL,"InventoryData::SetSort");
         return undefined;
      }
      var _loc3_ = this.m_CurrentSort;
      if(this.m_CurrentSort == sortParam)
      {
         if(!toggle)
         {
            return undefined;
         }
         sortParam = sortParam + 1;
      }
      this.m_CurrentSort = sortParam;
      callback(_loc3_,this.m_CurrentSort,this.Id);
      this.SortRuleChanged();
   }
   function SortPrev(callback)
   {
      var _loc3_ = this.m_CurrentSort;
      this.m_CurrentSort -= 1;
      if(_root.g_Mode == InvEnum.MODE_REPAIR || _root.g_Mode == InvEnum.MODE_WASH)
      {
         if(this.m_CurrentSort < InvEnum.SORT_NAME_ASC)
         {
            this.m_CurrentSort = InvEnum.SORT_COST_ASC;
         }
      }
      else if(this.m_CurrentSort < InvEnum.SORT_NAME_ASC)
      {
         this.m_CurrentSort = InvEnum.SORT_PRICE_ASC;
      }
      callback(_loc3_,this.m_CurrentSort,this.Id);
      this.SortRuleChanged();
   }
   function SortNext(callback)
   {
      var _loc3_ = this.m_CurrentSort;
      this.m_CurrentSort += 1;
      if(_root.g_Mode == InvEnum.MODE_REPAIR || _root.g_Mode == InvEnum.MODE_WASH)
      {
         if(this.m_CurrentSort > InvEnum.SORT_COST_ASC)
         {
            this.m_CurrentSort = InvEnum.SORT_NAME_ASC;
         }
      }
      else if(this.m_CurrentSort > InvEnum.SORT_PRICE_ASC)
      {
         this.m_CurrentSort = InvEnum.SORT_NAME_ASC;
      }
      callback(_loc3_,this.m_CurrentSort,this.Id);
      this.SortRuleChanged();
   }
   function SetFilter(filterParam, callback)
   {
      if(filterParam < InvEnum.FILTER_ALL || filterParam > InvEnum.FILTER_OTHER && _root.g_Mode != InvEnum.MODE_PLAYER && _root.g_Mode != InvEnum.MODE_SHOP_TRADER || filterParam > InvEnum.FILTER_HORSE && _root.g_Mode != InvEnum.MODE_SHOP_TRADER || filterParam > InvEnum.FILTER_BASKET)
      {
         DebugTrace.log("FilterParam is invalid: " + filterParam,DebugTrace.C_FATAL,"InventoryData::SetFilter");
         return undefined;
      }
      if(!this.IsFilterEnable(filterParam))
      {
         return undefined;
      }
      var _loc4_ = this.m_CurrentFilter;
      if(this.m_CurrentFilter == filterParam)
      {
         return undefined;
      }
      this.m_CgOpenKey = undefined;
      this.m_CgFlat = false;
      this.m_CurrentFilter = filterParam;
      callback(_loc4_,this.m_CurrentFilter,this.Id);
      this.FilterRuleChanged();
   }
   function FilterPrev(callback)
   {
      this.m_CgOpenKey = undefined;
      this.m_CgFlat = false;
      var _loc2_ = this.m_CurrentFilter;
      if(this.m_CurrentFilter == InvEnum.FILTER_BASKET && !this.IsFilterEnable(InvEnum.FILTER_HORSE))
      {
         this.m_CurrentFilter = InvEnum.FILTER_OTHER;
      }
      else
      {
         this.m_CurrentFilter -= 1;
      }
      if(this.m_CurrentFilter < InvEnum.FILTER_ALL)
      {
         if(this.IsFilterEnable(InvEnum.FILTER_BASKET))
         {
            this.m_CurrentFilter = InvEnum.FILTER_BASKET;
         }
         else if(this.IsFilterEnable(InvEnum.FILTER_HORSE))
         {
            this.m_CurrentFilter = InvEnum.FILTER_HORSE;
         }
         else
         {
            this.m_CurrentFilter = InvEnum.FILTER_OTHER;
         }
      }
      callback(_loc2_,this.m_CurrentFilter,this.Id);
      this.FilterRuleChanged();
   }
   function FilterNext(callback)
   {
      this.m_CgOpenKey = undefined;
      this.m_CgFlat = false;
      var _loc2_ = this.m_CurrentFilter;
      this.m_CurrentFilter += 1;
      if(this.m_CurrentFilter == InvEnum.FILTER_HORSE && this.IsFilterEnable(InvEnum.FILTER_BASKET))
      {
         this.m_CurrentFilter = InvEnum.FILTER_BASKET;
      }
      else if(this.m_CurrentFilter > InvEnum.FILTER_OTHER && !(this.IsFilterEnable(InvEnum.FILTER_HORSE) || this.IsFilterEnable(InvEnum.FILTER_BASKET)) || this.m_CurrentFilter > InvEnum.FILTER_HORSE)
      {
         this.m_CurrentFilter = InvEnum.FILTER_ALL;
      }
      callback(_loc2_,this.m_CurrentFilter,this.Id);
      this.FilterRuleChanged();
   }
   function ToggleHeadingVisibility(callback)
   {
      this.m_HeadingVisibility = !this.m_HeadingVisibility;
      callback(!this.m_HeadingVisibility,this.m_HeadingVisibility,this.Id);
      this.FilterRuleChanged();
   }
   function SetHeadingVisibility(visibility, callback)
   {
      var _loc2_ = this.m_HeadingVisibility;
      if(visibility == this.m_HeadingVisibility)
      {
         return undefined;
      }
      this.m_HeadingVisibility = visibility;
      callback(_loc2_,this.m_HeadingVisibility,this.Id);
      this.FilterRuleChanged();
   }
   function ChangeItem(dataA)
   {
      var _loc2_ = dataA[0];
      var _loc3_ = this.GetByKey(_loc2_);
      if(!_loc3_)
      {
         DebugTrace.log("Item not found: " + _loc2_,DebugTrace.C_ERROR,"InventoryData.ChangeItem");
         return undefined;
      }
      dataA.shift();
      _loc3_.Set(dataA);
   }
   function ChangeSelection(id, isSelected)
   {
      var _loc2_ = this.GetByKey(id);
      if(_loc2_.IsSelected != isSelected)
      {
         _loc2_.IsSelected = isSelected;
         this.DataChanged();
         Audio.Play(!isSelected ? Audio.APSE_UNSELECT : Audio.APSE_SELECT);
      }
   }
   function UpdateCurrentOutfit(currentOutfit)
   {
      var _loc2_ = function(inventoryItem)
      {
         if(!inventoryItem.IsHeading)
         {
            inventoryItem.UpdateCurrentOutfit(currentOutfit);
         }
      };
      this.Childrens.Call(_loc2_);
      this.DataChanged();
   }
   function UpdateQAMSubmenu()
   {
      this.DataChanged();
   }
   function GetMoney(inventoryId)
   {
      var money = 0;
      var _loc2_ = function(inventoryItem)
      {
         if(inventoryItem.IsMoney && (inventoryId == undefined || inventoryItem.InventoryId == inventoryId))
         {
            money += inventoryItem.Amount;
         }
      };
      this.Childrens.Call(_loc2_);
      return money;
   }
   function IsFilterEnable(filterParam)
   {
      if(filterParam == InvEnum.FILTER_HORSE)
      {
         if(_root.g_Mode == InvEnum.MODE_PLAYER && _root.g_HorseId != InvEnum.INVALID)
         {
            return true;
         }
         return false;
      }
      if(_root.g_Mode != InvEnum.MODE_SHOP_TRADER && filterParam == InvEnum.FILTER_BASKET)
      {
         return false;
      }
      return true;
   }
   function ToString()
   {
      var _loc3_ = "Tree " + this.Id + "\n";
      var _loc4_ = this.GetViewArray();
      var _loc5_ = _loc4_.length;
      var _loc2_ = 0;
      while(_loc2_ < _loc5_)
      {
         _loc3_ += _loc4_[_loc2_].ToString();
         _loc2_ = _loc2_ + 1;
      }
      return _loc3_;
   }
   function IsOwnerPlayer(inventoryId)
   {
      var _loc2_ = _root.g_PlayerId;
      return _loc2_ == undefined || _loc2_ == InvEnum.INVALID || inventoryId == _loc2_;
   }
}
