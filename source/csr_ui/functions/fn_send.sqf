disableSerialization;
params ["_op",["_args",[]]];
private _display = uiNamespace getVariable ["CSR_display",displayNull];
if (isNull _display) exitWith {};
[_display getVariable ["CSR_pending",-1]] call CSR_fnc_cancelRequest;
private _serial = (_display getVariable ["CSR_sendSerial",0])+1;
_display setVariable ["CSR_sendSerial",_serial];
_display setVariable ["CSR_pending",-2];
_display setVariable ["CSR_refreshAt",diag_tickTime+15];
private _panel = _display getVariable ["CSR_panel",controlNull];
(_panel controlsGroupCtrl 89003) ctrlSetText "Contacting server...";
// Rapid navigation must not trip the server's shared UI request rate limit.
private _when = diag_tickTime max (localNamespace getVariable ["CSR_nextUIRequest",0]);
localNamespace setVariable ["CSR_nextUIRequest",_when+0.4];
[{
    disableSerialization;
    params ["_display","_panel","_serial","_op","_args"];
    if (isNull _display || {isNull _panel} || {(_display getVariable ["CSR_sendSerial",-1]) != _serial} || {!((_display getVariable ["CSR_panel",controlNull]) isEqualTo _panel)}) exitWith {};
    private _token = [_op,_args,{_this call CSR_fnc_responseUI;}] call CSR_fnc_clientRequest;
    _display setVariable ["CSR_pending",_token];
    _display setVariable ["CSR_sentAt",diag_tickTime];
    if (_token < 0) then {(_panel controlsGroupCtrl 89003) ctrlSetText "Request could not be queued. Retry shortly.";};
},[_display,_panel,_serial,_op,+_args],_when-diag_tickTime] call CBA_fnc_waitAndExecute;