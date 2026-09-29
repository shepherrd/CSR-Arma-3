disableSerialization;
if (!hasInterface || {is3DEN} || {isRemoteExecuted}) exitWith {};
if ((localNamespace getVariable ["CSR_clientMode","pending"]) != "full") exitWith {};
params ["_display"];
private _box = missionNamespace getVariable ["ace_arsenal_currentBox",objNull];
private _proxy = localNamespace getVariable ["CSR_arsenalProxy",objNull];
if (!isNull _proxy && {_box isEqualTo _proxy}) exitWith {};
private _unit = missionNamespace getVariable ["ace_arsenal_center",player];
// ACE functions are final. Close this initial display before interaction, then
// reopen once with a server-approved local proxy. Mission boxes stay unchanged.
{_x ctrlEnable false; _x ctrlShow false;} forEach allControls _display;
_display displayAddEventHandler ["KeyDown",{true}];
// Request only after ACE's first display has closed, including on a local host.
[{
    params ["_display","_box","_unit"];
    if (!isNull _display) then {_display closeDisplay 2;};
    if (localNamespace getVariable ["CSR_arsenalWaiting",false]) exitWith {};
    localNamespace setVariable ["CSR_arsenalWaiting",true];
    private _token = ["arsenal",[],{_this call CSR_fnc_arsenalReply;}] call CSR_fnc_clientRequest;
    if (_token < 0) exitWith {localNamespace setVariable ["CSR_arsenalWaiting",false]; systemChat "CSR: Could not request arsenal permissions.";};
    (localNamespace getVariable "CSR_arsenalRequests") set [_token,[_box,_unit]];
},[_display,_box,_unit]] call CBA_fnc_execNextFrame;
