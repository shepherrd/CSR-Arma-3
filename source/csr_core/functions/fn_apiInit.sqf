if (!hasInterface || {isRemoteExecuted}) exitWith {};
localNamespace setVariable ["CSR_callbacks",createHashMap];
localNamespace setVariable ["CSR_nextToken",0];
[{
    private _requests = localNamespace getVariable ["CSR_callbacks",createHashMap];
    {
        private _pending = _requests getOrDefault [_x,[]];
        if (!(_pending isEqualTo []) && {diag_tickTime > (_pending # 2)}) then {
            _requests deleteAt _x;
            [_x,_pending # 0,false,"No server reply. Check the server addon and remote-execution rules.",[]] call (_pending # 1);
        };
    } forEach (keys _requests);
},1] call CBA_fnc_addPerFrameHandler;
