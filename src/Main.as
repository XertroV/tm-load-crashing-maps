const string CRASHES_WHEN_REGISTERS_WRONG = "83 F8 FF 74 10 B8 FF FF FF FF 48 8B 5C 24 40 48 83 C4 30 5F C3 BA FF FF FF FF 48 8B CB E8 ?? ?? ?? ?? 48 8B C8 8B D7 E8 ?? ?? ?? ?? 48 8B 5C 24 40 48 83 C4 30 5F C3";
const int64 PATTERN1_OFFSET = 39;

string[] origBytes;
uint64[] callPtr;
bool enabled = false;

void RunPatch() {
    if (enabled) return;
    enabled = true;
    // nop call to function
    // alternatively, hook it and check rcx for FFFFFFFFFFFFFFFFF8
    callPtr.InsertLast(Dev::FindPattern(CRASHES_WHEN_REGISTERS_WRONG));
    origBytes.InsertLast(Dev::Patch(callPtr[0], "90 90 90 90 90"));

    UI::ShowNotification(
        Meta::ExecutingPlugin().Name,
        "Patched the function in InitChallenge that crashes the game sometimes.",
        vec4(1, 0, 0, 1), 10000
        );
}

void Unload() {
    if (!enabled) return;
    for (uint i = 0; i < callPtr.Length; i++) {
        if (callPtr[i] == 0) continue;
        Dev::Patch(callPtr[i], origBytes[i]);
    }
    callPtr.RemoveRange(0, callPtr.Length);
    origBytes.RemoveRange(0, origBytes.Length);
    UI::ShowNotification(
        Meta::ExecutingPlugin().Name,
        "Unloaded patch to load crashing maps.",
        vec4(0, 1, 0, 1), 10000
    );
    enabled = false;
}

void OnDestroyed() { Unload(); }
void OnDisabled() { Unload(); }

/** Render function called every frame intended only for menu items in `UI`.
*/
void RenderMenu() {
    if (UI::MenuItem("PATCH: Load Crashing Maps", "", enabled)) {
        if (enabled) Unload();
        else RunPatch();
    }
}
