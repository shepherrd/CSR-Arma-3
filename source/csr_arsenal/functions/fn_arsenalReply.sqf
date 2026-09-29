params ["_token","_op","_ok","_message","_payload"];
localNamespace setVariable ["CSR_arsenalWaiting",false];
private _requests = localNamespace getVariable "CSR_arsenalRequests";
private _args = _requests getOrDefault [_token,[]];
_requests deleteAt _token;
if (_args isEqualTo []) exitWith {};
if (!_ok) exitWith {systemChat ("CSR arsenal: " + _message);};
_payload params ["_mode","_items"];
// Mode cannot switch after selection. An unexpected response never opens unrestricted gear.
if (_mode != "full") exitWith {};
if (_items isEqualTo []) exitWith {systemChat "CSR: Your active division has no configured arsenal equipment.";};
_args params ["_box","_unit"];
if (isNull _box || {isNull _unit} || {!alive _unit} || {isNull player}) exitWith {};
if (!isNil "ace_arsenal_camera") exitWith {};
private _available = _items select {isClass(configFile >> "CfgWeapons" >> _x) || {isClass(configFile >> "CfgMagazines" >> _x)} || {isClass(configFile >> "CfgVehicles" >> _x)} || {isClass(configFile >> "CfgGlasses" >> _x)}};
if (_available isEqualTo []) exitWith {systemChat "CSR: This division's equipment is unavailable in the loaded modset.";};
private _proxy = createVehicleLocal ["Land_HelipadEmpty_F",[0,0,0],[],0,"CAN_COLLIDE"];
[_proxy,_available,false] call ace_arsenal_fnc_addVirtualItems;
localNamespace setVariable ["CSR_arsenalProxy",_proxy];
[_proxy,_unit,false] call ace_arsenal_fnc_openBox;
[{
    if (isNil "ace_arsenal_camera") then {
        private _proxy = localNamespace getVariable ["CSR_arsenalProxy",objNull];
        if (!isNull _proxy) then {deleteVehicle _proxy;};
        localNamespace setVariable ["CSR_arsenalProxy",objNull];
    };
},[],2] call CBA_fnc_waitAndExecute;
