if (!hasInterface || {!isRemoteExecuted} || {remoteExecutedOwner != 2} || {isRemoteExecutedJIP}) exitWith {};
params [["_unit",objNull,[objNull]],["_uid","",[""]]];
if (!local _unit || {_unit != player} || {getPlayerUID _unit != _uid} || {!alive _unit}) exitWith {};
// Same engine operation as the pause menu; no ticket/timer/loadout overrides.
forceRespawn _unit;
