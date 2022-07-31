##One Line 
##$original = get-location | select-object -expandproperty Path; $directories = Get-ChildItem -Directory -Recurse | Select-Object -expandproperty FullName; foreach ($directory in $directories) { cd "$directory"; $videos = Get-ChildItem *.mkv; foreach ($file in $videos) { $bitrate = MediaInfo.exe --Inform=General`;%OverallBitRate% $file; $bitrate = [math]::round($bitrate/1024, 2); $output = "$file has a bitrate of $bitrate KB/s"; add-content -Path $original\all_bitrates.txt -Value "$output"} cd $original}

##Original path for use throughout
$original   = get-location | select-object -expandproperty Path
$mpeg       = "MPEG-4"

##output for all the bitrates it pulls 
$destination = "$original\mpeg4.txt"

##Tests for the file, if it doesn't exist 
if (Test-Path -Path $destination -PathType Leaf)
{
	Remove-Item $destination
    [void](New-Item -path $destination -ItemType File)
}
else
{
	[void](New-Item -path $destination -ItemType file)
}

#Gets all the sub-directories and stores it an array using only the Full Path
$directories = Get-ChildItem -Directory -Recurse | Select-Object -expandproperty FullName

#for loop that iterates through each directory found by the previous array
foreach ($directory in $directories) 
{ 
    #Changes the current directory
    Set-Location "$directory"

    #Searches to see if there are any videos in the subfolder
    $videos = Get-ChildItem *.mkv
    #If there are any video files in the subdirectory, it iterates through them here
    foreach ($file in $videos)
    {
        #Variable pulls the format from the file if it matches the format saves the path to a file for remuxing later.
        $format = MediaInfo.exe --Inform=General`;%Format% $file
        if ($format -eq $mpeg)
        {
            add-content -Path "$destination" -Value "$file"         
        }
    } 
    Set-Location "$original"
}