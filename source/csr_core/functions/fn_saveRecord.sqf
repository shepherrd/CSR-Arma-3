// v1/v2 adapter. Identity/rank edits remain supported; deprecated fields are read-only.
if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {[false,"Server-local API only.",[]]};
params [["_args",[],[[]]],["_actor","server",[""]]];
if (count _args != 6) exitWith {[false,"Invalid record.",[]]};
_args params ["_uid","_name","_rank","_role","_division","_rev"];
if !(_uid isEqualType "" && {_role isEqualType ""} && {_division isEqualType ""}) exitWith {[false,"Invalid legacy fields.",[]]};
private _old = [_uid] call CSR_fnc_getRecord;
private _r = call CSR_fnc_getRegistry;
if (_r isEqualTo []) exitWith {[false,"Roster unavailable.",[]]};
private _expectedRole = if (_old isEqualTo []) then {"Unassigned"} else {_old # 3};
private _expectedDivision = if (_old isEqualTo []) then {(call CSR_fnc_getDivisions) # 1} else {_old # 4};
if (_role != _expectedRole || {_division != _expectedDivision}) exitWith {[false,"API v3: role is retired; use updatePerson for eligibility and Join for active division.",[]]};
private _m = [_uid] call CSR_fnc_getMembership;
[[_uid,_name,_rank,if (_m isEqualTo []) then {[_r # 1]} else {_m # 1},_rev,_r # 0],_actor] call CSR_fnc_updatePerson
