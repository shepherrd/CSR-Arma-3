if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {[]};
params [["_uid","",[""]]];
+((localNamespace getVariable ["CSR_members",createHashMap]) getOrDefault [_uid,[]])
