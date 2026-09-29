if (!isServer || {isRemoteExecuted}) exitWith {};
params [["_victim",objNull,[objNull]], ["_killer",objNull,[objNull]], ["_instigator",objNull,[objNull]]];
if (isNull _victim || {alive _victim} || {!(_victim isKindOf "CAManBase")}) exitWith {};
private _key = netId _victim;
private _dead = localNamespace getVariable "CSR_dead";
if (_key in _dead) exitWith {};
_dead set [_key, true];
// This map exists only on the server; clients cannot mark ordinary deaths exempt.
if (diag_tickTime <= ((localNamespace getVariable ["CSR_switchBodies",createHashMap]) getOrDefault [_key,-1])) exitWith {};
private _ids = localNamespace getVariable "CSR_identity";
private _roster = localNamespace getVariable "CSR_roster";
private _session = localNamespace getVariable "CSR_session";
private _victimUID = _ids getOrDefault [_key, getPlayerUID _victim];
private _increment = {
    params ["_uid", "_index"];
    if !(_uid in _roster) exitWith {};
    private _row = _roster get _uid;
    _row set [_index, (_row # _index) + 1];
    private _stats = _session getOrDefault [_uid, [0,0,0,0,0]];
    _stats set [_index - 5, (_stats # (_index - 5)) + 1];
    _session set [_uid, _stats];
    localNamespace setVariable ["CSR_dirty", true];
};
if (_victimUID != "") then {[_victimUID,9] call _increment;};
// Prefer ACE's actual shooter. Only use driver for road kills; never credit a random commander.
if (isNull _instigator && {!isNull _killer}) then {
    if (_killer isKindOf "CAManBase") then {_instigator = _killer;} else {
        private _uav = UAVControl _killer;
        _instigator = _uav param [0,objNull];
        if (isNull _instigator) then {_instigator = driver _killer;};
    };
};
if (isNull _instigator || {_instigator == _victim}) exitWith {};
private _uid = getPlayerUID _instigator;
if (_uid == "" && {!alive _instigator}) then {_uid = _ids getOrDefault [netId _instigator, ""];};
if (_uid == "" || {_uid == _victimUID}) exitWith {};
if !(_uid in _roster) then {[_instigator] call CSR_fnc_register;};
private _getSide = {
    params ["_unit"];
    private _sides = localNamespace getVariable "CSR_sides";
    private _fallback = [east,west,resistance,civilian] param [getNumber (configOf _unit >> "side"),civilian];
    _sides getOrDefault [netId _unit, _fallback]
};
private _targetSide = [_victim] call _getSide;
private _shooterSide = [_instigator] call _getSide;
private _index = if (_victimUID == "") then {5} else {6};
if (_targetSide == civilian) then {_index = 8;} else {
    if ((_shooterSide getFriend _targetSide) >= 0.6) then {_index = 7;};
};
[_uid,_index] call _increment;
