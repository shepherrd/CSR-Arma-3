if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {false};
params ["_uid","_id",["_actor","session"]];
private _registry = localNamespace getVariable "CSR_registry";
private _defs = _registry # 3;
private _i = _defs findIf {(_x # 0) == _id};
private _row = (localNamespace getVariable "CSR_roster") getOrDefault [_uid,[]];
private _member = (localNamespace getVariable "CSR_members") getOrDefault [_uid,[]];
if (_i < 0 || {_row isEqualTo []} || {_member isEqualTo []}) exitWith {false};
if ((_member # 2) == _id && {(_row # 4) == ((_defs # _i) # 1)}) exitWith {true};
private _before = [_member # 2];
_member set [2,_id];
_row set [4,(_defs # _i) # 1];
_row set [10,(_row # 10)+1];
[_actor,_uid,_before,[_id]] call CSR_fnc_audit;
["CSR_rosterChanged",[_uid,+_row,_actor]] call CBA_fnc_localEvent;
["CSR_activeDivisionChanged",[_uid,_id,_actor]] call CBA_fnc_localEvent;
true
