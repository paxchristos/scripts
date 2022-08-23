$all = "C:\temp\all_Audio_Formats.txt"

$original = get-location | select-object -expandproperty Path
$directories = Get-ChildItem -Directory -Recurse | Select-Object -expandproperty FullName
foreach ($directory in $directories) 
{ 
    Set-Location "$directory"
    $videos = Get-ChildItem *.mkv
    foreach ($file in $videos) 
    {
        Write-Host "Working on $file"
        Add-Content -Path $all -Value "$file" 
        Add-Content -Path $all -Value "$(mediainfo.exe --inform="Audio;%Format%\n" $file)"
    } 
    Set-Location $original
}