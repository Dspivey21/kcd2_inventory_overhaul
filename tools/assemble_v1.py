"""
Builds the mod's Flash sources in src_v1/: reseeds the vanilla decompiled files, applies every patch, and
inserts the colour-group engine from src_v1/pkg/CgGrouping.as.

Run from the project root: python -I tools/assemble_v1.py
It is safe to re-run: every patch asserts its anchor text is present exactly once, so a second run
on already-patched files fails loudly instead of double-applying.
"""
import os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
V1 = os.path.join(ROOT, "src_v1")        # vanilla-based (target)

VAN = os.environ.get("CG_VANILLA_DEC") or os.path.join(ROOT, "vanilla_dec")   # JPEXS decompile of vanilla_original (dec/, dec_ItemTransfer/, dec_ItemSelection/)
import shutil
def reseed():
    for c in ["InvEnum", "InventoryItem", "InventoryData", "ItemView", "InventoryHeading"]:
        shutil.copy(os.path.join(VAN, "dec/scripts/__Packages", c + ".as"), os.path.join(V1, "pkg/scripts/__Packages", c + ".as"))
    shutil.copy(os.path.join(VAN, "dec/scripts/frame_1/DoAction.as"), os.path.join(V1, "list/scripts/frame_1/DoAction.as"))
    shutil.copy(os.path.join(VAN, "dec_ItemTransfer/scripts/frame_1/DoAction.as"), os.path.join(V1, "transfer/scripts/frame_1/DoAction.as"))
    shutil.copy(os.path.join(VAN, "dec_ItemSelection/scripts/frame_1/DoAction.as"), os.path.join(V1, "selection/scripts/frame_1/DoAction.as"))
    for n in ["ApseInventoryList", "ItemTransfer", "ItemSelection"]:
        shutil.copy(os.path.join(ROOT, "vanilla_original/UIElements", n + ".xml"), os.path.join(V1, "uielements", n + ".xml"))
reseed()

def load(p): return open(p, encoding="utf-8").read()
def save(p, s): open(p, "w", encoding="utf-8", newline="\n").write(s)
def rep(s, a, b, n=1):
    c = s.count(a)
    assert c == n, f"anchor found {c}x (expected {n}): {a[:90]!r}"
    return s.replace(a, b)
def rep_re(s, pattern, repl):
    ms = list(re.finditer(pattern, s))
    assert len(ms) == 1, f"regex found {len(ms)}x: {pattern[:90]!r}"
    m = ms[0]
    return s[:m.start()] + repl(m) + s[m.end():]

# ============================================================================ InvEnum
p = os.path.join(V1, "pkg/scripts/__Packages/InvEnum.as"); s = load(p)
s = rep(s, '   static var CATEGORY_NAMES = ["Sword","Blunt","Shield","Polearm","Ranged","Ammo","OtherWeapon","HeadArmor","BodyArmor","HandsArmor","LegsArmor","Attachment","HorseEquipment","OtherClothes","Food","Potion","Poison","LoreBook","SkillBook","Map","Letter","Plan","Recipe","Alchemy","Blacksmithing","Usable","Ointment","Die","Badge","Common","Buying","Selling"];',
        '   static var CATEGORY_NAMES = null;')
s = rep(s, '   static var CATEGORY_USABLE = "Usable";\n   static var CATEGORY_COMMON = "Common";',
        '   static var CATEGORY_USABLE = "tools";\n   static var CATEGORY_COMMON = "common";')
s = rep(s, '''   static function GetCategoryId(categoryName)
   {
      if(CATEGORY_UNKNOWN == categoryName)''', '''   static function EnsureCategories()
   {
      if(CATEGORY_NAMES == null)
      {
         CATEGORY_NAMES = HEADER_IDS.concat();
      }
   }
   static function GetCategoryId(categoryName)
   {
      EnsureCategories();
      if(CATEGORY_UNKNOWN == categoryName)''')
s = rep(s, '''   static function InitFilterBeginEndConsts()
   {
      FILTER_WEAPONS_BEGIN = GetCategoryId("Sword");
      FILTER_WEAPONS_END = GetCategoryId("OtherWeapon");
      FILTER_ARMOUR_BEGIN = GetCategoryId("HeadArmor");
      FILTER_ARMOUR_END = GetCategoryId("OtherClothes");
      FILTER_FOOD_BEGIN = GetCategoryId("Food");
      FILTER_FOOD_END = GetCategoryId("Poison");
      FILTER_DOCUMENT_BEGIN = GetCategoryId("LoreBook");
      FILTER_DOCUMENT_END = GetCategoryId("Recipe");
      FILTER_CRAFTING_BEGIN = GetCategoryId("Alchemy");
      FILTER_CRAFTING_END = GetCategoryId("Blacksmithing");
      FILTER_OTHER_BEGIN = GetCategoryId("Usable");
      FILTER_OTHER_END = GetCategoryId("Common");
   }
   static function IsHorseEquip(categoryName)
   {
      return categoryName == CATEGORY_HORSE_EQUIP;
   }''', '''   static function InitFilterBeginEndConsts()
   {
      EnsureCategories();
      FILTER_WEAPONS_BEGIN = GetCategoryId(TAB_FIRST_WEAPONS);
      FILTER_WEAPONS_END = GetCategoryId(TAB_LAST_WEAPONS);
      FILTER_ARMOUR_BEGIN = GetCategoryId(TAB_FIRST_ARMOUR);
      FILTER_ARMOUR_END = GetCategoryId(TAB_LAST_ARMOUR);
      FILTER_FOOD_BEGIN = GetCategoryId(TAB_FIRST_FOOD);
      FILTER_FOOD_END = GetCategoryId(TAB_LAST_FOOD);
      FILTER_DOCUMENT_BEGIN = GetCategoryId(TAB_FIRST_BOOKS);
      FILTER_DOCUMENT_END = GetCategoryId(TAB_LAST_BOOKS);
      FILTER_CRAFTING_BEGIN = GetCategoryId(TAB_FIRST_MATERIALS);
      FILTER_CRAFTING_END = GetCategoryId(TAB_LAST_MATERIALS);
      FILTER_OTHER_BEGIN = GetCategoryId(TAB_FIRST_OTHER);
      FILTER_OTHER_END = GetCategoryId(TAB_LAST_OTHER);
   }
   static function IsHorseEquip(categoryName)
   {
      return HeaderIsHorse(categoryName);
   }''')
s = rep(s, '''   static function GetItemCategoryName(category)
   {
      return LOCALIZABLE_TOKEN + "ui_item_category_" + category;
   }''', '''   static function GetItemCategoryName(category)
   {
      if(category == CATEGORY_BUYING || category == CATEGORY_SELLING || category == CATEGORY_UNKNOWN)
      {
         return LOCALIZABLE_TOKEN + "ui_item_category_" + category;
      }
      return HeaderText(category);
   }''')
snippet = load(os.path.join(V1, "pkg/scripts/__Packages/InvHeaders.snippet"))
s = rep(s, "   static var CATEGORY_NAMES = null;\n", "   static var CATEGORY_NAMES = null;\n" + snippet)
save(p, s); print("InvEnum ok")

# ============================================================================ InventoryItem
p = os.path.join(V1, "pkg/scripts/__Packages/InventoryItem.as"); s = load(p)
s = rep(s, '   var Weight;\n', '   var Weight;\n   var NameKey;\n   var HeaderId;\n   var IsColourGroup;\n   var ColourGroupKey;\n   var CgKey;\n   var CgTop;\n   var CgCount;\n   var CgIndent;\n   var CgTitleText;\n')
s = rep(s, '''      this.Name = dataA[startIndex];
      this.ClassId = dataA[startIndex + 1];''', '''      this.Name = dataA[startIndex];
      this.NameKey = dataA[startIndex];
      this.ClassId = dataA[startIndex + 1];''')
s = rep(s, '''      this.Category = InvEnum.GetCategoryId(_loc6_);''', '''      this.HeaderId = InvEnum.ResolveHeader(this.NameKey,this.IconId,_loc6_);
      this.Category = InvEnum.GetCategoryId(this.HeaderId);''')
s = rep(s, '''      this.IsHorseEquip = InvEnum.IsHorseEquip(_loc6_);''', '''      this.IsHorseEquip = InvEnum.IsHorseEquip(this.HeaderId);''')
save(p, s); print("InventoryItem ok")

# ============================================================================ ItemView
p = os.path.join(V1, "pkg/scripts/__Packages/ItemView.as"); s = load(p)
m = re.search(r'mc\.name\.tField\.text = TextExtension\.getShortenedText\(dataO\.Name,mc\.name\.tField,(_loc\d+_)\);', s)
assert m, "ItemView name line"
LIM = m.group(1)
# Name caps. Every name goes through CgFit: full size when it fits, scaled down (floor 85 %) when it does not,
# dots only past the floor. Buy list at a trader: the name must end before the HAVE column (CG_TRADE_COL_L).
# Sell list: before the equipped marker. Elsewhere: the vanilla limit.
s = s.replace(m.group(0), '''var cgQs = mc.quality._xscale / 100;
         var cgCol = mc.outfitPresence != undefined && mc.outfitPresence._x > mc.name._x + 100;
         var cgBuy = InventoryData.HaveBuyList();
         var cgSell = InventoryData.HaveTrade() && !cgBuy;
         var cgNameCap = ''' + LIM + ''';
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
            var cgGMax = ''' + LIM + ''';
            if(cgCol)
            {
               cgGMax = cgBuy ? InventoryData.CG_TRADE_COL_L - mc.name._x - 8 : mc.outfitPresence._x - mc.name._x - 40;
            }
            ItemView.CgFit(mc,dataO.CgNameMain,dataO.CgNameTail,cgGMax);
         }''')
s = rep(s, '''      if(dataO instanceof InventoryHeading)
      {
         mc.IsEnable = true;''', '''      if(mc.cgHaveQ != undefined)
      {
         mc.cgHaveQ._visible = false;
      }
      if(mc.cgHaveTf != undefined)
      {
         mc.cgHaveTf._visible = false;
      }
      if(dataO instanceof InventoryHeading)
      {
         mc.IsEnable = true;''')
# outside the trade lists, a row without an equipped marker may run its name through the empty marker column
# up to the first number cell (amount / stat / health are set by now)
s = rep(s, '''         TextExtension.setText(String(_loc12_),mc.health.tField,_loc10_);''',
        '''         TextExtension.setText(String(_loc12_),mc.health.tField,_loc10_);
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
         }''')
s = rep(s, '''         mc.quality._x = mc.name._x + mc.name.tField.textWidth + 13 * mc.quality._xscale / 100;''',
        '''         mc.quality._x = ItemView.CgMarkX(mc,true);
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
               var cgMax = ''' + LIM + ''';
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
         }''')
s = rep(s, '''   function m_highlightFunc(mc)
   {''', '''   static function CgFit(mc, main, tail, cap)
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
   {''')
s = rep(s, '''         TextExtension.setText(_loc6_,mc.name.tField,_loc8_);''', '''         TextExtension.setText(_loc6_,mc.name.tField,_loc8_);
         if(mc.cgHaveTf != undefined && mc.cgHaveTf._visible)
         {
            var cgHaveTxt = mc.cgHaveTf.tField.text;
            mc.cgHaveTf.gotoAndStop(mc.name._currentframe);
            TextExtension.setText(cgHaveTxt,mc.cgHaveTf.tField,_loc8_);
         }''')
save(p, s); print("ItemView ok")

# HAVE (n): on transfer screens, rows the player does not own show how many of the same item class + grade
# the player owns (any condition, pieces). Index over both lists' raw children, rebuilt lazily after any change.
HAVE = '''
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
'''

# ============================================================================ InventoryData
# The colour-group engine (GetViewArray / Cg* / FocusByKey, written for this mod) is its own source file,
# src_v1/pkg/CgGrouping.as; it is inserted verbatim into InventoryData.as after m_SetDataFunc below.
cg = load(os.path.join(V1, "pkg/CgGrouping.as"))
p = os.path.join(V1, "pkg/scripts/__Packages/InventoryData.as"); s = load(p)
s = rep(s, '''   var m_HeadingVisibility;
   function InventoryData(id)''', '''   var m_HeadingVisibility;
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
   function InventoryData(id)''')
s = rep(s, '''   function m_SetDataFunc(dataA, startIndex)
   {
      return startIndex;
   }''', '''   function m_SetDataFunc(dataA, startIndex)
   {
      return startIndex;
   }
''' + cg + HAVE)
# focus reporting
s = rep(s, '''   function m_FocusFunc(child)
   {
      if(child == undefined)
      {
         _root.onFocusedChanged("",this.Root.Id);
      }
      else
      {''', '''   function m_FocusFunc(child)
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
      {''')
s = rep(s, '''   function m_AfterClearFunc()
   {
      this.AddHeading();''', '''   function m_AfterClearFunc()
   {
      this.m_CgOpenKey = undefined;
      this.m_CgFlat = false;
      this.AddHeading();''')
RESET = "      this.m_CgOpenKey = undefined;\n      this.m_CgFlat = false;\n"
s = rep_re(s, r"      this\.m_CurrentFilter = filterParam;\n      callback\((_loc\d+_),this\.m_CurrentFilter,this\.Id\);",
           lambda m: RESET + "      this.m_CurrentFilter = filterParam;\n      callback(" + m.group(1) + ",this.m_CurrentFilter,this.Id);")
for fname in ("FilterPrev", "FilterNext"):
    s = rep_re(s, r"   function " + fname + r"\(callback\)\n   \{\n      var (_loc\d+_) = this\.m_CurrentFilter;",
               lambda m, fname=fname: "   function " + fname + "(callback)\n   {\n" + RESET + "      var " + m.group(1) + " = this.m_CurrentFilter;")
# vanilla bug: compares a category id with the string "Common"; use the id
s = rep(s, '''!(child.Category == InvEnum.CATEGORY_COMMON && child.IsQuestItem)''', '''!(child.Category == InvEnum.GetCategoryId(InvEnum.CATEGORY_COMMON) && child.IsQuestItem)''')
save(p, s); print("InventoryData ok")

# ============================================================================ frames
KEYLISTENER = '''var g_CgKeysDown = {};
var g_CgKeyListener = {};
g_CgKeyListener.onKeyDown = function()
{
   var code = Key.getCode();
   if(_root.g_CgKeysDown[code])
   {
      return undefined;
   }
   _root.g_CgKeysDown[code] = true;
   @ACTIVE@var data = @DATA@;
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
         @ACTIVE@var data = @DATA@;
         if(data.FocusedItem != undefined && data.FocusedItem.IsColourGroup)
         {
            data.CgToggle("key");
         }
      }
   }
};
Key.addListener(g_CgKeyListener);
'''
ACTIVE = 'if(!_root.g_ActiveState)\n   {\n      return undefined;\n   }\n   '

def toggle_block(data):
    return f'''   if(g_CgTcPending != undefined)
   {{
      clearInterval(g_CgTcPending);
      g_CgTcPending = undefined;
      {data}.CgHoldSignal();
      return undefined;
   }}
   g_CgTcPending = setInterval(cgTcFire,120);
}}
function cgTcFire()
{{
   clearInterval(g_CgTcPending);
   g_CgTcPending = undefined;
   var data = {data};
   InventoryData.CgLog("toggle_category");
   if(!data.CgToggle("l3"))
   {{
      if(getTimer() - InventoryData.s_CgLeftGroupAt < 400)
      {{
         InventoryData.CgLog("l3 ignored: focus left a group row " + (getTimer() - InventoryData.s_CgLeftGroupAt) + " ms ago");
      }}
      else
      {{
         data.ToggleHeadingVisibility(UpdateCategoryButton);
      }}
   }}
}}
var g_CgTcPending;'''

for fr, data, active in [("list", "g_Data", ACTIVE), ("transfer", "GetData(g_Idx)", ""), ("selection", "g_Data", "")]:
    p = os.path.join(V1, fr, "scripts/frame_1/DoAction.as"); s = load(p)
    # toggle category -> group toggle / hold signal
    s = rep(s, f'''   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_toggleCategory");
   {data}.ToggleHeadingVisibility(UpdateCategoryButton);
}}''', f'''   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_toggleCategory");
''' + toggle_block(data))
    # focused item: group rows report nothing to the game
    s = rep_re(s, r"   var (_loc\d+_) = " + re.escape(data) + r"\.FocusedItem;\n   if\(\1\)\n   \{\n      return \1\.GetStackIds\(\);",
               lambda m: ("   var R = " + data + ".FocusedItem;\n   if(R && R.IsColourGroup)\n   {\n      return " + data + ".CgTransferIds(R);\n   }\n"
                          "   if(R)\n   {\n      return R.GetStackIds();").replace("R", m.group(1)))
    # double click on a group row: handled by the list (FocusByKey toggles), not the game
    view = "g_View" if fr != "transfer" else "GetView(g_Idx)"
    s = rep_re(s, r"   var (_loc\d+_) = " + re.escape(view) + r"\.GetIdOnMousePosition\(\);\n   if\(\1 != undefined && \1 == " + re.escape(data) + r"\.FocusedItem\.Id\)\n   \{",
               lambda m: ("   var R = " + view + ".GetIdOnMousePosition();\n"
                          "   if(R != undefined && R == " + data + ".FocusedItem.Id && " + data + ".FocusedItem.IsColourGroup)\n   {\n      return undefined;\n   }\n"
                          "   if(R != undefined && R == " + data + ".FocusedItem.Id)\n   {").replace("R", m.group(1)))
    s = s.rstrip("\n") + "\n" + "function fc_cgSetHave(data)\n{\n   InventoryData.HaveReceive(data);\n}\n" + KEYLISTENER.replace("@DATA@", "_root." + data.replace("g_Idx", "_root.g_Idx")).replace("@ACTIVE@", active)
    save(p, s); print(f"{fr} frame: hooks ok")

# list only: report state on activate/deactivate
p = os.path.join(V1, "list/scripts/frame_1/DoAction.as"); s = load(p)

s = rep(s, '''   g_ActiveState = true;
   UpdateTabButtons(undefined,g_Data.CurrentFilter);''', '''   g_ActiveState = true;
   g_Data.CgReportState(g_Data.FocusedItem,true);
   UpdateTabButtons(undefined,g_Data.CurrentFilter);''')
s = rep(s, '''   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_deactivate");
   g_ActiveState = false;''', '''   DebugTrace.log("",DebugTrace.C_DEBUG,"fc_deactivate");
   InventoryData.s_CgLastState = "none";
   InventoryData.CgLog("state=none");
   g_ActiveState = false;''')
s = rep(s, '''function fc_setShopMode(isTrader, playerId)
{
   g_Mode = !isTrader ? InvEnum.MODE_SHOP_PLAYER : InvEnum.MODE_SHOP_TRADER;''', '''function CgTradeColumn(isTrader)
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
   CgTradeColumn(isTrader);''')
save(p, s); print("list frame: activate ok")

# transfer / selection: dialogs and screen open/close
for fr, data, dialogs in [("transfer", "GetData(g_Idx)", ["AmountDialog", "QuestionDialog"]),
                          ("selection", "g_Data", ["AmountDialog", "InfoDialog"])]:
    p = os.path.join(V1, fr, "scripts/frame_1/DoAction.as"); s = load(p)
    for fn in dialogs:
        for kind in ("open", "close"):
            m = re.search(r'(function fc_' + kind + fn + r'\([^)]*\)\n\{\n   DebugTrace\.log\([^\n]*\n)', s)
            assert m, (fr, kind, fn)
            add = '   InventoryData.CgModal(true);\n' if kind == "open" else f'   InventoryData.CgModal(false);\n   {data}.CgReportState({data}.FocusedItem,true);\n'
            s = s[:m.end()] + add + s[m.end():]
    m = re.search(r'(function fc_open\(mode[^)]*\)\n\{\n   DebugTrace\.log\([^\n]*\n)', s); assert m, fr
    s = s[:m.end()] + '   InventoryData.s_CgModal = false;\n' + s[m.end():]
    s = rep(s, 'function fc_close(force)\n{\n', 'function fc_close(force)\n{\n   InventoryData.s_CgLastState = "none";\n   InventoryData.CgLog("state=none");\n')
    if fr == "transfer":
        s = rep(s, '''   g_Idx = newIdx;''', '''   g_Idx = newIdx;
   InventoryData.s_CgLastState = undefined;
   GetData(g_Idx).CgReportState(GetData(g_Idx).FocusedItem,true);''')
    save(p, s); print(f"{fr} frame: dialogs ok")

# transfer: which inventory is the second list (stash or a world container)?
p = os.path.join(V1, "transfer/scripts/frame_1/DoAction.as"); s = load(p)
s = rep(s, '''   InventoryData.s_CgModal = false;
   g_Mode = mode + InvEnum.MODE_STORE;''', '''   InventoryData.s_CgModal = false;
   InventoryData.s_CgStoreKnown = false;
   InventoryData.s_CgStoreIsStash = true;
   g_Mode = mode + InvEnum.MODE_STORE;
   InventoryData.CgLog("open mode=" + mode + " inv=" + selectedInv + " name=" + name);''')
s = rep(s, '''   GetData(idx).SetDataFromArray(g_ItemsA);
   GetData(idx).FocusFirst();
   g_ItemsA.length = 0;''', '''   GetData(idx).SetDataFromArray(g_ItemsA);
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
   }''')
s = s.rstrip("\n") + "\n" + '''function fc_cgStore(v)
{
   InventoryData.CgStoreAnswer(v);
   GetData(InvEnum.TRANSFER_IDX_SECOND).UpdateView();
   GetData(InvEnum.TRANSFER_IDX_FIRST).UpdateView();
}
var g_CgStoreInv;
'''
save(p, s); print("transfer frame: store query ok")

# ============================================================================ UIElements xml
for n in ["ApseInventoryList", "ItemTransfer", "ItemSelection"]:
    p = os.path.join(V1, "uielements", n + ".xml"); b = open(p, "rb").read(); t = b.decode("utf-8")
    m = re.search(r'<UIElement [^>]*>', t); tag = m.group(0)
    assert "keyevents" not in tag
    new = tag.replace(' mouseevents=', ' keyevents="1" mouseevents=')
    t = t.replace(tag, new, 1)
    if "CgSetHave" not in t:
        crlf = "\r\n" if "\r\n" in t else "\n"
        fa = "<functions>"
        assert t.count(fa) == 1, n
        t = t.replace(fa, fa + crlf + '      <function name="CgSetHave" funcname="fc_cgSetHave" >' + crlf +
                      '        <param name="Data" desc="have counts chunk" type="string"/>' + crlf + '      </function>', 1)
    if n == "ItemTransfer" and "CgStore" not in t:
        crlf = "\r\n" if "\r\n" in t else "\n"
        fa = "<functions>"
        t = t.replace(fa, fa + crlf + '      <function name="CgStore" funcname="fc_cgStore" >' + crlf +
                      '        <param name="IsStash" desc="1 = the player stash, 0 = a world container" type="string"/>' + crlf + '      </function>', 1)
    # the mod's messages (row state, HAVE requests, store query) travel on their own event: sent on the game's
    # OnGeneralEvent they replaced the game's own goInHorseTab when both went out in one call
    if "onCgEvent" not in t:
        crlf = "\r\n" if "\r\n" in t else "\n"
        anchor = '      <event name="OnFocusChanged" fscommand="onFocusChanged" desc="" >'
        assert t.count(anchor) == 1, n
        add = ('      <!-- Inventory Overhaul: row state / messages from the list -->' + crlf +
               '      <event name="OnCgEvent" fscommand="onCgEvent" desc="" >' + crlf +
               '        <param name="Name" desc="" type="string"/>' + crlf +
               '        <param name="ClientId" desc="" type="int"/>' + crlf +
               '      </event>' + crlf)
        t = t.replace(anchor, add + anchor)
    open(p, "wb").write(t.encode("utf-8")); print(f"{n}.xml ok")

print("assembled src_v1")
