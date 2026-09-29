// Local callback only: code is never sent over the network.
if (!hasInterface || {isRemoteExecuted}) exitWith {-1};
params [["_op","",[""]],["_args",[],[[]]],["_callback",{},[{}]]];
if !(_op in ["get","list","save","roster","division","personnel","status","mode","state","adminData","updatePerson","definition","roleRules","join","arsenal"]) exitWith {-1};
private _requests = localNamespace getVariable ["CSR_callbacks",createHashMap];
if (count _requests >= 32) exitWith {-1};
private _token = (localNamespace getVariable ["CSR_nextToken",0]) + 1;
localNamespace setVariable ["CSR_nextToken",_token];
_requests set [_token,[_op,_callback,diag_tickTime+10]];
localNamespace setVariable ["CSR_callbacks",_requests];
// Return the token before a hosted-server reply can arrive.
[{
    params ["_token","_op","_args"];
    if (_token in (localNamespace getVariable ["CSR_callbacks",createHashMap])) then {
        [_token,_op,_args] remoteExecCall ["CSR_fnc_request",2];
    };
},[_token,_op,+_args]] call CBA_fnc_execNextFrame;
_token
