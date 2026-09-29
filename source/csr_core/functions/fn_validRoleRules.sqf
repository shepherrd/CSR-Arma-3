params ["_registry"];
private _valid = true;
private _commandDivision = "";
private _known = (call CSR_fnc_roleTable) apply {_x # 0};
{
    private _division = _x # 0;
    private _rules = _x param [5,[]];
    if !(_rules isEqualType [] && {count _rules <= count _known}) exitWith {_valid=false;};
    private _seen = [];
    {
        if !(_x isEqualType [] && {count _x == 2}) exitWith {_valid=false;};
        _x params ["_role","_cap"];
        if !(_role isEqualType "" && {_role in _known} && {!(_role in _seen)} && {_cap isEqualType 0} && {finite _cap} && {_cap == floor _cap} && {_cap == -1 || {_cap > 0 && {_cap <= 10000}}}) exitWith {_valid=false;};
        _seen pushBack _role;
        if (_role == "command") then {
            if (_division == (_registry # 1) || {_commandDivision != ""}) then {_valid=false;};
            _commandDivision = _division;
        };
    } forEach _rules;
    if (!_valid) exitWith {};
    if (_division == (_registry # 1) && {_rules findIf {(_x # 0) == "rifleman" && {(_x # 1) == -1}} < 0}) exitWith {_valid=false;};
} forEach (_registry # 3);
_valid
