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

$wholeTree = Get-ChildItem -Directory -Recurse
$original = Get-Location | Select-Object -ExpandProperty Path
foreach ($subfolder in $wholeTree)
{
    $folder_check = "Subs"

    
    $finalFolder = [System.IO.Path]::GetFileName($($subfolder.FullName))
    #$finalFolder
    ## Debug exit
    #Exit
    ##
    if ($finalFolder -ne $folder_check)
    {
        #Write-Output "Skipping $FinalFolder"
    }
    else
    {
        Set-Location $subfolder.FullName
        $directories = Get-ChildItem -Directory -Recurse | Select-Object -ExpandProperty FullName

        foreach ($directory in $directories)
        {
            Push-Location $directory
            $folderName = [System.IO.Path]::GetFileName($directory)
        
            $subs = Get-ChildItem -Filter *.srt -File

            foreach ($file in $subs)
            {

                $newName = $null
                switch ($file.Name)
                {
                    "2_eng,English (forced).srt" { $newName = "$folderName.en.srt" }
                    "3_eng,English (SDH).srt" { $newName = "$folderName.en1.srt" }
                    "2_eng,English (SDH)" { $newName = "$folderName.en2.srt" }
                    "5_English.srt" { $newName = "$folderName.en3.srt" }
                    "6_English.srt" { $newName = "$folderName.en4.srt" }
                    default { continue }  # Skip if it doesn't match any case
                }
                if ($newName)
                {
                    try
                    {
                        Rename-Item -Path $file.FullName -NewName $newName -ErrorAction Stop    
                    }
                    catch
                    {
                        Write-output "Failed to rename`n$($file.Name)`nExiting now`n$_"
                        exit
                    }
                }
                else
                {
                    # File didn't match known list, remove it
                    try
                    {
                        Write-Host "Removing unmatched file: $($file.Name)"
                        Remove-Item -Path $file.FullName -Force -ErrorAction Stop
                    }
                    catch
                    {
                        Write-Warning "Failed to remove $($file.Name): $_"
                    }
                }
                
            }
            Pop-Location
        }

        
        Get-ChildItem *.srt -Recurse | Move-Item -Destination ..\

        ## Remuxes mp4 files into mkv
        Set-Location ..\ 

        $mp4 = Get-ChildItem *.mp4

        foreach ($file in $mp4)
        {
            Write-Host "$file"
            $tempname = [System.IO.Path]::GetFileNameWithoutExtension($file)
            $tempname = $tempname + ".mkv"
            mkvmerge -o "$tempname" "$file"
            Remove-Item "$file"
        }

        $mkv = Get-ChildItem *.mkv

        foreach ($file in $mkv)
        {
            $filename = $file.name
            $tempname = [io.path]::GetFileNameWithoutExtension($file.name)

            $suffixes = @(".en.srt", ".en1.srt", ".en2.srt", ".en3.srt", ".en4.srt")
            foreach ($suffix in $suffixes)
            {
                $subtitle = "$tempname$suffix"
                if (Test-Path -Path $subtitle -PathType Leaf)
                {
                    mkvmerge -o "$tempname" "$filename" "$subtitle"
                    Remove-Item -Path "$file"
                    Remove-Item -Path "$subtitle"
                    Rename-Item -Path "$tempname" -NewName "$filename"
                }
            }
        }
    }
}
Set-Location $original
<#

        #$folderName
        ## debug exit 
        #Exit
        ## 


old parts:
            <# case switch test
            if ($file.Name -eq $matching1)
            {
                $newName = "$($folderName).en.srt"
                Rename-Item -Path $file.FullName -NewName $newName
            }
            elseif ($file.Name -eq $matching2)
            {
                $newName = "$($folderName).en1.srt"
                Rename-Item -Path $file.FullName -NewName $newName
            }
            elseif ($file.Name -eq $matching3)
            {
                $newName = "$($folderName).en2.srt"
                Rename-Item -Path $file.FullName -NewName $newName
            }
            elseif ($file.Name -eq $matching4)
            {
                $newName = "$($folderName).en3.srt"
                Rename-Item -Path $file.FullName -NewName $newName
            }
            elseif ($file.Name -eq $matching5)
            {
                $newName = "$($folderName).en4.srt"
                Rename-Item -Path $file.FullName -NewName $newName
            }#>
#>