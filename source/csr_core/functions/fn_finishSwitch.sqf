if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {};
if ((localNamespace getVariable ["CSR_mode","pending"]) != "full") exitWith {};
params ["_new","_old"];
private _uid = getPlayerUID _new;
if (_uid == "") then {_uid = (localNamespace getVariable "CSR_identity") getOrDefault [netId _old,""];};
if (_uid == "") exitWith {};
[_old] call CSR_fnc_roleDied;
private _switches = localNamespace getVariable "CSR_switches";
private _pending = _switches getOrDefault [_uid,[]];
if !(_pending isEqualTo [] || {(_pending # 1) isEqualTo _old}) exitWith {};
private _default = (localNamespace getVariable "CSR_registry") # 1;
if !(_pending isEqualTo []) then {
    _switches deleteAt _uid;
    if (([_uid,_pending # 0,_pending # 4] call CSR_fnc_roleAvailable) # 0) then {
        [_uid,_pending # 0,_pending # 4,_uid] call CSR_fnc_setRole;
    } else {[_uid,_default,"rifleman","cancelledRoleJoin"] call CSR_fnc_setRole;};
} else {
    private _role = [_uid] call CSR_fnc_getRole;
    if (_role isEqualTo [] || {!(([_uid,_role # 0,_role # 1] call CSR_fnc_roleAvailable) # 0)}) then {
        [_uid,_default,"rifleman","respawnFallback"] call CSR_fnc_setRole;
    };
};
(localNamespace getVariable "CSR_roleBodies") set [_uid,_new];
call CSR_fnc_persist;
