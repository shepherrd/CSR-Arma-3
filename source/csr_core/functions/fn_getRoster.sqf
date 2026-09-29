if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {[]};
if !(localNamespace getVariable ["CSR_initialized",false]) exitWith {[]};
private _roster = localNamespace getVariable "CSR_roster";
(keys _roster) apply {+(_roster get _x)}
