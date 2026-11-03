param([ValidateSet('Protect','Unlock')][string]$Mode='Protect')
$ErrorActionPreference='Stop'
$toolboxRoot=[IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
$prefix=$toolboxRoot+[IO.Path]::DirectorySeparatorChar
$manifestPath=Join-Path $toolboxRoot 'docs/maintenance/CODE_SHA256.json'
$manifest=Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$targets=@($manifest.files | ForEach-Object { $_.path }) + @('docs/maintenance/CODE_SHA256.json')
foreach($relative in $targets) {
    $target=[IO.Path]::GetFullPath((Join-Path $toolboxRoot $relative))
    if(-not $target.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)) { throw "Outside toolbox: $target" }
    if(-not (Test-Path -LiteralPath $target -PathType Leaf)) { throw "Missing core file: $target" }
}
foreach($relative in $targets) {
    $target=[IO.Path]::GetFullPath((Join-Path $toolboxRoot $relative))
    $attributes=[IO.File]::GetAttributes($target)
    if($Mode -eq 'Protect') { $attributes=$attributes -bor [IO.FileAttributes]::ReadOnly }
    else { $attributes=$attributes -band (-bnot [IO.FileAttributes]::ReadOnly) }
    [IO.File]::SetAttributes($target,$attributes)
}
Write-Output "$Mode completed for $($targets.Count) core files. User configuration functions are excluded."
