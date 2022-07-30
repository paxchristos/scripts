### Gets large files and sorts them into an alphabetical list

##Variables used
$filename = "C:\temp\big_files.txt"
$tempname = "C:\temp\big_files"

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

##Actual script part
#Gets all the files in every subfolder then pipes (|) the response into checking if anything is greater than (-gt) 1000mb then pipes (|) the result into a text file (located @ $filename)
Get-ChildItem *.* -Recurse -File | Where-Object { $_.Length -gt 1gb}  | add-content $filename
#Reads out $filename contest before piping (|) it into sort (sort-object) which sorts A-to-Z before piping (|) it get-unique which removes any duplicates rom the list before piping (|) the now sorted list into a new file
get-content $filename | Sort-Object |  get-unique | Add-Content $tempname
#Removes the original, unsorted file
Remove-Item $filename
#Renames the sorted file to match the original file the list gets dumped into. 
Rename-Item $tempname $filename