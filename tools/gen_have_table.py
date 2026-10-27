"""
HAVE lookup table for the mod's Lua: item class GUID -> "uiNameKey|IconId|MaxQuality|Weight|Price".

The Lua side reads the player's live inventory (class GUID, health, amount) and the Flash list keys
items by name key + icon + grade, so this table bridges the two. Grade is derived from health in Lua
using the game's quality bands, which need MaxQuality.

Run: python -I gen_have_table.py --tables "<folder>" --out "<src_v1/lua folder>"
"""
import argparse, os
import xml.etree.ElementTree as ET

FILES = ["item.xml", "item__alchemy.xml", "item__dlc.xml", "item__unique.xml", "item__rewards.xml",
         "item__aux.xml", "item__horse.xml", "item__system.xml", "item__reward.xml"]

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tables", required=True)
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    rows = {}
    for fn in FILES:
        p = os.path.join(a.tables, fn)
        if not os.path.exists(p):
            continue
        for el in ET.parse(p).iter():
            gid = (el.get("Id") or "").strip()
            ui = (el.get("UIName") or "").strip()
            if not gid or not ui or gid in rows:
                continue
            icon = (el.get("IconId") or "").strip()
            mq = (el.get("MaxQuality") or "1").strip()
            w = (el.get("Weight") or "0").strip()
            pr = (el.get("Price") or "0").strip()
            rows[gid] = f"{ui}|{icon}|{mq}|{w}|{pr}"
    os.makedirs(a.out, exist_ok=True)
    out = os.path.join(a.out, "zz_inventory_overhaul_items.lua")
    with open(out, "w", encoding="utf-8", newline="\n") as f:
        f.write("-- Inventory Overhaul: item class GUID -> \"uiNameKey|IconId|MaxQuality\" (generated, do not edit)\n")
        f.write("CG_HAVE_ITEMS = {\n")
        for gid in sorted(rows):
            v = rows[gid].replace("\\", "\\\\").replace('"', '\\"')
            f.write(f'  ["{gid}"] = "{v}",\n')
        f.write("}\n")
    print(f"wrote {out}: {len(rows)} items")

if __name__ == "__main__":
    main()
