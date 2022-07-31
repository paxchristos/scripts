##Script to go through all files and repair tags

##Gets the original path
$original = get-location | select-object -expandproperty Path

##Creates an array of all Directories to iterate through
$directories = Get-ChildItem -Directory -Recurse | Select-Object -expandproperty FullName
foreach ($directory in $directories) 
{ 
    ##Sets the location and the checks for mkv files
    Set-Location "$directory"
    $videos = Get-ChildItem *.mkv
    ##If there are any mkv files, it iterates thorugh them fixing the tags
    foreach ($file in $videos) 
    {
        $outputFile = Split-Path $file -leaf
        write-host "Working on $outputFile"
        mkvpropedit --add-track-statistics-tags "$file"
    }
    ##Goes back to the original directory and starts 
    Set-Location $original
}