// Read-only snapshot. Never remotely expose arbitrary people's records.
if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {[]};
params [["_uid","",[""]]];
if !(localNamespace getVariable ["CSR_initialized",false]) exitWith {[]};
+((localNamespace getVariable "CSR_roster") getOrDefault [_uid,[]])
