if (!isServer || {isRemoteExecuted}) exitWith {};
[{
    localNamespace getVariable ["CSR_initialized",false]
},{
    if (localNamespace getVariable ["CSR_statsInitialized",false]) exitWith {};
    localNamespace setVariable ["CSR_statsInitialized",true];
    localNamespace setVariable ["CSR_sides",createHashMap];
    localNamespace setVariable ["CSR_dead",createHashMap];
    private _scan = {
        private _sides = localNamespace getVariable "CSR_sides";
        {if (alive _x && {!captive _x}) then {_sides set [netId _x,side group _x];};} forEach allUnits;
    };
    call _scan;
    [_scan,3] call CBA_fnc_addPerFrameHandler;
    ["ace_killed",{
        params ["_unit","_cause","_killer","_instigator"];
        [{isNull (_this # 0) || {!alive (_this # 0)}},{
            _this call CSR_fnc_killed;
        },[_unit,_killer,_instigator],10,{
            diag_log "[CSR] ACE death event timed out waiting for dead state; no kill awarded.";
        }] call CBA_fnc_waitUntilAndExecute;
    }] call CBA_fnc_addEventHandler;
    diag_log "[CSR] Optional ACE statistics initialized.";
}] call CBA_fnc_waitUntilAndExecute;
