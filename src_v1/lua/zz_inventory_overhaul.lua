-- Inventory Overhaul: passes the inventory list's row state to KCD2_ColourGroupKeys.asi and answers the
-- list's HAVE requests from the player's live inventories.
-- The list reports "cg:state=group|member|item|none"; this logs "@@CGS=<state>", which the plugin reads as the
-- game writes it out, so it knows when controller A should open a group, and passes the state to the HUD for
-- the Expand/Collapse button hints. Other "cg:" messages are logged as [ColourGroups].
local CG = {}

local ELEMENTS = { "ApseInventoryList", "ItemTransfer", "ItemSelection" }

-- build_v1.ps1 -NoHud flips this to false: that build ships no hud.gfx / HUD.xml (for players who run a HUD mod),
-- so the hint functions below do not exist and must not be called
local CG_HUD_HINTS = true

local function setState(state)
    System.LogAlways("@@CGS=" .. state)
    -- the HUD adds/relabels the bottom button hints (Expand / Collapse) for group rows
    if CG_HUD_HINTS then UIAction.CallFunction("HUD", -1, "CgSetMode", state) end
end

-- ---------------------------------------------------------------------------------------------- HAVE (n)
-- On a trader, stash or loot screen the list asks ("cg:haveget") and we count what the player owns, per
-- "uiNameKey|IconId|grade" (any condition, pieces), across Henry, his horse and his stash, then push the counts
-- back into the list. Grade is derived from health with the game's quality bands (needs the item's MaxQuality,
-- which the shipped CG_HAVE_ITEMS table carries along with the name key and icon per item class).
local QUALITY_BANDS = {
    [2] = { 1 / 3, 1.0 },
    [3] = { 1 / 6, 3 / 6, 1.0 },
    [4] = { 1 / 10, 3 / 10, 6 / 10, 1.0 },
}

local function gradeOf(health, maxQuality)
    local bands = QUALITY_BANDS[maxQuality]
    if not bands or type(health) ~= "number" then return 0 end
    for i, top in ipairs(bands) do
        if health <= top + 0.00000001 then return i end
    end
    return #bands
end

-- WUIDs print as "userdata: 0300000000001F92"; the list's ids are "w" + the same hex in lower case
local function wuidStr(v)
    local str = tostring(v)
    local hex = string.match(str, "(%x+)%s*$")
    if hex and #hex >= 8 then return "w" .. string.lower(hex) end
    return str
end

function CG:FindHorse()
    if not (player and player.player) then return nil, "noplayer" end
    local ok, wuid = pcall(function() return player.player:GetPlayerHorse() end)
    if ok and wuid and XGenAIModule and XGenAIModule.GetEntityByWUID then
        local h = XGenAIModule.GetEntityByWUID(wuid)
        if h then return h, "wuid" end
    end
    local ok2, hid = pcall(function() return player.player:GetHorseId() end)
    if ok2 and hid then
        local h = System.GetEntity(hid)
        if h then return h, "entityid" end
    end
    return nil, "none"
end

-- The player's stash: every stash chest is an entity; the shared ("master") stash is the chest the others link
-- to with a "masterStash" link. Loaded chests are found by class; a chest the player owns outright counts too.
function CG:FindStashInventories()
    local found, how, ents = {}, {}, {}
    local okList, stashes = pcall(function() return System.GetEntitiesByClass("Stash") end)
    if not okList or type(stashes) ~= "table" then return found, "noentities", ents end
    local playerWuid = nil
    pcall(function() playerWuid = XGenAIModule.GetMyWUID(player) end)
    local seen = {}
    local total = 0
    for _, stash in pairs(stashes) do
        total = total + 1
        local target, why = nil, nil
        local okW, wuid = pcall(function() return XGenAIModule.GetMyWUID(stash) end)
        if okW and wuid then
            local okM, masters = pcall(function() return XGenAIModule.FindLinks(wuid, "masterStash") end)
            local okS, slaves = pcall(function() return XGenAIModule.FindLinks(wuid, "slaveStash") end)
            if okM and type(masters) == "table" and #masters > 0 then
                local okE, e = pcall(function() return XGenAIModule.GetEntityByWUID(masters[1]) end)
                if okE and e then target, why = e, "via master link" end
            elseif okS and type(slaves) == "table" and #slaves > 0 then
                target, why = stash, "is master"
            else
                local okO, owner = pcall(function() return XGenAIModule.GetOwner(wuid) end)
                if okO and owner and playerWuid and wuidStr(owner) == wuidStr(playerWuid) then
                    target, why = stash, "owned"
                end
            end
        end
        if target then ents[#ents + 1] = stash end
        if target and target.inventory then
            local okId, invId = pcall(function() return wuidStr(target.inventory:GetId()) end)
            local key = (okId and invId) or tostring(target)
            if not seen[key] then
                seen[key] = true
                found[#found + 1] = target.inventory
                how[#how + 1] = why
            end
        end
    end
    return found, total .. " chests loaded, used: " .. table.concat(how, ", "), ents
end

local function entityPos(e)
    local ok, p = pcall(function() return e:GetWorldPos() end)
    if ok and type(p) == "table" and p.x then return p end
    return nil
end

-- A stash/container transfer screen opened: is the second list one of the player's stash chests (then no HAVE,
-- it would count itself) or any other container in the world (then HAVE like loot)?
function CG:AnswerStore(elementName, instanceId, invId)
    -- The transfer screen's rows carry no inventory id in store mode, so the list usually sends "?" and we
    -- decide by distance: a stash chest the player can reach (< 4 m) means the stash screen; anything else is
    -- a world container. An id, when the list has one, is compared against the stash inventories first.
    local want = (invId ~= "?" and invId ~= "") and wuidStr(invId) or nil
    local isStash = false
    local okS, stashes, how, ents = pcall(function() return CG:FindStashInventories() end)
    local ids, dists = {}, {}
    if okS and type(stashes) == "table" then
        for _, inv in ipairs(stashes) do
            local okId, id = pcall(function() return wuidStr(inv:GetId()) end)
            if okId and id then
                ids[#ids + 1] = id
                if want and id == want then isStash = true end
            end
        end
    end
    local nearest = nil
    local me = player and entityPos(player) or nil
    if okS and type(ents) == "table" and me then
        for _, e in ipairs(ents) do
            local p = entityPos(e)
            if p then
                local dx, dy, dz = p.x - me.x, p.y - me.y, p.z - me.z
                local d = math.sqrt(dx * dx + dy * dy + dz * dz)
                dists[#dists + 1] = string.format("%.1f", d)
                if nearest == nil or d < nearest then nearest = d end
            end
        end
    end
    if not want and nearest and nearest < 4.0 then isStash = true end
    System.LogAlways("[ColourGroups] store query: inv=" .. tostring(invId) .. " nearest stash=" .. tostring(nearest) .. " m (" .. table.concat(dists, ",") .. ") stash=" .. tostring(isStash) .. " ids=" .. table.concat(ids, ","))
    UIAction.CallFunction(elementName, instanceId, "CgStore", isStash and "1" or "0")
end

function CG:SendHave(elementName, instanceId)
    if CG_HAVE_ITEMS == nil then
        Script.ReloadScript("Scripts/mods/zz_inventory_overhaul_items.lua")
    end
    local counts, keys, unmapped = {}, {}, 0
    local best = {}
    local function addInventory(inv)
        if not inv or not CG_HAVE_ITEMS then return 0 end
        local n = 0
        local okT, tbl = pcall(function() return inv:GetInventoryTable() end)
        if not okT or type(tbl) ~= "table" then return 0 end
        for _, userdata in pairs(tbl) do
            local it = ItemManager.GetItem(userdata)
            if it and it.class then
                n = n + 1
                local info = CG_HAVE_ITEMS[tostring(it.class)]
                if info then
                    local ui, icon, mq = string.match(info, "^([^|]*)|([^|]*)|(%d+)")
                    local grade = gradeOf(it.health, tonumber(mq))
                    local amount = tonumber(it.amount) or 1
                    local key = ui .. "|" .. icon .. "|" .. grade
                    if counts[key] == nil then
                        counts[key] = 0
                        keys[#keys + 1] = key
                    end
                    counts[key] = counts[key] + amount
                    -- graded items also get a grade-wide entry: total across grades + the best grade owned
                    if grade > 0 then
                        local akey = ui .. "|" .. icon .. "|*"
                        if counts[akey] == nil then
                            counts[akey] = 0
                            best[akey] = 0
                            keys[#keys + 1] = akey
                        end
                        counts[akey] = counts[akey] + amount
                        if grade > best[akey] then best[akey] = grade end
                    end
                else
                    unmapped = unmapped + 1
                end
            end
        end
        return n
    end
    local total = addInventory(player and player.inventory)
    local horse, horseHow = CG:FindHorse()
    local horseItems = 0
    if horse and horse.inventory then horseItems = addInventory(horse.inventory) end
    local stashes, stashHow = CG:FindStashInventories()
    local stashItems = 0
    for _, inv in ipairs(stashes) do stashItems = stashItems + addInventory(inv) end

    UIAction.CallFunction(elementName, instanceId, "CgSetHave", "!begin")
    local chunk, n = {}, 0
    for _, key in ipairs(keys) do
        chunk[#chunk + 1] = key .. "=" .. counts[key] .. (best[key] and (":" .. best[key]) or "")
        n = n + 1
        if n >= 40 then
            UIAction.CallFunction(elementName, instanceId, "CgSetHave", table.concat(chunk, ";"))
            chunk, n = {}, 0
        end
    end
    if n > 0 then
        UIAction.CallFunction(elementName, instanceId, "CgSetHave", table.concat(chunk, ";"))
    end
    UIAction.CallFunction(elementName, instanceId, "CgSetHave", "!end")
    System.LogAlways("[ColourGroups] have: " .. tostring(elementName) .. " henry=" .. total .. " horse=" .. horseHow .. "/" .. horseItems .. " stash=" .. #stashes .. " inv/" .. stashItems .. " items (" .. tostring(stashHow) .. ") keys=" .. #keys .. " unmapped=" .. unmapped)
end

-- ---------------------------------------------------------------------------------------------- events
-- The list sends its messages on its own event (OnCgEvent, added to the three UI element files), never on
-- the game's OnGeneralEvent: a message sent there right behind the game's own "goInHorseTab" replaced it,
-- and the inventory then stayed on Henry's side while showing the horse tab.
function CG:OnCgEvent(elementName, instanceId, eventName, args)
    local msg = type(args) == "table" and (args[0] or args[1]) or nil
    if type(msg) ~= "string" then return end
    if msg == "haveget" then
        CG:SendHave(elementName, instanceId)
    elseif string.sub(msg, 1, 9) == "storeinv=" then
        CG:AnswerStore(elementName, instanceId, string.sub(msg, 10))
    elseif string.sub(msg, 1, 6) == "state=" then
        local state = string.sub(msg, 7)
        -- ":t" = trader/stash/selection screen; the HUD shows the hints in that screen's hint area
        if elementName ~= "ApseInventoryList" and state ~= "none" then state = state .. ":t" end
        setState(state)
    elseif string.sub(msg, 1, 5) == "hold=" then
        -- Y held on the controller: the HUD spins the hold wheel on the Expand all hint
        if CG_HUD_HINTS then UIAction.CallFunction("HUD", -1, "CgHold", string.sub(msg, 6)) end
        System.LogAlways("[ColourGroups] " .. tostring(elementName) .. ": " .. msg)
    else
        if string.sub(msg, 1, 7) == "toggle " then
            -- a group just opened/closed: the plugin uses this to know its L3 did its job
            System.LogAlways("@@CGT=1")
        end
        System.LogAlways("[ColourGroups] " .. tostring(elementName) .. ": " .. msg)
    end
end

function CG:OnHide(elementName, instanceId, eventName, args)
    setState("none")
end

function CG:Init()
    for _, element in ipairs(ELEMENTS) do
        UIAction.RegisterElementListener(self, element, -1, "OnCgEvent", "OnCgEvent")
        UIAction.RegisterElementListener(self, element, -1, "OnHide", "OnHide")
    end
    System.LogAlways("[ColourGroups] loaded")
end

CG:Init()

return CG
