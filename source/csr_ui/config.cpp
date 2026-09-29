class CfgPatches {
    class CSR_UI {
        name = "Community Service Roster - Standalone Interface";
        author = "Community";
        requiredVersion = 2.14;
        requiredAddons[] = {"CSR_Core", "cba_keybinding", "A3_UI_F"};
        units[] = {}; weapons[] = {};
    };
};
class CfgFunctions {
    class CSR {
        class UI {
            file = "\csr_ui\functions";
            class uiInit {postInit = 1;};
            class openRoster {};
            class uiTick {};
            class panel {};
            class send {};
            class responseUI {};
            class uiAction {};
            class render {};
        };
    };
};
#include "controls.hpp"
class CSR_RosterDialog {
    idd = 89050;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "(_this # 0) setVariable ['CSR_standalone',true]; ['home',_this # 0] call CSR_fnc_panel;";
    onUnload = "['close',_this # 0] call CSR_fnc_panel;";
    class controlsBackground {};
    class controls {
        class Content: CSR_Group {
            idc = 4610;
            x = "safezoneX + safezoneW * 0.055";
            y = "safezoneY + safezoneH * 0.055";
            w = "safezoneW * 0.89";
            h = "safezoneH * 0.89";
        };
    };
};
class CSR_ModeDialog: CSR_RosterDialog {
    idd = 89060;
    onLoad = "(_this # 0) setVariable ['CSR_standalone',true]; ['mode',_this # 0] call CSR_fnc_panel;";
    onUnload = "localNamespace setVariable ['CSR_promptAfter',diag_tickTime+30]; ['close',_this # 0] call CSR_fnc_panel;";
};