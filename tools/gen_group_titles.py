"""
Builds the group-title table from the game files: one title per mesh (= one collapsible group).

Key   : what the list uses at runtime - the icon name up to "_m", lowercased (e.g. "hood07").
Title : the most common item name among that mesh's variants; ties and single-name meshes are
        resolved the same way (alphabetical first) and listed in the report for a human decision.

Output: data/group_titles.generated.json   regenerated every run
        data/group_titles.overrides.json   hand edits, created empty if missing, never overwritten
        data/group_titles.json             generated + overrides (overrides win) - what the mod ships
        data/group_titles_report.txt       every multi-name mesh with its name counts; ties flagged

Run: python -I gen_group_titles.py --tables "<folder>" --data "<data folder>"
"""
import argparse, collections, json, os, re
import xml.etree.ElementTree as ET

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tables", required=True)
    ap.add_argument("--data", required=True)
    a = ap.parse_args()
    T = lambda n: os.path.join(a.tables, n)

    loc = {}
    # titles follow the mod's fixed English names when the full fixed table exists
    fixed = os.path.join(a.data, "text_ui_items.xml")
    txt = open(fixed if os.path.exists(fixed) else T("text_ui_items.xml"), encoding="utf-8-sig").read()
    for row in re.findall(r"<Row>(.*?)</Row>", txt, re.S):
        c = re.findall(r"<Cell>(.*?)</Cell>", row, re.S)
        if len(c) >= 2:
            loc[c[0].strip()] = c[-1].strip()

    names = collections.defaultdict(collections.Counter)
    for fn in ["item.xml", "item__dlc.xml", "item__unique.xml", "item__rewards.xml", "item__aux.xml", "item__horse.xml"]:
        p = T(fn)
        if not os.path.exists(p):
            continue
        for el in ET.parse(p).iter():
            if el.tag not in ("Armor", "Hood", "Helmet", "QuickSlotContainer", "MeleeWeapon"):
                continue
            icon = el.get("IconId", "") or ""
            cut = icon.find("_m")
            if cut <= 0:
                continue                      # no colour code: groups by name, title is the name
            en = loc.get((el.get("UIName", "") or "").strip(), "")
            if not en or en == "A suspicious bag" or (el.get("Name", "") or "").startswith(("prop_", "poi_")):
                continue
            names[icon[:cut].lower()][en] += 1

    generated, report = {}, []
    for mesh, cnt in sorted(names.items()):
        ranked = sorted(cnt.items(), key=lambda kv: (-kv[1], kv[0]))
        title = ranked[0][0]
        generated[mesh] = title
        if len(cnt) > 1:
            tie = len(ranked) > 1 and ranked[0][1] == ranked[1][1]
            report.append(("TIE   " if tie else "      ") + f"{mesh:22s} -> {title:34s} " +
                          " | ".join(f"{n} x{k}" for n, k in ranked))
    os.makedirs(a.data, exist_ok=True)
    json.dump(generated, open(os.path.join(a.data, "group_titles.generated.json"), "w", encoding="utf-8"), indent=1, ensure_ascii=False, sort_keys=True)
    ov_path = os.path.join(a.data, "group_titles.overrides.json")
    if not os.path.exists(ov_path):
        json.dump({}, open(ov_path, "w", encoding="utf-8"), indent=1)
    overrides = json.load(open(ov_path, encoding="utf-8"))
    merged = dict(generated); merged.update({k.lower(): v for k, v in overrides.items()})
    json.dump(merged, open(os.path.join(a.data, "group_titles.json"), "w", encoding="utf-8"), indent=1, ensure_ascii=False, sort_keys=True)
    ties = [r for r in report if r.startswith("TIE")]
    hdr = [f"meshes with titles: {len(generated)}   multi-name meshes: {len(report)}   ties: {len(ties)}   overrides: {len(overrides)}", ""]
    open(os.path.join(a.data, "group_titles_report.txt"), "w", encoding="utf-8").write("\n".join(hdr + report))
    print("\n".join(hdr + report))

if __name__ == "__main__":
    main()
