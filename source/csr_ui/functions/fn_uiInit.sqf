if (!hasInterface || {isRemoteExecuted}) exitWith {};
["Community Service Roster","CSR_OpenRoster",["Open service roster","View your service record and access authorized personnel administration."],{
    [] call CSR_fnc_openRoster;
},{},[19,[false,true,true]]] call CBA_fnc_addKeybind;
[{call CSR_fnc_uiTick;},0.25] call CBA_fnc_addPerFrameHandler;
