"""
Turns data/headers.json + data/itemmap.json into InvHeaders.as (ActionScript 2) for the list files.

The class holds:
  IDS[]      header ids in display order (tab by tab), followed by "Buying","Selling"
  TEXT[]     header text shown in the list (same order)
  HORSE[]    1 for horse-gear headers (the Horse tab logic needs it)
  TAB_FIRST / TAB_LAST   first/last id per tab (weapons, armour, food, books, materials, other)
  DEFAULT    engine category string -> header id, used for items missing from the table (new mod items)
  Resolve(nameKey, iconId, engineCategory) -> header id
The item map is split across several static functions so no single function gets too large.

Run: python -I gen_invheaders_as.py --data "<data folder>" --out "<path to InvHeaders.as>"
"""
import argparse, json, os

DEFAULT = {
    "Sword": "shortsword", "Blunt": "mace", "Shield": "shield", "Polearm": "polearm", "Ranged": "bow",
    "Ammo": "arrow", "OtherWeapon": "weapon_other",
    "HeadArmor": "armour_other", "BodyArmor": "armour_other", "HandsArmor": "armour_other",
    "LegsArmor": "armour_other", "Attachment": "armour_other", "HorseEquipment": "saddles",
    "OtherClothes": "armour_other",
    "Food": "food_other", "Potion": "potion_special", "Poison": "poisons",
    "LoreBook": "books", "SkillBook": "skillbooks", "Map": "maps", "Letter": "letters", "Plan": "plans",
    "Recipe": "recipes", "Alchemy": "alchemy", "Blacksmithing": "blacksmithing",
    "Usable": "tools", "Ointment": "common", "Die": "dice", "Badge": "badges_tin", "Common": "common",
    "Money": "groschen",
}
TAB_ORDER = ["weapons", "armour", "food", "books", "materials", "other"]

def esc(s):
    s = s.replace("\\", "\\\\").replace('"', '\\"')
    return "".join(ch for ch in s if ch >= " " and ch != "")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", required=True)
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    headers = json.load(open(os.path.join(a.data, "headers.json"), encoding="utf-8"))
    itemmap = json.load(open(os.path.join(a.data, "itemmap.json"), encoding="utf-8"))

    ids, text, horse, first, last = [], [], [], {}, {}
    for tab in TAB_ORDER:
        first[tab] = headers[tab][0]["id"]; last[tab] = headers[tab][-1]["id"]
        for h in headers[tab]:
            ids.append(h["id"]); text.append(h["text"]); horse.append(1 if h.get("horse") else 0)
    ids += ["Buying", "Selling"]; text += ["@ui_item_category_Buying", "@ui_item_category_Selling"]; horse += [0, 0]
    known = set(ids)
    for v in itemmap.values():
        assert v in known, v
    for v in DEFAULT.values():
        assert v in known, v

    lines = []
    L = lines.append
    L("   // ---- generated header table (gen_invheaders_as.py) ----")
    L("   static var HEADER_IDS = [" + ",".join(f'"{i}"' for i in ids) + "];")
    L("   static var HEADER_TEXT = [" + ",".join(f'"{esc(t)}"' for t in text) + "];")
    L("   static var HEADER_HORSE = [" + ",".join(str(h) for h in horse) + "];")
    for tab in TAB_ORDER:
        L(f'   static var TAB_FIRST_{tab.upper()} = "{first[tab]}";')
        L(f'   static var TAB_LAST_{tab.upper()} = "{last[tab]}";')
    L("   static var HEADER_DEFAULT = {" + ",".join(f'{k}:"{v}"' for k, v in DEFAULT.items()) + "};")
    L("   static var HEADER_MAP = null;")
    gt_path = os.path.join(a.data, "group_titles.json")
    gt = json.load(open(gt_path, encoding="utf-8")) if os.path.exists(gt_path) else {}
    L("   static var GROUP_TITLES = {};")
    uk_path = os.path.join(a.data, "unique_keys.json")
    uniq = json.load(open(uk_path, encoding="utf-8")) if os.path.exists(uk_path) else []
    L("   static var UNIQUE_KEYS = {};")
    L("   static function HeaderText(id)")
    L("   {")
    L("      var i = 0;")
    L("      while(i < HEADER_IDS.length)")
    L("      {")
    L("         if(HEADER_IDS[i] == id)")
    L("         {")
    L("            return HEADER_TEXT[i];")
    L("         }")
    L("         i = i + 1;")
    L("      }")
    L('      return id;')
    L("   }")
    L("   static function HeaderIsHorse(id)")
    L("   {")
    L("      var i = 0;")
    L("      while(i < HEADER_IDS.length)")
    L("      {")
    L("         if(HEADER_IDS[i] == id)")
    L("         {")
    L("            return HEADER_HORSE[i] == 1;")
    L("         }")
    L("         i = i + 1;")
    L("      }")
    L("      return false;")
    L("   }")
    L("   static function ResolveHeader(nameKey, iconId, engineCategory)")
    L("   {")
    L("      if(HEADER_MAP == null)")
    L("      {")
    L("         BuildHeaderMap();")
    L("      }")
    L("      var k = String(nameKey);")
    L('      if(k.charAt(0) == "@")')
    L("      {")
    L("         k = k.substring(1);")
    L("      }")
    L("      var h;")
    L("      if(iconId != undefined)")
    L("      {")
    L('         h = HEADER_MAP[k + "|icon:" + iconId];')
    L("         if(h != undefined)")
    L("         {")
    L("            return h;")
    L("         }")
    L("      }")
    L("      h = HEADER_MAP[k];")
    L("      if(h != undefined)")
    L("      {")
    L("         return h;")
    L("      }")
    L("      h = HEADER_DEFAULT[engineCategory];")
    L("      if(h != undefined)")
    L("      {")
    L("         return h;")
    L("      }")
    L('      return "common";')
    L("   }")
    # map chunks
    entries = sorted(itemmap.items())
    CH = 250
    chunks = [entries[i:i + CH] for i in range(0, len(entries), CH)]
    L("   static function BuildGroupTitles()")
    L("   {")
    L("      var t = GROUP_TITLES;")
    for k, v in sorted(gt.items()):
        L(f'      t["{esc(k.lower())}"] = "{esc(v)}";')
    L("   }")
    L("   static function BuildUniqueKeys()")
    L("   {")
    L("      var u = UNIQUE_KEYS;")
    for k in uniq:
        L(f'      u["{esc(k)}"] = 1;')
    L("   }")
    L("   static function IsUniqueKey(nameKey)")
    L("   {")
    L("      var k = String(nameKey);")
    L('      if(k.charAt(0) == "@")')
    L("      {")
    L("         k = k.substring(1);")
    L("      }")
    L("      return UNIQUE_KEYS[k] == 1;")
    L("   }")
    L("   static function BuildHeaderMap()")
    L("   {")
    L("      HEADER_MAP = {};")
    L("      BuildGroupTitles();")
    L("      BuildUniqueKeys();")
    for ci in range(len(chunks)):
        L(f"      BuildHeaderMap{ci}();")
    L("   }")
    for ci, chunk in enumerate(chunks):
        L(f"   static function BuildHeaderMap{ci}()")
        L("   {")
        L("      var m = HEADER_MAP;")
        for k, v in chunk:
            L(f'      m["{esc(k)}"] = "{v}";')
        L("   }")
    open(a.out, "w", encoding="utf-8", newline="\n").write("\n".join(lines) + "\n")
    print(f"wrote {a.out}: {len(ids)} headers, {len(entries)} map entries in {len(chunks)} chunks")

if __name__ == "__main__":
    main()
