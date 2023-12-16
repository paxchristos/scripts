# Get the current directory as the starting point
$startingDirectory = Get-Location

# Define a function to add the folder name as a prefix to a file
function AddFolderNameAsPrefixToFile($filePath) {
    $folderName = (Get-Item (Split-Path -Path $filePath)).Name
    $fileName = ($filePath | Split-Path -Leaf)
    $newFileName = "${folderName} - ${fileName}"
    Rename-Item -Path $filePath -NewName $newFileName
}

#Recursively process files in the current directory and its subdirectories
Get-ChildItem -Path $startingDirectory -File -Recurse | ForEach-Object {
    AddFolderNameAsPrefixToFile $_.FullName
}

# Move all files to the current directory
Get-ChildItem -Path $startingDirectory -File -Recurse | ForEach-Object {
    $newPath = Join-Path $startingDirectory $_.Name
    Move-Item -Path $_.FullName -Destination $newPath
}

# Use -WhatIf for testing to see what changes would be made
# Remove -WhatIf to actually rename and move the files
