if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {};
if (localNamespace getVariable ["CSR_readOnly",true] || {(localNamespace getVariable ["CSR_mode","pending"]) != "full"}) exitWith {};
params ["_unit","_uid"];
if (isNull _unit || {!alive _unit} || {!isPlayer _unit}) exitWith {};
private _role = [_uid] call CSR_fnc_getRole;
if (_role isEqualTo []) exitWith {};
private _table = call CSR_fnc_roleTable;
private _i = _table findIf {(_x # 0) == (_role # 1)};
if (_i < 0) exitWith {};
private _p = _table # _i;
[_unit,_uid,_p # 4] call CSR_fnc_syncCurator;
private _wrong = (_unit getVariable ["ace_medical_medicClass",-1]) != (_p # 2)
    || {(_unit getVariable ["ACE_isEngineer",-1]) != (_p # 3)}
    || {(_unit getUnitTrait "medic") != ((_p # 2)>0)}
    || {(_unit getUnitTrait "engineer") != ((_p # 3)>0)}
    || {(_unit getVariable ["CSR_activeRole",""]) != (_role # 1)};
if (!_wrong) exitWith {};
private _requests = localNamespace getVariable "CSR_roleRequests";
private _key = format ["%1:%2:%3",netId _unit,owner _unit,_role # 1];
if (diag_tickTime < (_requests getOrDefault [_key,-1])) exitWith {};
_requests set [_key,diag_tickTime+3];
if (local _unit) then {
    [{_this call CSR_fnc_applyRole;},[_unit,_uid,_role # 1]] call CBA_fnc_execNextFrame;
} else {[_unit,_uid,_role # 1] remoteExecCall ["CSR_fnc_applyRole",owner _unit];};
