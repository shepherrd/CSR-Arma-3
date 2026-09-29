// Optional: load this PBO ONLY on the server with -serverMod=@CSR_ServerPolicy.
// Add trusted Steam UIDs as quoted strings, then run build.ps1 again.
class CfgPatches {
    class CSR_ServerPolicyAddon {
        requiredAddons[] = {"CSR_Core"};
        units[] = {}; weapons[] = {};
    };
};
class CSR_ServerPolicy {
    adminUIDs[] = {};
};
