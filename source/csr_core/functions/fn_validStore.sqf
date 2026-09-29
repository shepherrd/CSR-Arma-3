// Earlier schemas are retained solely for one-time migration.
params ["_data"];
if !(_data isEqualType [] && {count _data in [3,4,5]}) exitWith {false};
_data params ["_v","_rows","_audit"];
if !(_v in [1,2,3,4,5] && {_rows isEqualType []} && {_audit isEqualType []} && {count _data == ([3,4,5,5,5] # (_v-1))}) exitWith {false};
private _ok = true;
private _uids = [];
{
    if !(_x isEqualType [] && {count _x == 12}) exitWith {_ok = false;};
    if ((_x select [0,5]) findIf {!(_x isEqualType "")} >= 0) exitWith {_ok = false;};
    if ((_x select [5,6]) findIf {!(_x isEqualType 0) || {!finite _x} || {_x < 0} || {_x != floor _x}} >= 0) exitWith {_ok = false;};
    if !((_x # 11) isEqualType [] && {(_x # 0) != ""} && {!((_x # 0) in _uids)}) exitWith {_ok = false;};
    _uids pushBack (_x # 0);
} forEach _rows;
if (!_ok || {_v == 1}) exitWith {_ok};
private _meta = _data # 3;
if !(_meta isEqualType [] && {count _meta == (if (_v == 2) then {3} else {4})}) exitWith {false};
_meta params ["_rev","_default"];
if !(_rev isEqualType 0 && {finite _rev} && {_rev >= 0} && {_rev == floor _rev} && {_default isEqualType ""}) exitWith {false};
if (_v == 2) exitWith {
    private _names = _meta # 2;
    if !(_names isEqualType [] && {_default in _names}) exitWith {false};
    private _keys = [];
    {
        if !(_x isEqualType "" && {_x != ""} && {([_x] call CSR_fnc_divisionName) == _x} && {!(toLower _x in _keys)}) exitWith {_ok = false;};
        _keys pushBack toLower _x;
    } forEach _names;
    _ok && {_rows findIf {!((_x # 4) in _names)} < 0}
};
private _next = _meta # 2;
private _defs = _meta # 3;
if !(_next isEqualType 0 && {finite _next} && {_next >= 1} && {_next == floor _next} && {_defs isEqualType []}) exitWith {false};
private _ids = [];
private _names = [];
{
    if !(_x isEqualType [] && {count _x == (_v+1)}) exitWith {_ok = false;};
    _x params ["_id","_name","_description","_items"];
    if !(_id isEqualType "" && {_id != ""} && {!(_id in _ids)} && {_name isEqualType ""} && {_name != ""} && {([_name] call CSR_fnc_divisionName) == _name} && {!(toLower _name in _names)} && {_description isEqualType ""} && {count _description <= 2048} && {_items isEqualType []}) exitWith {_ok = false;};
    if (_items findIf {!(_x isEqualType "") || {count _x < 1} || {count _x > 256}} >= 0) exitWith {_ok = false;};
    // Missing addon classes are valid persisted choices; paths and code are not.
    if (_v >= 4 && {!([_x # 4] call CSR_fnc_validInsigniaID)}) exitWith {_ok = false;};
    _ids pushBack _id;
    _names pushBack toLower _name;
} forEach _defs;
if (!_ok || {!(_default in _ids)}) exitWith {false};
if (_v == 5 && {!([_meta] call CSR_fnc_validRoleRules)}) exitWith {false};
private _members = _data # 4;
if !(_members isEqualType [] && {count _members == count _rows}) exitWith {false};
private _seen = [];
{
    if !(_x isEqualType [] && {count _x == 3}) exitWith {_ok = false;};
    _x params ["_uid","_eligible","_active"];
    if !(_uid isEqualType "" && {_uid in _uids} && {!(_uid in _seen)} && {_eligible isEqualType []} && {_active isEqualType ""} && {_active in _ids} && {_default in _eligible}) exitWith {_ok = false;};
    if (_eligible findIf {!(_x isEqualType "") || {!(_x in _ids)}} >= 0 || {count (_eligible arrayIntersect _eligible) != count _eligible}) exitWith {_ok = false;};
    private _row = _rows # (_uids find _uid);
    if ((_row # 4) != ((_defs # (_ids find _active)) # 1)) exitWith {_ok = false;};
    _seen pushBack _uid;
} forEach _members;
_ok
