// Resolve locally so mission-relative texture paths use this machine's mission.
// Return [class ID, display name, texture], or [] for unavailable/None.
params [["_id",""]];
if (_id isEqualTo "" || {!([_id] call CSR_fnc_validInsigniaID)}) exitWith {[]};
private _cfg = missionConfigFile >> "CfgUnitInsignia" >> _id;
private _mission = isClass _cfg;
if (!_mission) then {_cfg = configFile >> "CfgUnitInsignia" >> _id;};
if (!isClass _cfg) exitWith {[]};
private _texture = getText (_cfg >> "texture");
if (_texture == "") exitWith {[]};
if (_mission && {(_texture select [0,1]) != "\"} && {(_texture select [0,1]) != "#"}) then {_texture = getMissionPath _texture;};
private _name = getText (_cfg >> "displayName");
if (_name select [0,1] == "$") then {_name = localize (_name select [1]);};
if (_name == "") then {_name = configName _cfg;};
[configName _cfg,_name,_texture]