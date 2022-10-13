<# One line using an existing text file to fix handbrake issues. (No longer needed, set as one line to deal with problems.)
$original = get-location | select-object -expandproperty Path; $mpegs = Get-Content -Path "$original\mpeg4.txt"; foreach ($file in $mpegs) { $actualFile = Get-ChildItem $file; $folder = Split-Path -Path $actualFile; Set-Location $folder; mkvpropedit.exe --add-track-statistics-tags $actualFile; Set-Location $original}#>

##copy files based on list from text file
##Get-Content "C:\temp\copy_me.txt" | ForEach-Object { Copy-Item -Path $_ -Destination "D:\temp\videos" -Recurse}

##Gets folders with more than 1 file per folder. Used to see which ones still have a .srt that's unneeded.
##Get-ChildItem -recurse | where {$_.PSIsContainer -and @(Get-ChildItem $_.FullName | Where {!$_.PSIsContainer}).Length -gt 1}


##Get-Content "C:\temp\big_files.txt" | ForEach-Object { write-host "$($_.Name)"; Copy-Item -Path $_ -Destination "Y:\sharing\temp\videos" -Recurse}



#Set-Location 'Y:\sharing\New\!to_merging_anime\Lycoris'; remove_video.ps1; Set-Location 'Y:\sharing\New\!to_merging_anime\made_in_abyss'; remove_video.ps1; Set-Location 'Y:\sharing\New\!to_merging_anime\ex'; remove_video.ps1; Set-Location 'Y:\sharing\New\!to_merging_anime\maid'; remove_video.ps1; Set-Location 'Y:\sharing\New\!to_merging_anime\shadows'; remove_video.ps1; Set-Location 'Y:\sharing\New\!to_merging_anime\shoot'; remove_video.ps1; Set-Location 'Y:\sharing\New\!to_merging_anime\prince'; remove_video.ps1; Set-Location 'Y:\sharing\New\!to_merging_anime\smile'; remove_video.ps1; Set-Location 'Y:\sharing\New\!to_merging_anime\lycoris_4k'; remove_video.ps1; copy-item -path 'Y:\sharing\Media\4k\Anime\Lycoris Recoil\Season 1\Lycoris Recoil - S01E02 - The more the merrier HDTV-2160p.mkv' -Destination 'Y:\sharing\New\!to_merging_anime\lycoris_4k'; dual_audio.ps1; Move-Item -Path 'Y:\sharing\New\!to_merging_anime\lycoris_4k\Lycoris Recoil - S01E02 - The more the merrier HDTV-2160p.mkv' -Destination 'Y:\sharing\Media\4k\Anime\Lycoris Recoil\Season 1' -Force; Set-Location 'Y:\sharing\New\!to_merging_anime\working\merge'; dual_audio.ps1; move-item *.mkv -Destination 'Y:\sharing\New\!to_merging_anime\working\transcode'; Set-Location 'Y:\sharing\New\!to_merging_anime\working\transcode'; transcode-anime.ps1


#Get a list of folders based off matching regex pattern and then create a text file to copy from 
$temp_array = Get-ChildItem -Directory | Where-Object {$_.Name -match '^[n-r]'} | Sort-Object; foreach ($directory in $temp_array) {add-content -path D:\temp\videos\copy_list.txt "$(Get-Location)\$($directory.Name)"}
#next lists
$temp_array = Get-ChildItem -Directory | Where-Object {$_.Name -match '^[s]'} | Sort-Object; foreach ($directory in $temp_array) {add-content -path D:\temp\videos\copy_list.txt "$(Get-Location)\$($directory.Name)"}


A-J
K-S
T-Z
Get-Content D:\temp\videos\copy_list.txt | Foreach-Object{copy-item -path $_.FullName -recurse -destination D:\temp\videos -Verbose}; transcode-live_subfolders.ps1; merge_srt_subfolders.ps1

copy-item 

$arrayDragon = get-childitem *.mkv; foreach ($file in $arrayDragon) { $original = $file.name; mkvmerge -o temp.mkv -a 1,10,11 -d -s $file; Remove-Item $file; Rename-Item temp.mkv $original}

(Get-ChildItem -File -Recurse) | Rename-Item -NewName { $_.Name -replace "[\[\]]" }; (Get-ChildItem -Directory -Recurse) | Rename-Item -NewName { $_.Name -replace "[\[\]]" }

Set-Location -Path 'Y:\sharing\New\!to_merging_anime\aoashi'; remove_video.ps1; Set-Location -Path 'Y:\sharing\New\!to_merging_anime\dungeon'; remove_video.ps1; Set-Location -Path 'Y:\sharing\New\!to_merging_anime\part-timer'; remove_video.ps1; Set-Location -Path 'Y:\sharing\New\!to_merging_anime\lucifer'; remove_video.ps1; Set-Location -Path 'Y:\sharing\New\!to_merging_anime\vermeil'; remove_video.ps1; Set-Location -Path 'Y:\sharing\New\!to_merging_anime\ex'; remove_video.ps1; Set-Location -Path 'Y:\sharing\New\!to_merging_anime\overlord'; remove_video.ps1; Set-Location -Path 'Y:\sharing\New\!to_merging_anime\shadows'; remove_video.ps1; Set-Location -Path 'Y:\sharing\New\!to_merging_anime\prince'; remove_video.ps1; Set-Location -Path 'Y:\sharing\New\!to_merging_anime\smile'; remove_video.ps1; Set-Location -Path 'Y:\sharing\New\!to_merging_anime\call'; remove_video.ps1; Set-Location -Path 'Y:\sharing\New\!to_merging_anime\made_4k'; remove_video.ps1; Copy-Item -Path 'Y:\sharing\Media\4k\Anime\Made in Abyss\Season 2\Made in Abyss - S02E04 - Friend HDTV-2160p.mkv' -Destination 'Y:\sharing\New\!to_merging_anime\made_4k'; dual_audio.ps1; Move-Item -Path 'Y:\sharing\New\!to_merging_anime\made_4k\Made in Abyss - S02E04 - Friend HDTV-2160p.mkv' -Destination 'Y:\sharing\Media\4k\Anime\Made in Abyss\Season 2' -Force; Set-Location 'Y:\sharing\New\!to_merging_anime\overlord_4k'; remove_video.ps1; Copy-Item -Path 'Y:\sharing\Media\4k\Anime\Overlord\Season 4\Overlord - S04E10 - The Last King HDTV-2160p.mkv' -Destination 'Y:\sharing\New\!to_merging_anime\overlord_4k'; dual_audio.ps1; Move-Item -Path 'Y:\sharing\New\!to_merging_anime\overlord_4k\Overlord - S04E10 - The Last King HDTV-2160p.mkv' -Destination 'Y:\sharing\Media\4k\Anime\Overlord\Season 4' -force; Set-Location 'Y:\sharing\New\!to_merging_anime\working\merge'; dual_audio.ps1; Move-Item -Path .\*.mkv -Destination 'Y:\sharing\New\!to_merging_anime\working\transcode'; Set-Location -Path 'Y:\sharing\New\!to_merging_anime\working\transcode'; transcode-anime.ps1

$currentDir = Get-Location; $listoffiles = "$currentDir\notEnglish.txt"; new-item $listoffiles -ItemType File; $array4me = Get-ChildItem *.mkv; foreach ($file in $array4me) {$holder = MediaInfo.exe --Inform="Audio;%Language%" "$file"; if (-not ($holder -like "*en*")) {write-host "$file --- $holder";Add-Content -path $listoffiles "$file does not contain an english track"} }

Get-ChildItem -recurse | Where {$_.PSIsContainer -and @(Get-ChildItem $_.Fullname | Where {!$_.PSIsContainer}).Length -gt 1}

Measure-Command {$directories = Get-ChildItem -Directory -Recurse | Select-Object -ExpandProperty FullName; $currentDir = Get-Location | select -ExpandProperty Path; $missingEng = "$currentDir\notEnglish.txt"; $missingJA = "$currentDir\missingJA.txt"; $sortedENG = "$currentDir\missing_english_sorted.txt"; $sortedJA = "$Currentdir\missing_japanese_sorted.txt" new-item $sortedENG -ItemType File; New-Item $sortedJA -ItemType File; new-item $missingEng -ItemType File; new-item $missingJA -type file; foreach ($directory in $directories){ Set-Location "$directory"; $mkvs = Get-ChildItem *.mkv; foreach ($file in $mkvs) {$name = Get-ChildItem $file | select -ExpandProperty BaseName; $holder = MediaInfo.exe --Inform="Audio;%Language%" "$file"; if (-not ($holder -like "*en*")) {Add-Content -path $missingEng "$name does not contain an english track"} if (-not ($holder -like "*ja*")) {Add-Content -Path $missingJA -Value "Check audio tracks for $name"} } Set-Location $currentDir} Get-Content $missingEng | sort | Get-Unique > $sortedEng; Remove-Item $missingEng; Get-Content $missingJA | sort | Get-Unique > $sortedJA; Remove-Item $missingJA}


$directories = Get-ChildItem -Directory -Recurse | Select-Object -ExpandProperty FullName; $original	 = Get-Location | Select-Object -ExpandProperty Path; foreach ($directory in $directories) { Set-Location "$directory"; $name = Split-Path -Path (Get-Location) -Leaf; $subs = Get-ChildItem *.srt; foreach ($file in $subs){ if ($file.name -eq "2_English.srt"){get-childitem $file | Rename-Item -NewName {$file.BaseName.Replace("2_English","$name") + $file.Extension} } if ($file.name -eq "3_English.srt"){get-childitem $file | Rename-Item -NewName {$file.BaseName.Replace("3_English","$name.en") + $file.Extension} } if ($file.name -eq "4_English.srt"){Get-ChildItem $file | Rename-Item  -NewName {$file.BaseName.Replace("4_English","$name.eng") + $file.Extension} }}Set-Location $original} Get-ChildItem -recurse *.srt | Move-Item -Destination ..\

### PAD FILE NAMES STARTING W/ 1-9
Get-ChildItem -Recurse | Where-Object {($_.Extension -like '.mp3') -and ($_.Name -match "^\d\b") -and ($_.Name -notmatch "^\d\b\-")} | Rename-Item -NewName {"0" + $_.Name} -WhatIf


$directories = Get-ChildItem -Directory -Recurse | Select-Object -ExpandProperty FullName; $originaldirectory = Get-Location | Select-Object -ExpandProperty Path; foreach ($directory in $directories){ Set-Location "$directory"; Add-content -path A:\anon\count.txt "$((Get-ChildItem $_ -File | Measure-Object).count) $($_.FullName)"; set-location $originaldirectory} Get-Content count.txt | sort -Descending > sorted_count.txt