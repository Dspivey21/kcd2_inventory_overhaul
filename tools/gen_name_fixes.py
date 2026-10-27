"""
English name fixes for item names the game spells inconsistently across colour variants
("Gambeson long" vs "Long gambeson"). Writes the full English item table (vanilla + fixes) the mod ships in
Localization/English_xml.pak; other languages are untouched.

Run: python -I gen_name_fixes.py --tables "<folder>" --out "<data folder>"
"""
import argparse, os, re
import xml.etree.ElementTree as ET

FIXES = {                       # wrong text -> fixed text (exact match on the English string)
    "Gambeson long": "Long gambeson",
    "Gambeson short": "Short gambeson",
    "Gambeson worn": "Worn gambeson",
    "Courtiers boots": "Courtier's boots",
    "Courtier's pourpoint.": "Courtier's pourpoint",
    # too long for the group row with its count; both apostrophe spellings the game uses
    "Executioner's caparison with breeching": "Executioner caparison w/ breeching",
    "Executioner’s caparison with breeching": "Executioner caparison w/ breeching",
}

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tables", required=True)
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    loc = {}
    txt = open(os.path.join(a.tables, "text_ui_items.xml"), encoding="utf-8-sig").read()
    for row in re.findall(r"<Row>(.*?)</Row>", txt, re.S):
        c = re.findall(r"<Cell>(.*?)</Cell>", row, re.S)
        if len(c) >= 2:
            loc[c[0].strip()] = c[-1].strip()
    used = set()
    for fn in ["item.xml", "item__dlc.xml", "item__unique.xml", "item__rewards.xml", "item__aux.xml", "item__horse.xml", "item__alchemy.xml"]:
        p = os.path.join(a.tables, fn)
        if os.path.exists(p):
            for el in ET.parse(p).iter():
                ui = (el.get("UIName") or "").strip()
                if ui:
                    used.add(ui)
    # The game only MERGES a mod's "text_ui_items__x.xml" for keys it does not already have, so existing names
    # cannot be overridden that way. The mod therefore ships the FULL table: the game's current text_ui_items.xml
    # with the fixed rows swapped in. Regenerate after every game patch (the base table may change).
    base_path = os.path.join(a.tables, "text_ui_items.current.xml")
    if not os.path.exists(base_path):
        base_path = os.path.join(a.tables, "text_ui_items.xml")
    base = open(base_path, encoding="utf-8-sig").read()
    changed = []
    def fix_row(m):
        row = m.group(0)
        cells = re.findall(r"<Cell>(.*?)</Cell>", row, re.S)
        if len(cells) < 2:
            return row
        key = cells[0].strip()
        if key not in used or cells[-1].strip() not in FIXES:
            return row
        fixed = FIXES[cells[-1].strip()].replace("&", "&amp;").replace("<", "&lt;")
        changed.append((key, cells[-1].strip(), fixed))
        return "<Row><Cell>" + key + "</Cell><Cell>" + fixed + "</Cell><Cell>" + fixed + "</Cell></Row>"
    out_xml = re.sub(r"<Row>.*?</Row>", fix_row, base, flags=re.S)
    os.makedirs(a.out, exist_ok=True)
    out = os.path.join(a.out, "text_ui_items.xml")
    with open(out, "w", encoding="utf-8", newline="\n") as f:
        f.write(out_xml)
    print("wrote " + out + ": full table, " + str(len(changed)) + " rows changed")
    for key, old_en, new_en in changed:
        print("  " + key.ljust(36) + " " + old_en + " -> " + new_en)

if __name__ == "__main__":
    main()
