if (!isServer || {isRemoteExecuted && {isNil "_CSR_requestContext"}}) exitWith {};
if ((localNamespace getVariable ["CSR_mode","pending"]) != "full") exitWith {};
params ["_unit","_uid","_enabled"];
private _curators = localNamespace getVariable "CSR_curators";
private _logic = _curators getOrDefault [_uid,objNull];
private _assigned = if (isNull _unit) then {objNull} else {getAssignedCuratorLogic _unit};
if (!_enabled || {isNull _unit} || {!alive _unit}) exitWith {
    if (!isNull _assigned) then {unassignCurator _assigned;};
    if (!isNull _logic) then {unassignCurator _logic; deleteVehicle _logic;};
    _curators deleteAt _uid;
};
if (isNull _logic) then {
    private _group = localNamespace getVariable ["CSR_curatorGroup",grpNull];
    if (isNull _group) then {_group = createGroup [sideLogic,true]; localNamespace setVariable ["CSR_curatorGroup",_group];};
    _logic = _group createUnit ["CSR_CuratorLogic",[0,0,0],[],0,"NONE"];
    if (isNull _logic) exitWith {};
    _curators set [_uid,_logic];
    private _addons = localNamespace getVariable ["CSR_curatorAddons",[]];
    if (_addons isEqualTo []) then {
        _addons = ("true" configClasses (configFile >> "CfgPatches")) apply {configName _x};
        _addons call BIS_fnc_activateAddons;
        localNamespace setVariable ["CSR_curatorAddons",_addons];
    };
    _logic addCuratorAddons _addons;
    {_logic setCuratorCoef [_x,0];} forEach ["Place","Edit","Delete","Destroy","Group","Synchronize"];
    _logic setCuratorWaypointCost 0;
    _logic addCuratorPoints 1;
    removeAllCuratorEditingAreas _logic;
    _logic setCuratorEditingAreaType false;
    removeAllCuratorCameraAreas _logic;
    _logic setCuratorCameraAreaCeiling 1e10;
    _logic allowCuratorLogicIgnoreAreas true;
    _logic addCuratorEditableObjects [(allMissionObjects "All")-allCurators,true];
};
if (isNull _logic) exitWith {};
if !(_assigned isEqualTo _logic) then {
    if (!isNull _assigned) then {unassignCurator _assigned;};
    if (!isNull getAssignedCuratorUnit _logic) then {unassignCurator _logic;};
    _unit assignCurator _logic;
};
