if (!hasInterface || {!isRemoteExecuted} || {remoteExecutedOwner != 2} || {isRemoteExecutedJIP}) exitWith {};
if !(_this isEqualType [] && {count _this == 5}) exitWith {};
params ["_token","_op","_ok","_message","_payload"];
if !(_token isEqualType 0 && {_op isEqualType ""} && {_ok isEqualType true} && {_message isEqualType ""} && {_payload isEqualType []}) exitWith {};
private _requests = localNamespace getVariable ["CSR_callbacks",createHashMap];
private _pending = _requests getOrDefault [_token,[]];
if (_pending isEqualTo [] || {(_pending # 0) != _op}) exitWith {};
_requests deleteAt _token;
// Call consumers locally, without inheriting the remote-execution context.
[{params ["_response","_callback"]; _response call _callback;},[+_this,_pending # 1]] call CBA_fnc_execNextFrame;
