disableSerialization;
private _d = uiNamespace getVariable ["CSR_display",displayNull];
if (!isNull _d) then {
    private _p = _d getVariable ["CSR_panel",controlNull];
    private _page = _d getVariable ["CSR_page",""];
    if (_page == "mode" && {(localNamespace getVariable ["CSR_clientMode","pending"]) != "pending" || {!(localNamespace getVariable ["CSR_clientAdmin",false])}}) then {closeDialog 0;};
    if (_page == "admin" && {ctrlText (_p controlsGroupCtrl 89040) != (_d getVariable ["CSR_search",""])}) then {["filter"] call CSR_fnc_render;};
    if (_page in ["home","profile","browse"] && {(_d getVariable ["CSR_pending",-1]) == -1} && {diag_tickTime > (_d getVariable ["CSR_refreshAt",0])}) then {["state",[]] call CSR_fnc_send;};
};
if (isNull player || {getPlayerUID player == ""}) exitWith {};
if (diag_tickTime >= (localNamespace getVariable ["CSR_statusAt",0]) && {!(localNamespace getVariable ["CSR_statusPending",false])}) then {
    localNamespace setVariable ["CSR_statusAt",diag_tickTime+5];
    localNamespace setVariable ["CSR_statusPending",true];
    private _token = ["status",[],{
        params ["_token","_op","_ok","_message","_data"];
        localNamespace setVariable ["CSR_statusPending",false];
        if (!_ok) exitWith {};
        localNamespace setVariable ["CSR_clientAdmin",_data # 0];
        // A status reply sent before the admin decision must not undo its broadcast.
        if ((_data # 1) != "pending" || {(localNamespace getVariable ["CSR_clientMode","pending"]) == "pending"}) then {
            localNamespace setVariable ["CSR_clientMode",_data # 1];
        };
    }] call CSR_fnc_clientRequest;
    if (_token < 0) then {localNamespace setVariable ["CSR_statusPending",false];};
};
if (localNamespace getVariable ["CSR_clientAdmin",false] && {(localNamespace getVariable ["CSR_clientMode","pending"]) == "pending"} && {diag_tickTime >= (localNamespace getVariable ["CSR_promptAfter",0])} && {!dialog} && {!isNull findDisplay 46} && {isNull (uiNamespace getVariable ["CSR_display",displayNull])} && {alive player} && {isNil "ace_arsenal_camera"}) then {
    createDialog "CSR_ModeDialog";
};
