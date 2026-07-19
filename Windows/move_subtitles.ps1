#cleans up filenames
$ErrorActionPreference = 'silentlycontinue'
(Get-ChildItem -File -Recurse) | Rename-Item -NewName { $_.Name -replace "[^\p{L}\p{Nd}/./\s/-/_/(/)]+" }
$folders = Get-ChildItem -Directory -Recurse |
Sort-Object { $_.FullName.Split([IO.Path]::DirectorySeparatorChar).Count } -Descending

foreach ($folder in $folders)
{
    $newName = $folder.Name -replace '[^\p{L}\p{Nd}\.\s\-_()]', ''
    if ($folder.Name -ne $newName)
    {
        try
        {
            Rename-Item -Path $folder.FullName -NewName $newName -ErrorAction Stop
        }
        catch
        {
            Write-Warning "Failed to rename $($folder.FullName): $_"
        }
    }
}

$ErrorActionPreference = 'continue'


# -------------------------------------------------------
# Helper: map a subtitle filename to a language tag
# Returns $null if the file isn't a recognized language
# -------------------------------------------------------
function Get-SubtitleLanguageTag {
    param([string]$filename)

    $name = [System.IO.Path]::GetFileNameWithoutExtension($filename).ToLower()

    # Detect modifiers
    $isSDH    = $name -match '\bsdh\b'
    $isForced = $name -match '\bforced\b'
    $isFull   = $name -match '\bfull\b'

    # Boundary pattern: no adjacent letter on either side
    # Handles separators like _ - . and start/end of string
    $b = '(?<![a-z])({0})(?![a-z])'

    # Detect language — extend these patterns for additional languages
    if     ($name -match ($b -f 'en|eng|english'))        { $lang = "en" }
    elseif ($name -match ($b -f 'fr|fra|french'))         { $lang = "fr" }
    elseif ($name -match ($b -f 'de|ger|german'))         { $lang = "de" }
    elseif ($name -match ($b -f 'es|spa|spanish'))        { $lang = "es" }
    elseif ($name -match ($b -f 'pt|por|portuguese'))     { $lang = "pt" }
    elseif ($name -match ($b -f 'it|ita|italian'))        { $lang = "it" }
    elseif ($name -match ($b -f 'ja|jpn|japanese'))       { $lang = "ja" }
    elseif ($name -match ($b -f 'zh|chi|chinese'))        { $lang = "zh" }
    else   { return $null }  # Not a recognized language

    # Build tag: en, en.forced, en.sdh, en.full etc.
    $tag = $lang
    if ($isForced) { $tag += ".forced" }
    if ($isSDH)    { $tag += ".sdh" }
    if ($isFull)   { $tag += ".full" }

    return $tag
}


$wholeTree = Get-ChildItem -Directory -Recurse
$original  = Get-Location | Select-Object -ExpandProperty Path

foreach ($subfolder in $wholeTree)
{
    $folder_check = "Subs"
    $finalFolder  = [System.IO.Path]::GetFileName($($subfolder.FullName))

    if ($finalFolder -ne $folder_check)
    {
        # Not a Subs folder, skip
    }
    else
    {
        Set-Location $subfolder.FullName
        $directories = Get-ChildItem -Directory -Recurse | Select-Object -ExpandProperty FullName

        foreach ($directory in $directories)
        {
            Push-Location $directory
            $folderName = [System.IO.Path]::GetFileName($directory)

            $subs     = Get-ChildItem -Filter *.srt -File
            $usedTags = @{}

            foreach ($file in $subs)
            {
                $tag = Get-SubtitleLanguageTag -filename $file.Name

                if ($null -eq $tag)
                {
                    # Unrecognized subtitle — remove it
                    Write-Host "Removing unrecognized subtitle: $($file.Name)"
                    try
                    {
                        Remove-Item -Path $file.FullName -Force -ErrorAction Stop
                    }
                    catch
                    {
                        Write-Warning "Failed to remove $($file.Name): $_"
                    }
                    continue
                }

                # Deduplicate: if the same tag appears more than once, append a counter
                if ($usedTags.ContainsKey($tag))
                {
                    $usedTags[$tag]++
                    $dedupTag = "$tag$($usedTags[$tag])"
                }
                else
                {
                    $usedTags[$tag] = 0
                    $dedupTag = $tag
                }

                $newName = "$folderName.$dedupTag.srt"
                try
                {
                    Rename-Item -Path $file.FullName -NewName $newName -ErrorAction Stop
                }
                catch
                {
                    Write-Output "Failed to rename`n$($file.Name)`nExiting now`n$_"
                    exit
                }
            }
            Pop-Location
        }

        # Move all renamed subs up one level (next to the video files)
        Get-ChildItem *.srt -Recurse | Move-Item -Destination ..\

        Set-Location ..\

        # Remux mp4 -> mkv
        $mp4 = Get-ChildItem *.mp4

        foreach ($file in $mp4)
        {
            Write-Host "Remuxing: $file"
            $tempname = [System.IO.Path]::GetFileNameWithoutExtension($file) + ".mkv"
            mkvmerge -o "$tempname" "$file"
            Remove-Item "$file"
        }

        # Merge subtitles into mkv
        $mkv = Get-ChildItem *.mkv

        foreach ($file in $mkv)
        {
            $filename = $file.Name
            $tempname = [IO.Path]::GetFileNameWithoutExtension($file.Name)

            # Try to extract an episode identifier (S01E02, S01E01E02, etc.)
            $episodeID = $null
            if ($tempname -match '(?i)(S\d{2}E\d{2}(?:E\d{2})?)')
            {
                $episodeID = $Matches[1].ToUpper()
            }

            # Match subs by episode ID if available, otherwise fall back to stem prefix
            if ($episodeID)
            {
                Write-Host "Matching subs for $filename by episode ID: $episodeID"
                $matchingSubs = Get-ChildItem -Filter *.srt | Where-Object { $_.Name -match "(?i)$episodeID" }
            }
            else
            {
                Write-Host "No episode ID found in $filename — falling back to stem prefix match"
                $matchingSubs = Get-ChildItem -Filter "$tempname.*.srt"
            }

            if ($matchingSubs)
            {
                $subArgs    = $matchingSubs | ForEach-Object { "`"$($_.FullName)`"" }
                $mergedName = "$tempname.merged.mkv"

                Write-Host "Merging into: $filename"
                $cmd = "mkvmerge -o `"$mergedName`" `"$($file.FullName)`" $($subArgs -join ' ')"
                Invoke-Expression $cmd

                if ($LASTEXITCODE -eq 0)
                {
                    Remove-Item -Path $file.FullName
                    $matchingSubs | Remove-Item
                    Rename-Item -Path $mergedName -NewName $filename
                }
                else
                {
                    Write-Warning "mkvmerge failed for $filename — original files kept"
                    Remove-Item -Path $mergedName -ErrorAction SilentlyContinue
                }
            }
            else
            {
                Write-Host "No subtitles found for: $filename"
            }
        }
    }
}

Set-Location $original