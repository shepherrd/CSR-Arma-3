if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {[false,"Server-local API only.",[]]};
params [["_args",[],[[]]],["_actor","server",[""]]];
if (localNamespace getVariable ["CSR_readOnly",true]) exitWith {[false,"Storage is read-only.",[]]};
if !(count _args in [5,6]) exitWith {[false,"Invalid division.",[]]};
_args params ["_id","_name","_description","_items","_revision"];
if !(_id isEqualType "" && {_name isEqualType ""} && {_description isEqualType ""} && {count _description <= 2048} && {_items isEqualType []} && {count _items <= 10000} && {_revision isEqualType 0}) exitWith {[false,"Invalid division fields or size.",[]]};
_name = [_name] call CSR_fnc_divisionName;
if (_name == "") exitWith {[false,"Division name must contain 1-64 printable characters.",[]]};
if (_items findIf {!(_x isEqualType "") || {count _x < 1} || {count _x > 256} || {(toArray _x) findIf {!(_x in ([45,46,95] + [48,49,50,51,52,53,54,55,56,57])) && {!(_x >= 65 && {_x <= 90})} && {!(_x >= 97 && {_x <= 122})}} >= 0}} >= 0) exitWith {[false,"Equipment must be an array of item classnames.",[]]};
private _r = call CSR_fnc_getRegistry;
if (_revision != (_r # 0)) exitWith {[false,"Divisions changed. Reload before saving.",[]]};
private _defs = _r # 3;
private _i = _defs findIf {(_x # 0) == _id};
if (_id != "" && {_i < 0}) exitWith {[false,"Division not found.",[]]};
if (_defs findIf {toLower (_x # 1) == toLower _name && {(_x # 0) != _id}} >= 0) exitWith {[false,"That division name already exists.",[]]};
private _before = if (_i < 0) then {[]} else {+(_defs # _i)};
// Older callers omit the logo and must preserve the existing choice.
private _logo = if (count _args == 6) then {_args # 5} else {_before param [4,""]};
if !([_logo] call CSR_fnc_validInsigniaID) exitWith {[false,"Choose an insignia class or None; texture paths are not accepted.",[]]};
if (_logo != "" && {_logo != (_before param [4,""])} && {([_logo] call CSR_fnc_insignia) isEqualTo []}) exitWith {[false,"That insignia is not available on the server. Load its addon on the server too.",[]]};
if (_i < 0) then {
    _id = format ["div_%1",_r # 2];
    while {_defs findIf {(_x # 0) == _id} >= 0} do {_r set [2,(_r # 2)+1]; _id = format ["div_%1",_r # 2];};
    _r set [2,(_r # 2)+1];
    _i = count _defs;
};
private _entry = [_id,_name,_description,_items arrayIntersect _items,_logo,+(_before param [5,[["rifleman",-1]]])];
_defs set [_i,_entry];
_r set [0,(_r # 0)+1];
localNamespace setVariable ["CSR_registry",_r];
private _roster = localNamespace getVariable "CSR_roster";
{
    private _m = [_x] call CSR_fnc_getMembership;
    private _row = _roster get _x;
    if ((_m # 2) == _id && {(_row # 4) != _name}) then {
        _row set [4,_name]; _row set [10,(_row # 10)+1];
        ["CSR_rosterChanged",[_x,+_row,_actor]] call CBA_fnc_localEvent;
    };
} forEach keys _roster;
[_actor,"division",_before,_entry] call CSR_fnc_audit;
call CSR_fnc_persist;
["CSR_divisionsChanged",[call CSR_fnc_getDivisions,if (_before isEqualTo []) then {""} else {_before # 1},_name,_actor]] call CBA_fnc_localEvent;
["CSR_registryChanged",[call CSR_fnc_getRegistry,_id,_actor]] call CBA_fnc_localEvent;
private _missing = _items select {!(isClass(configFile >> "CfgWeapons" >> _x) || {isClass(configFile >> "CfgMagazines" >> _x)} || {isClass(configFile >> "CfgVehicles" >> _x)} || {isClass(configFile >> "CfgGlasses" >> _x)})};
[true,if (_missing isEqualTo []) then {"Division saved."} else {format ["Division saved. %1 classnames are absent from this server's modset; retained for other missions.",count _missing]},[_id]]
