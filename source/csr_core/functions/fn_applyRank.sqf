// setRank requires unit locality. Only server-originated requests may reach this sink.
if ((isRemoteExecuted && {remoteExecutedOwner != 2 || {isRemoteExecutedJIP}}) || {!isRemoteExecuted && {!isServer}}) exitWith {};
params [["_unit",objNull,[objNull]],["_uid","",[""]],["_rank","",[""]]];
if (isNull _unit || {!local _unit} || {!alive _unit} || {!isPlayer _unit}) exitWith {};
if (getPlayerUID _unit != _uid || {_uid == ""}) exitWith {};
if !(_rank in ["PRIVATE","CORPORAL","SERGEANT","LIEUTENANT","CAPTAIN","MAJOR","COLONEL"]) exitWith {};
if (rank _unit == _rank) exitWith {};
// Rank commands can reset rating; preserve existing rating, including negative values.
private _rating = rating _unit;
_unit setRank _rank;
_unit addRating (_rating - rating _unit);
