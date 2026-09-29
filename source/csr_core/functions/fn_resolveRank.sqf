params [["_input","",[""]]];
private _key = toUpper ((_input splitString ". -_") joinString "");
private _table = call CSR_fnc_rankTable;
private _index = _table findIf {(_x # 0) == _key || {_key in (_x # 4)}};
if (_index < 0) exitWith {[]};
_table # _index
