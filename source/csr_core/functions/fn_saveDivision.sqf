// v2 rename/create adapter; never edits membership or equipment.
if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {[false,"Server-local API only.",[]]};
params [["_args",[],[[]]],["_actor","server",[""]]];
if (count _args != 3) exitWith {[false,"Invalid arguments.",[]]};
_args params ["_old","_new","_rev"];
if !(_old isEqualType "" && {_new isEqualType ""}) exitWith {[false,"Invalid name.",[]]};
private _defs = (call CSR_fnc_getRegistry) # 3;
private _i = _defs findIf {toLower (_x # 1) == toLower _old};
if (_old != "" && {_i < 0}) exitWith {[false,"Division not found.",[]]};
private _d = if (_i < 0) then {["","","",[]]} else {_defs # _i};
private _result = [[_d # 0,_new,_d # 2,_d # 3,_rev],_actor] call CSR_fnc_saveDefinition;
if (_result # 0) then {_result set [2,[call CSR_fnc_getRoster,call CSR_fnc_getDivisions]];};
_result
