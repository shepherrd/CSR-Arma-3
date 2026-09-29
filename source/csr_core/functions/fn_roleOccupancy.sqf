// [divisionID,roleID,assigned,reserved]; assigned includes respawning/unconscious players.
if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {[]};
// Unary call inherits its caller's _this. Never treat a numeric request token as a UID.
private _exclude = "";
if (!isNil "_this" && {_this isEqualType []} && {count _this > 0} && {(_this # 0) isEqualType ""}) then {_exclude = _this # 0;};
private _counts = createHashMap;
private _add = {
    params ["_division","_role","_index"];
    private _key = _division + ":" + _role;
    private _row = _counts getOrDefault [_key,[_division,_role,0,0]];
    _row set [_index,(_row # _index)+1];
    _counts set [_key,_row];
};
private _roles = localNamespace getVariable ["CSR_roles",createHashMap];
{if (_x != _exclude) then {private _r = _roles get _x; [_r # 0,_r # 1,2] call _add;};} forEach keys _roles;
private _pending = localNamespace getVariable ["CSR_switches",createHashMap];
{
    private _p = _pending get _x;
    if (_x != _exclude && {count _p >= 5}) then {[_p # 0,_p # 4,3] call _add;};
} forEach keys _pending;
(keys _counts) apply {+(_counts get _x)}
