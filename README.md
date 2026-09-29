# Community Service Roster — 0.7.1 test build

CSR combines a persistent personnel roster, division definitions, eligibility administration, and player division selection. The standalone UI requires CBA. cTAB, ACE statistics, and ACE Arsenal integration are optional addons.

**This build has automated dedicated-server validation; live client UI, forced respawn, and arsenal interaction still require the acceptance checks in VALIDATION.md.**

Version 0.7.1 fixes the role-count error that prevented Home and Admin replies. Replace the core PBO on server and clients and restart Arma. No profile reset or schema migration is needed from 0.7.0.

## Installation and packages

| Package | PBOs | Dependencies |
|---|---|---|
| @CSR_Roster | csr_core, csr_ui | CBA |
| @CSR_CTAB | csr_tablet | CSR UI, cTab 1erGTD, BCE |
| @CSR_ACEStats | csr_stats_ace | CSR Core, ACE Medical |
| @CSR_ACEArsenal | csr_arsenal | CSR Core, ACE Arsenal |
| @CSR_ServerPolicy | csr_server_policy | CSR Core; optional server-only admin allowlist |

The first four packages can be combined in **@CSC Utilities/addons**, on server and clients. Keep only one loaded copy of each PBO. No storage DLL, database service, or additional persistence mod is required. Optional policy remains server-only. Preserve any customized policy PBO rather than replacing it with the supplied empty example.

Restart Arma after changing PBOs. The build is unsigned: sign with your unit's key if signature checking is enabled; never distribute the private key. Build with `build.ps1 -SignKey 'D:\PrivateKeys\MyUnit.biprivatekey'`.

Standalone access: **Ctrl+Alt+R**, configurable under Controls → Configure Addons → Community Service Roster. cTAB's icon below the clipboard opens the same Home page; its native Home control closes the CSR app. The core never requires a tablet.

## Personnel portal

- **Home:** Cascadian banner, personnel card (name, rank, active division, UID), and up to four division previews. **View** opens that division; **View All** opens the complete list.
- **Service Record:** career and current-mission enemy kills, AI/player breakdown, friendly/civilian kills and deaths.
- **Units:** all divisions, their descriptions and the existing eligible Join action.
- **Admin:** authorized personnel/division administration. This tab is hidden for ordinary players.
- **X:** closes the standalone portal or returns to the cTAB desktop. cTAB's own hardware Home action is retained.

There are no announcements, task/resource boxes, Profile, Applications or Resources tabs. The theme and navigation are shared by both interfaces. Artwork provenance and the generation prompt are in `source/csr_ui/data/ASSETS.md`.

Version 0.7.0 adds division role selection, per-role capacities and Full Integration permission enforcement. Update `csr_core.pbo` and `csr_ui.pbo` together, restart Arma, and re-sign them if required. Back up the stopped server profile before this schema update.

## Upgrading and storage

Stop the server and back up its **complete profile directory** before upgrading. Replace core, UI and ACE statistics; install the new arsenal PBO if desired. cTAB remains optional. Replace all shipped runtime PBOs together and re-sign changed files.

The existing profile key `CSR_store_v1` now contains schema 5. Schemas 1/2/3/4 migrate automatically:
- Stable IDs are generated for existing divisions; renamed Default retains its identity.
- Existing assignments become eligibility for that division plus Default.
- Existing personnel names, ranks, combat totals, and audit entries survive.
- Old role values are retained only in the deprecated API/storage field. They are not used for the new session role system.
- Active divisions reset to Default when the new mission initializes.
- Existing descriptions, equipment lists, memberships and schema-4 logos are preserved. Schema-3 divisions gain an empty logo selection. All migrated divisions receive unlimited Rifleman slots.
- When migrating schema 1/2, new descriptions and equipment lists begin empty. **Configure equipment before using Full Integration. Empty lists deny arsenal access.**

The previous snapshot stays in `CSR_store_backup_v1`, in the **same physical profile file**. It is not a separate disaster-recovery backup. Invalid/unsupported stores are preserved and writes disabled. Do not downgrade against schema 5; restore the pre-upgrade profile backup first.

Configuration and personnel save together after admin edits and division changes, every 30 seconds while dirty, at disconnect, and normal mission end. A crash may lose unsaved statistics. Arma's writer does not acknowledge physical disk durability to SQF.

For Windows server migration, stop both servers, copy the profile directory preserving its structure, and configure the destination's `-profiles` path and the same `-name`. CSR lives in `<name>.vars.Arma3Profile`; `<name>.Arma3Profile` holds profile settings. Other mods using that profile storage travel with it. Replacing a destination profile does not merge its records. Mod packages, launch settings, and separately stored mission saves are transferred separately.

## Mission mode dialog

At mission startup, Compatibility behavior applies while awaiting an authorized administrator. Once an admin is available and no other UI is open, CSR shows:
- **Full Integration:** division/role Join requires mission respawn, role permissions and Zeus access are controlled by CSR, division ACE Arsenal whitelists apply, and CSR ranks synchronize to Arma ranks.
- **Compatibility:** Join immediately updates the displayed CSR division. CSR does not change mission roles, Zeus access, arsenals, equipment, respawn, squads, or Arma engine ranks. CSR ranks remain visible in its own record.

The first server-accepted selection wins. Other admins' dialogs close when the selected mode arrives. The selection is fixed for that mission session, including reconnects and JIP. Restarting or switching missions prompts again. It is never restored from the persistent roster. Closing the pending dialog postpones another prompt for 30 seconds. Logging out of admin closes it.

Use Compatibility for unfamiliar Workshop missions and mission frameworks such as Antistasi pending specific testing. It makes no claim of dedicated framework integration. Full Integration deliberately assumes the administrator has selected a mission with working respawns; it does not disable Join based on a generic mission respawn-setting check.

## Player divisions

Select **Units** in the top navigation (or **View All** on Home):
- All divisions and their descriptions are visible.
- In Compatibility, an eligible non-active division has **Join**. In Full Integration, select an offered role to Join. Ineligible divisions have no Join option.
- The active entry is marked **Active**. Everyone is always eligible for the designated Default.
- Eligibility is separate from the single active division; switching never removes other eligibility.
- Reconnect and new missions start in Default; UI refresh retains the active division. Ordinary respawn retains a valid role/division; the Full Integration rules below describe fallback after admin changes.
- No permanent home division, squad/group movement, location restriction, or switching cooldown is introduced.

In Full Integration, Join shows **Yes / No** and:
> You will respawn.  
> Equipment will be reset based on mission settings.

No makes no change. Yes sends a server-validated request using the mode shown in the confirmation. A changed mode requires refreshing and confirming again. CSR invokes the normal `forceRespawn` operation, preserving mission timer/location/loadout behavior and ticket policy. It reserves the selected role, commits the division/role on the new player body, checks eligibility and capacity again, and prevents duplicate pending switches. Reconnecting cancels a pending switch. A dispatch that leaves the original body alive for 30 seconds is cleared for retry; CSR never repeatedly kills/retries automatically.

The optional statistics module excludes the intentional switching death. Mission scripts and other mods' death counters are outside CSR's control. CSR does not give equipment, save loadouts, create spawn positions, or implement custom mission respawn logic.

## Administration

Normal logged-in server admins, hosted-server hosts, and server-policy allowlisted UIDs can administer. Voted admins cannot. Permissions and revisions are checked on every request, not just by hiding controls.

**ADMIN → PERSONNEL ADMINISTRATION**
- Edit display name and rank, or create an offline record with a 17-digit Steam UID.
- Double-click eligible divisions to toggle them, then **SAVE RECORD**. Default cannot be removed.
- Search names/UIDs; combine active-division and rank filters; sort by division/rank, name, or rank.
- Filtering preserves the editor's unsaved fields. Selecting another person, RELOAD, or navigation discards them.
- Changing eligibility does not change the active division. In Full Integration, revoked active members remain until actual death or switching. Compatibility retains the previous behavior until leaving or reconnecting/new mission.

**DIVISION ADMIN**
- Create divisions, rename them, edit descriptions, and paste equipment arrays.
- Default is identified by ID; renaming it updates all displayed active records and future joins.
- Names: 1–64 printable characters, unique ignoring case. Descriptions: up to 2048 characters.
- Equipment: a plain classname array, e.g. `["ItemMap","ItemCompass","ACE_fieldDressing"]`. The text is parsed as data, never executed.
- Empty `[]` denies arsenal access in Full Integration. Duplicate entries are removed. Missing mod classnames are retained with a warning for portability to other modsets.
- **ELIGIBLE PLAYERS** edits membership from the division side. Select a person and **TOGGLE ELIGIBILITY**; those changes save immediately.
- Stale edits are rejected. Reload before retrying.
- Deleting/merging divisions, changing the designated Default ID, and deleting/resetting player statistics are not provided.

Optional admin UIDs are configured in `source/csr_server_policy/config.cpp` and loaded only on the server. Rank labels/mappings are unchanged from 0.5.0: full community ranks resolve to Arma's seven ranks in Full Integration only. The mod does not rename actual players or add name prefixes.


## Division roles (Full Integration only)

Open **Admin → Division Admin**, select a saved division, then **Roles / Slots**. Enter **Off**, **Unlimited**, or a whole-number maximum from 1 to 10,000 for each preset, then **Save Role Limits**. The page shows assigned players and pending reservations separately. Reload updates those counts.

| Role | Permissions granted by CSR |
|---|---|
| Command Staff | Unrestricted Zeus: loaded addon catalog, free actions, no CSR editing/camera boundaries, existing and newly created mission objects editable |
| Rifleman | No medic, engineer or Zeus permissions |
| Pioneer | Advanced Engineer (ACE engineer level 2 and Arma engineer trait) |
| Combat Lifesaver | Medic (ACE medical level 1 and Arma medic trait) |
| Medic | Doctor (ACE medical level 2 and Arma medic trait) |
| Pilot | No medic, engineer or Zeus permissions |

Enable Command Staff in **one non-Default division**. Its existing eligible-player list controls who can take the role. CSR rejects Command Staff in Default or in a second division. To move its configuration, disable it in the previous division first. Previously assigned living occupants retain their permissions until death or switching, even if the role is moved.

The designated Default always has unlimited Rifleman slots; that cannot be disabled or capped, and renaming Default does not change it. Other divisions start with unlimited Rifleman after migration or creation; configure their desired roles and limits in the admin page.

Players open **Units**, select a division, select an offered role, and click **Join**. Everyone can see divisions and role counts; ineligible divisions have no Join button. Full roles show a disabled **Full** button. Changing roles within the same division also requires the existing Yes/No respawn confirmation. The currently active role appears on Home and Service Record.

- New connections, reconnects and new Full Integration missions start in Default → Rifleman. Selecting Full Integration initially applies that starting role to connected players.
- Server authorization checks division eligibility and capacity. Accepted requests reserve the target slot during respawn; another request cannot claim that reservation. The previous assignment remains held until the switch completes.
- Ordinary death/respawn retains a role when still eligible, enabled and within its cap. Actual death rechecks an occupant after admin changes; if the role is no longer valid, CSR moves them to Default → Rifleman. Other occupants remain until their own death or switch. ACE unconsciousness does not count as death.
- Role limits are rechecked when respawn completes. If an admin removes a reserved role or eligibility before completion, the player falls back to Default → Rifleman.
- Disconnect releases assignments and reservations. These are live session state, not permanent personnel roles. Definitions and limits persist in the same profile snapshot as divisions.
- In Compatibility or pending mode, the role selector and role permission enforcement are inactive. Admins can still prepare saved role limits for a later Full Integration mission.

Full Integration owns player medic/engineer traits, ACE training levels and Zeus assignment. It clears those permissions for roles that do not grant them, including a mission-assigned player curator. Mission scripts should not repeatedly override those same permissions in Full Integration. CSR does not grant EOD/UAV abilities or alter groups. Mission respawn equipment remains mission-controlled.

ACE's server settings still determine what a medic/doctor/engineer can do; CSR assigns the training level rather than rewriting ACE settings. See the [ACE repair framework](https://ace3.acemod.org/wiki/framework/repair-framework) for engineer levels. Zeus uses Arma's [curator addon and editing controls](https://community.bistudio.com/wiki/Curator). No ACE or cTAB dependency is added to the core; the built-in Arma curator addon is required.

## Division logos

In **Admin → Division Admin**, select or create a division. Choose **Division Logo / Insignia** from the dropdown, check the preview, then **Save Division**. **None** clears the assigned logo.

Choices use Arma's [CfgUnitInsignia definitions](https://community.bohemia.net/wiki/Arma_3:_Unit_Insignia): built-in insignias, loaded addon insignias, and definitions in the current mission. Entries display their name and thumbnail. New selections must also exist on the server. The supplying addon should be loaded by the server and clients for consistent availability.

CSR saves the class name, not an uploaded image or a machine-specific texture path. Mission-relative textures are resolved locally. Logos follow the division's stable ID through renames and appear on Home, Units, and the admin division list. The personnel card uses the active division's logo.

If an addon or mission insignia is missing later, the saved choice is retained as **Unavailable: class name** in the selector and the UI uses its generic pine icon. Saving other division fields preserves that choice. Select another available insignia or None to change it. Divisions with no assigned logo also use the generic icon.

## ACE Arsenal behavior

A division's exact list is the sole equipment whitelist: no union with other eligible divisions and no rank/role bonuses. All roles in the same active division receive the same list. In Full Integration, CSR controls the listed role abilities; the mission still determines respawn equipment.

The optional adapter uses ACE arsenal open/close events. In Full Integration it briefly closes the initial arsenal, requests the server's current list, and reopens a restricted arsenal using a temporary local proxy. This also handles scripted full-arsenal opens through the normal ACE UI. It does not overwrite ACE's finalized functions or mutate the mission's shared arsenal object.

Admin changes apply at the next opening. Already-open arsenals retain their snapshot. Empty lists, missing loaded equipment, or permission-request errors produce an explanation. Compatibility/pending mode leaves ACE opening behavior untouched.

ACE handles item categorization, weapon aliases and saved-loadout verification. Equipment already granted by the mission remains carried and may appear as ACE's unique inventory items; this is not a global inventory/looting ban. Custom arsenal replacements or mods bypassing ACE's standard display need their own adapters and testing.

## Remote execution

If a mission supplies a restrictive whitelist, merge these into its existing Functions list:

```cpp
class CSR_fnc_request {allowedTargets = 2; jip = 0;};
class CSR_fnc_receive {allowedTargets = 0; jip = 0;};
class CSR_fnc_applyRank {allowedTargets = 0; jip = 0;};
class CSR_fnc_applyRole {allowedTargets = 0; jip = 0;};
class CSR_fnc_forceSwitchRespawn {allowedTargets = 0; jip = 0;};
class CSR_fnc_applyPolicy {allowedTargets = 0; jip = 1;};
```

All client effects accept only server-originated calls. Policy is replayed to joining clients; other effects are non-JIP. Helpers are server-local and must not be remotely whitelisted. CSR cannot override an arbitrary mission's restrictive whitelist; check its RPT if requests time out.

See **API.md** for schema/API v5 and **VALIDATION.md** for executed tests and remaining client acceptance.
