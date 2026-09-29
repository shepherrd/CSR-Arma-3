// Only public server endpoint. The caller never supplies their own identity or privileges.
if (!isServer || {!isRemoteExecuted} || {isRemoteExecutedJIP}) exitWith {};
if !(localNamespace getVariable ["CSR_initialized",false]) exitWith {};
if !(_this isEqualType [] && {count _this == 3}) exitWith {};
params ["_token", "_op", "_args"];
if !(_token isEqualType 0 && {finite _token} && {_op isEqualType ""} && {_args isEqualType []}) exitWith {};
private _owner = remoteExecutedOwner;
if (_owner < 2) exitWith {};
private _players = (allPlayers - entities "HeadlessClient_F") select {owner _x == _owner};
if (count _players != 1) exitWith {};
private _caller = _players # 0;
private _uid = getPlayerUID _caller;
if (_uid == "") exitWith {};
private _reply = {
    params ["_ok", "_message", ["_payload",[]]];
    [_token,_op,_ok,_message,_payload] remoteExecCall ["CSR_fnc_receive",_owner];
};
private _rates = localNamespace getVariable "CSR_rate";
if (diag_tickTime < (_rates getOrDefault [_uid + (if (_op == "status") then {"_status"} else {""}), -1])) exitWith {[false,"Please wait a moment and retry."] call _reply;};
_rates set [_uid + (if (_op == "status") then {"_status"} else {""}),diag_tickTime + 0.3];
if (localNamespace getVariable ["CSR_readOnly",true]) exitWith {[false,"Roster storage needs server-owner attention. Original data preserved."] call _reply;};
private _CSR_requestContext = true;
[_caller] call CSR_fnc_register;
private _admin = [_owner,_uid] call CSR_fnc_isAdmin;
private _roster = localNamespace getVariable "CSR_roster";
private _adminData = {
    private _members = localNamespace getVariable "CSR_members";
    [call CSR_fnc_getRoster,call CSR_fnc_getRegistry,(keys _members) apply {+(_members get _x)},[] call CSR_fnc_roleOccupancy]
};
switch (_op) do {
    case "status": {
        [true,"",[_admin,localNamespace getVariable ["CSR_mode","pending"]]] call _reply;
    };
    case "mode": {
        if (!_admin) exitWith {[false,"Administrator access required."] call _reply;};
        if (count _args != 1) exitWith {[false,"Invalid mode."] call _reply;};
        ([_args # 0,_uid] call CSR_fnc_setMode) call _reply;
    };
    case "state": {
        private _publicRegistry = call CSR_fnc_getRegistry;
        { _x set [3,[]]; } forEach (_publicRegistry # 3);
        [true,"",[
            [_uid] call CSR_fnc_getRecord,
            +((localNamespace getVariable "CSR_session") getOrDefault [_uid,[0,0,0,0,0]]),
            _admin,_publicRegistry,[_uid] call CSR_fnc_getMembership,
            localNamespace getVariable ["CSR_mode","pending"],
            _uid in (localNamespace getVariable "CSR_switches"),
            if ((localNamespace getVariable "CSR_mode") == "full") then {[_uid] call CSR_fnc_getRole} else {[]},
            if ((localNamespace getVariable "CSR_mode") == "full") then {[] call CSR_fnc_roleOccupancy} else {[]}
        ]] call _reply;
    };
    case "adminData": {
        if (!_admin) exitWith {[false,"Administrator access required."] call _reply;};
        [true,"",call _adminData] call _reply;
    };
    case "updatePerson";
    case "definition";
    case "roleRules": {
        if (!_admin) exitWith {[false,"Administrator access required."] call _reply;};
        private _result = switch (_op) do {
            case "definition": {[_args,_uid] call CSR_fnc_saveDefinition};
            case "roleRules": {[_args,_uid] call CSR_fnc_saveRoles};
            default {[_args,_uid] call CSR_fnc_updatePerson};
        };
        [_result # 0,_result # 1,if (_result # 0) then {call _adminData} else {[]}] call _reply;
    };
    case "join": {
        if !(count _args in [2,3]) exitWith {[false,"Invalid join request."] call _reply;};
        ([_caller,_args # 0,_args # 1,_args param [2,""]] call CSR_fnc_joinDivision) call _reply;
    };
    case "arsenal": {
        private _mode = localNamespace getVariable ["CSR_mode","pending"];
        private _items = [];
        if (_mode == "full") then {
            private _m = [_uid] call CSR_fnc_getMembership;
            private _defs = (call CSR_fnc_getRegistry) # 3;
            private _i = _defs findIf {(_x # 0) == (_m # 2)};
            if (_i >= 0) then {_items = +((_defs # _i) # 3);};
        };
        [true,"",[_mode,_items]] call _reply;
    };
    case "get": {
        [true,"",[[_uid] call CSR_fnc_getRecord, +( (localNamespace getVariable "CSR_session") getOrDefault [_uid,[0,0,0,0,0]]),_admin]] call _reply;
    };
    case "list": {
        if (!_admin) exitWith {[false,"Administrator access required."] call _reply;};
        private _rows = call CSR_fnc_getRoster;
        [true,"",_rows] call _reply;
    };
    case "save": {
        if (!_admin) exitWith {[false,"Administrator access required."] call _reply;};
        ([_args,_uid] call CSR_fnc_saveRecord) call _reply;
    };
    case "roster": {
        if (!_admin) exitWith {[false,"Administrator access required."] call _reply;};
        [true,"",[call CSR_fnc_getRoster,call CSR_fnc_getDivisions]] call _reply;
    };
    case "personnel": {
        if (!_admin) exitWith {[false,"Administrator access required."] call _reply;};
        private _result = [_args,_uid] call CSR_fnc_saveRecord;
        _result params ["_ok","_message","_row"];
        [_ok,_message,if (_ok) then {[_row,call CSR_fnc_getDivisions]} else {[]}] call _reply;
    };
    case "division": {
        if (!_admin) exitWith {[false,"Administrator access required."] call _reply;};
        ([_args,_uid] call CSR_fnc_saveDivision) call _reply;
    };
    default {[false,"Unknown request."] call _reply;};
};
