<# One line using an existing text file to fix handbrake issues. (No longer needed, set as one line to deal with problems.)
$original = get-location | select-object -expandproperty Path; $mpegs = Get-Content -Path "$original\mpeg4.txt"; foreach ($file in $mpegs) { $actualFile = Get-ChildItem $file; $folder = Split-Path -Path $actualFile; Set-Location $folder; mkvpropedit.exe --add-track-statistics-tags $actualFile; Set-Location $original}#>

##copy files based on list from text file
##Get-Content "C:\temp\copy_me.txt" | ForEach-Object { Copy-Item -Path $_ -Destination "D:\temp\videos" -Recurse}

##Gets folders with more than 1 file per folder. Used to see which ones still have a .srt that's unneeded.
##Get-ChildItem -recurse | where {$_.PSIsContainer -and @(Get-ChildItem $_.FullName | Where {!$_.PSIsContainer}).Length -gt 1}


Get-Content "C:\temp\big_files.txt" | ForEach-Object { write-host "$($_.Name)"; Copy-Item -Path $_ -Destination "Y:\sharing\temp\videos" -Recurse}