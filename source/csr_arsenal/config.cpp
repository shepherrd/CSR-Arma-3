class CfgPatches {
    class CSR_Arsenal {
        name = "Community Service Roster - ACE Arsenal Integration";
        author = "Community";
        requiredVersion = 2.14;
        requiredAddons[] = {"CSR_Core","ace_arsenal"};
        units[] = {}; weapons[] = {};
    };
};
class CfgFunctions {
    class CSR {
        class Arsenal {
            file = "\csr_arsenal\functions";
            class arsenalInit {postInit = 1;};
            class arsenalOpen {};
            class arsenalReply {};
        };
    };
};
