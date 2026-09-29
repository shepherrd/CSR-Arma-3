class CfgPatches {
    class CSR_Stats_ACE {
        name = "Community Service Roster - ACE Statistics";
        author = "Community";
        requiredVersion = 2.14;
        requiredAddons[] = {"CSR_Core", "ace_medical_status"};
        units[] = {}; weapons[] = {};
    };
};
class CfgFunctions {
    class CSR {
        class ACEStats {
            file = "\csr_stats_ace\functions";
            class statsInit {postInit = 1;};
            class killed {};
        };
    };
};
