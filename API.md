# Community Service Roster API v5

Depend on `CSR_Core` (CBA only). UI, cTAB, ACE statistics and ACE Arsenal are separate addons. `getNumber(configFile >> "CSR_RosterAPI" >> "version")` returns 5.

## Compatibility

`getRecord`, `getRoster`, client `get/list`, and the 12-field personnel row keep their original shapes:

`[uid,name,rankLabel,legacyRole,activeDivisionName,enemyAI,enemyPlayers,friendly,civilian,deaths,revision,lastSeenUTC]`

Field 3 is deprecated, preserved legacy data; new records use Unassigned. It has no role/arsenal meaning. Field 4 always resolves the active division's current name. Use IDs for new integrations.

Legacy `saveRecord` / client `save/personnel` still accept `[uid,name,rank,role,division,revision]` but **reject changes to role or active division**, with a v3 migration message. Existing consumers may edit name/rank while echoing the current deprecated fields. New records through this adapter must use Unassigned role and the current Default name. A legacy write cannot silently grant membership or create a division.

`getDivisions` still projects `[registryRevision,defaultName,names]`. Legacy `saveDivision` / client `division` retain create/rename arguments `[oldName,newName,revision]` and return `[ok,message,[rows,legacyMetadata]]`, preserving descriptions/equipment/memberships/logos/role rules.

## Server-local functions

All data access uses independent snapshots. Calls from clients return empty/failure; remote calls are rejected except within the private context of the authorized request dispatcher. Never whitelist these helpers.

```sqf
private _row = ["76561198000000001"] call CSR_fnc_getRecord;
private _rows = call CSR_fnc_getRoster;
private _registry = call CSR_fnc_getRegistry;
private _member = ["76561198000000001"] call CSR_fnc_getMembership;
```

Registry:
`[revision,defaultDivisionID,nextIDNumber,definitions]`

Definition:
`[id,displayName,description,itemClassnames,insigniaClass,roleRules]`

Membership:
`[uid,eligibleDivisionIDs,activeDivisionID]`

Default is always included in eligibility. Active may be absent from eligibility following revocation; that is a deliberate grandfathered state.

```sqf
// Explicit personnel + eligibility update. revision -1 creates an offline person.
private _result = [[
    "76561198000000001","Example","SGT",["div_1","div_2"],-1,_registry # 0
],"my-server-mod"] call CSR_fnc_updatePerson;

// Empty ID creates a division. Existing ID edits it in place.
private _result = [[
    "","Infantry","Division description",["ItemMap","ItemCompass"],_registry # 0
],"my-server-mod"] call CSR_fnc_saveDefinition;
```

updatePerson returns `[ok,message,row]`. It validates UID/name/rank, exact personnel and registry revisions, eligible IDs, and always includes Default. It preserves legacy role, active ID, statistics, and lastSeen. New personnel start in Default. It cannot edit combat totals.

saveDefinition returns `[ok,message,[savedID]]`. It rejects stale revisions, duplicate/invalid names and malformed item lists. It allocates stable IDs, never reuses names as identity, deduplicates equipment, and warns about unloaded classnames without deleting them. Empty equipment is valid and denies access. Names are 1–64 characters; descriptions up to 2048; equipment up to 10,000 classnames of 1–256 characters. The UI array-text field is limited to 262,144 characters.

Server-local `[_mode,actor] call CSR_fnc_setMode` selects full/compatibility once per mission. Player switching should go through the Join request/UI to retain permission and confirmation checks. Internal setActive/register/finishSwitch helpers are not permission-granting APIs for other mods.

## Insignia extension (v4)

Definitions append insigniaClass at index 4; indices 0–3 keep their meanings. Update consumers that enforce an exact four-field definition length. The 12-field personnel row and legacy metadata formats are unchanged.

saveDefinition/client definition accept either five original arguments or six: `[id,name,description,items,registryRevision,insigniaClass]`. Omitting the final field preserves an existing logo (or uses None when creating); empty string explicitly clears it. New nonempty selections must resolve on the server. An unchanged previously saved class may remain even when its addon is absent. Paths, procedural texture strings and non-string values are rejected. Logo saves use the same admin authorization, revision checks, persistence and audit as other division fields.

These read-only configuration helpers work locally on both server and clients (unlike the roster storage APIs):

- `[className] call CSR_fnc_insignia` returns `[canonicalClassName,displayName,texturePath]`, or `[]` for None/unavailable. Mission config takes precedence over addon config; relative mission paths resolve on the calling machine.
- `call CSR_fnc_insigniaList` returns available entries sorted by name, without duplicate class IDs or textureless classes.
- `[value] call CSR_fnc_validInsigniaID` checks class ID syntax; it does not require the class to be installed. This allows persistent data to survive modset changes.

Public registry replies retain insigniaClass while stripping equipment lists. No new remote-execution whitelist entries are needed. `CSR_RosterAPI >> divisionInsignia` is 1.


## Role extension (v5)

Definition index 5 is now roleRules: an array of [roleID,maximumPlayers]. Known IDs are command, rifleman, pioneer, lifesaver, medic and pilot. Omit a role to disable it; -1 is unlimited; otherwise the cap must be an integer from 1 to 10,000. Duplicate/unknown roles are rejected. Default requires ["rifleman",-1]; command is permitted in at most one non-Default division.

Five/six-argument saveDefinition and legacy saveDivision preserve existing roleRules. Newly created divisions receive [["rifleman",-1]]. Consumers requiring an exact five-element definition must update.

Server-local API:

~~~sqf
private _assignment = ["76561198000000001"] call CSR_fnc_getRole;
// [] when no session assignment; otherwise [divisionID,roleID].
private _counts = [] call CSR_fnc_roleOccupancy;
// [[divisionID,roleID,assignedCount,reservedCount], ...]; zero rows may be omitted.
private _result = [[
    "div_2",[["rifleman",-1],["pioneer",2],["medic",1]],_registry # 0
],"my-server-mod"] call CSR_fnc_saveRoles;
// [ok,message,[divisionID]]; uses registry revision, audit, read-only checks and persistence.
~~~

call CSR_fnc_roleTable works locally on server or client and returns preset rows [id,label,medicLevel,engineerLevel,hasZeus,description]. CSR_RosterAPI >> divisionRoles is 1.

getRole/roleOccupancy read live server state; they do not reconstruct selected roles from the deprecated personnel field. roleRules saves may occur in either mode but affect gameplay only in Full Integration. Internal setRole, roleAvailable, roleDied, syncRole, syncCurator and finishSwitch are lifecycle helpers, not public permission-granting endpoints. Do not call or whitelist them for client use.

Full Join requires the roleID third argument. Old two-argument Full Join requests are rejected instead of guessing a privileged role. Compatibility/pending retains two-argument division Join; a nonempty roleID is rejected there. Existing own-row/get/list formats remain unchanged. state appends ownRole and roleOccupancy at indices 7 and 8 (both [] outside Full Integration); adminData and successful definition/updatePerson/roleRules replies append roleOccupancy at index 3.

Slots count the assigned role, including ordinary death/respawn and ACE unconsciousness, plus accepted target reservations. The caller's own entries are excluded during revalidation. Accepted joins reserve before respawn dispatch; commits recheck eligibility, rules and capacity. Removal/cap reduction does not eject living occupants. Death and respawn completion revalidate; invalid roles fall back to Default/rifleman. A configured Command Staff division can move while an old living occupant remains grandfathered.

CSR_activeRole is published on the live player unit for display purposes after permission application; the server session map is authoritative. This variable is not a permission-granting API. Medic/engineer effects are dispatched to the unit owner through server-originated CSR_fnc_applyRole. Zeus logic/assignment and slot accounting remain server-managed.

## Client API

```sqf
private _token = ["state",[],{
    params ["_token","_operation","_ok","_message","_payload"];
    // Runs locally on a later frame, outside remote-exec context.
}] call CSR_fnc_clientRequest;
```

Only token/op/data crosses the network. Identity comes from the request's network owner; clients cannot choose their caller UID. Callbacks have about a ten-second timeout; up to 32 can be pending. `[_token] call CSR_fnc_cancelRequest` drops a callback, not an already-submitted write. Server requests are rate-limited; status polling has its own bucket.

| Operation | Arguments | Successful payload | Access |
|---|---|---|---|
| state | [] | [ownRow,missionStats,isAdmin,publicRegistry,ownMembership,mode,switchPending,ownRole,roleOccupancy] | Player |
| status | [] | [isAdmin,mode] | Player |
| join | [divisionID,modeShownAtConfirmation,roleID?] | [] | Own eligible division |
| arsenal | [] | [mode,activeDivisionItems] | Own permissions |
| adminData | [] | [rows,registry,memberships,roleOccupancy] | Admin |
| updatePerson | [uid,name,rank,eligibleIDs,personnelRevision,registryRevision] | [rows,registry,memberships,roleOccupancy] | Admin |
| definition | [id,name,description,items,registryRevision,insigniaClass?] | [rows,registry,memberships,roleOccupancy] | Admin |
| roleRules | [divisionID,roleRules,registryRevision] | [rows,registry,memberships,roleOccupancy] | Admin |
| mode | [full or compatibility] | [selectedMode] | Admin, first accepted choice |
| get | [] | [ownRow,missionStats,isAdmin] | Player; legacy |
| list | [] | rows | Admin; legacy |
| roster | [] | [rows,legacyMetadata] | Admin; legacy |
| save | legacy six fields | row | Admin; legacy |
| personnel | legacy six fields | [row,legacyMetadata] | Admin; legacy |
| division | [oldName,newName,registryRevision] | [rows,legacyMetadata] | Admin; legacy |

PublicRegistry has the same structure as registry but equipment arrays are empty; request your current arsenal permissions separately. Empty public arrays are not evidence that admin equipment is unconfigured.

Mode is pending/full/compatibility. Pending uses Compatibility behavior. A Join confirmed under a different mode is rejected. Full Join validates current player/eligibility, allows one pending request, invokes a server-authorized local forceRespawn, then commits when the new body appears. Eligibility, role rules and capacity are rechecked at completion. In Full Integration, death revalidates roles and falls back to Default/rifleman if no longer valid; Compatibility retains division membership until leaving/reconnecting.

## Events and readiness

Server-local CBA events:
- CSR_rosterReady: [] after initialization.
- CSR_rosterChanged: [uid,rowSnapshot,actor] after personnel edits, active changes, and active-name renames.
- CSR_divisionsChanged: [legacyMetadata,oldName,newName,actor] for legacy consumers.
- CSR_registryChanged: [registrySnapshot,divisionID,actor].
- CSR_eligibilityChanged: [uid,eligibleIDs,actor].
- CSR_activeDivisionChanged: [uid,divisionID,actor].
- CSR_modeChanged: [mode,actor].
- CSR_roleChanged: [uid,divisionID,roleID,actor] after a session assignment changes.

Check `localNamespace getVariable ["CSR_initialized",false]` when initializing after rosterReady. Events do not publish the roster. Stats increments are not rosterChanged events.

## Persistence schema 5

Existing profile keys remain CSR_store_v1 and CSR_store_backup_v1:
`[5,rows,audit,registry,memberships]`

Schemas 1–4 are validated and migrated. Schema 5 is validated without remigration. All migrated divisions gain unlimited Rifleman rules; schema-4 logos are preserved. Schema 3 gains an empty insigniaClass for every definition; existing fields, eligibility, active IDs, equipment and audit are retained by migration. For schemas 1/2, existing assignment becomes eligibility plus Default; legacy fields, totals and audit survive. Each new mission resets all active IDs/displayed names to Default and increments affected personnel revisions. Role assignments/reservations reset per connection/mission and are not saved; division role rules are persistent. Mode is never saved as authoritative state; audit may record the choice historically.

Eligibility and registry changes are included in one snapshot with personnel, preserving stable references. Physical storage is the shared Arma server profile. Snapshot backup is in that same file. Invalid data disables writes and preserves the original profile; external stopped-server backups are necessary for rollback.

## Remote whitelist

```cpp
class CSR_fnc_request {allowedTargets = 2; jip = 0;};
class CSR_fnc_receive {allowedTargets = 0; jip = 0;};
class CSR_fnc_applyRank {allowedTargets = 0; jip = 0;};
class CSR_fnc_applyRole {allowedTargets = 0; jip = 0;};
class CSR_fnc_forceSwitchRespawn {allowedTargets = 0; jip = 0;};
class CSR_fnc_applyPolicy {allowedTargets = 0; jip = 1;};
```

receive/forceSwitchRespawn/applyRank/applyRole accept only server owner 2 and reject JIP effects. applyPolicy accepts server-originated JIP to inform joining clients of the current session choice. The core does not depend on ACE or cTAB.
