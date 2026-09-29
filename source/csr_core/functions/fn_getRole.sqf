if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {[]};
params ["_uid"];
+((localNamespace getVariable ["CSR_roles",createHashMap]) getOrDefault [_uid,[]])
