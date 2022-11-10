## Remuxes mp4 files into mkv
$directories        = Get-ChildItem -Directory -Recurse | Select-Object -ExpandProperty FullName
$originaldirectory  = Get-Location | Select-Object -ExpandProperty Path
$logFile            = $originaldirectory + "\remux.log"
$currentTime        = Get-Date -Format "MM/dd/yyyy hh:mm"

if (Test-Path -Path $logFile -PathType Leaf)
{
    Add-Content -Path $logFile -Value ---***---
    Add-Content -Path $logFile -Value "Stated new batch of remuxes on $($currentTime)"
}
else
{
    New-Item -Path $logFile -ItemType File
}
foreach ($directory in $directories)
{
    ##Changes directory to current working one
    Set-Location  "$directory"
    $mp4 = Get-ChildItem *.mp4
    ## DEBUG STATEMENT ##
    ##write-host $mp4.count##

    foreach ($file in $mp4)
    {
        Write-Host "$file"
        $tempname = [System.IO.Path]::GetFileNameWithoutExtension($file)
        $tempname = $tempname+".mkv"
        mkvmerge -o "$tempname" "$file"
        Remove-Item "$file"
        Add-Content -Path $logFile -Value "Remuxed $($tempname) from MP4 to MKV"
    }
    Set-Location $originaldirectory
}