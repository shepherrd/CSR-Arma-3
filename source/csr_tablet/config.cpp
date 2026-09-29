class CfgPatches {
    class CSR_Tablet {
        name = "Community Service Roster - cTAB Interface";
        author = "Community";
        requiredVersion = 2.14;
        requiredAddons[] = {"CSR_UI", "cTab", "ctab_core", "BCE_cTab_UI"};
        units[] = {}; weapons[] = {};
    };
};
class CfgFunctions {
    class CSR {
        class Tablet {
            file = "\csr_tablet\functions";
            class clientInit {postInit = 1;};
            class attach {};
        };
    };
};
class cTab_ActiveText;
class CSR_AppIcon: cTab_ActiveText {
    style = 48;
    text = "\a3\ui_f\data\gui\rsc\rscdisplaymain\profile_ca.paa";
    tooltip = "Service Record";
    action = "['home',uiNamespace getVariable ['cTab_Tablet_dlg',displayNull]] call CSR_fnc_panel;";
};
