$sourceFolder = "C:\temp2\temp\google\Holding"
$destinationFolder = "C:\temp2\temp\google\Holding2"
$itemsPerFolder = 100

# Create the destination folder if it doesn't exist
if (-not (Test-Path $destinationFolder)) {
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
}

$files = Get-ChildItem $sourceFolder -File

$folderIndex = 1
$itemCount = 0

foreach ($file in $files) {
    $currentDestinationFolder = Join-Path $destinationFolder $folderIndex.ToString()

    # Create a new subfolder if the maximum item count has been reached
    if ($itemCount -eq 0) {
        New-Item -ItemType Directory -Path $currentDestinationFolder | Out-Null
    }

    $newPath = Join-Path $currentDestinationFolder $file.Name
    Move-Item -Path $file.FullName -Destination $newPath

    $itemCount++

    # If the maximum item count has been reached, reset the count and increment the folder index
    if ($itemCount -eq $itemsPerFolder) {
        $folderIndex++
        $itemCount = 0
    }
}
