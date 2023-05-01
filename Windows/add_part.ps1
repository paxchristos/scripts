$directories = Get-ChildItem -Directory -Recurse | Select-Object -ExpandProperty FullName
$originaldirectory = Get-Location | Select-Object -ExpandProperty Path

foreach ($directory in $directories)
{
    ##Changes directory to current working one
    Set-Location "$directory"
    
    $files = Get-ChildItem $directory -File
    if ($files.Count -gt 1)
    {
        $counter = 1
        foreach ($file in $files)
        {
            $newName = $file.BaseName + " - part" + $counter.ToString("D2") + $file.Extension
            Rename-Item $file.FullName $newName
            $counter++
        }
    }
    Set-Location $originaldirectory
}