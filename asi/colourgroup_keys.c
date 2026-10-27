/*
 * Inventory_Overhaul.asi  -  companion plugin for the Ultimate Inventory Overhaul mod (zz_inventory_overhaul)
 *
 * The inventory list folds colour variants into group rows. The game never tells the
 * list when A is pressed on the controller, so while a group row is highlighted this plugin
 * adds a short left-stick-click (L3, the inventory's "toggle category" input) to the pad
 * state the game reads, through both input paths the game has (GameInput and XInput, like
 * KCD2_DpadConsume). The list opens/closes the group on L3. On every other row nothing is
 * changed, so A still equips as normal. B on an open group row or a colour inside it closes
 * the group first (that B press is hidden from the game); the next B exits as usual.
 * Holding Y for 2.5 s while the list is active toggles expand/collapse all (signalled to the menu
 * with double L3 presses); a shorter Y press is replayed to the game on release.
 * Keyboard G is passed on as Insert, which the list also reads as expand/collapse all. Keyboard: the list hears Enter itself; E (group row)
 * and V (group row or inside an open group) are passed on as End, which the list also handles.
 *
 * Which row is highlighted comes from the mod's Lua script, which logs "@@CGS=<state>"
 * (group, member, item, none). This plugin watches WHGame.dll's file/log writes for it.
 *
 * Build: build.ps1 next to this file (w64devkit GCC). Install next to the other .asi files.
 * Log:   Inventory_Overhaul.log next to the .asi.
 */

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdint.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>

/* ------------------------------------------------------------------ logging */

static char g_dir[MAX_PATH];
static char g_logPath[MAX_PATH];
static CRITICAL_SECTION g_logLock;

static void wlog(const char *fmt, ...)
{
    char line[1024];
    SYSTEMTIME t;
    GetLocalTime(&t);
    int n = snprintf(line, sizeof line, "[%02d:%02d:%02d.%03d] ", t.wHour, t.wMinute, t.wSecond, t.wMilliseconds);
    va_list ap;
    va_start(ap, fmt);
    n += vsnprintf(line + n, sizeof line - n, fmt, ap);
    va_end(ap);
    if (n > (int)sizeof line - 3) n = (int)sizeof line - 3;
    line[n++] = '\r';
    line[n++] = '\n';
    EnterCriticalSection(&g_logLock);
    HANDLE h = CreateFileA(g_logPath, FILE_APPEND_DATA, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    if (h != INVALID_HANDLE_VALUE) {
        DWORD w;
        WriteFile(h, line, (DWORD)n, &w, NULL);
        CloseHandle(h);
    }
    LeaveCriticalSection(&g_logLock);
}

/* ------------------------------------------------------------------ row state */

enum { ST_NONE = 0, ST_GROUP = 1, ST_MEMBER = 2, ST_ITEM = 3, ST_GROUPOPEN = 4 };
static const char *k_stateNames[] = { "none", "group", "member", "item", "groupopen" };
static volatile LONG g_state = ST_NONE;
static volatile LONG g_canExpand = 0;       /* current list has groups (or is expanded): Y hold / G work */
static volatile LONG g_transfer = 0;        /* the list is a stash/loot (transfer) screen: a held A on a group row = transfer all */
static volatile LONG g_sourceLogged = 0;

static const char k_marker[] = "@@CGS=";
static const char k_toggleMarker[] = "@@CGT";
static volatile LONG g_lastToggle = 0;      /* GetTickCount() when the list last opened/closed a group */

/* Look for the last "@@CGS=<word>" in a buffer the game is writing out. */
static void scan_for_state(const void *buf, size_t len, const char *source)
{
    if (!buf || len < sizeof k_toggleMarker - 1 || len > 8192) return;   /* "@@CGT" lines are shorter than "@@CGS=x" */
    const char *p = (const char *)buf, *end = p + len, *hit = NULL;
    for (const char *q = p; q + (sizeof k_toggleMarker - 1) <= end; q++) {
        q = memchr(q, '@', (size_t)(end - q));
        if (!q || q + (sizeof k_toggleMarker - 1) > end) break;
        if (q + (sizeof k_marker - 1) <= end && memcmp(q, k_marker, sizeof k_marker - 1) == 0) hit = q;
        else if (memcmp(q, k_toggleMarker, sizeof k_toggleMarker - 1) == 0) InterlockedExchange(&g_lastToggle, (LONG)GetTickCount());
    }
    if (!hit) return;
    const char *w = hit + sizeof k_marker - 1;
    LONG st = -1;
    for (LONG i = 0; i < 5; i++) {
        size_t n = strlen(k_stateNames[i]);
        if (w + n <= end && memcmp(w, k_stateNames[i], n) == 0 && (w + n == end || !isalpha((unsigned char)w[n]))) st = i;
    }
    if (st < 0) return;
    /* flags after the state word, e.g. "item:flat:ng" (ng = no groups, expand all unavailable) */
    const char *e = w;
    while (e < end && *e != '\r' && *e != '\n' && *e != ' ' && *e != 0) e++;
    LONG can = 1, tr = 0;
    for (const char *f = w; f + 3 <= e; f++)
        if (f[0] == ':' && f[1] == 'n' && f[2] == 'g' && (f + 3 == e || f[3] == ':')) can = 0;
    for (const char *f = w; f + 2 <= e; f++)
        if (f[0] == ':' && f[1] == 't' && (f + 2 == e || f[2] == ':')) tr = 1;
    InterlockedExchange(&g_transfer, tr);
    if (InterlockedExchange(&g_sourceLogged, 1) == 0) wlog("State marker seen through %s", source);
    LONG old = InterlockedExchange(&g_state, st);
    LONG oldCan = InterlockedExchange(&g_canExpand, can);
    if (old != st || oldCan != can) wlog("Row state: %s%s", k_stateNames[st], can ? "" : " (no groups: Y/G left alone)");
}

/* ------------------------------------------------------------------ log/file hooks (WHGame.dll IAT) */

typedef int    (__cdecl *fputs_t)(const char *, FILE *);
typedef size_t (__cdecl *fwrite_t)(const void *, size_t, size_t, FILE *);
typedef int    (__cdecl *write_t)(int, const void *, unsigned);
typedef BOOL   (WINAPI *WriteFile_t)(HANDLE, LPCVOID, DWORD, LPDWORD, LPOVERLAPPED);
typedef void   (WINAPI *OutputDebugStringA_t)(LPCSTR);

static fputs_t              g_origFputs;
static fwrite_t             g_origFwrite;
static write_t              g_origWrite;
static WriteFile_t          g_origWriteFile;
static OutputDebugStringA_t g_origODS;

static int __cdecl hook_fputs(const char *s, FILE *f)
{
    if (s) scan_for_state(s, strnlen(s, 8193), "fputs");
    return g_origFputs(s, f);
}
static size_t __cdecl hook_fwrite(const void *b, size_t sz, size_t cnt, FILE *f)
{
    if (sz && cnt && cnt <= 8192 / sz) scan_for_state(b, sz * cnt, "fwrite");
    return g_origFwrite(b, sz, cnt, f);
}
static int __cdecl hook_write(int fd, const void *b, unsigned n)
{
    scan_for_state(b, n, "_write");
    return g_origWrite(fd, b, n);
}
static BOOL WINAPI hook_WriteFile(HANDLE h, LPCVOID b, DWORD n, LPDWORD w, LPOVERLAPPED o)
{
    scan_for_state(b, n, "WriteFile");
    return g_origWriteFile(h, b, n, w, o);
}
static void WINAPI hook_ODS(LPCSTR s)
{
    if (s) scan_for_state(s, strnlen(s, 8193), "OutputDebugStringA");
    g_origODS(s);
}

/* ------------------------------------------------------------------ button injection */

/* GameInput gamepad bits (GameInput.h v0) */
#define GI_A   0x0004
#define GI_B   0x0008
#define GI_X   0x0010
#define GI_Y   0x0020
#define GI_LS  0x1000
/* GameInput UI navigation bits */
#define GI_NAV_ACCEPT 0x0004
#define GI_NAV_CANCEL 0x0008
/* XInput wButtons bits */
#define XI_LS  0x0040
#define XI_A   0x1000
#define XI_B   0x2000
#define XI_X   0x4000
#define XI_Y   0x8000

#define PULSE_ON_MS     40      /* one fake L3 press */
#define PULSE_PERIOD_MS 80      /* press + gap; two presses this close are the Y-hold signal */
#define TRAIN_GAP_MS    160     /* quiet time between two signals so the menu never merges them */
#define Y_START_MS      250     /* Y must be held this long before "hold started" is sent (taps stay taps) */
#define Y_LATE_MS       (Y_START_MS + 2000)  /* released after this: let the menu's 2.25 s timer finish */
#define Y_TAP_MS        90      /* replayed Y tap when Y is released early */
#define B_CHECK_MS      350     /* after hiding B: if the group has not closed by then, a dialog is on top */
#define B_TAP_MS        90      /* replayed B tap in that case */
#define A_HOLD_MS       250     /* A held this long on a group row is passed to the game (transfer all) instead of toggling */
#define E_HOLD_MS       250     /* same for keyboard E: a shorter press is relayed as End (toggle) on release */

/*
 * Fake L3 presses are sent in trains (1 press for A/B, 2 presses for the Y-hold signals).
 * Trains are queued back to back with a gap, so two signals can never overlap or merge.
 */
#define MAX_TRAINS 8
static struct { DWORD start; LONG count; } g_trains[MAX_TRAINS];
static DWORD g_trainsFree = 0;              /* GetTickCount() when the queue is idle again */
static CRITICAL_SECTION g_trainLock;
static volatile LONG g_yTapUntil = 0;       /* GetTickCount() deadline for the replayed Y tap */
static volatile LONG g_bTapUntil = 0;       /* GetTickCount() deadline for the replayed B tap */

static int injecting(void)
{
    DWORD now = GetTickCount();
    int on = 0;
    EnterCriticalSection(&g_trainLock);
    for (int i = 0; i < MAX_TRAINS; i++) {
        if (!g_trains[i].count) continue;
        DWORD t = now - g_trains[i].start;
        if ((LONG)t < 0) continue;                                   /* queued, not started yet */
        if (t >= (DWORD)(g_trains[i].count * PULSE_PERIOD_MS)) { g_trains[i].count = 0; continue; }
        if ((t % PULSE_PERIOD_MS) < PULSE_ON_MS) on = 1;
    }
    LeaveCriticalSection(&g_trainLock);
    return on;
}

static int tapping_y(void)
{
    return (LONG)(GetTickCount() - (DWORD)g_yTapUntil) < 0;
}

static int tapping_b(void)
{
    return (LONG)(GetTickCount() - (DWORD)g_bTapUntil) < 0;
}

static void start_l3(int presses, const char *why, const char *path)
{
    DWORD now = GetTickCount(), start;
    EnterCriticalSection(&g_trainLock);
    start = ((LONG)(g_trainsFree - now) > 0) ? g_trainsFree : now;
    for (int i = 0; i < MAX_TRAINS; i++) {
        if (g_trains[i].count && (LONG)(now - g_trains[i].start) >= g_trains[i].count * PULSE_PERIOD_MS) g_trains[i].count = 0;
        if (!g_trains[i].count) {
            g_trains[i].start = start;
            g_trains[i].count = presses;
            g_trainsFree = start + presses * PULSE_PERIOD_MS + TRAIN_GAP_MS;
            break;
        }
    }
    LeaveCriticalSection(&g_trainLock);
    wlog("%s (%s): sending L3 x%d%s", why, path, presses, start != now ? " (queued)" : "");
}

/*
 * Per input path: previous A/B/Y state and which presses are being hidden from the game.
 *   A on a group row (open or closed)            -> one L3 (open/close the group)
 *   B on an open group row or a colour inside it -> one L3 (close the group); that B press is
 *     hidden until released, so it does not also close the inventory. If the group has not
 *     closed 350 ms later, a dialog is on top of the list: B is let through / replayed instead
 *   Y while the list is active                   -> hidden while held. Held 0.25 s, it sends a double
 *     L3 ("hold started": the menu runs a 2.25 s timer and the HUD spins the hold wheel); letting go
 *     early sends another double L3 ("cancel"). A shorter tap sends no signal at all. Either way a
 *     normal Y tap is replayed on release, so Change outfit still works (on release, not press).
 *     Held to the end, the menu toggles expand/collapse all.
 * Returns a mask of buttons to hide: 1 = B, 2 = Y, 4 = A, 8 = X.
 */
typedef struct { volatile LONG prevA, prevB, prevY, prevX, hideA, hideB, hideY, hideX, yStarted, yFired, yAt, bPending, bSnap, bAt, aPending, aAt; } PadTrack;
static PadTrack g_trackGI, g_trackXI;

static int track_pad(PadTrack *t, int aDown, int bDown, int yDown, int xDown, const char *path)
{
    LONG st = g_state;
    LONG wasX = InterlockedExchange(&t->prevX, xDown ? 1 : 0);
    /* X on a group row in the inventory / trader lists = move or (held) drop of a row that is not an item:
       the list answers the focused-item query with nothing and the game crashes on drop. Swallow it. */
    if (xDown && !wasX && !g_transfer && (st == ST_GROUP || st == ST_GROUPOPEN)) {
        InterlockedExchange(&t->hideX, 1);
        wlog("X on group row (%s): hidden", path);
    }
    if (!xDown) InterlockedExchange(&t->hideX, 0);
    LONG wasA = InterlockedExchange(&t->prevA, aDown ? 1 : 0);
    LONG wasB = InterlockedExchange(&t->prevB, bDown ? 1 : 0);
    LONG wasY = InterlockedExchange(&t->prevY, yDown ? 1 : 0);
    /* A on a group row: hidden from the game at first (the list reports the group's top item as highlighted, so a
       plain A would equip it). Released within A_HOLD_MS -> a tap: send L3, the list opens/closes the group.
       Still held after A_HOLD_MS -> stop hiding it: the game sees a hold and does its hold action (transfer all),
       and the list answers its focused-item query with every member of the group. */
    if (aDown && !wasA && (st == ST_GROUP || st == ST_GROUPOPEN)) {
        InterlockedExchange(&t->hideA, 1);
        InterlockedExchange(&t->aPending, 1);
        InterlockedExchange(&t->aAt, (LONG)GetTickCount());
    }
    if (t->aPending && aDown && g_transfer && GetTickCount() - (DWORD)t->aAt >= A_HOLD_MS) {
        InterlockedExchange(&t->aPending, 0);
        InterlockedExchange(&t->hideA, 0);
        wlog("A held on group row (%s): passing it to the game", path);
    }
    if (!aDown) {
        if (t->aPending) {
            InterlockedExchange(&t->aPending, 0);
            start_l3(1, "A tapped on group row", path);
        }
        InterlockedExchange(&t->hideA, 0);
    }
    if (bDown != wasB) wlog("B %s (%s) state=%s%s", bDown ? "down" : "up", path, k_stateNames[st], t->hideB ? " [hidden]" : "");
    if (bDown && !wasB && (st == ST_GROUPOPEN || st == ST_MEMBER)) {
        InterlockedExchange(&t->hideB, 1);
        InterlockedExchange(&t->bPending, 1);
        InterlockedExchange(&t->bSnap, st);
        InterlockedExchange(&t->bAt, (LONG)GetTickCount());
        start_l3(1, "B inside open group", path);
    }
    if (!bDown) InterlockedExchange(&t->hideB, 0);
    /* No group toggled after that B (a dialog is on top, e.g. "equipped in an outfit", or the
       list was already deactivated): give that B to the game after all, so the dialog gets its No. */
    if (t->bPending && GetTickCount() - (DWORD)t->bAt >= B_CHECK_MS) {
        InterlockedExchange(&t->bPending, 0);
        if ((LONG)((DWORD)g_lastToggle - (DWORD)t->bAt) < 0) {   /* no group toggled since that B */
            InterlockedExchange(&t->hideB, 0);
            if (bDown) {
                wlog("B (%s): group did not close, dialog on top? letting B through", path);
            } else {
                InterlockedExchange(&g_bTapUntil, (LONG)(GetTickCount() + B_TAP_MS));
                wlog("B (%s): group did not close, dialog on top? replaying B tap", path);
            }
        }
    }

    if (yDown && !wasY && st != ST_NONE && g_canExpand) {
        InterlockedExchange(&t->hideY, 1);
        InterlockedExchange(&t->yStarted, 0);
        InterlockedExchange(&t->yFired, 0);
        InterlockedExchange(&t->yAt, (LONG)GetTickCount());
    }
    if (t->hideY && yDown) {
        DWORD held = GetTickCount() - (DWORD)t->yAt;
        if (!t->yStarted && held >= Y_START_MS) {
            InterlockedExchange(&t->yStarted, 1);
            start_l3(2, "Y held: hold started", path);
        }
        if (t->yStarted && !t->yFired && held >= Y_LATE_MS)
            InterlockedExchange(&t->yFired, 1);
    }
    if (t->hideY && !yDown) {
        InterlockedExchange(&t->hideY, 0);
        if (!t->yFired) {
            if (t->yStarted) start_l3(2, "Y released early: hold cancelled", path);
            InterlockedExchange(&g_yTapUntil, (LONG)(GetTickCount() + Y_TAP_MS));
        }
    }
    return (t->hideB ? 1 : 0) | (t->hideY ? 2 : 0) | (t->hideA ? 4 : 0) | (t->hideX ? 8 : 0);
}

/* ------------------------------------------------------------------ GameInput */

typedef struct { uint32_t buttons; float lt, rt, lx, ly, rx, ry; } GIGamepadState;
typedef struct { uint32_t buttons; } GIUiNavState;
typedef int     (*GI_GetGamepadState_t)(void *self, GIGamepadState *st);
typedef int     (*GI_GetUiNavState_t)(void *self, GIUiNavState *st);
typedef HRESULT (*GI_GetCurrentReading_t)(void *self, uint32_t kind, void *device, void **reading);
typedef ULONG   (*GI_Release_t)(void *self);
typedef HRESULT (WINAPI *GameInputCreate_t)(void **out);

#define GI_SLOT_RELEASE        2
#define GI_SLOT_GETCURREADING  4
#define GI_SLOT_GAMEPADSTATE   22
#define GI_SLOT_UINAVSTATE     24
#define GI_KIND_GAMEPAD        0x00040000

static GI_GetGamepadState_t g_origGamepadState;
static GI_GetUiNavState_t   g_origUiNavState;
static volatile LONG g_calledGI = 0;

static int hook_GetGamepadState(void *self, GIGamepadState *st)
{
    int ok = g_origGamepadState(self, st);
    if (InterlockedExchange(&g_calledGI, 1) == 0) wlog("GameInput: GetGamepadState is being called");
    if (ok && st) {
        int hide = track_pad(&g_trackGI, (st->buttons & GI_A) != 0, (st->buttons & GI_B) != 0, (st->buttons & GI_Y) != 0, (st->buttons & GI_X) != 0, "GameInput");
        if (hide & 1) st->buttons &= ~GI_B;
        if (hide & 8) st->buttons &= ~GI_X;
        if (hide & 2) st->buttons &= ~GI_Y;
        if (hide & 4) st->buttons &= ~GI_A;
        if (tapping_y()) st->buttons |= GI_Y;
        if (tapping_b()) st->buttons |= GI_B;
        if (injecting()) st->buttons |= GI_LS;
    }
    return ok;
}

/* The game may also read B as the UI navigation "cancel" button; hide that too while B is held back. */
static int hook_GetUiNavState(void *self, GIUiNavState *st)
{
    int ok = g_origUiNavState(self, st);
    if (ok && st && g_trackGI.hideB) st->buttons &= ~GI_NAV_CANCEL;
    if (ok && st && g_trackGI.hideA) st->buttons &= ~GI_NAV_ACCEPT;
    if (ok && st && tapping_b()) st->buttons |= GI_NAV_CANCEL;
    return ok;
}

static int patch_vtable_slot(void **vt, int slot, void *newFn, void **outOld)
{
    DWORD old;
    if (!VirtualProtect(&vt[slot], sizeof(void *), PAGE_READWRITE, &old)) return 0;
    *outOld = vt[slot];
    vt[slot] = newFn;
    VirtualProtect(&vt[slot], sizeof(void *), old, &old);
    return 1;
}

static int install_gameinput_hook(void)
{
    HMODULE gi = LoadLibraryA("GameInput.dll");
    if (!gi) { wlog("GameInput: GameInput.dll not available (%lu)", GetLastError()); return -1; }
    GameInputCreate_t create = (GameInputCreate_t)GetProcAddress(gi, "GameInputCreate");
    if (!create) { wlog("GameInput: GameInputCreate export missing"); return -1; }

    static void *s_gameInput = NULL;
    if (!s_gameInput) {
        HRESULT hr = create(&s_gameInput);
        if (FAILED(hr) || !s_gameInput) { wlog("GameInput: GameInputCreate failed 0x%08lX", (unsigned long)hr); return -1; }
    }
    void **ivt = *(void ***)s_gameInput;
    void *reading = NULL;
    HRESULT hr = ((GI_GetCurrentReading_t)ivt[GI_SLOT_GETCURREADING])(s_gameInput, GI_KIND_GAMEPAD, NULL, &reading);
    if (FAILED(hr) || !reading) return 0;   /* no gamepad reading yet, retry later */

    void **rvt = *(void ***)reading;
    int ok1 = patch_vtable_slot(rvt, GI_SLOT_GAMEPADSTATE, (void *)hook_GetGamepadState, (void **)&g_origGamepadState);
    int ok2 = patch_vtable_slot(rvt, GI_SLOT_UINAVSTATE, (void *)hook_GetUiNavState, (void **)&g_origUiNavState);
    ((GI_Release_t)rvt[GI_SLOT_RELEASE])(reading);
    wlog("GameInput: reading vtable at %p, GetGamepadState %s (chained to %p), GetUiNavigationState %s (chained to %p)",
         rvt, ok1 ? "hooked" : "FAILED", (void *)g_origGamepadState, ok2 ? "hooked" : "FAILED", (void *)g_origUiNavState);
    return (ok1 && ok2) ? 1 : -1;
}

/* ------------------------------------------------------------------ XInput (IAT) */

typedef struct { WORD wButtons; BYTE bLeftTrigger, bRightTrigger; SHORT sThumbLX, sThumbLY, sThumbRX, sThumbRY; } XIGamepad;
typedef struct { DWORD dwPacketNumber; XIGamepad Gamepad; } XIState;
typedef DWORD (WINAPI *XInputGetState_t)(DWORD, XIState *);

static XInputGetState_t g_origXInputGetState;

static DWORD WINAPI hook_XInputGetState(DWORD idx, XIState *st)
{
    DWORD r = g_origXInputGetState(idx, st);
    if (r == ERROR_SUCCESS && st && idx == 0) {
        int hide = track_pad(&g_trackXI, (st->Gamepad.wButtons & XI_A) != 0, (st->Gamepad.wButtons & XI_B) != 0, (st->Gamepad.wButtons & XI_Y) != 0, (st->Gamepad.wButtons & XI_X) != 0, "XInput");
        if (hide & 1) st->Gamepad.wButtons &= (WORD)~XI_B;
        if (hide & 8) st->Gamepad.wButtons &= (WORD)~XI_X;
        if (hide & 2) st->Gamepad.wButtons &= (WORD)~XI_Y;
        if (hide & 4) st->Gamepad.wButtons &= (WORD)~XI_A;
        if (tapping_y()) st->Gamepad.wButtons |= XI_Y;
        if (tapping_b()) st->Gamepad.wButtons |= XI_B;
        if (injecting()) st->Gamepad.wButtons |= XI_LS;
    }
    return r;
}

/* Patch every import named funcName from any DLL whose lowercase name contains dllSubstr. */
static int patch_iat(HMODULE mod, const char *dllSubstr, const char *funcName, void *newFn, void **outOrig)
{
    BYTE *base = (BYTE *)mod;
    IMAGE_DOS_HEADER *dos = (IMAGE_DOS_HEADER *)base;
    if (dos->e_magic != IMAGE_DOS_SIGNATURE) return 0;
    IMAGE_NT_HEADERS *nt = (IMAGE_NT_HEADERS *)(base + dos->e_lfanew);
    if (nt->Signature != IMAGE_NT_SIGNATURE) return 0;
    IMAGE_DATA_DIRECTORY dir = nt->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT];
    if (!dir.VirtualAddress) return 0;
    int patched = 0;
    for (IMAGE_IMPORT_DESCRIPTOR *d = (IMAGE_IMPORT_DESCRIPTOR *)(base + dir.VirtualAddress); d->Name; d++) {
        const char *dll = (const char *)(base + d->Name);
        char lower[64]; size_t i;
        for (i = 0; i + 1 < sizeof lower && dll[i]; i++) lower[i] = (char)tolower((unsigned char)dll[i]);
        lower[i] = 0;
        if (!strstr(lower, dllSubstr)) continue;
        IMAGE_THUNK_DATA *names = (IMAGE_THUNK_DATA *)(base + (d->OriginalFirstThunk ? d->OriginalFirstThunk : d->FirstThunk));
        IMAGE_THUNK_DATA *iat   = (IMAGE_THUNK_DATA *)(base + d->FirstThunk);
        for (; names->u1.AddressOfData; names++, iat++) {
            if (IMAGE_SNAP_BY_ORDINAL(names->u1.Ordinal)) continue;
            IMAGE_IMPORT_BY_NAME *ibn = (IMAGE_IMPORT_BY_NAME *)(base + names->u1.AddressOfData);
            if (strcmp((const char *)ibn->Name, funcName) != 0) continue;
            DWORD old;
            if (!VirtualProtect(&iat->u1.Function, sizeof(void *), PAGE_READWRITE, &old)) continue;
            if (!*outOrig) *outOrig = (void *)iat->u1.Function;
            iat->u1.Function = (ULONG_PTR)newFn;
            VirtualProtect(&iat->u1.Function, sizeof(void *), old, &old);
            patched++;
        }
    }
    wlog("IAT: %s!%s %s", dllSubstr, funcName, patched ? "hooked" : "not imported");
    return patched;
}

/* ------------------------------------------------------------------ keyboard */

/*
 * The list gets special keys like Enter straight from the engine, but not letters. So E on a
 * group row, or V on a group row / inside an open group, is passed on as an End press, which
 * the list treats as open/close. End is not bound to anything in the inventory.
 */
static int game_is_foreground(void)
{
    HWND fg = GetForegroundWindow();
    DWORD pid = 0;
    if (fg) GetWindowThreadProcessId(fg, &pid);
    return pid == GetCurrentProcessId();
}

static void send_key(WORD vk)
{
    INPUT in;
    memset(&in, 0, sizeof in);
    in.type = INPUT_KEYBOARD;
    in.ki.wVk = vk;
    in.ki.wScan = (WORD)MapVirtualKeyA(vk, MAPVK_VK_TO_VSC);
    in.ki.dwFlags = KEYEVENTF_SCANCODE | KEYEVENTF_EXTENDEDKEY;
    SendInput(1, &in, sizeof in);
    Sleep(30);
    in.ki.dwFlags |= KEYEVENTF_KEYUP;
    SendInput(1, &in, sizeof in);
}

static DWORD WINAPI keyboard_worker(LPVOID p)
{
    (void)p;
    int prevE = 0, prevV = 0, prevG = 0, ePending = 0;
    DWORD eAt = 0;
    for (;;) {
        Sleep(8);
        int fg = game_is_foreground();
        int e = fg && (GetAsyncKeyState('E') & 0x8000) != 0;
        int v = fg && (GetAsyncKeyState('V') & 0x8000) != 0;
        int g = fg && (GetAsyncKeyState('G') & 0x8000) != 0;
        LONG st = g_state;
        /* E on a group row: a short press is relayed as End on release (toggle); a hold is left to the game (transfer all) */
        if (e && !prevE && (st == ST_GROUP || st == ST_GROUPOPEN)) { ePending = 1; eAt = GetTickCount(); }
        if (ePending && e && g_transfer && GetTickCount() - eAt >= E_HOLD_MS) { ePending = 0; wlog("E held on group row: left to the game"); }
        if (!e && ePending) {
            ePending = 0;
            wlog("E tapped on group row: sending End");
            send_key(VK_END);
        }
        if (v && !prevV && (st == ST_GROUP || st == ST_GROUPOPEN || st == ST_MEMBER)) {
            wlog("V on %s row: sending End", k_stateNames[st]);
            send_key(VK_END);
        }
        if (g && !prevG && st != ST_NONE && g_canExpand) {
            wlog("G in the list: sending Insert (expand/collapse all)");
            send_key(VK_INSERT);
        }
        prevE = e;
        prevV = v;
        prevG = g;
    }
    return 0;
}

/* ------------------------------------------------------------------ setup */

static DWORD WINAPI setup_worker(LPVOID p)
{
    (void)p;
    int iatDone = 0, giDone = 0;
    for (int tick = 0; tick < 2400 && (!iatDone || !giDone); tick++) {   /* up to ~20 min */
        if (!iatDone) {
            HMODULE wh = GetModuleHandleA("WHGame.dll");
            if (wh) {
                patch_iat(wh, "xinput", "XInputGetState", (void *)hook_XInputGetState, (void **)&g_origXInputGetState);
                patch_iat(wh, "api-ms-win-crt-stdio", "fputs", (void *)hook_fputs, (void **)&g_origFputs);
                patch_iat(wh, "api-ms-win-crt-stdio", "fwrite", (void *)hook_fwrite, (void **)&g_origFwrite);
                patch_iat(wh, "api-ms-win-crt-stdio", "_write", (void *)hook_write, (void **)&g_origWrite);
                patch_iat(wh, "kernel32", "WriteFile", (void *)hook_WriteFile, (void **)&g_origWriteFile);
                patch_iat(wh, "kernel32", "OutputDebugStringA", (void *)hook_ODS, (void **)&g_origODS);
                iatDone = 1;
            }
        }
        if (!giDone) {
            int r = install_gameinput_hook();
            if (r != 0) giDone = 1;
            else if (tick == 0) wlog("GameInput: no gamepad reading yet, waiting for a controller...");
        }
        Sleep(500);
    }
    wlog("Setup finished (imports %s, GameInput %s)", iatDone ? "done" : "skipped", giDone ? "done" : "never got a reading");
    return 0;
}

BOOL WINAPI DllMain(HINSTANCE inst, DWORD reason, LPVOID reserved)
{
    (void)reserved;
    if (reason == DLL_PROCESS_ATTACH) {
        DisableThreadLibraryCalls(inst);
        InitializeCriticalSection(&g_logLock);
        InitializeCriticalSection(&g_trainLock);
        GetModuleFileNameA(inst, g_dir, sizeof g_dir);
        char *slash = strrchr(g_dir, '\\');
        if (slash) slash[1] = 0;
        snprintf(g_logPath, sizeof g_logPath, "%sInventory_Overhaul.log", g_dir);
        DeleteFileA(g_logPath);
        wlog("Inventory_Overhaul loaded (build " __DATE__ " " __TIME__ ")");
        HANDLE t = CreateThread(NULL, 0, setup_worker, NULL, 0, NULL);
        if (t) CloseHandle(t);
        t = CreateThread(NULL, 0, keyboard_worker, NULL, 0, NULL);
        if (t) CloseHandle(t);
    }
    return TRUE;
}
