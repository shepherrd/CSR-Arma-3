// Internal session assignment. Caller must validate eligibility/capacity.
if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {false};
params ["_uid","_division","_role",["_actor","session"]];
private _roles = localNamespace getVariable "CSR_roles";
private _before = [_uid] call CSR_fnc_getRole;
if !([_uid,_division,_actor] call CSR_fnc_setActive) exitWith {false};
if (_before isEqualTo [_division,_role]) exitWith {true};
_roles set [_uid,[_division,_role]];
[_actor,"role:"+_uid,_before,[_division,_role]] call CSR_fnc_audit;
["CSR_roleChanged",[_uid,_division,_role,_actor]] call CBA_fnc_localEvent;
true
