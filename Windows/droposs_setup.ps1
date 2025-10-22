## Assumes only installers + extra files needed to install a program in the directory structure scanned
## Moves the Installer + any extra files to a new directory created that Matches the necessary path

[CmdletBinding()]
param (
    [string]
    $workingPath
)

if ([string]::IsNullOrEmpty($workingPath))
{
    $workingPath = (Get-Location).Path #in case a path isn't passed, sets the current directory as the working path
}

#Recusively Gets all installers
$listfOfFiles = Get-ChildItem -Path $workingPath -filter *.exe -Recurse

foreach ($installer in $listfOfFiles)
{
    #Cleared a variable used later
    $extraFiles = $null
    #Variable used to create a folder structure needed for DropOSS to work correctly
    #$directoryName = Join-Path -Path (Join-Path $installer.Directory $installer.BaseName) "Version 1.0"
    $directoryName = $installer.Directory + '\' + $installer.BaseName + '\Version 1.0'
    #Creates the folder as needed
    New-Item -LiteralPath $directoryName -ItemType Directory
    #Moves the installer to the new folder
    Move-Item -LiteralPath $installer.FullName -Destination $directoryName
    #Variable to used to filter for extra files
    $extraFilesCheck = $installer.BaseName + '*'
    #Scans for extra files
    $extraFiles = Get-ChildItem -LiteralPath $installer.Directory  -filter $extraFilesCheck
    #if it finds any, moves then 
    if ($null -ne $extraFiles)
    {
        foreach ($file in $extraFiles)
        {
            Move-Item -LiteralPath $file.FullName -Destination $directoryName
        }
    }
}