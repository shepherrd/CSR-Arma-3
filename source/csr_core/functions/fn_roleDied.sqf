if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {};
if ((localNamespace getVariable ["CSR_mode","pending"]) != "full") exitWith {};
params ["_unit"];
if (isNull _unit || {alive _unit}) exitWith {};
private _key = netId _unit;
private _uid = (localNamespace getVariable "CSR_identity") getOrDefault [_key,getPlayerUID _unit];
if (_uid == "") exitWith {};
private _bodies = localNamespace getVariable "CSR_roleBodies";
if !((_bodies getOrDefault [_uid,objNull]) isEqualTo _unit) exitWith {};
private _dead = localNamespace getVariable "CSR_roleDeaths";
if (_key in _dead) exitWith {};
_dead set [_key,true];
private _role = [_uid] call CSR_fnc_getRole;
if !(_role isEqualTo []) then {
    if !(([_uid,_role # 0,_role # 1] call CSR_fnc_roleAvailable) # 0) then {
        [_uid,(localNamespace getVariable "CSR_registry") # 1,"rifleman","deathFallback"] call CSR_fnc_setRole;
        call CSR_fnc_persist;
    };
};
[_unit,_uid,false] call CSR_fnc_syncCurator;
