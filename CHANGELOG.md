# 0.7.1

- Fixes Home/Admin remaining at Contacting server after the role update. Role occupancy queries accidentally inherited the numeric request token as an excluded UID, aborting server replies.
- Explicitly supplies empty arguments when building all-player slot counts and safely handles malformed/inherited exclusion arguments.
- Keeps valid self-exclusion during role capacity checks. No persistence schema, API shape, gameplay policy or UI change.
- Adds 29 passing dedicated-server request-dispatch regression checks. Replace csr_core.pbo on server/clients and restart; saved data requires no reset.

# 0.7.0

- Adds Full Integration division roles: Command Staff, Rifleman, Pioneer, Combat Lifesaver, Medic and Pilot. Admins configure enabled roles and per-role limits under Division Admin → Roles / Slots.
- Reserves accepted role joins server-side before the confirmed mission respawn. Same-division role changes use the same confirmation. All roles retain the division's shared ACE Arsenal list.
- Default always offers unlimited Rifleman; new connections/reconnects start there. Ordinary death retains a valid role. Disabled, revoked or over-cap roles fall back to Default/Rifleman on actual death or respawn completion; living occupants and unconscious players are not ejected.
- Command Staff can be configured in one eligible-only non-Default division and receives unrestricted Zeus. Pioneer grants advanced engineer, Combat Lifesaver grants medic, and Medic grants doctor training. Full Integration controls those traits and Zeus assignment; Compatibility leaves mission role systems alone.
- Shows offered roles and occupied/reserved counts in Units, with the current role on Home and Service Record. Adds admin Off/Unlimited/numeric limit controls.
- API v5 appends role rules to definitions and live role/occupancy fields to expanded replies; original personnel row/legacy reads remain unchanged. Adds roleRules administration and server-local role reads. Old Full Join clients must supply a role ID.
- Migrates schemas 1–4 to schema 5 while preserving personnel, ranks, counters, audit, equipment, logos and memberships. Role limits persist with the registry; selected roles/reservations are session-only. No storage DLL or new third-party dependency.
- Adds server-originated CSR_fnc_applyRole to restrictive mission whitelists. Core/UI PBOs must be updated together; schema rollback requires a pre-upgrade server-profile backup.

# 0.6.2

- Adds an administrator Division Logo / Insignia dropdown with named thumbnails, a live preview and None.
- Uses CfgUnitInsignia from the game, loaded addons and current mission; mission classes override matching addon classes. Resolves mission texture paths on each client.
- Displays division logos in Home cards, the active personnel card, Units list/details and the admin division list. Preserves the image aspect ratio.
- Saves the class ID with the stable division definition. Renames and legacy save calls preserve the logo; an unavailable saved class is retained with a fallback icon.
- API v4 appends insigniaClass to division definitions and accepts an optional sixth saveDefinition argument. Existing personnel read formats, field indices and legacy five-argument saves remain supported.
- Migrates storage schemas 1–3 to schema 4; existing divisions start with no logo. Back up the stopped server profile before upgrading. Update core and UI together.

# 0.6.1

- Replaces the dark utility-style UI with a Cascadian personnel portal: forest-green header, mountain banner, pale background and white panels.
- Adds persistent Home, Service Record and Units navigation. Service Record contains career/mission combat statistics; Units opens the division browser.
- Home shows real name/rank/active division/UID and a four-division overview with direct View actions and View All.
- Removes the need for separate profile navigation; no announcements, tasks, applications or resources areas are added. Admin navigation appears only for authorized administrators.
- Applies the shared theme to personnel, division and eligibility administration, mode selection and Join confirmation.
- Opens both standalone and cTAB access at Home; cTAB's native hardware Home still returns to the cTAB desktop.
- Paces UI requests during rapid navigation and discards delayed requests from replaced pages.
- Includes bundled PAA artwork; no new mod dependency, persistence schema or server-policy change. Replace UI and tablet PBOs together and re-sign if needed.

# 0.6.0

- Combines personnel management with stable-ID division definitions, editable descriptions, multiple eligible divisions and one active division. Default retains its identity through renames.
- Adds a player division browser, eligible Join controls, membership editing from personnel or division, and pasted ACE item classname arrays. CSR no longer manages roles; old values remain available to legacy readers.
- Adds a one-time, server-authorized mission mode dialog. Full Integration applies division arsenals/rank synchronization and confirmed mission respawn on Join; Compatibility changes CSR records without taking over mission systems. Mode resets each mission.
- Adds optional `csr_arsenal.pbo`, using ACE display events and local restricted arsenal proxies. Exact active-division lists replace mission arsenal stock in Full mode; empty lists deny access.
- Reconnect/new mission starts at Default; ordinary respawn retains active division. Revoking eligibility retains active membership until the player leaves.
- Preserves profile storage and migrates schema 1/2 to schema 3 with personnel, ranks, statistics and audit retained. Existing assigned divisions become eligibility. New item lists start empty.
- API v3 retains legacy read shapes and name/rank edits; legacy writes may no longer mutate role or active division. Adds registry/membership APIs and server-authorized operations. See API.md.
- Adds remote-execution entries for server-originated mode policy and forced respawn. Excludes CSR-triggered switch deaths from CSR statistics.
- Built six PBOs and passed 42 dedicated-server API/migration checks plus nine persistence/restart checks. Client UI, respawn and arsenal acceptance remain outstanding; see VALIDATION.md.

# 0.5.0

- New players start in the persistent Default division; rank and role remain Unassigned.
- Added Manage Divisions to both interfaces: create empty divisions and rename divisions for all members, including offline players. Renaming the starting division updates future joins too.
- Added server-side registry validation, unique names, registry/member revision checks, bulk-edit audit and a division-change event.
- Automatically migrates schema 1 to schema 2 under the existing profile key, importing existing divisions and moving Unassigned division entries to Default without changing statistics.
- API v2 adds registry methods and admin operations while preserving the existing get/list/save reply formats. No new remote-execution whitelist entries.
- Update csr_core.pbo and csr_ui.pbo together. Back up the profile before upgrading; a downgrade requires restoring the pre-upgrade profile.

# 0.4.0

- Split CSR into an independent CBA-based roster core, shared standalone interface, optional cTAB integration and optional ACE statistics module.
- Added standalone access through Ctrl+Alt+R (configurable CBA keybind), with the same server-authorized admin screen, sorting and filters.
- Removed all cTAB/BCE/ACE dependencies from the core and shared UI; use native Arma fonts in the shared screen.
- Added documented server-local read/save APIs, client request callbacks with shared token allocation/cancellation/timeouts, and local personnel-save/ready events.
- Preserved profile storage keys/schema, personnel revisions, admin authorization, rank synchronization and existing statistics. The ACE module is required to collect new combat statistics.
- New packaging requires replacing the old core/tablet PBOs and adding `csr_ui.pbo` plus optional `csr_stats_ace.pbo`. Do not load old and new copies together.

# 0.3.0

- Added roster sorting by division/rank/name (default), name, rank, or role. Rank order follows the full approved hierarchy.
- Added name/Steam UID search, combinable division/rank/role filters, visible/total counts and a CLEAR button.
- Preserves unsaved editor fields during search, sorting and filtering, including records hidden by the current filters.
- Division and role filter choices are populated from saved records and updated after saving. Admins create a division by saving a new Division field value.
- Wider roster list and entry tooltips show division, role and UID. Tablet UI update only; storage and server permissions are unchanged.
- Passed 17 in-engine sorting/filtering assertions and engine compilation of all 21 shipped SQF files. Revised UI rendering and interactions still need client testing.

# 0.2.2

- The tablet's built-in Home button now closes Service Record and Personnel Administration and returns to the main cTAB desktop, preserving cTAB's existing Home action.
- Removed the extra DESKTOP button from the app. The Service Record launcher is hidden while the app is open and restored when it closes.
- Tablet UI update only. Replace `csr_tablet.pbo` and re-sign it if needed.

# 0.2.1

- Replaced the large top-right Service Record button with a native cTAB-style clickable profile icon directly below BCE's clipboard app.
- Matches the clipboard's dimensions and the spacing between the existing app icons. Uses Arma's built-in profile texture and the cTAB active-icon control.
- Tablet UI update only; core, rank behavior and stored records are unchanged. Replace `csr_tablet.pbo` and re-sign it if needed.

# 0.2.0

- Added the approved 22-rank hierarchy to the personnel editor as a dropdown, including 1LT, WO1–WO5, and CDT (Cadet).
- Added server-directed engine-rank synchronization on join, respawn, save and subsequent drift/locality changes, with bounded retries.
- Preserves existing rating when setting engine rank. Name and ACE-name prefixes are not applied.
- Maps detailed community ranks to seven engine ranks; retains Unassigned as a no-override state.
- Validates selected ranks on the server, resolves familiar older rank labels and preserves unknown legacy records until explicitly edited.
- Storage schema and career totals remain compatible with 0.1.0.
- Adds `CSR_fnc_applyRank` to the remote-execution whitelist; missions with their own whitelist must include it.
- Passed 37 in-engine rank assertions and engine compilation of all addon scripts. Client/server gameplay acceptance remains pending. Build remains unsigned.
