# Validation — 0.7.1 request-reply hotfix

- The supplied dedicated-server RPT identified repeated errors in fn_roleOccupancy.sqf line 13 while CSR API v5 was initialized. A request token was inherited as _this by a unary call and interpreted as the optional excluded UID; comparing a UID string to that number aborted the response.
- Reproduced that exact expression error using the 0.7.0 PBO with [42,"state",[]] as the enclosing arguments.
- State/adminData builders now explicitly pass [] to roleOccupancy. The helper also normalizes missing/non-string exclusion arguments safely while retaining valid UID exclusion.
- Passed **29/29 dedicated-server regression checks** against the corrected PBO. Tested request-shaped inherited arguments, all/own assigned and reserved counts, empty maps, and the actual shipped response-dispatch section for state/adminData in Full, Compatibility and pending modes. Replies contain valid personnel data/counts and round-trip as plain arrays. Non-admin adminData requests remain rejected.
- The fixture supplies player identity/admin state locally before executing the production dispatch section. It does not bypass or change shipped authentication code; it is not a connected-client network/UI test. Live confirmation on the user's dedicated server remains needed.
- All 61 SQF files pass static checks. All six PBOs build and pass config decode/source-hash parity. The regression run contains no SQF expression errors. See request-test-results.txt; fixture is under work/csr-request-test.
- Updated only csr_core.pbo in the shared CSC Utilities addons folder. Source/package/deployed-core backup is under work/csr-request-071-backup. The isolated test server was stopped; production profile untouched.
- No schema/API version or permission-policy change. Existing schema-5 data is retained; do not delete or reset the profile to install this hotfix. Replace the core PBO on server and clients, re-sign if applicable, and restart Arma.

---

# Validation — 0.7.0 division roles

- Passed **63/63 isolated dedicated-server assertions** with CBA and CSR Roster. Coverage: schema 1–4 migration and schema-5 validation; personnel/ranks/legacy values/stats/audit/logos/equipment preservation; role rule validation; immutable unlimited Default Rifleman; one eligible-only Command Staff division; stale/read-only rejection; legacy definition preservation; assigned/reserved capacity accounting; eligibility; living/unconscious occupant retention; actual death fallback; reduced-cap resolution; valid ordinary respawn; pending role commit/cancellation; preset mappings; real engine curator creation/assignment, addon catalog, free costs, existing/new editable objects and cleanup. See role-test-results.txt.
- Restarted against the same isolated profile with CBA, ACE 3.21.2, cTab/BCE and all CSR runtime modules. **11/11 restart assertions passed**: role limits, renamed Default ID, ranks, counters, logos, equipment and audit persist; live assignments/reservations reset, active division becomes Default, and mode returns to pending. See role-restart-test-results.txt.
- The final optional-module boot compiled all **61 shipped SQF files**, with no CSR script expression errors in that run. All six PBO configs build/decode successfully; extracted SQF hashes match source. Static checks resolve 55 CSR function references and validate build-script syntax.
- An exploratory engine run caught the EntityCreated handler receiving a direct object rather than an array. Corrected the handler and reran all 63 checks with a fresh isolated profile. Curator deletion is checked after the engine's following frame.
- The death/respawn tests use engine-created test AI bodies with fixture-owned identity/session maps to exercise server helpers. Reservations are exercised through those maps. **No connected-player remote requests, client traits, actual forceRespawn flow or client UI were gameplay-tested.** Do not interpret server-helper tests as multiplayer end-to-end coverage.
- Additional live acceptance: two eligible clients race for the last role; switch roles inside one division; cancel confirmation; verify mission respawn/loadout/tickets and CSR switching-death exclusion; die/revive with ACE; reduce/remove an occupied role; revoke eligibility; edit a pending target; disconnect/JIP; check permissions are removed after leaving medic/engineer/Command Staff. Verify unrestricted Zeus UI/assets, editing newly spawned objects and regrant after valid respawn. Check ACE treatment/repair actions with the unit's actual ACE settings.
- Verify Units role list/Full indicator, active role labels, admin limits/counts, keyboard navigation and cTAB layout at actual UI scales. Compatibility should retain mission roles, Zeus, arsenals and respawn behavior. Full Integration deliberately overrides mission medic/engineer/curator ownership. Client synchronization with mission scripts that continuously overwrite those traits remains an integration test.
- API/schema 5 preserves the 12-field personnel row and existing division fields. New role rules append definition index 5. Expanded replies append live role/occupancy data. Legacy Full Join must supply a role ID; legacy personnel reads and name/rank edits remain supported. Restrictive mission whitelists need CSR_fnc_applyRole.
- Backed up previous source/packages/deployed PBOs under work/csr-roles-070-backup. Core/UI PBOs are updated together in @CSC Utilities/addons. Other deployed modules and server policy are unchanged. Packages are unsigned.
- No production profile was edited. Isolated fixtures/profiles/logs are under work/csr-roles-test; test server processes were stopped. Before upgrading the production server, stop it and back up its complete profile directory. Schema downgrade requires restoring that backup.

---

# Validation — 0.6.2 division insignias

- Passed **34/34 dedicated-server assertions** covering schema-3 migration (plus schemas 1/2), stored data preservation, insignia enumeration/resolution, mission-over-addon precedence, case-insensitive lookup, mission-relative textures, None, missing/textureless classes, malformed IDs/paths, assignment/clearing, stale/read-only rejection, legacy save preservation, unavailable saved choices, new divisions and audit entries. See `insignia-test-results.txt`.
- Restarted the isolated server with the same profile and CBA, ACE, cTab/BCE and all CSR runtime modules. **10/10 restart assertions passed**: assigned logo, renamed Default ID, ranks, legacy role, combat totals, eligibility, equipment, historical audit and schema validity survived. Active division reset to Default as designed. See `insignia-restart-test-results.txt`.
- The optional-module engine run compiled all **50 SQF files** without CSR script errors. Built all six PBOs, decoded packed configs and compared packaged SQF hashes against source. Static checks resolved 44 CSR function references.
- The fixtures used real test CfgUnitInsignia entries and a packed mission-relative image. Test-only insignias/PBOs are not included in the runtime packages.
- **No live-client visual/input validation was performed.** Check dropdown thumbnails, None/Unavailable selection, preview changes without overwriting unsaved fields, long insignia names, mission/mod logos, image aspect ratio, Home cards, Units list/detail, admin list and different UI scales. Test with a server/client modset match and a deliberately absent client insignia addon.
- Data now uses schema 4 under the same native profile keys. Pure schema-3 migration preserves all previous values and appends an empty logo field. Old five-argument definition saves preserve assigned logos. API v4 appends a definition field; readers enforcing exact four-element length must adapt.
- Backed up the previous source/packages/deployed PBOs under `work/csr-insignia-062-backup`. Updated core and UI PBOs in `@CSC Utilities/addons`; other deployed PBOs are unchanged. Back up the stopped production profile before upgrading; downgrade requires its older-schema backup. Packages remain unsigned.
- Test profiles and logs are isolated under `work/csr-insignia-test`; no production profile was edited. Test server processes were stopped.

---

# Validation — 0.6.1 UI refresh

- Built all six PBOs and passed config conversion, SQF delimiter/function-reference checks, and extracted PBO/source parity.
- Booted the isolated dedicated-server fixture with CBA, ACE, cTab/BCE and CSR. The engine compiled all 47 SQF files without CSR script errors; all nine persistence/restart assertions passed. See `ui-refresh-engine-results.txt`. The final subsequent edit only simplifies the stats label text.
- The generated banner and code-drawn pine motif were converted successfully with Bohemia ImageToPAA. Their packaged hashes were checked against source.
- This is a presentation/navigation update: core persistence, membership, arsenal policy, statistics collection and server authorization sources are unchanged from 0.6.0.
- Home, Service Record and Units share the standalone/cTAB panel. Home previews at most four divisions, with View All opening the full browser; View opens the selected division. Only existing eligible Join behavior is used.
- Rapid UI requests are paced; deferred requests from a closed/replaced page are discarded. This still requires client interaction testing.
- **No in-game visual inspection was performed.** Verify font sizing, clipping, banner rendering, Home/View/Units navigation, admin visibility, keyboard/controller focus, cTAB native Home and window close at your normal UI size. Confirm callbacks after rapid navigation and the unchanged Join confirmation flow.
- Backed up the previous source/packages and shared modpack under `work/csr-ui-061-backup`. Updated only `csr_ui.pbo` and `csr_tablet.pbo` in `@CSC Utilities/addons`. Existing storage requires no new migration. PBOs remain unsigned.
- Isolated test server PID 23628 was stopped; no production profile was edited.

---

# Validation — 0.6.0 test build

## Executed checks

- Passed **42/42 assertions** in an isolated Arma dedicated-server mission with CBA and CSR Roster. Coverage includes schema 1/2 migration, stable Default ID, retained ranks/legacy roles/statistics/audit, multiple eligibility, active-division display, revocation without removing current access, empty division preservation, equipment deduplication, malformed/stale/read-only writes, legacy API behavior, independent snapshots, and first-admin-wins mission mode. See `expanded-test-results.txt`.
- Restarted the process against the same saved profile with CBA, ACE 3.21.2, cTab 1erGTD, BCE and all CSR runtime modules: **9/9 persistence assertions passed**. Renamed Default, eligibility, equipment, rank, totals and historical audit survived; active division reset to Default and mission mode returned to pending. Repeated this restart after the final client timing fixes; see `expanded-restart-test-results.txt`.
- The final engine boot compiled **47 shipped SQF files**, initialized core and optional ACE statistics, and reported no CSR script errors in that run. Dedicated-server compilation does not execute client-only UI/arsenal paths.
- Built **six PBOs** using Bohemia CfgConvert/FileBank; decoded each packed config and checked packaged SQF hashes against source. All passed. Static checks covered SQF delimiters/strings, 41 resolved CSR function references and PowerShell build syntax.
- The first exploratory migration run exposed use of `_forEachIndex` inside `apply`. Corrected it to an explicit `forEach`; the 42 passing checks used a fresh isolated profile after that correction.
- Reviewed the installed ACE Arsenal source. ACE functions are finalized, so the adapter uses public display events and a temporary local arsenal proxy instead of replacing ACE functions. Permissions are requested after the initial display closes. An older pending status reply cannot undo the selected mission mode broadcast.

## Client acceptance still required

No players were connected during automated server checks. The following are **not yet gameplay-validated**:

1. Standalone keybind/rebinding, all new page layouts, editing long descriptions/item arrays, filters, buttons and cTAB native Home navigation at your UI sizes.
2. Admin login/allowlist detection, automatic mode prompt, two admins racing to select a mode, reconnect/JIP propagation, and real remote rejection for non-admin writes.
3. Two connected players with different active divisions opening the same ACE arsenal. Check exact list separation, saved-loadout validation, scripted full arsenals, empty/unknown lists, and reopening after an admin equipment edit.
4. Full-mode Yes/No, the exact warning, mission-controlled respawn delay/location/loadout/tickets, single switch commit, normal respawn retaining active division, reconnect resetting Default, and intentional-switch death exclusion from CSR statistics.
5. Compatibility mode on the unit's Workshop/Antistasi missions: CSR switching without altering mission arsenals, gear, respawn, groups or Arma engine ranks.
6. Revocation while active and during a pending respawn; closing UI during requests; timeouts; restrictive mission remote-execution whitelists.
7. The full Iceman addon/dependency set. The optional-module test boot included cTab/BCE, not that complete set.

ACE itself exposes already-carried equipment as unique inventory entries and performs weapon classname normalization. CSR's division array controls supplied arsenal stock; the implementation does not strip mission-issued gear or enforce a global inventory ban. Test your unit's equipment mods and saved loadouts before deployment.

## Isolation, packaging and upgrade

All fake personnel, profiles, test mission and logs stayed under `work/csr-060-test`. No production server profile was edited. All isolated test server processes were stopped.

The original 0.5 source/packages and deployed PBOs were backed up under `work/csr-060-backup`. Updated core/UI/statistics/tablet and the new arsenal PBO were copied to `@CSC Utilities/addons`. The optional server policy was not added to the shared modpack.

Back up the **stopped production server's profile directory** before first launch with schema 3. The older addon cannot read schema 3; downgrade requires restoring that backup. The new schema retains the existing native profile storage key. PBOs remain unsigned; use the unit's normal signing process if required.

---

# Validation — 0.5.0 test build

## Division registry update

- Passed 30 assertions in a live isolated dedicated-server mission with CBA and CSR Roster. Coverage includes schema-1 migration, Default before first join, retaining assigned divisions/ranks/roles/statistics, persistent empty divisions, bulk renames, the future-join default value, case-only renames, canonical spelling, stale member/registry rejection, collisions, invalid names, read-only storage, change events and schema validation. See `division-test-results.txt`.
- Restarted the process with the same profile and optional ACE/cTAB/BCE modules. All six restart assertions passed: renamed starting division, both member assignments, an empty division, preserved career totals, and no repeat migration back to Default. See `division-restart-test-results.txt`.
- The final restart boot compiled all 37 shipped SQF files without CSR script errors and initialized the optional ACE statistics module. Final config compilation, static checks, resolved function references and extracted PBO/source parity passed.
- The unchanged registration path now reads the current starting division from server metadata. Live player join assignment, NEW personnel defaults, Manage Divisions rendering/clicks, and remote admin/non-admin interactions still require client testing. The backend tests use seeded offline personnel and trusted local APIs; they do not claim client gameplay coverage.
- Test data and profiles stayed in `work/csr-division-test`; all test server processes were stopped. The updated core and UI PBOs were copied into the user's `@CSC Utilities/addons` after backing up the previous files under `work/csr-default-backup`. No production profile was edited.

## Storage change

The existing `CSR_store_v1` key now contains schema 2 with division metadata in the same snapshot as personnel. Schema 1 is migrated automatically. Keep a stopped-server profile backup before first upgrade; an older addon rejects the upgraded schema, so downgrading requires the earlier profile backup. The PBOs remain unsigned.

---
# Validation — 0.4.0 test build

## Passed

- Built all five PBOs using Bohemia CfgConvert/FileBank. Extracted each final PBO, decoded its config and verified packaged SQF hashes against source. Static checks covered 31 SQF files and 26 referenced function names; the build script parsed successfully.
- Booted an isolated dedicated server with only CBA and `@CSR_Roster`. The engine confirmed ACE=false and cTAB=false, loaded the exported test mission, and initialized the roster. The shared UI config loaded without those dependencies; its visual behavior was not exercised on the dedicated server.
- Passed 18 server API assertions inside the running mission: missing/empty reads, create/edit, independent snapshots including nested arrays, validated rank/revision handling, preserved career counters, change events, invalid UID/rank/text/revision rejection, read-only rejection and storage schema compatibility. See `standalone-test-results.txt`.
- Restarted the dedicated-server process using the same isolated profile. Confirmed the saved division and a seeded career counter loaded from disk. The restart run passed 19 assertions, including that persistence check; see `restart-test-results.txt`.
- Booted the same test mission with CBA, ACE 3.21.2, cTab 1erGTD, BCE and all three CSR runtime packages. The roster and optional ACE module initialized. All 18 server API assertions passed again; see `integration-test-results.txt`.
- Compiled all 31 shipped SQF files inside the engine during the optional-module boot. No CSR script compilation/runtime errors were reported in the successful mission runs. The core and UI have no cTAB/BCE/ACE addon dependencies.
- Retained the existing storage key/schema and unchanged rank mapping/sorting logic. Earlier versions passed 37 rank and 17 roster-view assertions; those earlier results do not constitute testing of the new client transport or standalone dialog.

## Still requires client testing

- No clients were connected. Standalone rendering, Ctrl+Alt+R/rebinding, CLOSE/Esc, cTAB launcher/Home behavior, view switching, and field/filter controls require in-game checks at your UI sizes.
- Client request/callback delivery, cancellation, timeouts, simultaneous integrations, logged-in admin/allowlist/voted-admin behavior, and remote rejection need dedicated-server/client acceptance tests. The server-side authorization checks were retained, but the API tests invoked the trusted local API rather than authenticating live players.
- Live rank application, rating preservation, respawns and new ACE kill/death attribution were not exercised by this update's API fixtures. The persisted career count was deliberately seeded in the isolated test. The ACE implementation was extracted from the previous core with its attribution logic unchanged.
- The optional-module boot included cTab/BCE, not the full Iceman addon/dependency set. Complete-modset compatibility is not claimed.
- PBOs remain unsigned. Sign them with your modpack key and distribute matching signatures/public key when your server requires signatures.

## Test isolation

All test profiles, fake personnel, mission files and logs were confined to `work/csr-api-test` in the workspace. The generated test mission was exported as an addon and selected by its terrain-qualified template name (`CSR_API.VR`). An earlier attempt without the terrain suffix failed to locate it; the subsequent mission runs succeeded. An exploratory preStart-only API run was unsuitable for CBA event/profile testing; the passed results above come from the running mission and process restart.

Test-only PBOs and fixtures are not included in the runtime packages. All temporary dedicated-server processes were stopped. Existing Workshop files, deployed modpack PBOs and production server profiles were not edited.
