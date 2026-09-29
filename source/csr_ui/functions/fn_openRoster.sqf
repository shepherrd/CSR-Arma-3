if (!hasInterface || {isRemoteExecuted}) exitWith {false};
if (isNull player || {isNull findDisplay 46} || {dialog}) exitWith {false};
if (!isNull findDisplay 89050) exitWith {true};
createDialog "CSR_RosterDialog"
