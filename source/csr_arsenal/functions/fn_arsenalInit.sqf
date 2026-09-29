if (!hasInterface || {isRemoteExecuted}) exitWith {};
if (localNamespace getVariable ["CSR_arsenalInstalled",false]) exitWith {};
localNamespace setVariable ["CSR_arsenalInstalled",true];
localNamespace setVariable ["CSR_arsenalRequests",createHashMap];
["ace_arsenal_displayOpened",{_this call CSR_fnc_arsenalOpen;}] call CBA_fnc_addEventHandler;
["ace_arsenal_displayClosed",{
    private _proxy = localNamespace getVariable ["CSR_arsenalProxy",objNull];
    if (!isNull _proxy) then {deleteVehicle _proxy;};
    localNamespace setVariable ["CSR_arsenalProxy",objNull];
}] call CBA_fnc_addEventHandler;
