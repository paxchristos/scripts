##One Line 
##$original = get-location | select-object -expandproperty Path; $directories = Get-ChildItem -Directory -Recurse | Select-Object -expandproperty FullName; foreach ($directory in $directories) { cd "$directory"; $videos = Get-ChildItem *.mkv; foreach ($file in $videos) { $bitrate = MediaInfo.exe --Inform=General`;%OverallBitRate% $file; $bitrate = [math]::round($bitrate/1024, 2); $output = "$file has a bitrate of $bitrate KB/s"; add-content -Path $original\all_bitrates.txt -Value "$output"} cd $original}

##Original path for use throughout
$original = get-location | select-object -expandproperty Path
##output for all the bitrates it pulls 
$destination = "$original\all_bitrates.txt"

##Tests for the file, if it doesn't exist 
if (Test-Path -Path $filename -PathType Leaf)
{
	Remove-Item $filename
    New-Item -path $filename -ItemType File
}
else
{
	New-Item -path $filename -ItemType file
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
        #Variable pulls the bitrate from the file rounds it from bits/sec and converts it to kilobits/sec
        $bitrate = MediaInfo.exe --Inform=Video`;%BitRate% $file
        $bitrate = [math]::round($bitrate/1024, 0)
        $output = "$file has a bitrate of $bitrate KB/s"
        add-content -Path "$destination" -Value "$output"
    } 
    Set-Location "$original"
}