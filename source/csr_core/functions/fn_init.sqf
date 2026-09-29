if (!isServer || {isRemoteExecuted}) exitWith {};
if (localNamespace getVariable ["CSR_initialized",false]) exitWith {};
private _previous = profileNamespace getVariable ["CSR_store_v1",[1,[],[]]];
private _data = [_previous] call CSR_fnc_upgradeStore;
private _valid = !(_data isEqualTo []) && {[_data] call CSR_fnc_validStore};
localNamespace setVariable ["CSR_readOnly",!_valid];
if (!_valid) then {
    diag_log "[CSR] Invalid storage; writes disabled and original profile preserved.";
    _data = [5,[],[],[0,"div_1",2,[["div_1","Default","",[],"",[["rifleman",-1]]]]],[]];
};
private _roster = createHashMap;
{_roster set [_x # 0,+_x];} forEach (_data # 1);
private _members = createHashMap;
{_members set [_x # 0,+_x];} forEach (_data # 4);
localNamespace setVariable ["CSR_roster",_roster];
localNamespace setVariable ["CSR_members",_members];
localNamespace setVariable ["CSR_registry",+(_data # 3)];
localNamespace setVariable ["CSR_audit",+(_data # 2)];
{localNamespace setVariable [_x,createHashMap];} forEach ["CSR_session","CSR_identity","CSR_rate","CSR_connections","CSR_switches","CSR_switchBodies","CSR_roles","CSR_roleBodies","CSR_roleDeaths","CSR_roleRequests","CSR_curators"];
localNamespace setVariable ["CSR_mode","pending"];
localNamespace setVariable ["CSR_dirty",_valid && {!(_data isEqualTo _previous)}];
localNamespace setVariable ["CSR_adminUIDs",getArray (configFile >> "CSR_ServerPolicy" >> "adminUIDs")];
localNamespace setVariable ["CSR_initialized",true];
// Active division is session state; offline records also display Default for this mission.
{[_x,(_data # 3) # 1,"missionStart"] call CSR_fnc_setActive;} forEach keys _roster;
private _scan = {
    private _players = allPlayers - entities "HeadlessClient_F";
    {[_x] call CSR_fnc_register;} forEach _players;
    private _switches = localNamespace getVariable "CSR_switches";
    {
        private _uid = _x;
        private _pending = _switches get _uid;
        private _i = _players findIf {getPlayerUID _x == _uid};
        if (_i >= 0 && {alive (_players # _i)} && {!((_players # _i) isEqualTo (_pending # 1))}) then {
            [_players # _i,_pending # 1] call CSR_fnc_finishSwitch;
        } else {
            // Failed dispatch must not suppress a later real death or block retry forever.
            if (alive (_pending # 1) && {diag_tickTime > (_pending # 3)+30}) then {
                _switches deleteAt _uid;
                (localNamespace getVariable "CSR_switchBodies") deleteAt netId (_pending # 1);
                diag_log format ["[CSR] Respawn dispatch did not complete for %1; pending switch cleared.",_uid];
            };
        };
    } forEach keys _switches;
};
call _scan;
[_scan,3] call CBA_fnc_addPerFrameHandler;
[{call CSR_fnc_persist;},30] call CBA_fnc_addPerFrameHandler;
addMissionEventHandler ["EntityRespawned",{
    params ["_new","_old"];
    [_new,_old] call CSR_fnc_finishSwitch;
    [_new] call CSR_fnc_register;
}];
addMissionEventHandler ["EntityKilled",{[_this # 0] call CSR_fnc_roleDied;}];
addMissionEventHandler ["EntityCreated",{
    if ((localNamespace getVariable ["CSR_mode","pending"]) == "full") then {
        [{
            params ["_entity"];
            if (isNull _entity || {_entity in allCurators}) exitWith {};
            private _curators = localNamespace getVariable "CSR_curators";
            {private _logic = _curators get _x; if (!isNull _logic) then {_logic addCuratorEditableObjects [[_entity],true];};} forEach keys _curators;
        },[_this]] call CBA_fnc_execNextFrame;
    };
}];
addMissionEventHandler ["HandleDisconnect",{
    params ["_unit","_id","_uid"];
    (localNamespace getVariable "CSR_connections") deleteAt _uid;
    (localNamespace getVariable "CSR_switches") deleteAt _uid;
    (localNamespace getVariable "CSR_roles") deleteAt _uid;
    (localNamespace getVariable "CSR_roleBodies") deleteAt _uid;
    [_unit,_uid,false] call CSR_fnc_syncCurator;
    [_uid,(localNamespace getVariable "CSR_registry") # 1,"disconnect"] call CSR_fnc_setActive;
    call CSR_fnc_persist;
    false
}];
addMissionEventHandler ["Ended",{call CSR_fnc_persist;}];
addMissionEventHandler ["MPEnded",{call CSR_fnc_persist;}];
call CSR_fnc_persist;
["CSR_rosterReady",[]] call CBA_fnc_localEvent;
diag_log format ["[CSR] API v5 ready. %1 records; awaiting mission mode.",count _roster];
