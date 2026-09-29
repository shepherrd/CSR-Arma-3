param(
    [string]$ArmaTools = 'C:\Program Files (x86)\Steam\steamapps\common\Arma 3 Tools',
    [string]$WorkDirectory = (Join-Path ([IO.Path]::GetTempPath()) ('csr-build-' + [guid]::NewGuid().ToString('N'))),
    [string]$SignKey = ''
)
$ErrorActionPreference = 'Stop'
$convert = Join-Path $ArmaTools 'CfgConvert\CfgConvert.exe'
$bank = Join-Path $ArmaTools 'FileBank\FileBank.exe'
foreach ($tool in @($convert,$bank)) { if (!(Test-Path -LiteralPath $tool)) { throw "Missing Arma tool: $tool" } }
$run = Join-Path $WorkDirectory ([guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $run -Force | Out-Null
$modules = [ordered]@{
    csr_core = '@CSR_Roster'
    csr_ui = '@CSR_Roster'
    csr_stats_ace = '@CSR_ACEStats'
    csr_arsenal = '@CSR_ACEArsenal'
    csr_tablet = '@CSR_CTAB'
    csr_server_policy = '@CSR_ServerPolicy'
}
foreach ($addon in $modules.Keys) {
    $source = Join-Path $PSScriptRoot "source\$addon"
    $stage = Join-Path $run $addon
    New-Item -ItemType Directory -Path $stage -Force | Out-Null
    Get-ChildItem -LiteralPath $source -Directory | ForEach-Object {Copy-Item -LiteralPath $_.FullName -Destination $stage -Recurse}
    & $convert -bin -dst (Join-Path $stage 'config.bin') (Join-Path $source 'config.cpp')
    if ($LASTEXITCODE -ne 0) {throw "Config compilation failed: $addon"}
    $pack = Join-Path $run "packed-$addon"
    New-Item -ItemType Directory -Path $pack -Force | Out-Null
    & $bank -property "prefix=$addon" -dst $pack $stage
    if ($LASTEXITCODE -ne 0) {throw "PBO build failed: $addon"}
    $mod = $modules[$addon]
    $destination = Join-Path $PSScriptRoot "$mod\addons"
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    $pbo = Join-Path $pack "$addon.pbo"
    if (!(Test-Path -LiteralPath $pbo)) {throw "Missing built PBO: $pbo"}
    Copy-Item -LiteralPath $pbo -Destination $destination -Force
    if ($SignKey) {
        & (Join-Path $ArmaTools 'DSSignFile\DSSignFile.exe') $SignKey (Join-Path $destination "$addon.pbo")
        if ($LASTEXITCODE -ne 0) {throw "Signing failed: $addon"}
    }
}
foreach ($mod in ($modules.Values | Select-Object -Unique)) {
    $label = $mod.Substring(1).Replace('_',' ')
    ('name = "{0}"; author = "Community"; tooltip = "Community Service Roster 0.7.1";' -f $label) | Set-Content -LiteralPath (Join-Path $PSScriptRoot "$mod\mod.cpp")
}
Write-Output 'Built independent roster/UI, optional ACE arsenal, ACE statistics, cTAB interface and server policy.'
