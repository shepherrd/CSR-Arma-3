// Internal mutation helper; callers validate before entering.
params ["_actor","_target","_before","_after"];
private _audit = localNamespace getVariable "CSR_audit";
_audit pushBack [systemTimeUTC,_actor,_target,+_before,+_after];
if (count _audit > 200) then {_audit deleteAt 0;};
localNamespace setVariable ["CSR_dirty",true];
