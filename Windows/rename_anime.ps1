$files = Get-ChildItem *.* | Where-Object { ! $_.PSIsContainer }
$translations = Import-Csv -Path "C:\programs\scripts\translations.csv"

ForEach ($file in $files)
{
    $filePath = $file.FullName
    $fileName = $file.Name
    $newFileName = $fileName -replace '\[.*?\]', '' #'\[.*?\]|\(.*?\)', ''
    $newFileName = $newFileName -replace '\s{2,}', ''
    $newFileName = $newFileName.TrimStart()
    foreach ($translation in $translations)
    {
        if ($newFileName.Contains($translation.OldName))
        {
            $newFileName = $newFileName -replace [regex]::Escape($translation.OldName), $translation.NewName
        }
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
    else
    {
        $regex = '^(.*) - (\d+)'
        if ($newFileName -match $regex)
        {
            $seriesName = $Matches[1]
            $episodeNumber = [int]$Matches[2]
            $episodeNumberString = "{0:D2}" -f $episodeNumber
            $newFileName = "$seriesName - S01E${episodeNumberString}.mkv"
        }
    }
    Rename-Item -LiteralPath $filePath -NewName $newFileName
}