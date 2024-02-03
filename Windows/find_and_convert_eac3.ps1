$directories = Get-ChildItem -Directory -Recurse | Select-Object -ExpandProperty FullName
$originaldirectory = Get-Location | Select-Object -ExpandProperty Path
$logFile = "C:\temp\logs\remux_from_eac3.log"
$skipFile = ".skip_ac3"
$currentTime = Get-Date -Format "MM/dd/yyyy hh:mm"

##cleanup file & folder names so powershell doesn't throw a fit
(Get-ChildItem -Directory -Recurse) | Rename-Item -NewName { $_.Name -replace "[^\p{L}\p{Nd}/./\s/-/_/(/)]+" }
(Get-ChildItem -File -Recurse) | Rename-Item -NewName { $_.Name -replace "[^\p{L}\p{Nd}/./\s/-/_/(/)]+" }

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

    if (Test-Path $skipFile -PathType Leaf)
    {
        Write-Host "Skipping processing in $directory. Found $skipFile."
        continue  # Skip to the next directory
    }

    # Get all MKV files in the specified folder
    $mkvFiles = Get-ChildItem -Path $sourceFolder -Filter *.mkv

    foreach ($mkvFile in $mkvFiles)
    {
        # Get information about the audio tracks using mediainfocli
        $mediaInfo = & mediainfo --Inform="Audio;%Format%`t%Channels%`t%BitRate%" $mkvFile.FullName

        # Loop through each line of audio track information
        foreach ($audioInfo in $mediaInfo.Split("`n"))
        {
            # Split the line into format, channels, and bitrate
            $audioInfoParts = $audioInfo -split "`t"
            $format = $audioInfoParts[0]

            # Check if the format is eac3
            if ($format -like "E*")
            {
                $to_delete = $false
                try
                {
                    # Construct the output file name (assuming you want to append _converted to the original file name)
                    $outputFile = [System.IO.Path]::ChangeExtension($mkvFile.FullName, "ac3")
                    $tempFile = $mkvFile.FullName -replace ".mkv", "_converted.mkv"

                    # Use eac3to to extract and convert the audio track to AC3
                    & eac3to $mkvFile.FullName $outputFile -downStereo -192

                    # Use ffmpeg to set the bitrate of the AC3 file
                    & mkvmerge -o $tempFile --track-name 0:English --default-track 0:true --language 0:en $outputFile --language 0:en --default-track 0:false $mkvFile.FullName
                    $to_delete = $true
                    Add-Content -Path $logFile -Value "$original has been remuxed from EAC3 to AC3 Stereo"
                }
                catch
                {
                    Write-host "Operation Failed for $($mkvFile.FullName)"
                    $to_delete = $false
                }
                if ($to_delete)
                {
                    # Optional: Remove the intermediate converted file
                    Remove-Item $outputFile
                    Remove-Item -LiteralPath $mkvFile.FullName
                    Rename-Item $tempFile $mkvFile.FullName
                }
            }
        }
    }
    # Create .skip_ac3 file in the directory to mark it as processed
    [void](New-Item -Path $skipFile -ItemType File)

    Set-Location $originaldirectory
}

