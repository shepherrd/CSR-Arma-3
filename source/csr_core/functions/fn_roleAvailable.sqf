if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {[false,"Server-local API only."]};
params ["_uid","_division","_role"];
if !(_division isEqualType "" && {_role isEqualType ""}) exitWith {[false,"Select a division and role."]};
private _m = [_uid] call CSR_fnc_getMembership;
if (_m isEqualTo [] || {!(_division in (_m # 1))}) exitWith {[false,"You are not eligible for this division."]};
private _defs = (call CSR_fnc_getRegistry) # 3;
private _di = _defs findIf {(_x # 0) == _division};
if (_di < 0) exitWith {[false,"Division not found."]};
private _rules = (_defs # _di) # 5;
private _ri = _rules findIf {(_x # 0) == _role};
if (_ri < 0) exitWith {[false,"This role is not offered by the division."]};
private _cap = (_rules # _ri) # 1;
private _counts = [_uid] call CSR_fnc_roleOccupancy;
private _ci = _counts findIf {(_x # 0) == _division && {(_x # 1) == _role}};
private _used = if (_ci < 0) then {0} else {(_counts # _ci # 2)+(_counts # _ci # 3)};
if (_cap != -1 && {_used >= _cap}) exitWith {[false,"This role has no free slots."]};
[true,""]
