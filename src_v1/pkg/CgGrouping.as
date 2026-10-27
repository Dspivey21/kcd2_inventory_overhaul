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