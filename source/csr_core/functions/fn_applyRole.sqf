// Unit traits need locality. Only the server may direct this sink.
if ((isRemoteExecuted && {remoteExecutedOwner != 2 || {isRemoteExecutedJIP}}) || {!isRemoteExecuted && {!isServer}}) exitWith {};
params [["_unit",objNull,[objNull]],["_uid","",[""]],["_role","",[""]]];
if (isNull _unit || {!local _unit} || {!alive _unit} || {!isPlayer _unit} || {getPlayerUID _unit != _uid}) exitWith {};
private _table = call CSR_fnc_roleTable;
private _i = _table findIf {(_x # 0) == _role};
if (_i < 0) exitWith {};
private _preset = _table # _i;
_unit setUnitTrait ["medic",(_preset # 2)>0];
_unit setUnitTrait ["engineer",(_preset # 3)>0];
_unit setVariable ["ace_medical_medicClass",_preset # 2,true];
_unit setVariable ["ACE_isEngineer",_preset # 3,true];
_unit setVariable ["CSR_activeRole",_role,true];
