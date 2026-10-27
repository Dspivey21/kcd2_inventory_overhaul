"""
Builds the item -> header table for the standalone inventory mod from the game's own data.

Input : extracted game tables (item*.xml, equipment_slot.xml, weapon_class.xml, food_type.xml, ...,
        CharacterComponent.xml) and text_ui_items.xml, all in one folder (--tables).
Output: headers.json  - the header list per tab, in display order, with text and flags
        itemmap.json  - { "<UIName key>": "<header id>" } plus { "icon:<IconId>": ... } overrides where
                        one name key would land in two different headers
        report.txt    - counts per header, unmapped items, name-key conflicts

Run:  python -I gen_headers.py --tables "<folder>" --out "<folder>"
"""
import argparse, collections, json, os, re, sys
import xml.etree.ElementTree as ET

# ----------------------------------------------------------------------------- headers (decided with the user)
# id, text, tab, flags
TABS = {}
def H(tab, hid, text, **flags):
    TABS.setdefault(tab, []).append(dict(id=hid, text=text, **flags))

for hid, text in [
    ("longsword", "Longswords - Both hands"), ("shortsword", "Short swords - Right hand"),
    ("huntingsword", "Hunting swords - Right hand"), ("sabre", "Sabres - Right hand"),
    ("axe", "Axes - Right hand"), ("mace", "Maces - Right hand"), ("polearm", "Polearms - Both hands"),
    ("dagger", "Daggers"), ("bow", "Bows - Ranged"), ("arrow", "Arrows - Ammo"),
    ("crossbow", "Crossbows - Ranged"), ("bolt", "Bolts - Ammo"), ("handgonne", "Handgonnes - Ranged"),
    ("shot", "Shot - Ammo"), ("shield", "Shields - Left hand"), ("torch", "Torches"), ("weapon_other", "Other weapons")]:
    H("weapons", hid, text)
for hid, text in [
    ("coifs", "Coifs - Head I"), ("helmets", "Helmets - Head II"), ("hats", "Hats - Head II"),
    ("collars", "Collars - Head III"), ("hoods", "Hoods - Head IV"), ("shirts", "Shirts - Body I"),
    ("gambesons", "Gambesons - Body I"), ("mail", "Mail - Body II"), ("plate", "Plate - Body III"),
    ("outerwear", "Outerwear - Body IV"), ("sleeves", "Sleeves - Arms I"), ("gloves", "Gloves - Arms II"),
    ("belts", "Belts - Waist I"), ("pouches", "Pouches - Waist II"), ("hose", "Hose - Legs I"),
    ("hose_feet", "Hose - Legs I + Feet I"), ("paddedhose", "Padded hose - Legs I"),
    ("legarmour", "Leg armour - Legs II"), ("legarmour_feet", "Leg armour - Legs II + Feet I"),
    ("boots", "Boots - Feet I"), ("spurs", "Spurs - Feet II"), ("necklaces", "Necklaces - Neck I"),
    ("brooches", "Brooches - Neck I"), ("rings", "Rings - Fingers I"), ("spectacles", "Spectacles - Neck I")]:
    H("armour", hid, text)
for hid, text in [("saddles", "Saddles"), ("bridles", "Bridles"), ("chanfrons", "Chanfrons"),
                  ("caparisons", "Caparisons"), ("breeching", "Breeching"), ("horseshoes", "Horseshoes")]:
    H("armour", hid, text, horse=True)
H("armour", "womens", "Women's clothing")
H("armour", "armour_other", "Other clothing")
for hid, text in [
    ("dried", "Dried"), ("smoked", "Smoked"), ("cooked", "Cooked"), ("baked", "Baked goods"),
    ("dairy", "Dairy & eggs"), ("fruit", "Fruit"), ("vegetables", "Vegetables"), ("rawmeat", "Raw meat"),
    ("rawfish", "Raw fish"), ("spices", "Spices & honey"), ("beer", "Beer"), ("wine", "Wine"),
    ("liquor", "Liquor"), ("water", "Water"), ("saviour", "Saviour Schnapps"), ("potion_best", "Best potions"),
    ("potion_strong", "Strong potions"), ("potion_normal", "Normal potions"), ("potion_weak", "Weak potions"),
    ("potion_special", "Special potions"), ("poisons", "Poisons"), ("food_other", "Other food")]:
    H("food", hid, text)
for hid, text in [("skillbooks", "Skill books"), ("books", "Regular books"), ("recipes", "Recipes"),
                  ("plans", "Blacksmith plans"), ("maps", "Maps"), ("letters", "Letters & notes")]:
    H("books", hid, text)
for hid, text in [("herbs", "Herbs"), ("driedherbs", "Dried herbs"), ("alchemy", "Alchemy ingredients"),
                  ("blacksmithing", "Blacksmithing"), ("hides", "Hides & skins")]:
    H("materials", hid, text)
for hid, text in [("groschen", "Groschen"), ("tools", "Tools"), ("repairkits", "Repair kits"),
                  ("bandages", "Bandages & soap"), ("dice", "Dice"), ("badges_gold", "Gold badges"),
                  ("badges_silver", "Silver badges"), ("badges_tin", "Tin badges"), ("perfumes", "Perfumes"),
                  ("valuables", "Valuables"), ("common", "Common"), ("keys", "Keys")]:
    H("other", hid, text)

# ----------------------------------------------------------------------------- game tables
def table(path, tag, idk, namek):
    return {e.get(idk): e.get(namek) for e in ET.parse(path).iter(tag)}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tables", required=True)
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    T = lambda n: os.path.join(a.tables, n)

    loc = {}
    txt = open(T("text_ui_items.xml"), encoding="utf-8-sig").read()
    for row in re.findall(r"<Row>(.*?)</Row>", txt, re.S):
        c = re.findall(r"<Cell>(.*?)</Cell>", row, re.S)
        if len(c) >= 2:
            loc[c[0].strip()] = c[-1].strip()

    FT = table(T("food_type.xml"), "food_type", "food_type_id", "food_type_name")
    FS = table(T("food_subtype.xml"), "food_subtype", "food_subtype_id", "food_subtype_name")
    DT = table(T("document_class.xml"), "document_class", "document_class_id", "document_class_name")
    CT = table(T("crafting_material_type.xml"), "crafting_material_type", "crafting_material_type_id", "crafting_material_type_name")
    CS = table(T("crafting_material_subtype.xml"), "crafting_material_subtype", "crafting_material_subtype_id", "crafting_material_subtype_name")
    MT = table(T("misc_type.xml"), "misc_type", "misc_type_id", "misc_type_name")
    MS = table(T("misc_subtype.xml"), "misc_subtype", "misc_subtype_id", "misc_subtype_name")
    OT = table(T("ointment_item_type.xml"), "ointment_item_type", "ointment_item_type_id", "ointment_item_type_name")
    BT = table(T("dice_badge_type.xml"), "dice_badge_type", "dice_badge_type_id", "dice_badge_type_name")
    WC = {e.get("id"): e.get("name") for e in ET.parse(T("weapon_class.xml")).getroot().iter() if e.get("id") and e.get("name")}
    AC = table(T("ammo_class.xml"), "ammo_class", "ammo_class_id", "ammo_class_name")
    ARCH = table(T("armor_archetype.xml"), "armor_archetype", "armor_archetype_id", "armor_archetype_name")

    # armour type -> game slot
    slot_of_type = {}
    for e in ET.parse(T("equipment_slot.xml")).iter("EquipmentSlot"):
        for t in (e.get("ArmorTypes") or "").split():
            slot_of_type[t] = e.get("Name")
    slot_of_type.update({
        "Hood": "head_hood", "Coat": "body_coat", "Waffenrock": "body_coat", "Habit": "body_coat",
        "Gloves": "gloves", "Gauntlets": "gloves", "HandWrap": "gloves", "Shoes": "boot", "Boots": "boot",
        "BootsAnkle": "boot", "BootsKnee": "boot", "Spurs": "spur", "Belt": "belt", "Pouch": "pouch",
        "CollarPadded": "collar", "CollarMail": "collar", "Collar": "collar", "Ring": "ring",
        "Necklace": "necklace", "Brooch": "brooch", "Spectacles": "spectacles", "Wreath": "head_cap",
        "Eyepatch": "spectacles", "Amulet": "necklace",
    })
    slot_header = {
        "head_cap": "hats", "head_helmet": "helmets", "head_coif": "coifs", "head_coif_padded": "coifs",
        "collar": "collars", "head_hood": "hoods", "body_cloth": "shirts", "body_cloth_padded": "gambesons",
        "body_chainmail": "mail", "body_plate": "plate", "body_coat": "outerwear", "sleeves": "sleeves",
        "gloves": "gloves", "belt": "belts", "pouch": "pouches", "leg_trousers": "hose",
        "leg_trousers_padded": "paddedhose", "leg_armor": "legarmour", "boot": "boots", "spur": "spurs",
        "necklace": "necklaces", "brooch": "brooches", "ring": "rings", "spectacles": "spectacles",
        "horse_saddle": "saddles", "horse_head": "bridles", "horse_torso": "caparisons", "horse_shoe": "horseshoes",
    }
    # horse gear by name family (the horse slot table lumps bridles and chanfrons, saddles and breeching)
    horse_family = [("Chanfron", "chanfrons"), ("Bridle", "bridles"), ("Saddle", "saddles"), ("Harness", "breeching"),
                    ("Caparison", "caparisons"), ("horseshoe", "horseshoes"), ("Horseshoe", "horseshoes")]

    clothing = {c.get("Name"): c for c in ET.parse(T("CharacterComponent.xml")).getroot().iter("Clothing")}

    # type prefixes (longest match wins) -> game slot; covers the slot table's spellings and the
    # clothing names' spellings, plus unique NPC pieces like "HoodAlbik" or "GambesonShortKomar"
    prefix_slot = dict(slot_of_type)
    prefix_slot.update({
        "BrigandineArm": "sleeves", "ArmBrigandine": "sleeves", "ArmPlate": "sleeves", "CollarChain": "collar",
        "Bascinet": "head_helmet", "KettleHat": "head_helmet", "SkullCap": "head_helmet", "Helmet": "head_helmet",
        "CoifMail": "head_coif_padded", "CoifLarge": "head_coif_padded", "CoifSmall": "head_coif_padded",
        "CoifCap": "head_coif", "Coif": "head_coif", "Cap": "head_cap", "Hat": "head_cap", "Hood": "head_hood",
        "PlagueSuit": "head_hood", "Coat": "body_coat", "Waffenrock": "body_coat", "Habit": "body_coat",
        "Tunic": "body_cloth", "LeatherApron": "body_cloth", "Gambeson": "body_cloth_padded",
        "Caftan": "body_cloth_padded", "Pourpoint": "body_cloth_padded", "Mail": "body_chainmail",
        "Cuirass": "body_plate", "Brigandine": "body_plate", "Gauntlets": "gloves", "Gloves": "gloves",
        "HandWrap": "gloves", "Hose": "leg_trousers", "LegsPadded": "leg_trousers_padded",
        "LegsChain": "leg_trousers_padded", "LegsPlate": "leg_armor", "LegsBrigandine": "leg_armor",
        "Boots": "boot", "Shoes": "boot", "Spurs": "spur", "Belt": "belt", "Pouch": "pouch",
        "Rings": "ring", "Ring": "ring", "Necklace": "necklace", "Amulet": "necklace", "Brooch": "brooch",
        "Spectacles": "spectacles", "Eyepatch": "spectacles", "Wreath": "head_cap",
    })
    prefixes = sorted(prefix_slot, key=len, reverse=True)
    word_slot = [("sleeves", "sleeves"), ("pauldron", "sleeves"), ("gauntlet", "gloves"), ("glove", "gloves"),
                 ("hood", "head_hood"), ("coif", "head_coif_padded"), ("collar", "collar"), ("bascinet", "head_helmet"),
                 ("helmet", "head_helmet"), ("hat", "head_cap"), ("cap", "head_cap"), ("coat", "body_coat"),
                 ("garb", "body_coat"), ("tunic", "body_cloth"), ("gambeson", "body_cloth_padded"),
                 ("aketon", "body_cloth_padded"), ("hose", "leg_trousers"), ("chausses", "leg_armor"),
                 ("plate legs", "leg_armor"), ("boots", "boot"), ("shoes", "boot"), ("ring", "ring"),
                 ("kastenbrust", "body_plate"), ("cuirass", "body_plate")]
    placeholder = lambda en, name: (not en) or en == "A suspicious bag" or name.startswith(("prop_", "poi_"))
    family = lambda cl: re.sub(r"_m\d+.*$", "", re.sub(r"_(NoBags|NoDagger|flipped|closed|mNoBags|mNoDagger|mArmor|mCaptured).*$", "", cl))
    # per mesh family: the most specific ArmorType / archetype any colour variant carries
    fam_type, fam_arch = {}, {}
    for cl_name, c in clothing.items():
        f = family(cl_name)
        if c.get("ArmorType"): fam_type.setdefault(f, c.get("ArmorType"))
        an = ARCH.get(c.get("ArmorArchetypeId"))
        if an and an.lower().endswith("_withfeet"): fam_arch[f] = an

    def slot_from_prefix(s):
        for pfx in prefixes:
            if s.startswith(pfx):
                return prefix_slot[pfx], pfx
        return None, None

    def armour_header(el):
        name = el.get("Name", ""); en = loc.get(el.get("UIName", ""), "")
        cl = el.get("Clothing", "") or name
        if cl.startswith("F_") or name.startswith("F_"):
            return "womens", "women"
        if placeholder(en, name):
            return "armour_other", "placeholder"
        for fam, hid in horse_family:
            if fam.lower() in cl.lower() or fam.lower() in name.lower():
                return hid, "horse family"
        c = clothing.get(cl)
        atype = (c.get("ArmorType") if c is not None and c.get("ArmorType") else None) or fam_type.get(family(cl))
        slot = slot_of_type.get(atype) if atype else None
        why = f"ArmorType {atype}"
        if not slot:
            slot, pfx = slot_from_prefix(cl)
            why = f"prefix {pfx}"
        if not slot:
            slot, pfx = slot_from_prefix(name)
            why = f"name prefix {pfx}"
        if not slot:
            l = en.lower()
            for w, sl in word_slot:
                if w in l:
                    slot, why = sl, f"english word '{w}'"; break
        if not slot:
            return None, f"no slot (clothing {cl}, '{en}')"
        # pieces whose English name says sleeves but whose mesh prefix says body plate
        if slot == "body_plate" and ("sleeves" in en.lower() or "pauldron" in en.lower()):
            slot, why = "sleeves", why + " + english 'sleeves'"
        if slot == "necklace" and "brooch" in en.lower():
            slot = "brooch"
        hid = slot_header.get(slot)
        if not hid:
            return None, f"no header for slot '{slot}'"
        arch = (ARCH.get(c.get("ArmorArchetypeId")) if c is not None else None) or fam_arch.get(family(cl))
        if arch and arch.lower().endswith("_withfeet"):
            if hid in ("hose", "paddedhose"):
                hid = "hose_feet"
            elif hid == "legarmour":
                hid = "legarmour_feet"
        return hid, why

    def weapon_header(el):
        cls = WC.get(el.get("Class", ""), "")
        m = {"dagger": "dagger", "sword": "shortsword", "sabre": "sabre", "axe": "axe", "longsword": "longsword",
             "mace": "mace", "flail": "mace", "halberd": "polearm", "shield": "shield", "shield_broken": "shield",
             "bow": "bow", "crossbow_light": "crossbow", "crossbow_medium": "crossbow", "crossbow_heavy": "crossbow",
             "torch": "torch", "rifle": "handgonne", "hunting_sword": "huntingsword"}
        if cls in m:
            return m[cls], f"class {cls}"
        return "weapon_other", f"unknown weapon class '{cls}'"

    def ammo_header(el):
        ac = AC.get(el.get("Class", "") or el.get("AmmoClass", ""), "")
        m = {"Arrow": "arrow", "Bolt": "bolt", "Ball": "shot", "Shotgun": "shot"}
        if ac in m:
            return m[ac], f"ammo {ac}"
        n = el.get("Name", "").lower()
        if "arrow" in n: return "arrow", "name"
        if "bolt" in n: return "bolt", "name"
        return "shot", f"ammo fallback ({ac})"

    def food_header(el, en):
        ft = FT.get(el.get("Type"), "")
        fs = FS.get(el.get("SubType"), "")
        l = en.lower()
        if ft == "potion":
            if "saviour" in l:
                return "saviour", "saviour"
            if not fs or fs in ("poison",):
                return "potion_special", "potion no subtype"
            if l.startswith("henry's "): return "potion_best", "henry"
            if l.startswith("strong "): return "potion_strong", "strong"
            if l.startswith("weak "): return "potion_weak", "weak"
            return "potion_normal", "normal"
        if ft == "drink":
            if fs == "wine": return "wine", "wine"
            if fs == "beer": return "beer", "beer"
            if fs == "liquor": return "liquor", "liquor"
            if fs == "water": return "water", "water"
            return "potion_special", f"drink subtype '{fs}'"
        if fs == "bacon": return "cooked", "bacon"
        if any(w in l for w in ("dried",)): return "dried", "name dried"
        if "smoked" in l: return "smoked", "name smoked"
        if any(w in l for w in ("cooked", "boiled", "fried", "roast", "baked", "hard boiled")): return "cooked", "name cooked"
        if ft == "meat": return "rawmeat", "meat"
        if ft == "bowel":
            if any(w in l for w in ("crayfish", "fish", "trout", "perch", "herring", "carp", "pike")): return "rawfish", "bowel fish"
            return "rawmeat", "bowel offal"
        if ft == "vegetable" or ft == "mushroom": return "vegetables", ft
        if ft == "fruit": return "fruit", "fruit"
        if ft == "pastry": return "baked", "pastry"
        if ft == "dairy": return "dairy", "dairy"
        if not ft: return "spices", "untyped food"
        return "food_other", f"food type '{ft}'"

    def misc_header(el, en):
        mt = MT.get(el.get("Type"), ""); ms = MS.get(el.get("SubType"), "")
        l = en.lower()
        if mt == "usable":
            return ("keys", "usable key") if "key" in l else ("tools", "usable tool")
        if mt == "skin": return "hides", "skin"
        if ms == "loot": return "valuables", "loot"
        return "common", f"misc {mt}/{ms}"

    items = []
    files = ["item.xml", "item__alchemy.xml", "item__dlc.xml", "item__unique.xml", "item__rewards.xml",
             "item__aux.xml", "item__horse.xml", "item__system.xml"]
    for fn in files:
        p = T(fn)
        if not os.path.exists(p):
            continue
        for el in ET.parse(p).iter():
            name = el.get("Name"); ui = (el.get("UIName", "") or "").strip()
            if not name or not ui:
                continue
            en = loc.get(ui, "")
            tag = el.tag
            hid = why = None
            if tag in ("Armor", "Hood", "Helmet", "QuickSlotContainer"):
                hid, why = armour_header(el)
            elif tag in ("MeleeWeapon", "MissileWeapon"):
                hid, why = weapon_header(el)
            elif tag == "Ammo":
                hid, why = ammo_header(el)
            elif tag == "Food":
                hid, why = food_header(el, en)
            elif tag == "Poison":
                hid, why = "poisons", "poison"
            elif tag == "Document":
                dt = DT.get(el.get("Type"), "")
                hid = {"skillBook": "skillbooks", "book": "books", "recipe": "recipes", "plan": "plans",
                       "map": "maps", "letter": "letters"}.get(dt); why = f"document {dt}"
            elif tag == "Herb":
                hid, why = ("driedherbs", "dried herb") if "dried" in en.lower() else ("herbs", "herb")
            elif tag == "CraftingMaterial":
                ct = CT.get(el.get("Type"), ""); cs = CS.get(el.get("SubType"), "")
                if cs == "craftingSkin": hid, why = "hides", "crafting skin"
                elif ct == "special": hid, why = "alchemy", "crafting special"
                elif ct == "blacksmithing": hid, why = "blacksmithing", "crafting blacksmithing"
                elif ct == "herb": hid, why = "herbs", "crafting herb"
                else: hid, why = None, f"crafting type '{ct}'"
            elif tag == "MiscItem":
                hid, why = misc_header(el, en)
            elif tag == "Ointment":
                ot = OT.get(el.get("Type"), "")
                hid = {"repairkit": "repairkits", "bandage": "bandages", "soap": "bandages", "perfume": "perfumes"}.get(ot); why = f"ointment {ot}"
            elif tag == "Die":
                hid, why = "dice", "die"
            elif tag == "DiceBadge":
                bt = BT.get(el.get("Type"), "")
                hid = {"gold": "badges_gold", "silver": "badges_silver", "plumb": "badges_tin"}.get(bt); why = f"badge {bt}"
            elif tag == "Money":
                hid, why = "groschen", "money"
            elif tag in ("Key", "KeyRing"):
                hid, why = "keys", "key element"
            else:
                continue
            items.append(dict(tag=tag, name=name, ui=ui, en=en, icon=el.get("IconId", ""), header=hid, why=why, file=fn))

    # ---------------------------------------------------------------- name-key map with icon overrides
    # placeholders (props, "A suspicious bag") never shape the map when a real item shares their name key:
    # a prop can share a real item's icon too (prop_TunicShort01_m01_D vs Henry's Short tunic), and an icon
    # override written for the prop would send the real item to "Other".
    is_ph = lambda it: it["why"] == "placeholder" or not it["en"] or it["en"] == "A suspicious bag"
    real_keys = {it["ui"] for it in items if it["header"] and not is_ph(it)}
    mapped = [it for it in items if it["header"] and not (is_ph(it) and it["ui"] in real_keys)]
    by_ui = collections.defaultdict(lambda: collections.Counter())
    for it in mapped:
        by_ui[it["ui"]][it["header"]] += 1
    itemmap = {}
    conflicts = []
    for ui, cnt in by_ui.items():
        if len(cnt) == 1:
            itemmap[ui] = next(iter(cnt))
        else:
            main = cnt.most_common(1)[0][0]
            itemmap[ui] = main
            conflicts.append((ui, dict(cnt)))
            for it in mapped:
                if it["ui"] == ui and it["header"] != main and it["icon"]:
                    itemmap[ui + "|icon:" + it["icon"]] = it["header"]

    # ---------------------------------------------------------------- outputs
    os.makedirs(a.out, exist_ok=True)
    json.dump(TABS, open(os.path.join(a.out, "headers.json"), "w", encoding="utf-8"), indent=1)
    json.dump(itemmap, open(os.path.join(a.out, "itemmap.json"), "w", encoding="utf-8"), indent=0, sort_keys=True)
    # a group gets a "*" when a member's name key is a game unique. Many unique/reward entries reuse the
    # name key of a plain item (a reward "Coif" is still called "Coif"), so only keys that no plain item
    # uses count - the list reaches Flash as name keys, so a shared key can never mark an item as unique.
    UNIQUE_FILES = ("item__unique.xml", "item__rewards.xml")
    plain_keys = {it["ui"] for it in items if it["file"] not in UNIQUE_FILES}
    unique_all = {it["ui"] for it in items if it["file"] in UNIQUE_FILES and it["en"] and it["en"] != "A suspicious bag"}
    unique = sorted(unique_all - plain_keys)
    json.dump(unique, open(os.path.join(a.out, "unique_keys.json"), "w", encoding="utf-8"), indent=0)
    rep_unique = f"unique name keys (item__unique + item__rewards, not used by plain items): {len(unique)} of {len(unique_all)}"

    hdr_text = {h["id"]: h["text"] for hs in TABS.values() for h in hs}
    rep = []
    rep.append(f"items considered: {len(items)}   name keys: {len(by_ui)}   map entries: {len(itemmap)}   {rep_unique}")
    unm = [it for it in items if not it["header"] and it["en"] and it["en"] != "A suspicious bag"]
    rep.append(f"\nUNMAPPED ({len(unm)}):")
    for it in unm:
        rep.append(f"  {it['tag']:14s} {it['name']:40s} {it['en'][:30]:30s} {it['why']}")
    rep.append(f"\nNAME-KEY CONFLICTS ({len(conflicts)}) - same name key in two headers, icon overrides added:")
    for ui, cnt in conflicts:
        rep.append(f"  {ui:40s} {loc.get(ui,'')[:28]:28s} {cnt}")
    oth = [it for it in mapped if it["header"] == "armour_other" and not is_ph(it)]
    rep.append(chr(10) + f"REAL ITEMS IN OTHER ARMOUR ({len(oth)}) - placeholders/props excluded; decide a header or leave:")
    for it in oth:
        rep.append(f"  {it['name']:40s} {it['en'][:30]:30s} icon={it['icon']:28s} {it['why']}")
    rep.append("\nCOUNTS PER HEADER (player-facing items only):")
    for tab, hs in TABS.items():
        rep.append(f"  [{tab}]")
        for h in hs:
            its = [it for it in items if it["header"] == h["id"] and it["en"] and it["en"] != "A suspicious bag"]
            ex = sorted(set(it["en"] for it in its))[:5]
            rep.append(f"    {h['text']:34s} {len(its):4d}   {'; '.join(ex)}")
    open(os.path.join(a.out, "report.txt"), "w", encoding="utf-8").write("\n".join(rep))
    print("\n".join(rep))

if __name__ == "__main__":
    main()
