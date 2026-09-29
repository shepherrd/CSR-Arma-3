disableSerialization;
params [["_page","home"],["_display",uiNamespace getVariable ["CSR_display",displayNull]]];
if (isNull _display) exitWith {};
if (_page != "close") then {
    private _active = uiNamespace getVariable ["CSR_display",displayNull];
    if (!isNull _active && {!(_active isEqualTo _display)}) then {["close",_active] call CSR_fnc_panel;};
    uiNamespace setVariable ["CSR_display",_display];
};
[_display getVariable ["CSR_pending",-1]] call CSR_fnc_cancelRequest;
private _old = _display getVariable ["CSR_panel",controlNull];
if (!isNull _old) then {ctrlDelete _old;};
_display setVariable ["CSR_panel",controlNull];
_display setVariable ["CSR_pending",-1];
private _entry = _display getVariable ["CSR_entry",controlNull];
if (_page == "close") exitWith {
    _display setVariable ["CSR_page",""];
    if (!isNull _entry) then {_entry ctrlShow true;};
    if ((uiNamespace getVariable ["CSR_display",displayNull]) isEqualTo _display) then {uiNamespace setVariable ["CSR_display",displayNull];};
};
_entry ctrlShow false;
private _desktop = _display displayCtrl 4610;
if (isNull _desktop) exitWith {};
private _pos = ctrlPosition _desktop;
private _w = _pos # 2;
private _h = _pos # 3;
private _panel = _display ctrlCreate ["CSR_Group",89001,_desktop];
_panel ctrlSetPosition [0,0,_w,_h]; _panel ctrlCommit 0;
_display setVariable ["CSR_panel",_panel];
_display setVariable ["CSR_page",_page];
_display setVariable ["CSR_rendering",true];
private _makeRoot = {
    params ["_type","_id","_bounds",["_text",""]];
    private _c = _display ctrlCreate [_type,_id,_panel];
    _bounds params ["_x","_y","_cw","_ch"];
    _c ctrlSetPosition [_x*_w,_y*_h,_cw*_w,_ch*_h];
    _c ctrlSetFontHeight (0.025*_h); _c ctrlSetText _text; _c ctrlCommit 0;
    _c
};
private _contentY = if (_page == "home") then {0.105} else {0.135};
private _contentH = if (_page == "home") then {0.85} else {0.82};
private _make = {
    params ["_type","_id","_bounds",["_text",""]];
    _bounds params ["_x","_y","_cw","_ch"];
    [_type,_id,[_x,_contentY+_y*_contentH,_cw,_ch*_contentH],_text] call _makeRoot
};
private _button = {
    params ["_id","_bounds","_text","_action"];
    private _c = ["CSR_Button",_id,_bounds,_text] call _make;
    _c setVariable ["CSR_action",_action];
    _c ctrlAddEventHandler ["ButtonClick",{[(_this # 0) getVariable "CSR_action",_this # 0] call CSR_fnc_uiAction;}];
    _c
};
private _card = {
    params ["_bounds"];
    private _border = ["CSR_Text",-1,_bounds] call _make;
    _border ctrlSetBackgroundColor [0.83,0.87,0.87,1];
    _bounds params ["_x","_y","_cw","_ch"];
    private _fill = ["CSR_Text",-1,[_x+0.001,_y+0.0015,_cw-0.002,_ch-0.003]] call _make;
    _fill ctrlSetBackgroundColor [0.99,0.995,0.995,1];
};
private _bg = ["CSR_Text",-1,[0,0,1,1]] call _makeRoot;
_bg ctrlSetBackgroundColor [0.92,0.945,0.945,1];
private _header = ["CSR_Text",-1,[0,0,1,0.105]] call _makeRoot;
_header ctrlSetBackgroundColor [0.12,0.20,0.19,1];
["CSR_Picture",-1,[0.013,0.015,0.04,0.073],"\csr_ui\data\pine_ca.paa"] call _makeRoot;
private _brand = ["CSR_MultiText",-1,[0.06,0.018,0.235,0.074],format ["GREATER CASCADIAN%1ARMED FORCES",endl]] call _makeRoot;
_brand ctrlSetFontHeight (0.023*_h); _brand ctrlSetTextColor [0.92,0.96,0.94,1];
private _tabs = [[89400,0.305,0.10,"Home","home"],[89401,0.405,0.18,"Service Record","profile"],[89402,0.585,0.10,"Units","browse"],[89013,0.685,0.10,"Admin","admin"]];
{
    _x params ["_id","_left","_width","_label","_action"];
    private _c = ["CSR_NavButton",_id,[_left,0,_width,0.105],_label] call _makeRoot;
    _c setVariable ["CSR_action",_action];
    _c ctrlAddEventHandler ["ButtonClick",{[(_this # 0) getVariable "CSR_action",_this # 0] call CSR_fnc_uiAction;}];
    private _selected = _page == _action || {_action == "admin" && {_page in ["admin","divisions","members","roles"]}};
    if (_selected) then {
        _c ctrlSetBackgroundColor [0.21,0.32,0.29,1];
        private _line = ["CSR_Text",-1,[_left,0.101,_width,0.004]] call _makeRoot;
        _line ctrlSetBackgroundColor [0.76,0.85,0.79,1];
    };
    if (_page == "mode") then {_c ctrlShow false;};
} forEach _tabs;
(_panel controlsGroupCtrl 89013) ctrlShow (_page != "mode" && {localNamespace getVariable ["CSR_clientAdmin",false]});
private _account = ["CSR_Text",89403,[0.80,0.025,0.15,0.055],if (isNull player) then {""} else {name player}] call _makeRoot;
_account ctrlSetTextColor [0.86,0.92,0.89,1]; _account ctrlSetFontHeight (0.021*_h);
_account ctrlSetTooltip "Signed-in personnel";
private _exit = ["CSR_NavButton",89404,[0.957,0.022,0.033,0.058],"X"] call _makeRoot;
_exit ctrlSetTooltip "Close personnel portal";
_exit ctrlAddEventHandler ["ButtonClick",{
    private _d = ctrlParent (_this # 0);
    if (_d getVariable ["CSR_standalone",false]) then {closeDialog 0;} else {["close",_d] call CSR_fnc_panel;};
}];
private _status = ["CSR_Text",89003,[0.027,0.961,0.945,0.032],"Connecting to server..."] call _makeRoot;
_status ctrlSetTextColor [0.35,0.43,0.42,1]; _status ctrlSetFontHeight (0.019*_h);
if (_page != "home") then {
    private _title = ["CSR_Text",89002,[0.025,0,0.95,0.075],switch (_page) do {
        case "admin":{"Personnel Administration"};
        case "divisions":{"Division Configuration"};
        case "members":{"Division Eligibility"};
        case "roles":{"Division Roles / Slots"};
        case "browse":{"Units"};
        case "confirm":{"Confirm Division / Role Change"};
        case "mode":{"Select Mission Mode"};
        default {"Service Record"};
    }] call _make;
    _title ctrlSetFontHeight (0.039*_h);
};
switch (_page) do {
    case "home": {
        ["CSR_Picture",-1,[0,0,1,0.295],"\csr_ui\data\cascadia_co.paa"] call _make;
        private _shade = ["CSR_Text",-1,[0,0,1,0.295]] call _make;
        _shade ctrlSetBackgroundColor [0.03,0.10,0.09,0.28];
        {
            _x params ["_bounds","_text","_size"];
            private _c = ["CSR_Text",-1,_bounds,_text] call _make;
            _c ctrlSetTextColor [0.96,0.98,0.97,1]; _c ctrlSetFontHeight (_size*_h);
        } forEach [
            [[0.035,0.039,0.78,0.04],"P E O P L E   /   L A N D   /   P U R P O S E",0.017],
            [[0.035,0.095,0.85,0.075],"STRONGER TOGETHER",0.047],
            [[0.035,0.195,0.82,0.05],"Greater Cascadian Armed Forces",0.024]
        ];
        [[0.025,0.325,0.295,0.615]] call _card;
        [[0.34,0.325,0.635,0.615]] call _card;
        private _emblem = ["CSR_Text",-1,[0.045,0.35,0.067,0.11]] call _make;
        _emblem ctrlSetBackgroundColor [0.15,0.25,0.23,1];
        ["CSR_Logo",89207,[0.052,0.36,0.052,0.09],"\csr_ui\data\pine_ca.paa"] call _make;
        private _name = ["CSR_MultiText",89200,[0.123,0.35,0.178,0.12],"Loading personnel..."] call _make;
        _name ctrlSetFontHeight (0.028*_h);
        ["CSR_Text",-1,[0.045,0.495,0.25,0.04],"RANK"] call _make;
        ["CSR_Text",89201,[0.045,0.54,0.25,0.045]] call _make;
        ["CSR_Text",-1,[0.045,0.61,0.25,0.04],"ACTIVE DIVISION"] call _make;
        ["CSR_MultiText",89202,[0.045,0.655,0.255,0.085]] call _make;
        private _roleLabel = ["CSR_Text",89208,[0.045,0.74,0.255,0.04]] call _make;
        _roleLabel ctrlSetFontHeight (0.021*_h);
        private _uid = ["CSR_Text",89203,[0.045,0.79,0.255,0.035]] call _make;
        _uid ctrlSetFontHeight (0.018*_h); _uid ctrlSetTextColor [0.38,0.45,0.46,1];
        [89205,[0.045,0.845,0.255,0.06],"View Service Record","profile"] call _button;
        private _heading = ["CSR_Text",89204,[0.36,0.35,0.395,0.055],"Divisions"] call _make;
        _heading ctrlSetFontHeight (0.03*_h);
        [89206,[0.81,0.35,0.14,0.053],"View All","browse"] call _button;
        for "_i" from 0 to 3 do {
            private _y = 0.435 + _i*0.12;
            ["CSR_Logo",89303+_i*4,[0.36,_y+0.006,0.052,0.09]] call _make;
            private _name = ["CSR_Text",89300+_i*4,[0.425,_y,0.36,0.045]] call _make;
            private _desc = ["CSR_Text",89301+_i*4,[0.425,_y+0.05,0.36,0.044]] call _make;
            _desc ctrlSetFontHeight (0.020*_h); _desc ctrlSetTextColor [0.39,0.46,0.46,1];
            private _view = [89302+_i*4,[0.81,_y+0.016,0.14,0.055],"View","viewUnit"] call _button;
            _view ctrlShow false;
            private _line = ["CSR_Text",-1,[0.36,_y+0.109,0.59,0.0015]] call _make;
            _line ctrlSetBackgroundColor [0.87,0.90,0.90,1];
        };
        ["state",[]] call CSR_fnc_send;
    };
    case "profile": {
        [[0.025,0.105,0.95,0.115]] call _card;
        ["CSR_MultiText",89010,[0.045,0.12,0.91,0.095]] call _make;
        [[0.025,0.25,0.465,0.595]] call _card;
        [[0.51,0.25,0.465,0.595]] call _card;
        ["CSR_Text",-1,[0.05,0.275,0.41,0.055],"CAREER"] call _make;
        ["CSR_Text",-1,[0.535,0.275,0.41,0.055],"THIS MISSION"] call _make;
        {
            _x params ["_id","_left"];
            private _n = ["CSR_Text",_id,[_left,0.345,0.18,0.12],"--"] call _make;
            _n ctrlSetFontHeight (0.068*_h); _n ctrlSetTextColor [0.16,0.33,0.27,1];
            ["CSR_Text",-1,[_left+0.20,0.385,0.21,0.05],"ENEMY KILLS"] call _make;
        } forEach [[89210,0.05],[89211,0.535]];
        ["CSR_MultiText",89011,[0.05,0.505,0.41,0.32]] call _make;
        ["CSR_MultiText",89012,[0.535,0.505,0.41,0.32]] call _make;
        [89014,[0.78,0.88,0.195,0.06],"Refresh Stats","refresh"] call _button;
        ["state",[]] call CSR_fnc_send;
    };
    case "browse": {
        [[0.025,0.11,0.365,0.73]] call _card;
        [[0.41,0.11,0.565,0.73]] call _card;
        private _list = ["CSR_List",89100,[0.04,0.135,0.335,0.68]] call _make;
        _list ctrlAddEventHandler ["LBSelChanged",{["pickDivision"] call CSR_fnc_uiAction;}];
        ["CSR_Logo",89112,[0.435,0.14,0.105,0.16]] call _make;
        ["CSR_MultiText",89114,[0.56,0.15,0.38,0.15]] call _make;
        ["CSR_ReadDescription",89103,[0.435,0.335,0.51,0.465]] call _make;
        private _roleHeading = ["CSR_Text",89600,[0.435,0.555,0.51,0.04],"ROLES / OCCUPIED SLOTS"] call _make;
        private _roles = ["CSR_List",89601,[0.435,0.605,0.51,0.205]] call _make;
        _roles ctrlAddEventHandler ["LBSelChanged",{["pickRole"] call CSR_fnc_uiAction;}];
        _roleHeading ctrlShow false; _roles ctrlShow false;
        [89102,[0.755,0.88,0.22,0.06],"Join","join"] call _button;
        [89106,[0.025,0.88,0.20,0.06],"Refresh Units","refresh"] call _button;
        (_panel controlsGroupCtrl 89102) ctrlShow false;
        ["state",[]] call CSR_fnc_send;
    };
    case "confirm": {
        [[0.12,0.14,0.76,0.69]] call _card;
        ["CSR_MultiText",89103,[0.16,0.22,0.68,0.38],format ["Join %1?%2%2You will respawn.%2Equipment will be reset based on mission settings.",_display getVariable ["CSR_joinName",""],endl]] call _make;
        [89102,[0.16,0.70,0.30,0.075],"Yes, Join","confirmJoin"] call _button;
        [89105,[0.54,0.70,0.30,0.075],"No, Go Back","browse"] call _button;
        _status ctrlSetText "";
    };
    case "mode": {
        [[0.025,0.11,0.95,0.765]] call _card;
        ["CSR_MultiText",89103,[0.06,0.16,0.88,0.53],format ["Choose once for this mission session.%1%1FULL INTEGRATION%1Division and role changes require respawn. CSR controls role permissions, Zeus access, ACE Arsenal lists and Arma ranks. Assumes mission respawns are available.%1%1COMPATIBILITY%1Division changes update CSR immediately. Mission roles, Zeus, equipment, respawn and Arma ranks remain under mission control.",endl]] call _make;
        [89102,[0.06,0.745,0.42,0.085],"Full Integration","full"] call _button;
        [89105,[0.52,0.745,0.42,0.085],"Compatibility","compatibility"] call _button;
        _status ctrlSetText "Compatibility behavior is active until an authorized admin selects a mode.";
    };
    case "admin": {
        ["CSR_Text",-1,[0.025,0.105,0.43,0.035],"SEARCH NAME / UID"] call _make;
        ["CSR_Edit",89040,[0.025,0.145,0.43,0.05]] call _make;
        {
            _x params ["_id","_xPos","_label"];
            ["CSR_Text",-1,[_xPos,0.21,0.135,0.035],_label] call _make;
            private _c = ["CSR_Combo",_id,[_xPos,0.25,0.135,0.055]] call _make;
            _c ctrlAddEventHandler ["LBSelChanged",{["filter"] call CSR_fnc_uiAction;}];
        } forEach [[89041,0.025,"SORT"],[89042,0.172,"DIVISION"],[89043,0.32,"RANK"]];
        private _sort = _panel controlsGroupCtrl 89041;
        {_sort lbAdd _x;} forEach ["Division / rank","Name","Rank"];
        _sort lbSetCurSel 0;
        ["CSR_Text",89046,[0.025,0.32,0.43,0.04]] call _make;
        private _list = ["CSR_List",89020,[0.025,0.37,0.43,0.40]] call _make;
        _list ctrlAddEventHandler ["LBSelChanged",{["pickPerson"] call CSR_fnc_uiAction;}];
        {
            _x params ["_id","_y","_label","_type"];
            ["CSR_Text",-1,[0.5,_y,0.47,0.04],_label] call _make;
            [_type,_id,[0.5,_y+0.04,0.47,0.055]] call _make;
        } forEach [[89030,0.105,"STEAM UID","CSR_Edit"],[89031,0.22,"DISPLAY NAME","CSR_Edit"],[89032,0.335,"RANK","CSR_Combo"]];
        private _rank = _panel controlsGroupCtrl 89032;
        {private _i = _rank lbAdd (_x # 1); _rank lbSetData [_i,_x # 0];} forEach call CSR_fnc_rankTable;
        ["CSR_Text",-1,[0.5,0.45,0.47,0.05],"ELIGIBLE DIVISIONS (double-click to toggle)"] call _make;
        private _elig = ["CSR_List",89034,[0.5,0.51,0.47,0.26]] call _make;
        _elig ctrlAddEventHandler ["LBDblClick",{["toggleEligible"] call CSR_fnc_uiAction;}];
        [89021,[0.73,0.83,0.24,0.065],"SAVE RECORD","savePerson"] call _button;
        [89022,[0.025,0.83,0.10,0.065],"NEW","newPerson"] call _button;
        [89023,[0.135,0.83,0.15,0.065],"RELOAD","refresh"] call _button;
        [89024,[0.295,0.83,0.16,0.065],"MY RECORD","profile"] call _button;
        [89025,[0.5,0.83,0.21,0.065],"DIVISION ADMIN","divisions"] call _button;
        (_panel controlsGroupCtrl 89021) ctrlEnable false;
        ["adminData",[]] call CSR_fnc_send;
    };
    case "divisions": {
        private _list = ["CSR_List",89100,[0.025,0.13,0.31,0.62]] call _make;
        _list ctrlAddEventHandler ["LBSelChanged",{["pickDefinition"] call CSR_fnc_uiAction;}];
        ["CSR_Text",-1,[0.37,0.095,0.60,0.035],"DIVISION NAME"] call _make;
        ["CSR_Edit",89101,[0.37,0.135,0.60,0.055]] call _make;
        ["CSR_Text",-1,[0.37,0.205,0.43,0.035],"DIVISION LOGO / INSIGNIA"] call _make;
        private _logos = ["CSR_Combo",89113,[0.37,0.25,0.43,0.065]] call _make;
        _logos ctrlAddEventHandler ["LBSelChanged",{["pickLogo"] call CSR_fnc_uiAction;}];
        private _logoBackground = ["CSR_Text",-1,[0.835,0.21,0.13,0.14]] call _make;
        _logoBackground ctrlSetBackgroundColor [0.15,0.25,0.23,1];
        ["CSR_Logo",89112,[0.842,0.218,0.116,0.124]] call _make;
        ["CSR_Text",-1,[0.37,0.37,0.60,0.035],"DESCRIPTION"] call _make;
        ["CSR_Description",89107,[0.37,0.415,0.60,0.13]] call _make;
        ["CSR_Text",-1,[0.37,0.57,0.60,0.035],"ACE ITEM ARRAY (empty [] blocks arsenal access)"] call _make;
        ["CSR_Items",89108,[0.37,0.615,0.60,0.135]] call _make;
        [89104,[0.025,0.83,0.14,0.065],"NEW","newDivision"] call _button;
        [89115,[0.025,0.765,0.31,0.05],"ROLES / SLOTS","roles"] call _button;
        [89106,[0.18,0.83,0.155,0.065],"ROSTER","admin"] call _button;
        [89109,[0.37,0.83,0.28,0.065],"ELIGIBLE PLAYERS","members"] call _button;
        [89102,[0.67,0.83,0.30,0.065],"SAVE DIVISION","saveDefinition"] call _button;
        (_panel controlsGroupCtrl 89102) ctrlEnable false;
        (_panel controlsGroupCtrl 89115) ctrlEnable false;
        ["adminData",[]] call CSR_fnc_send;
    };
    case "roles": {
        ["CSR_MultiText",89610,[0.025,0.09,0.95,0.11],"Loading division roles..."] call _make;
        ["CSR_Text",-1,[0.035,0.20,0.37,0.04],"ROLE"] call _make;
        ["CSR_Text",-1,[0.43,0.20,0.19,0.04],"MAXIMUM PLAYERS"] call _make;
        ["CSR_Text",-1,[0.68,0.20,0.29,0.04],"ASSIGNED / RESERVED"] call _make;
        {
            private _y = 0.26+_forEachIndex*0.087;
            ["CSR_Text",-1,[0.035,_y,0.37,0.06],_x # 1] call _make;
            private _edit = ["CSR_Edit",89620+_forEachIndex,[0.43,_y,0.19,0.06]] call _make;
            _edit ctrlSetTooltip "Enter a positive limit, Off, or Unlimited. Default Rifleman is always Unlimited.";
            ["CSR_Text",89630+_forEachIndex,[0.68,_y,0.29,0.06]] call _make;
        } forEach call CSR_fnc_roleTable;
        [89611,[0.025,0.86,0.23,0.065],"BACK","divisions"] call _button;
        [89612,[0.28,0.86,0.23,0.065],"RELOAD","refresh"] call _button;
        [89613,[0.71,0.86,0.265,0.065],"SAVE ROLE LIMITS","saveRoles"] call _button;
        (_panel controlsGroupCtrl 89613) ctrlEnable false;
        ["adminData",[]] call CSR_fnc_send;
    };
    case "members": {
        ["CSR_MultiText",89103,[0.025,0.105,0.95,0.12]] call _make;
        private _list = ["CSR_List",89110,[0.025,0.25,0.95,0.52]] call _make;
        [89106,[0.025,0.83,0.30,0.065],"BACK","divisions"] call _button;
        [89111,[0.54,0.83,0.43,0.065],"TOGGLE ELIGIBILITY","toggleMember"] call _button;
        ["adminData",[]] call CSR_fnc_send;
    };
};
_display setVariable ["CSR_rendering",false];
