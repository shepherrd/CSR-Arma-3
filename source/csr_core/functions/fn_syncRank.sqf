// Server derives the target rank solely from its roster; no rank from a client request.
if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {};
if (localNamespace getVariable ["CSR_readOnly",true]) exitWith {};
if ((localNamespace getVariable ["CSR_mode","pending"]) != "full") exitWith {};
params ["_unit","_uid"];
if (isNull _unit || {!alive _unit} || {!isPlayer _unit}) exitWith {};
private _row = (localNamespace getVariable "CSR_roster") getOrDefault [_uid,[]];
if (_row isEqualTo []) exitWith {};
private _rank = [_row # 2] call CSR_fnc_resolveRank;
if (_rank isEqualTo [] || {(_rank # 3) == ""}) exitWith {};
private _engineRank = _rank # 3;
if (rank _unit == _engineRank) exitWith {};
private _requests = localNamespace getVariable ["CSR_rankRequests",createHashMap];
private _key = format ["%1:%2:%3",netId _unit,owner _unit,_engineRank];
if (diag_tickTime < (_requests getOrDefault [_key,-1])) exitWith {};
_requests set [_key,diag_tickTime+5];
localNamespace setVariable ["CSR_rankRequests",_requests];
if (local _unit) then {
    // Do not inherit an admin client's remote-exec context when editing the host.
    [{_this call CSR_fnc_applyRank;},[_unit,_uid,_engineRank]] call CBA_fnc_execNextFrame;
} else {
    [_unit,_uid,_engineRank] remoteExecCall ["CSR_fnc_applyRank",owner _unit];
};
