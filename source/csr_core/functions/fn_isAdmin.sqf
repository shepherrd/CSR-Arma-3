params ["_owner", "_uid"];
if (!isServer) exitWith {false};
// Voted admins (1) are deliberately excluded. A local hosted-server player is trusted.
(_owner == 2 && {hasInterface}) || {admin _owner == 2} || {_uid in (localNamespace getVariable ["CSR_adminUIDs", []])}
