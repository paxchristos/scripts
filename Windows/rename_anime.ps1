$files = Get-ChildItem *.* | Where-Object { ! $_.PSIsContainer }
$translations = Import-Csv -Path "C:\programs\scripts\translations.csv"

ForEach ($file in $files)
{
    $filePath = $file.FullName
    $fileName = $file.Name
    $newFileName = $fileName -replace '\[.*?\]', '' #'\[.*?\]|\(.*?\)', ''
    $newFileName = $newFileName -replace '\s{2,}', ''
    $newFileName = $newFileName.TrimStart()
    $newFileName = $newFileName -replace '(\s+\.mkv$)','.mkv'
    #Write-Host "$newFileName"
    foreach ($translation in $translations)
    {
        if ($newFileName.Contains(($translation.OldName)))
        {
            $newFileName = $newFileName -replace [regex]::Escape($translation.OldName), $translation.NewName
            #Write-Host "Match Found, $translation.OldName"
        }
        <# Be very careful sorting CSV files 
        
        #testing
        $japaneseName = $translations.OldName
        $testingFilename = $newFileName
        $testingFilename = $testingFilename -replace '\s\-\sS\d{2,}E\d{2,}', ''
        $testingFilename = $testingFilename -replace '\.[A-z0-9]{3}', ''
        Write-Host $testingFilename
        
        if ($testingFilename -match $japaneseName)
        {
            $newFileName = $newFileName -replace [regex]::Escape($translation.OldName), $translation.NewName
            Write-Host "Match Found, $translation.OldName"
        }
        
        #>
    }
    $regex = 'S(\d+) -\s(\d+)'
    if ($newFileName -match $regex)
    {
        $seasonNumber = [int]$Matches[1]
        $episodeNumber = [int]$Matches[2]
        $episodeNumberString = "{0:D2}" -f $episodeNumber
        $seasonNumberString = "{0:D2}" -f $seasonNumber
        $newFileName = $newFileName -replace $regex, "- S${seasonNumberString}E${episodeNumberString}"
    }
    <#else
    {
        $regex = '^(.*) - (\d+)'
        if ($newFileName -match $regex)
        {
            $seriesName = $Matches[1]
            $episodeNumber = [int]$Matches[2]
            $episodeNumberString = "{0:D2}" -f $episodeNumber
            $newFileName = "$seriesName - S01E${episodeNumberString}.mkv"
        }
    }#>
    
    Rename-Item -LiteralPath $filePath -NewName $newFileName
}