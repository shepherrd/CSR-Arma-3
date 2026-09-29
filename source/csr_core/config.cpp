class CfgPatches {
    class CSR_Core {
        name = "Community Service Roster - Core";
        author = "Community";
        requiredVersion = 2.14;
        requiredAddons[] = {"cba_main", "cba_common", "A3_Modules_F_Curator_Curator"};
        units[] = {}; weapons[] = {};
    };
};
class CfgFunctions {
    class CSR {
        class Core {
            file = "\csr_core\functions";
            class init {postInit = 1;};
            class validStore {};
            class upgradeStore {};
            class divisionName {};
            class getDivisions {};
            class saveDivision {};
            class register {};
            class persist {};
            class apiInit {postInit = 1;};
            class clientRequest {};
            class cancelRequest {};
            class getRecord {};
            class getRoster {};
            class saveRecord {};
            class isAdmin {};
            class request {};
            class receive {};
            class rankTable {};
            class resolveRank {};
            class syncRank {};
            class applyRank {};
            class getRegistry {};
            class getMembership {};
            class audit {};
            class setActive {};
            class setMode {};
            class saveDefinition {};
            class updatePerson {};
            class joinDivision {};
            class finishSwitch {};
            class forceSwitchRespawn {};
            class applyPolicy {};
            class validInsigniaID {};
            class insignia {};
            class insigniaList {};
            class roleTable {};
            class validRoleRules {};
            class saveRoles {};
            class getRole {};
            class roleOccupancy {};
            class roleAvailable {};
            class setRole {};
            class roleDied {};
            class applyRole {};
            class syncRole {};
            class syncCurator {};
        };
    };
};
class CfgRemoteExec {
    class Functions {
        class CSR_fnc_request {allowedTargets = 2; jip = 0;};
        class CSR_fnc_receive {allowedTargets = 0; jip = 0;};
        class CSR_fnc_applyRank {allowedTargets = 0; jip = 0;};
        class CSR_fnc_forceSwitchRespawn {allowedTargets = 0; jip = 0;};
        class CSR_fnc_applyPolicy {allowedTargets = 0; jip = 1;};
        class CSR_fnc_applyRole {allowedTargets = 0; jip = 0;};
    };
};
class CSR_ServerPolicy {adminUIDs[] = {};};
class CSR_RosterAPI {version = 5; divisionInsignia = 1; divisionRoles = 1;};
class CfgVehicles {
    class ModuleCurator_F;
    class CSR_CuratorLogic: ModuleCurator_F {
        scope = 1; scopeCurator = 0;
        displayName = "CSR Command Staff Curator";
        function = "";
    };
};
