// v2 projection retained. New integrations use getRegistry.
private _r = call CSR_fnc_getRegistry;
if (_r isEqualTo []) exitWith {[]};
private _d = (_r # 3) select {(_x # 0) == (_r # 1)};
[_r # 0,(_d # 0) # 1,(_r # 3) apply {_x # 1}]
