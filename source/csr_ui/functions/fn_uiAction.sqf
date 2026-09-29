disableSerialization;
params ["_action",["_control",controlNull]];
private _d = uiNamespace getVariable ["CSR_display",displayNull];
if (isNull _d || {_d getVariable ["CSR_rendering",false]}) exitWith {};
private _p = _d getVariable ["CSR_panel",controlNull];
private _page = _d getVariable ["CSR_page",""];
private _status = _p controlsGroupCtrl 89003;
if (_action in ["home","profile","admin","divisions","browse","members","roles"]) exitWith {[_action] call CSR_fnc_panel;};
if (_action == "viewUnit") exitWith {
    _d setVariable ["CSR_browseID",_control getVariable ["CSR_divisionID",""]];
    ["browse"] call CSR_fnc_panel;
};
if (_action == "refresh") exitWith {[if (_page in ["home","profile","browse"]) then {"state"} else {"adminData"},[]] call CSR_fnc_send;};
if (_action == "filter") exitWith {["filter"] call CSR_fnc_render;};
if (_action in ["full","compatibility"]) exitWith {["mode",[_action]] call CSR_fnc_send;};
if (_action == "pickRole") exitWith {
    private _s = _d getVariable ["CSR_state",[]];
    if (_s isEqualTo [] || {(_s # 5) != "full"}) exitWith {};
    private _id = _d getVariable ["CSR_browseID",""];
    private _c = _p controlsGroupCtrl 89601;
    private _role = _c lbData lbCurSel _c;
    _d setVariable ["CSR_browseRole",_role];
    private _defs = _s # 3 # 3;
    private _di = _defs findIf {(_x # 0) == _id};
    private _button = _p controlsGroupCtrl 89102;
    _button ctrlShow false;
    if (_di < 0 || {_role == ""}) exitWith {};
    private _rules = _defs # _di # 5;
    private _ri = _rules findIf {(_x # 0) == _role};
    if (_ri < 0) exitWith {};
    private _cap = _rules # _ri # 1;
    private _counts = _s param [8,[]];
    private _ci = _counts findIf {(_x # 0) == _id && {(_x # 1) == _role}};
    private _used = if (_ci < 0) then {0} else {(_counts # _ci # 2)+(_counts # _ci # 3)};
    private _free = _cap == -1 || {_used < _cap};
    private _current = _s param [7,[]];
    _button ctrlShow (_id in (_s # 4 # 1) && {!(_current isEqualTo [_id,_role])});
    _button ctrlEnable (_free && {!(_s # 6)});
    _button ctrlSetText (if (_free) then {"Join"} else {"Full"});
};
if (_action == "pickDivision") exitWith {
    private _s = _d getVariable ["CSR_state",[]];
    if (_s isEqualTo []) exitWith {};
    private _list = _p controlsGroupCtrl 89100;
    private _id = _list lbData lbCurSel _list;
    _d setVariable ["CSR_browseID",_id];
    private _defs = (_s # 3) # 3;
    private _i = _defs findIf {(_x # 0) == _id};
    if (_i < 0) exitWith {};
    private _m = _s # 4;
    private _active = _id == (_m # 2);
    (_p controlsGroupCtrl 89114) ctrlSetText format ["%1%2%3",(_defs # _i) # 1,endl,if (_active) then {"Active"} else {""}];
    (_p controlsGroupCtrl 89103) ctrlSetText ((_defs # _i) # 2);
    private _logo = [(_defs # _i) param [4,""]] call CSR_fnc_insignia;
    (_p controlsGroupCtrl 89112) ctrlSetText (_logo param [2,"\csr_ui\data\pine_ca.paa"]);
    private _full = (_s # 5) == "full";
    private _roleList = _p controlsGroupCtrl 89601;
    _roleList ctrlShow _full;
    (_p controlsGroupCtrl 89600) ctrlShow _full;
    private _description = _p controlsGroupCtrl 89103;
    private _bounds = ctrlPosition _description;
    _bounds set [3,(if (_full) then {0.205} else {0.465})*0.82*((ctrlPosition _p) # 3)];
    _description ctrlSetPosition _bounds; _description ctrlCommit 0;
    if (_full) then {
        private _current = _s param [7,[]];
        if (_active && {!(_current isEqualTo [])}) then {
            private _table = call CSR_fnc_roleTable;
            private _ri = _table findIf {(_x # 0) == (_current # 1)};
            (_p controlsGroupCtrl 89114) ctrlSetText format ["%1%2Active: %3",(_defs # _i) # 1,endl,if (_ri < 0) then {""} else {_table # _ri # 1}];
        };
        _d setVariable ["CSR_rendering",true];
        lbClear _roleList;
        private _wanted = _d getVariable ["CSR_browseRole",_current param [1,"rifleman"]];
        private _selected = 0;
        private _counts = _s param [8,[]];
        private _table = call CSR_fnc_roleTable;
        {
            _x params ["_role","_cap"];
            private _ri = _table findIf {(_x # 0) == _role};
            private _ci = _counts findIf {(_x # 0) == _id && {(_x # 1) == _role}};
            private _used = if (_ci < 0) then {0} else {(_counts # _ci # 2)+(_counts # _ci # 3)};
            private _idx = _roleList lbAdd format ["%1 | %2 / %3%4",_table # _ri # 1,_used,if (_cap == -1) then {"Unlimited"} else {str _cap},if (_current isEqualTo [_id,_role]) then {" [Active]"} else {""}];
            _roleList lbSetData [_idx,_role];
            _roleList lbSetTooltip [_idx,_table # _ri # 5];
            if (_role == _wanted) then {_selected = _idx;};
        } forEach (_defs # _i # 5);
        _roleList lbSetCurSel _selected;
        _d setVariable ["CSR_rendering",false];
        ["pickRole"] call CSR_fnc_uiAction;
    } else {
        (_p controlsGroupCtrl 89102) ctrlSetText "Join";
        (_p controlsGroupCtrl 89102) ctrlShow (!_active && {_id in (_m # 1)});
        (_p controlsGroupCtrl 89102) ctrlEnable !(_s # 6);
    };
};
if (_action == "join") exitWith {
    private _s = _d getVariable ["CSR_state",[]];
    if (_s isEqualTo []) exitWith {};
    private _id = _d getVariable ["CSR_browseID",""];
    private _defs = (_s # 3) # 3;
    private _i = _defs findIf {(_x # 0) == _id};
    if (_i < 0) exitWith {};
    _d setVariable ["CSR_joinID",_id];
    _d setVariable ["CSR_joinMode",_s # 5];
    _d setVariable ["CSR_joinName",(_defs # _i) # 1];
    private _role = if ((_s # 5) == "full") then {_d getVariable ["CSR_browseRole",""]} else {""};
    _d setVariable ["CSR_joinRole",_role];
    if ((_s # 5) == "full") then {
        private _table = call CSR_fnc_roleTable;
        private _ri = _table findIf {(_x # 0) == _role};
        if (_ri >= 0) then {_d setVariable ["CSR_joinName",(_defs # _i # 1)+" / "+(_table # _ri # 1)];};
    };
    if ((_s # 5) == "full") then {["confirm"] call CSR_fnc_panel;} else {["join",[_id,_s # 5]] call CSR_fnc_send;};
};
if (_action == "confirmJoin") exitWith {["join",[_d getVariable ["CSR_joinID",""],_d getVariable ["CSR_joinMode",""],_d getVariable ["CSR_joinRole",""]]] call CSR_fnc_send;};
private _data = _d getVariable ["CSR_adminData",[]];
if (_data isEqualTo []) exitWith {};
_data params ["_rows","_registry","_members"];
switch (_action) do {
    case "saveRoles": {
        private _rules = [];
        private _valid = true;
        {
            private _text = toLower ctrlText (_p controlsGroupCtrl (89620+_forEachIndex));
            _text = toString ((toArray _text) select {!(_x in [9,10,13,32])});
            private _cap = 0;
            switch true do {
                case (_text in ["off","disabled","0"]): {_cap = 0;};
                case (_text in ["unlimited","-1"]): {_cap = -1;};
                default {
                    if (_text == "" || {(toArray _text) findIf {_x < 48 || {_x > 57}} >= 0}) then {_valid=false;} else {
                        _cap = parseNumber _text;
                        if (!finite _cap || {_cap < 1} || {_cap > 10000} || {_cap != floor _cap}) then {_valid=false;};
                    };
                };
            };
            if (_cap != 0) then {_rules pushBack [_x # 0,_cap];};
        } forEach call CSR_fnc_roleTable;
        if (!_valid) exitWith {_status ctrlSetText "Enter Off, Unlimited, or a whole-number limit from 1 to 10000.";};
        ["roleRules",[_d getVariable ["CSR_definitionID",""],_rules,_registry # 0]] call CSR_fnc_send;
    };
    case "pickLogo": {
        private _c = _p controlsGroupCtrl 89113;
        private _id = _c lbData lbCurSel _c;
        private _logo = [_id] call CSR_fnc_insignia;
        (_p controlsGroupCtrl 89112) ctrlSetText (_logo param [2,"\csr_ui\data\pine_ca.paa"]);
        (_p controlsGroupCtrl 89112) ctrlSetTooltip (if (_id == "") then {"No division logo assigned"} else {_logo param [1,"Insignia unavailable; saved choice retained"]});
    };
    case "pickPerson": {
        private _c = _p controlsGroupCtrl 89020;
        _d setVariable ["CSR_editUID",_c lbData lbCurSel _c];
        ["person"] call CSR_fnc_render;
    };
    case "newPerson": {_d setVariable ["CSR_editUID",""]; ["person"] call CSR_fnc_render; ["filter"] call CSR_fnc_render;};
    case "toggleEligible": {
        private _c = _p controlsGroupCtrl 89034;
        private _id = _c lbData lbCurSel _c;
        if (_id == "" || {_id == (_registry # 1)}) exitWith {};
        private _eligible = _d getVariable ["CSR_draftEligible",[]];
        if (_id in _eligible) then {_eligible = _eligible - [_id];} else {_eligible pushBack _id;};
        _d setVariable ["CSR_draftEligible",_eligible];
        ["eligible"] call CSR_fnc_render;
    };
    case "savePerson": {
        private _row = _d getVariable ["CSR_editRow",[]];
        if (_row isEqualTo []) exitWith {};
        private _uid = ctrlText (_p controlsGroupCtrl 89030);
        private _c = _p controlsGroupCtrl 89032;
        _d setVariable ["CSR_editUID",_uid];
        ["updatePerson",[_uid,ctrlText (_p controlsGroupCtrl 89031),_c lbData lbCurSel _c,_d getVariable ["CSR_draftEligible",[]],_row # 10,_registry # 0]] call CSR_fnc_send;
    };
    case "pickDefinition": {
        private _c = _p controlsGroupCtrl 89100;
        _d setVariable ["CSR_definitionID",_c lbData lbCurSel _c];
        _d setVariable ["CSR_newDefinition",false];
        ["definition"] call CSR_fnc_render;
    };
    case "newDivision": {
        _d setVariable ["CSR_definitionID",""]; _d setVariable ["CSR_newDefinition",true];
        _d setVariable ["CSR_rendering",true];
        (_p controlsGroupCtrl 89100) lbSetCurSel -1;
        _d setVariable ["CSR_rendering",false];
        ["definition"] call CSR_fnc_render;
    };
    case "saveDefinition": {
        private _text = ctrlText (_p controlsGroupCtrl 89108);
        private _items = parseSimpleArray _text;
        private _compact = toString ((toArray _text) select {!(_x in [9,10,13,32])});
        if (_items isEqualTo [] && {_compact != "[]"}) exitWith {_status ctrlSetText "Enter a valid item classname array, or [] for no access.";};
        private _name = ctrlText (_p controlsGroupCtrl 89101);
        _d setVariable ["CSR_wantedName",[_name] call CSR_fnc_divisionName];
        private _logoControl = _p controlsGroupCtrl 89113;
        ["definition",[_d getVariable ["CSR_definitionID",""],_name,ctrlText (_p controlsGroupCtrl 89107),_items,_registry # 0,_logoControl lbData lbCurSel _logoControl]] call CSR_fnc_send;
    };
    case "toggleMember": {
        private _c = _p controlsGroupCtrl 89110;
        private _uid = _c lbData lbCurSel _c;
        private _i = _rows findIf {(_x # 0) == _uid};
        if (_i < 0) exitWith {_status ctrlSetText "Select a player first.";};
        private _row = _rows # _i;
        private _m = _members # (_members findIf {(_x # 0) == _uid});
        private _eligible = +(_m # 1);
        private _id = _d getVariable ["CSR_definitionID",""];
        if (_id == (_registry # 1)) exitWith {};
        if (_id in _eligible) then {_eligible = _eligible - [_id];} else {_eligible pushBack _id;};
        ["updatePerson",[_uid,_row # 1,_row # 2,_eligible,_row # 10,_registry # 0]] call CSR_fnc_send;
    };
};
