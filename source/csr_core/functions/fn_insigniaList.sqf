// Installed game/mod insignias plus this mission's definitions, sorted by name.
private _ids = [];
{
    {_ids pushBackUnique toLower configName _x;} forEach ("true" configClasses (_x >> "CfgUnitInsignia"));
} forEach [configFile,missionConfigFile];
private _rows = [];
{
    private _entry = [_x] call CSR_fnc_insignia;
    if !(_entry isEqualTo []) then {_rows pushBack [toLower (_entry # 1),_entry # 0,_entry];};
} forEach _ids;
_rows sort true;
_rows apply {_x # 2}
