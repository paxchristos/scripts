#cleans up filenames
$ErrorActionPreference= 'silentlycontinue'
(Get-ChildItem -Directory -Recurse) | Rename-Item -NewName { $_.Name -replace "[^\p{L}\p{Nd}/./\s/-/_/(/)]+" }
(Get-ChildItem -File -Recurse) | Rename-Item -NewName { $_.Name -replace "[^\p{L}\p{Nd}/./\s/-/_/(/)]+" }
$ErrorActionPreference= 'continue'