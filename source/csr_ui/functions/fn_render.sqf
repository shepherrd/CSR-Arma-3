disableSerialization;
params [["_what","state"]];
private _d = uiNamespace getVariable ["CSR_display",displayNull];
if (isNull _d) exitWith {};
private _p = _d getVariable ["CSR_panel",controlNull];
if (isNull _p) exitWith {};
private _page = _d getVariable ["CSR_page",""];
private _status = _p controlsGroupCtrl 89003;
_d setVariable ["CSR_rendering",true];
if (_what == "state") exitWith {
    private _s = _d getVariable ["CSR_state",[]];
    if (_s isEqualTo []) exitWith {_d setVariable ["CSR_rendering",false];};
    _s params ["_row","_mission","_admin","_registry","_member","_mode","_switching"];
    (_p controlsGroupCtrl 89403) ctrlSetText (_row # 1);
    (_p controlsGroupCtrl 89403) ctrlSetTooltip format ["%1 | %2",_row # 1,_row # 0];
    (_p controlsGroupCtrl 89013) ctrlShow _admin;
    if (_page == "home") then {
        (_p controlsGroupCtrl 89200) ctrlSetText (_row # 1);
        (_p controlsGroupCtrl 89201) ctrlSetText (_row # 2);
        (_p controlsGroupCtrl 89202) ctrlSetText (_row # 4);
        (_p controlsGroupCtrl 89202) ctrlSetTooltip (_row # 4);
        (_p controlsGroupCtrl 89203) ctrlSetText (_row # 0);
        (_p controlsGroupCtrl 89204) ctrlSetText format ["Divisions  /  %1",count (_registry # 3)];
        private _defs = _registry # 3;
        private _activeDefinition = _defs # (_defs findIf {(_x # 0) == (_member # 2)});
        private _activeLogo = [_activeDefinition param [4,""]] call CSR_fnc_insignia;
        (_p controlsGroupCtrl 89207) ctrlSetText (_activeLogo param [2,"\csr_ui\data\pine_ca.paa"]);
        for "_i" from 0 to 3 do {
            private _name = _p controlsGroupCtrl (89300+_i*4);
            private _desc = _p controlsGroupCtrl (89301+_i*4);
            private _view = _p controlsGroupCtrl (89302+_i*4);
            private _picture = _p controlsGroupCtrl (89303+_i*4);
            private _exists = _i < count _defs;
            {_x ctrlShow _exists;} forEach [_name,_desc,_view,_picture];
            if (_exists) then {
                private _def = _defs # _i;
                private _logo = [_def param [4,""]] call CSR_fnc_insignia;
                _picture ctrlSetText (_logo param [2,"\csr_ui\data\pine_ca.paa"]);
                private _badge = if ((_def # 0) == (_member # 2)) then {"Active"} else {if ((_def # 0) in (_member # 1)) then {"Eligible"} else {""}};
                _name ctrlSetText ((_def # 1) + (if (_badge == "") then {""} else {"  /  " + _badge}));
                _name ctrlSetTooltip (_def # 1);
                private _summary = toString ((toArray (_def # 2)) apply {if (_x in [10,13,9]) then {32} else {_x}});
                _desc ctrlSetText (if (_summary == "") then {"View division details"} else {_summary});
                _desc ctrlSetTooltip (_def # 2);
                _view setVariable ["CSR_divisionID",_def # 0];
            };
        };
    };
    private _role = _s param [7,[]];
    private _roleLabel = "";
    if (_mode == "full" && {!(_role isEqualTo [])}) then {
        private _table = call CSR_fnc_roleTable;
        private _ri = _table findIf {(_x # 0) == (_role # 1)};
        if (_ri >= 0) then {_roleLabel = _table # _ri # 1;};
    };
    (_p controlsGroupCtrl 89208) ctrlSetText _roleLabel;
    private _modeText = switch (_mode) do {case "full":{"Full Integration"}; case "compatibility":{"Compatibility"}; default {"Compatibility (awaiting admin selection)"};};
    if (_page == "profile") then {
        (_p controlsGroupCtrl 89010) ctrlSetText format ["%1  /  %2%4Active division: %3",_row # 1,_row # 2,(_row # 4)+(if (_roleLabel == "") then {""} else {" / "+_roleLabel}),endl];
        private _fmt = {params ["_s"]; format ["AI kills: %1%6Player kills: %2%6Friendly kills: %3%6Civilian kills: %4%6Deaths: %5",_s # 0,_s # 1,_s # 2,_s # 3,_s # 4,endl]};
        (_p controlsGroupCtrl 89210) ctrlSetText str ((_row # 5)+(_row # 6));
        (_p controlsGroupCtrl 89211) ctrlSetText str ((_mission # 0)+(_mission # 1));
        (_p controlsGroupCtrl 89011) ctrlSetText ([_row select [5,5]] call _fmt);
        (_p controlsGroupCtrl 89012) ctrlSetText ([_mission] call _fmt);
        (_p controlsGroupCtrl 89013) ctrlShow _admin;
    };
    if (_page == "browse") then {
        private _list = _p controlsGroupCtrl 89100;
        private _wanted = _d getVariable ["CSR_browseID",_member # 2];
        lbClear _list;
        {
            private _label = _x # 1;
            if ((_x # 0) == (_member # 2)) then {_label = _label + "  [Active]";};
            if ((_x # 0) == (_registry # 1)) then {_label = _label + "  [Default]";};
            private _i = _list lbAdd _label;
            _list lbSetData [_i,_x # 0];
            private _logo = [_x param [4,""]] call CSR_fnc_insignia;
            _list lbSetPicture [_i,_logo param [2,"\csr_ui\data\pine_ca.paa"]];
            _list lbSetPictureColor [_i,[1,1,1,1]];
            _list lbSetPictureColorSelected [_i,[1,1,1,1]];
        } forEach (_registry # 3);
        private _idx = (_registry # 3) findIf {(_x # 0) == _wanted};
        if (_idx < 0) then {_idx = 0;};
        _list lbSetCurSel _idx;
    };
    _status ctrlSetText (_modeText + (if (_switching) then {" | Awaiting mission respawn"} else {""}));
    _d setVariable ["CSR_rendering",false];
    if (_page == "browse") then {["pickDivision"] call CSR_fnc_uiAction;};
};
private _data = _d getVariable ["CSR_adminData",[]];
if (_data isEqualTo []) exitWith {_d setVariable ["CSR_rendering",false];};
_data params ["_rows","_registry","_members"];
private _defs = _registry # 3;
if (_what == "adminData") then {
    if (_page == "admin") then {
        {
            _x params ["_id","_entries"];
            private _c = _p controlsGroupCtrl _id;
            private _wanted = _c lbData lbCurSel _c;
            lbClear _c;
            private _sel = 0;
            {
                private _i = _c lbAdd (_x # 0); _c lbSetData [_i,_x # 1];
                if ((_x # 1) == _wanted) then {_sel = _i;};
            } forEach _entries;
            _c lbSetCurSel _sel;
        } forEach [
            [89042,[["All",""]] + (_defs apply {[_x # 1,_x # 1]})],
            [89043,[["All",""]] + ((call CSR_fnc_rankTable) apply {[_x # 1,_x # 0]})]
        ];
    };
    if (_page == "divisions") then {
        private _wantedName = _d getVariable ["CSR_wantedName",""];
        if (_wantedName != "") then {
            private _i = _defs findIf {(_x # 1) == _wantedName};
            if (_i >= 0) then {_d setVariable ["CSR_definitionID",(_defs # _i) # 0];};
            _d setVariable ["CSR_wantedName",""];
        };
        private _list = _p controlsGroupCtrl 89100;
        lbClear _list;
        {
            private _i = _list lbAdd ((_x # 1) + (if ((_x # 0) == (_registry # 1)) then {" [Default]"} else {""}));
            _list lbSetData [_i,_x # 0];
            private _logo = [_x param [4,""]] call CSR_fnc_insignia;
            _list lbSetPicture [_i,_logo param [2,"\csr_ui\data\pine_ca.paa"]];
            _list lbSetPictureColor [_i,[1,1,1,1]];
            _list lbSetPictureColorSelected [_i,[1,1,1,1]];
        } forEach _defs;
        private _idx = _defs findIf {(_x # 0) == (_d getVariable ["CSR_definitionID",""])};
        if (_idx < 0 && {!(_d getVariable ["CSR_newDefinition",false])}) then {_idx = 0; _d setVariable ["CSR_definitionID",(_defs # 0) # 0];};
        _list lbSetCurSel _idx;
    };
};
if (_page == "admin" && {_what in ["adminData","filter"]}) then {
    private _search = toLower ctrlText (_p controlsGroupCtrl 89040);
    _d setVariable ["CSR_search",ctrlText (_p controlsGroupCtrl 89040)];
    private _div = (_p controlsGroupCtrl 89042) lbData lbCurSel (_p controlsGroupCtrl 89042);
    private _rank = (_p controlsGroupCtrl 89043) lbData lbCurSel (_p controlsGroupCtrl 89043);
    private _sort = lbCurSel (_p controlsGroupCtrl 89041);
    private _table = call CSR_fnc_rankTable;
    private _order = [];
    {
        private _row = _x;
        private _rd = [_row # 2] call CSR_fnc_resolveRank;
        private _rankID = if (_rd isEqualTo []) then {""} else {_rd # 0};
        if ((_search == "" || {_search in toLower (_row # 1)} || {_search in (_row # 0)}) && {_div == "" || {_div == (_row # 4)}} && {_rank == "" || {_rank == _rankID}}) then {
            private _rankIndex = _table findIf {(_x # 0) == _rankID};
            if (_rankIndex < 0) then {_rankIndex = 999;};
            private _key = switch (_sort) do {
                case 1:{["",0,toLower (_row # 1)]};
                case 2:{["",_rankIndex,toLower (_row # 1)]};
                default {[toLower (_row # 4),_rankIndex,toLower (_row # 1)]};
            };
            _order pushBack (_key + [_row # 0,_row]);
        };
    } forEach _rows;
    _order sort true;
    private _list = _p controlsGroupCtrl 89020;
    private _uid = _d getVariable ["CSR_editUID",""];
    lbClear _list;
    private _sel = -1;
    {
        private _row = _x # 4;
        private _i = _list lbAdd format ["%1 | %2",_row # 1,_row # 2];
        _list lbSetData [_i,_row # 0];
        _list lbSetTooltip [_i,format ["%1 | %2",_row # 4,_row # 0]];
        if ((_row # 0) == _uid) then {_sel = _i;};
    } forEach _order;
    _list lbSetCurSel _sel;
    (_p controlsGroupCtrl 89046) ctrlSetText format ["%1 / %2 personnel%3",count _order,count _rows,if (_sel < 0 && {_uid != ""}) then {" | Editing hidden record"} else {""}];
};
if (_page == "admin" && {_what in ["adminData","person"]}) then {
    private _uid = _d getVariable ["CSR_editUID",""];
    private _i = _rows findIf {(_x # 0) == _uid};
    private _row = if (_i < 0) then {["","","Unassigned","Unassigned","",0,0,0,0,0,-1,[]]} else {_rows # _i};
    _d setVariable ["CSR_editRow",+_row];
    private _mi = _members findIf {(_x # 0) == _uid};
    _d setVariable ["CSR_draftEligible",if (_mi < 0) then {[_registry # 1]} else {+((_members # _mi) # 1)}];
    (_p controlsGroupCtrl 89030) ctrlSetText (_row # 0);
    (_p controlsGroupCtrl 89030) ctrlEnable (_i < 0);
    (_p controlsGroupCtrl 89031) ctrlSetText (_row # 1);
    private _rd = [_row # 2] call CSR_fnc_resolveRank;
    private _ri = (call CSR_fnc_rankTable) findIf {(_x # 0) == (_rd param [0,""])};
    (_p controlsGroupCtrl 89032) lbSetCurSel _ri;
    (_p controlsGroupCtrl 89021) ctrlEnable true;
};
if (_page == "admin" && {_what in ["adminData","person","eligible"]}) then {
    private _c = _p controlsGroupCtrl 89034;
    private _old = lbCurSel _c;
    lbClear _c;
    private _eligible = _d getVariable ["CSR_draftEligible",[]];
    {
        private _i = _c lbAdd format ["[%1] %2%3",if ((_x # 0) in _eligible) then {"x"} else {" "},_x # 1,if ((_x # 0) == (_registry # 1)) then {" (always eligible)"} else {""}];
        _c lbSetData [_i,_x # 0];
    } forEach _defs;
    _c lbSetCurSel _old;
};
if (_page == "divisions" && {_what in ["adminData","definition"]}) then {
    private _id = _d getVariable ["CSR_definitionID",""];
    private _i = _defs findIf {(_x # 0) == _id};
    private _def = if (_i < 0) then {["","","",[]]} else {_defs # _i};
    (_p controlsGroupCtrl 89101) ctrlSetText (_def # 1);
    (_p controlsGroupCtrl 89107) ctrlSetText (_def # 2);
    (_p controlsGroupCtrl 89108) ctrlSetText str (_def # 3);
    private _savedLogo = _def param [4,""];
    private _logos = _p controlsGroupCtrl 89113;
    lbClear _logos;
    _logos lbAdd "None"; _logos lbSetData [0,""];
    private _selectedLogo = 0;
    private _catalog = localNamespace getVariable ["CSR_insigniaCatalog",[]];
    if (isNil {localNamespace getVariable "CSR_insigniaCatalog"}) then {
        _catalog = call CSR_fnc_insigniaList;
        localNamespace setVariable ["CSR_insigniaCatalog",_catalog];
    };
    {
        private _index = _logos lbAdd (_x # 1);
        _logos lbSetData [_index,_x # 0];
        _logos lbSetPicture [_index,_x # 2];
        _logos lbSetPictureColor [_index,[1,1,1,1]];
        _logos lbSetPictureColorSelected [_index,[1,1,1,1]];
        _logos lbSetTooltip [_index,_x # 0];
        if (toLower (_x # 0) == toLower _savedLogo) then {_selectedLogo = _index;};
    } forEach _catalog;
    if (_savedLogo != "" && {_selectedLogo == 0}) then {
        _selectedLogo = _logos lbAdd ("Unavailable: " + _savedLogo);
        _logos lbSetData [_selectedLogo,_savedLogo];
        _logos lbSetTooltip [_selectedLogo,"Saved insignia is absent from this modset; keeping it preserves the choice."];
    };
    _logos lbSetCurSel _selectedLogo;
    private _logo = [_savedLogo] call CSR_fnc_insignia;
    (_p controlsGroupCtrl 89112) ctrlSetText (_logo param [2,"\csr_ui\data\pine_ca.paa"]);
    (_p controlsGroupCtrl 89112) ctrlSetTooltip (if (_savedLogo == "") then {"No division logo assigned"} else {_logo param [1,"Insignia unavailable; saved choice retained"]});
    (_p controlsGroupCtrl 89102) ctrlEnable true;
    (_p controlsGroupCtrl 89109) ctrlEnable (_i >= 0);
    (_p controlsGroupCtrl 89115) ctrlEnable (_i >= 0);
};
if (_page == "roles") then {
    private _id = _d getVariable ["CSR_definitionID",""];
    private _di = _defs findIf {(_x # 0) == _id};
    if (_di >= 0) then {
        private _rules = _defs # _di # 5;
        private _counts = _data param [3,[]];
        private _commandIndex = _defs findIf {(_x # 5) findIf {(_x # 0) == "command"} >= 0};
        private _commandDivision = if (_commandIndex < 0) then {""} else {_defs # _commandIndex # 0};
        (_p controlsGroupCtrl 89610) ctrlSetText format ["%1 | Off disables a role. Unlimited removes its cap.%2Changes take effect for existing occupants on death or their next switch.",_defs # _di # 1,endl];
        {
            private _role = _x # 0;
            private _ri = _rules findIf {(_x # 0) == _role};
            private _cap = if (_ri < 0) then {0} else {_rules # _ri # 1};
            private _edit = _p controlsGroupCtrl (89620+_forEachIndex);
            _edit ctrlSetText (switch (_cap) do {case -1:{"Unlimited"}; case 0:{"Off"}; default {str _cap};});
            private _locked = _id == (_registry # 1) && {_role in ["rifleman","command"]};
            if (_role == "command" && {_commandDivision != "" && {_commandDivision != _id}}) then {_locked=true; _edit ctrlSetTooltip ("Command Staff is configured in "+(_defs # _commandIndex # 1)+". Disable it there before moving it.");};
            _edit ctrlEnable !_locked;
            private _ci = _counts findIf {(_x # 0) == _id && {(_x # 1) == _role}};
            private _used = if (_ci < 0) then {[0,0]} else {(_counts # _ci) select [2,2]};
            (_p controlsGroupCtrl (89630+_forEachIndex)) ctrlSetText format ["%1 / %2",_used # 0,_used # 1];
        } forEach call CSR_fnc_roleTable;
        (_p controlsGroupCtrl 89613) ctrlEnable true;
    };
};
if (_page == "members") then {
    private _id = _d getVariable ["CSR_definitionID",""];
    private _i = _defs findIf {(_x # 0) == _id};
    if (_i >= 0) then {
        (_p controlsGroupCtrl 89103) ctrlSetText format ["%1%2Changes save immediately. Revoking eligibility leaves an active member in place until they leave.",(_defs # _i) # 1,endl];
        private _list = _p controlsGroupCtrl 89110;
        private _wanted = _list lbData lbCurSel _list;
        lbClear _list;
        {
            private _uid = _x # 0;
            private _mi = _members findIf {(_x # 0) == _uid};
            private _m = _members # _mi;
            private _idx = _list lbAdd format ["[%1] %2 | %3%4",if (_id in (_m # 1)) then {"x"} else {" "},_x # 1,_x # 2,if (_id == (_m # 2)) then {" | Active"} else {""}];
            _list lbSetData [_idx,_uid];
            if (_uid == _wanted) then {_list lbSetCurSel _idx;};
        } forEach _rows;
        (_p controlsGroupCtrl 89111) ctrlEnable (_id != (_registry # 1));
    };
};
if (_what == "adminData") then {_status ctrlSetText "Server data loaded. Save changes before navigating; RELOAD discards edits.";};
_d setVariable ["CSR_rendering",false];
