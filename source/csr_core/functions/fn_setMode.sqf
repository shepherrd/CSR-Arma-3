if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {[false,"Server-local API only.",[]]};
params ["_mode",["_actor","server"]];
if (localNamespace getVariable ["CSR_readOnly",true]) exitWith {[false,"Storage is read-only.",[]]};
if !(_mode isEqualType "" && {_mode in ["full","compatibility"]}) exitWith {[false,"Invalid mission mode.",[]]};
if ((localNamespace getVariable ["CSR_mode","pending"]) != "pending") exitWith {[false,"An administrator has already selected this mission's mode.",[]]};
localNamespace setVariable ["CSR_mode",_mode];
if (_mode == "full") then {
    {
        private _uid = [_x] call CSR_fnc_register;
        if (_uid != "") then {
            [_uid,(localNamespace getVariable "CSR_registry") # 1,"rifleman","fullModeStart"] call CSR_fnc_setRole;
            [_x,_uid] call CSR_fnc_syncRole;
        };
    } forEach (allPlayers - entities "HeadlessClient_F");
};
[_mode] remoteExecCall ["CSR_fnc_applyPolicy",0,"CSR_missionPolicy"];
[_actor,"missionMode",[],[_mode]] call CSR_fnc_audit;
call CSR_fnc_persist;
["CSR_modeChanged",[_mode,_actor]] call CBA_fnc_localEvent;
[true,"Mission mode selected.",[_mode]]
