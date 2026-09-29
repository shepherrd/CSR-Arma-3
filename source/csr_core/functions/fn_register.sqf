if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {""};
params ["_unit"];
if (isNull _unit || {!isPlayer _unit} || {_unit isKindOf "HeadlessClient_F"}) exitWith {""};
private _uid = getPlayerUID _unit;
if (_uid == "") exitWith {""};
private _roster = localNamespace getVariable "CSR_roster";
private _members = localNamespace getVariable "CSR_members";
private _default = (localNamespace getVariable "CSR_registry") # 1;
if !(_uid in _roster) then {
    private _name = (call CSR_fnc_getDivisions) # 1;
    _roster set [_uid,[_uid,name _unit,"Unassigned","Unassigned",_name,0,0,0,0,0,0,systemTimeUTC]];
    _members set [_uid,[_uid,[_default],_default]];
    localNamespace setVariable ["CSR_dirty",true];
};
private _connections = localNamespace getVariable "CSR_connections";
if !(_uid in _connections) then {
    _connections set [_uid,owner _unit];
    [_uid,_default,"connect"] call CSR_fnc_setActive;
    if ((localNamespace getVariable ["CSR_mode","pending"]) == "full") then {[_uid,_default,"rifleman","connect"] call CSR_fnc_setRole;};
};
private _identity = localNamespace getVariable "CSR_identity";
private _key = netId _unit;
if !(_key in _identity) then {
    _identity set [_key,_uid];
    (_roster get _uid) set [11,systemTimeUTC];
    localNamespace setVariable ["CSR_dirty",true];
};
[_unit,_uid] call CSR_fnc_syncRank;
if ((localNamespace getVariable ["CSR_mode","pending"]) == "full") then {
    if (([_uid] call CSR_fnc_getRole) isEqualTo []) then {[_uid,_default,"rifleman","initialRole"] call CSR_fnc_setRole;};
    private _bodies = localNamespace getVariable "CSR_roleBodies";
    if (_uid in _bodies && {!((_bodies get _uid) isEqualTo _unit)} && {alive _unit}) then {[_unit,_bodies get _uid] call CSR_fnc_finishSwitch;};
    _bodies set [_uid,_unit];
    if (!alive _unit) then {[_unit] call CSR_fnc_roleDied;};
    [_unit,_uid] call CSR_fnc_syncRole;
};
_uid
