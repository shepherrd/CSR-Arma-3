// Server-originated mission policy; replayed to joining clients.
if (!hasInterface || {!isRemoteExecuted} || {remoteExecutedOwner != 2}) exitWith {};
params [["_mode","",[""]]];
if !(_mode in ["full","compatibility"]) exitWith {};
localNamespace setVariable ["CSR_clientMode",_mode];
