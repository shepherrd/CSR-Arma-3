if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {[false,"Server-local API only.",[]]};
params [["_args",[],[[]]],["_actor","server",[""]]];
if (localNamespace getVariable ["CSR_readOnly",true]) exitWith {[false,"Storage is read-only.",[]]};
if (count _args != 3) exitWith {[false,"Invalid role configuration.",[]]};
_args params ["_id","_rules","_revision"];
if !(_id isEqualType "" && {_rules isEqualType []} && {_revision isEqualType 0}) exitWith {[false,"Invalid role fields.",[]]};
private _r = call CSR_fnc_getRegistry;
if (_revision != (_r # 0)) exitWith {[false,"Divisions changed. Reload before saving.",[]]};
private _i = (_r # 3) findIf {(_x # 0) == _id};
if (_i < 0) exitWith {[false,"Division not found.",[]]};
private _before = +((_r # 3 # _i) # 5);
(_r # 3 # _i) set [5,+_rules];
if !([_r] call CSR_fnc_validRoleRules) exitWith {[false,"Use valid role limits. Default requires unlimited Riflemen. Command Staff may be offered by only one non-Default division.",[]]};
_r set [0,(_r # 0)+1];
localNamespace setVariable ["CSR_registry",_r];
[_actor,"divisionRoles:"+_id,_before,_rules] call CSR_fnc_audit;
call CSR_fnc_persist;
["CSR_registryChanged",[call CSR_fnc_getRegistry,_id,_actor]] call CBA_fnc_localEvent;
// Existing live occupants keep their assignment/permissions until death or a voluntary switch.
[true,"Role limits saved. Existing occupants are rechecked on death.",[_id]]
