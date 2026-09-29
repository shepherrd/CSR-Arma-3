if (!hasInterface || {isRemoteExecuted}) exitWith {};
params [["_token",-1,[0]]];
(localNamespace getVariable ["CSR_callbacks",createHashMap]) deleteAt _token;
