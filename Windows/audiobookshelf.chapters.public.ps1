$apiToken = "API_KEY"
$uri = "https://abs.example.com/api/libraries"
$headers = @{ "Authorization" = "Bearer $apiToken" }

$baseOutputPath = "C:\temp\audiobooks\api\jsons"

$response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

# Convert response to JSON-formatted string
$jsonString = $response | ConvertTo-Json

# Define the path to the JSON file
$jsonFilePath = "libraries\response.json"
$outputFilePath = Join-Path -Path $baseOutputPath -ChildPath "$jsonFilePath"
# Save the JSON string to the JSON file
$jsonString | Out-File -FilePath $outputFilePath -Force

#Write-Host "Response saved to $outputFilePath"

$librariesResponse = Invoke-RestMethod -Uri "https://abs.example.com/api/libraries" -Headers @{ "Authorization" = "Bearer $apiToken" }

$audibleLibraryIDs = @()

foreach ($library in $librariesResponse.libraries)
{
    if ($library.provider -eq "audible")
    {
        $audibleLibraryIDs += $library.id
    }
}


# Save the array of audible library IDs to a file
$outputFileName = "audibleLibraryIDs.json"
$outputFilePath = Join-Path -Path $baseOutputPath -ChildPath "libraries\$outputFileName"
$audibleLibraryIDs | ConvertTo-Json | Out-File -FilePath $outputFilePath  -Force
#Write-Host "Audible library IDs saved to $outputFilePath"

$audibleLibraryIDs = Get-Content -Path $outputFilePath | ConvertFrom-Json

foreach ($libraryID in $audibleLibraryIDs)
{
    $libraryItemsResponse = Invoke-RestMethod -Uri "https://abs.example.com/api/libraries/$libraryID/items?sort=media.metadata.title&limit=0" -Headers @{ "Authorization" = "Bearer $apiToken" }
    
    $outputFileName = "libraryItems_${libraryID}.json"
    $outputFilePath = Join-Path -Path $baseOutputPath -ChildPath "items\$outputFileName"
    
    $libraryItems = $libraryItemsResponse.results

    $libraryItems | ConvertTo-Json -Depth 5 | Out-File -FilePath $outputFilePath -Force
    #Write-Host "Library items for Library ID $libraryID saved to $outputFilePath"
}

foreach ($libraryID in $audibleLibraryIDs)
{
    $libraryItems = Get-Content -Path "C:\temp\audiobooks\api\jsons\items\libraryItems_${libraryID}.json" | ConvertFrom-Json

    $itemsWithASIN = @()
    foreach ($item in $libraryItems)
    {
        if ($item.media.metadata.asin -ne $null -and $item.media.metadata.asin -ne '')
        {
            $itemsWithASIN += $item
        }
    }

    $outputFileName = "itemswithASIN_${libraryID}.json"
    $outputFilePath = Join-Path -Path $baseOutputPath -ChildPath "ASIN\$outputFileName"

    $itemsWithASIN | ConvertTo-Json -Depth 5 | Out-File -FilePath $outputFilePath -Force
    #Write-Host "Items with ASIN for Library ID $libraryID saved to $outputFilePath"
}

foreach ($libraryID in $audibleLibraryIDs)
{
    $itemsWithASIN = Get-Content -Path "C:\temp\audiobooks\api\jsons\ASIN\itemswithASIN_${libraryID}.json" | ConvertFrom-Json
    foreach ($item in $itemsWithASIN)
    {
        $random_start = Get-Random -Minimum 1 -Maximum 20
        Start-Sleep -Seconds $random_start
        $asin = $item.media.metadata.asin
        if ($item.media.metadata.language -match "Japanese")
        {
            $countrycode = "jp"
        }
        else
        {
            $countrycode = "us"
        }
        try 
        {
            $chaptersResponse = Invoke-RestMethod -Uri "https://abs.example.com/api/search/chapters?asin=$asin&region=$countrycode" -Headers @{ "Authorization" = "Bearer $apiToken" }
    
            if ($null -ne $chaptersResponse.error)
            {
                # Log the error message from the response
                $errorMessage = "API Error for $($item.media.metadata.title) by $($item.media.metadata.authors.name) - Error: $($chaptersResponse.error)"
                $logPath = "C:\temp\audiobooks\missing.asin.log"
                $errorMessage | Out-File -Append -FilePath $logPath
            }
            else
            {
                $chapters = $chaptersResponse.chapters

                $chaptersPayload = @()
                $idCounter = 0 

                foreach ($chapter in $chapters)
                {
                    $endOffsetSec = $chapter.startOffsetSec + [math]::Round($chapter.lengthMs / 1000)
                    $chapterPayload = @{
                        "id"    = $idCounter
                        "start" = $chapter.startOffsetSec
                        "end"   = $endOffsetSec
                        "title" = $chapter.title
                    }
                    $chaptersPayload += $chapterPayload
                    $idcounter++
                }

                $rootPayload = @{
                    "chapters" = $chaptersPayload
                }

                $chaptersPayloadJson = $rootPayload | ConvertTo-Json
                $replaceChaptersUri = "https://abs.example.com/api/items/$($item.id)/chapters"
                $headers = @{ "Content-Type" = "application/json"; "Authorization" = "Bearer $apiToken" }

                Invoke-RestMethod -Uri $replaceChaptersUri -Method Post -Headers $headers -Body $chaptersPayloadJson
                $book_updated = "Chapters replaced for $($item.media.metadata.title) by $($item.media.metadata.authors.name)"  
                $logPath = "C:\temp\audiobooks\updated_books.log"
                Write-Host $book_updated
                Add-Content -Value "$book_updated" -Path $logPath -Encoding Ascii
            }
        }
        catch
        {
            # Handle other types of errors (e.g., network issues, etc.)
            $errorMessage = "Failed request for $($item.media.metadata.title) by $($item.media.metadata.authors.name) - Error: $_"
            $logPath = "C:\temp\audiobookshelf\other_errors.log"
            $errorMessage | Out-File -Append -FilePath $logPath
        }
    }
}
