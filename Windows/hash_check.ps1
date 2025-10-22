$RootPath = "C:\temp\hold"
$OutputCsv = "C:\temp\hold\HashMismatches.csv"

$Results = @()

$Results = @()

# Traverse into MD5 folders
Get-ChildItem -Path $RootPath -Directory -Recurse | Where-Object { $_.Name -ieq 'MD5' } | ForEach-Object {
    $md5Folder = $_
    
    # Game name = parent of version folder
    $gameName = $md5Folder.Parent.Parent.Name

    # Get .md5 files inside this MD5 folder
    Get-ChildItem -literalPath $md5Folder.FullName -Filter *.md5 | ForEach-Object {
        $md5File = $_
        $md5Content = Get-Content -LiteralPath $md5File.FullName

        foreach ($line in $md5Content) {
            # Skip comments or empty lines
            if ($line.Trim().StartsWith(";") -or [string]::IsNullOrWhiteSpace($line)) {
                continue
            }

            # Match: <hash> *..\filename
            if ($line -match '^(?<hash>[0-9a-fA-F]{32})\s+\*\.\.\\(?<file>.+)$') {
                $expectedHash = $matches['hash'].ToLower()
                $fileName     = $matches['file']

                # filePath should be relative to the version folder (parent of MD5)
                $versionFolder = $md5Folder.Parent
                $filePath = Join-Path $versionFolder.FullName $fileName

                if (Test-Path -LiteralPath $filePath) {
                    Write-Output "Running Hash on $filePath`nThis might take a while..."
                    $actualHash = (Get-FileHash -LiteralPath $filePath -Algorithm MD5).Hash.ToLower()
                    if ($actualHash -ne $expectedHash) {
                        $Results += [pscustomobject]@{
                            GameName = $gameName
                            FileName = $fileName
                        }
                    }
                } else {
                    # File listed in md5 but missing
                    $Results += [pscustomobject]@{
                        GameName = $gameName
                        FileName = "$fileName (MISSING)"
                    }
                }
            }
        }
    }
}

# Export mismatches to CSV
if ($Results.Count -gt 0) {
    $Results | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8
    Write-Host "Mismatches found. Saved to $OutputCsv"
} else {
    Write-Host "All files matched."
}