ULTIMATE INVENTORY OVERHAUL  -  Kingdom Come: Deliverance II
by Spivey

WHAT IT DOES
  - Every inventory tab is split under plain-English headers. Armour is headed by the slot it
    fills (Helmets - Head II, Gambesons - Body I, Boots - Feet I ...), weapons by type, food,
    books, materials and the rest by kind. No more guessing which slot a piece goes in.
  - Colour and pattern variants of the same item are folded into one collapsible group row with
    combined count, weight and price, the average condition (coloured by the worst piece) and
    the best stat. Expand a group to see every piece; expand or collapse all at once.
  - Food, potions, materials and anything else that spoils or wears is grouped the same way.
  - HAVE (n): at traders, when looting bodies and animals, and when opening chests and other
    containers, every row you do not own yet shows how many of it you already own (Henry, the
    horse and the stash together) and the best grade you own, so you can compare on the spot.
  - Long names shrink instead of being cut off, so nothing bleeds into the next column.
  - Works with keyboard and controller. Expand / Collapse / Expand all show in the button hints.
  - English item names with inconsistent spellings across colour variants are fixed.

INSTALL
  1. Extract the archive into the game folder (the one that holds the Bin and Mods folders).
     You get:
        Mods\zz_inventory_overhaul\...
        Bin\Win64MasterMasterSteamPGO\Inventory_Overhaul.asi
  2. Controller support needs Ultimate ASI Loader (Nexus) so the .asi is loaded. Keyboard and
     mouse work without it.
  3. Remove "A Real Sorted Inventory" and "Sorted Inventory" if you have them; this replaces both.

UNINSTALL
  Delete Mods\zz_inventory_overhaul and Bin\Win64MasterMasterSteamPGO\Inventory_Overhaul.asi.
  Nothing is written to your save.

CONTROLS
  Keyboard: E / Enter on a group row expands it, again collapses. V expands or collapses all.
  Controller: A on a group row expands it, B collapses it (B on a plain row still leaves the
  screen). Hold Y to expand or collapse all. Headers toggle with L3 as in vanilla.
  Hold A / E on a group row to take or sell the whole group.

COMPATIBILITY
  Replaces these game files, so any other mod that edits them will conflict:
    Libs/UI/ApseInventoryList.gfx, ItemTransfer.gfx, ItemSelection.gfx, hud.gfx and their
    UIElements xml files; English text_ui_items.xml (item names).
  Tested on the Steam build. On other stores put the .asi in that store's Bin\Win64... folder.
  Only the English item names are patched; other languages keep the original names. Headers
  are English in every language.

KNOWN ISSUES
  - A chest standing within four metres of one of your stash chests is treated as the stash
    (no HAVE column).
  - Keyboard "drop" on a group title row is not blocked. Expand the group and drop a piece.

The .asi writes Inventory_Overhaul.log next to itself (reset at every launch). Attach it and
kcd.log when reporting a controller problem.
