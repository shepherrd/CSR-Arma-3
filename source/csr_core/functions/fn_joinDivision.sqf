if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {[false,"Server-local API only.",[]]};
params ["_unit","_id","_expectedMode",["_role",""]];
if !(_id isEqualType "" && {_expectedMode isEqualType ""} && {_role isEqualType ""}) exitWith {[false,"Invalid division or role selection.",[]]};
if (localNamespace getVariable ["CSR_readOnly",true]) exitWith {[false,"Storage is read-only.",[]]};
private _uid = getPlayerUID _unit;
private _m = [_uid] call CSR_fnc_getMembership;
private _mode = localNamespace getVariable ["CSR_mode","pending"];
if !(_id isEqualType "" && {_m isNotEqualTo []} && {_id in (_m # 1)}) exitWith {[false,"You are not eligible for this division.",[]]};
if (_mode != _expectedMode) exitWith {[false,"Mission mode changed. Refresh and confirm again.",[]]};
private _switches = localNamespace getVariable "CSR_switches";
if (_uid in _switches) exitWith {[false,"A respawn is already pending.",[]]};
if (_mode != "full") exitWith {
    if (_role != "") exitWith {[false,"Roles are available in Full Integration only.",[]]};
    if (_id == (_m # 2)) exitWith {[false,"This division is already active.",[]]};
    [_uid,_id,_uid] call CSR_fnc_setActive;
    call CSR_fnc_persist;
    [true,"Active division updated.",[]]
};
if (!alive _unit) exitWith {[false,"Complete your current respawn before selecting a role.",[]]};
private _available = [_uid,_id,_role] call CSR_fnc_roleAvailable;
if !(_available # 0) exitWith {[false,_available # 1,[]]};
if (([_uid] call CSR_fnc_getRole) isEqualTo [_id,_role]) exitWith {[false,"This division and role are already active.",[]]};
// Reserve before dispatching respawn. Requests execute unscheduled on the server.
_switches set [_uid,[_id,_unit,owner _unit,diag_tickTime,_role]];
(localNamespace getVariable "CSR_switchBodies") set [netId _unit,diag_tickTime+30];
[_unit,_uid] remoteExecCall ["CSR_fnc_forceSwitchRespawn",owner _unit];
[true,"Division and role reserved; awaiting mission respawn.",[]]
