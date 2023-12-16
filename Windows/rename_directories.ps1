# Define the directory path where you want to rename folders
$directoryPath = Get-Location | Select-Object -ExpandProperty Path

# Get a list of all folders in the specified directory
$folders = Get-ChildItem -Path $directoryPath -Directory

# Loop through each folder and rename them according to the rules
foreach ($folder in $folders)
{
    $newName = $folder.Name -replace '\.', ' '         # Replace periods with spaces
    $newName = $newName -replace '(\d{4}).*', '($1)'  # Put parentheses around the 4 numbers
    $newName = (Get-Culture).TextInfo.ToTitleCase($newName)

    #Write-Host "Old Name: $($folder.Name)"
    #Write-Host "New Name: $($newName)"

    #Check if the folder contains MKV files
    $files = Get-ChildItem -LiteralPath $folder.FullName -File
        
    foreach ($file in $files)
    {
        $fileExtension = $file.Extension
        #Write-Host $fileExtension
        if ($fileExtension -eq ".txt")
        {
            # This is a .txt or .nfo file, delete it
            #Write-Host $File.FullName
            Remove-Item -LiteralPath $file.FullName -Force
        }
        if ($fileExtension -eq ".nfo")
        {
            # This is a .txt or .nfo file, delete it
            #Write-Host $File.FullName
            Remove-Item -LiteralPath $file.FullName -Force
        }
        if ($fileExtension -eq ".jpg")
        {
            # This is a .txt or .nfo file, delete it
            #Write-Host $File.FullName
            Remove-Item -LiteralPath $file.FullName -Force
        }
        if ($fileExtension -eq ".exe")
        {
            # This is a .txt or .nfo file, delete it
            #Write-Host $File.FullName
            Remove-Item -LiteralPath $file.FullName -Force
        }
        if ($fileExtension -eq ".sfv")
        {
            # This is a .txt or .nfo file, delete it
            #Write-Host $File.FullName
            Remove-Item -LiteralPath $file.FullName -Force
        }
    }
        
    $mkvFiles = Get-ChildItem -LiteralPath $folder.Name -Filter *.mkv -File

    if ($mkvFiles.Count -gt 0)
    {
        # Loop through each MKV file and rename them using the same rules
        foreach ($mkvFile in $mkvFiles)
        {
            $fileExtension = $mkvFile.Extension
            $newFileName = $mkvFile.Name -replace '\.', ' '         # Replace periods with spaces
            $newFileName = $newFileName -replace '(\d{4}).*', '($1)'  # Put parentheses around the 4 numbers
            $newFileName = (Get-Culture).TextInfo.ToTitleCase($newFileName)
            $newFileName += $fileExtension

            Write-Host "Old Name: $($mkvFile.Name)"
            Write-Host "New Name: $($newFileName)"

            # Rename the MKV file
            Rename-Item -literalPath $mkvFile.FullName -NewName $newFileName -Force
        }
    }

    $srtFiles = Get-ChildItem -LiteralPath $folder.Name -Filter *.srt -File

    if ($srtFiles.Count -gt 0)
    {
        # Loop through each SRT file and rename them using the same rules
        foreach ($srtFile in $srtFiles)
        {
            $fileExtension = $srtFile.Extension
            $newFileName = $srtFile.Name -replace '\.', ' '         # Replace periods with spaces
            $newFileName = $newFileName -replace '(\d{4}).*', '($1)'  # Put parentheses around the 4 numbers
            $newFileName = (Get-Culture).TextInfo.ToTitleCase($newFileName)
            $newFileName += $fileExtension

            Write-Host "Old Name: $($srtFile.Name)"
            Write-Host "New Name: $($newFileName)"

            # Rename the SRT file
            Rename-Item -literalPath $srtFile.FullName -NewName $newFileName -Force
        }
    }

    # Rename the folder
    Rename-Item -LiteralPath $folder.FullName -NewName $newName -Force
}
