###Used to find any mkv files that aren't encoded as hevc
##Variables used
##Creates an array of all MKV files
$mkv = Get-ChildItem *.mkv -Recurse -File
## idea
#$mkv = [System.IO.Directory]::EnumerateFiles($pwd, '*.*', 'AllDirectories')
$format = "FLAC"
$filename = "C:\temp\not_hevc.txt"
$tempname = "C:\temp\not_hevc"

#Checks for the file, if it exists deletes then creates it
if (Test-Path -Path $filename -PathType Leaf)
{
	Remove-Item $filename
    New-Item -path $filename -ItemType File
}
else
{
	New-Item -path $filename -ItemType file
}

#Iterates through each mkv that was found earlier
foreach ($file in $mkv)
{
    #pulls the format using media info
    $format = mediainfo.exe --Inform="Audio;%Format%" "$file"

    ##DEBUG STATEMENTS##
    #Write-host $file
    #Write-Host $format

    #if the format doesn't match hevc then it adds the path to $filename
    if ($format -ne $hevc)
    {
        $output = $format + " - " + $file 
        add-content -Path $filename -Value "$($output)"

        ## DEBUG STATEMENT ##
        #Write-Host $output
    }

}
#Reads out $filename contest before piping (|) it into sort (sort-object) which sorts A-to-Z before piping (|) it get-unique which removes any duplicates rom the list before piping (|) the now sorted list into a new file
get-content $filename | Sort-Object |  get-unique | Add-Content $tempname
#Removes the original, unsorted file
Remove-Item $filename
#Renames the sorted file to match the original file the list gets dumped into. 
Rename-Item $tempname $filename