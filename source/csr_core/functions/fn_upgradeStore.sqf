params ["_data"];
if !([_data] call CSR_fnc_validStore) exitWith {[]};
if ((_data # 0) == 5) exitWith {+_data};
if ((_data # 0) in [3,4]) exitWith {
    private _result = +_data;
    _result set [0,5];
    {if ((_data # 0) == 3) then {_x pushBack "";}; _x pushBack [["rifleman",-1]];} forEach (_result # 3 # 3);
    if ([_result] call CSR_fnc_validStore) then {_result} else {[]}
};
private _rows = +(_data # 1);
private _names = ["Default"];
private _default = "Default";
private _rev = 0;
if ((_data # 0) == 2) then {
    (_data # 3) params ["_r","_d","_n"];
    _rev = _r; _default = _d; _names = +_n;
} else {
    {
        private _name = [_x # 4] call CSR_fnc_divisionName;
        if (toLower _name == "unassigned") then {_name = "Default";};
        if (_name == "") exitWith {_names = [];};
        private _i = _names findIf {toLower _x == toLower _name};
        if (_i < 0) then {_names pushBack _name;} else {_name = _names # _i;};
        if ((_x # 4) != _name) then {_x set [4,_name]; _x set [10,(_x # 10)+1];};
    } forEach _rows;
};
if (_names isEqualTo []) exitWith {[]};
private _defs = [];
{_defs pushBack [format ["div_%1",_forEachIndex+1],_x,"",[],"",[["rifleman",-1]]];} forEach _names;
private _defaultID = (_defs # (_names find _default)) # 0;
private _members = _rows apply {
    [_x # 0, [_defaultID,(_defs # (_names find (_x # 4))) # 0] arrayIntersect [_defaultID,(_defs # (_names find (_x # 4))) # 0],(_defs # (_names find (_x # 4))) # 0]
};
private _result = [5,_rows,+(_data # 2),[_rev,_defaultID,count _defs+1,_defs],_members];
if ([_result] call CSR_fnc_validStore) then {_result} else {[]}
