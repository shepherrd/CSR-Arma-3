disableSerialization;
private _display = uiNamespace getVariable ["cTab_Tablet_dlg",displayNull];
if (isNull _display) exitWith {};
// Keep cTAB's native Home action; also dismiss our overlay when it is pressed.
private _home = _display displayCtrl 1606;
if (!isNull _home && {!(_home isEqualTo (_display getVariable ["CSR_homeControl",controlNull]))}) then {
    _home ctrlAddEventHandler ["ButtonClick",{["close",ctrlParent (_this # 0)] call CSR_fnc_panel;}];
    _display setVariable ["CSR_homeControl",_home];
};
private _desktop = _display displayCtrl 4610;
if (isNull _desktop) exitWith {};
private _entry = _display getVariable ["CSR_entry",controlNull];
if (isNull _entry) then {
    private _p = ctrlPosition _desktop;
    // Sixth desktop app, directly beneath BCE's clipboard / Task Builder.
    // Use the installed controls' geometry to follow tablet scaling and movement.
    private _clipboard = _desktop controlsGroupCtrl 10041;
    private _mail = _desktop controlsGroupCtrl 1004;
    private _position = [25/1341*(_p # 2),650/951*(_p # 3),100/1341*(_p # 2),100/951*(_p # 3)];
    if (!isNull _clipboard) then {
        _position = +(ctrlPosition _clipboard);
        private _pitch = 1.25 * (_position # 3);
        if (!isNull _mail) then {
            private _difference = (_position # 1) - ((ctrlPosition _mail) # 1);
            if (_difference > 0) then {_pitch = _difference;};
        };
        _position set [1,(_position # 1) + _pitch];
    };
    _entry = _display ctrlCreate ["CSR_AppIcon",89000,_desktop];
    _entry ctrlSetPosition _position;
    _entry ctrlSetTooltip "Service Record - personnel profile and career statistics";
    _entry ctrlCommit 0;
    _display setVariable ["CSR_entry",_entry];
};
private _panel = _display getVariable ["CSR_panel",controlNull];
if (isNull _panel) exitWith {};
if ((["cTab_Tablet_dlg","mode"] call cTab_fnc_getSettings) != "DESKTOP") exitWith {
    ["close",_display] call CSR_fnc_panel;
};
