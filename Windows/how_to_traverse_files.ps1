##One Line --- Change Get-ChildItem *.<extension> to prefferd option
$original = get-location | select-object -expandproperty Path; $directories = Get-ChildItem -Directory -Recurse | Select-Object -expandproperty FullName; foreach ($directory in $directories) { Set-Location "$directory"; $videos = Get-ChildItem *.mkv; foreach ($file in $videos) { Write-Host "$file is located in $directory" } Set-Location $original}

##Multi-line
$original = get-location | select-object -expandproperty Path
$directories = Get-ChildItem -Directory -Recurse | Select-Object -expandproperty FullName
 foreach ($directory in $directories) 
 { 
    Set-Location "$directory"
    $videos = Get-ChildItem *.mkv
    foreach ($file in $videos) 
    {
        Write-Host "$file is located in $directory" 
    } 
    Set-Location $original
}