disableSerialization;
params ["_token","_op","_ok","_message","_payload"];
private _d = uiNamespace getVariable ["CSR_display",displayNull];
if (isNull _d || {(_d getVariable ["CSR_pending",-1]) != _token}) exitWith {};
_d setVariable ["CSR_pending",-1];
private _p = _d getVariable ["CSR_panel",controlNull];
(_p controlsGroupCtrl 89003) ctrlSetText _message;
if (!_ok) exitWith {};
switch (_op) do {
    case "state": {
        _d setVariable ["CSR_state",_payload];
        ["state"] call CSR_fnc_render;
    };
    case "adminData";
    case "updatePerson";
    case "roleRules";
    case "definition": {
        _d setVariable ["CSR_adminData",_payload];
        ["adminData"] call CSR_fnc_render;
        if (_message != "") then {(_p controlsGroupCtrl 89003) ctrlSetText _message;};
    };
    case "join": {
        ["browse"] call CSR_fnc_panel;
    };
    case "mode": {
        localNamespace setVariable ["CSR_clientMode",_payload # 0];
        closeDialog 0;
    };
};
