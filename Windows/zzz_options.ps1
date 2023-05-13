#bard

# Import the Sonarr PowerShell module
Import-Module Sonarr

# Get the list of files in the current directory
$files = Get-ChildItem -Recurse

# For each file, get the series name from the filename
foreach ($file in $files)
{
    $seriesName = $file.Name.Split(" - ")[0]

    # Call the Sonarr API to import the file
    Import-SonarrFile -Series $seriesName -Path $file.FullName
}

#ChatGPT

$file = "example-series-name - S01E01.mkv"
$regex = "^(?<series>.+) - S(?<season>\d+)E(?<episode>\d+).mkv$"
if ($file -match $regex) {
    $seriesName = $Matches["series"]
    $seasonNumber = [int]$Matches["season"]
    $episodeNumber = [int]$Matches["episode"]
}


$apiKey = "your-api-key-here"
$baseUrl = "http://localhost:8989/api"


$searchUrl = "$baseUrl/series/lookup?apikey=$apiKey&term=$seriesName"


$searchResults = Invoke-RestMethod -Uri $searchUrl -Method Get
$series = $searchResults[0]
$seriesId = $series.id

$addUrl = "$baseUrl/command?apikey=$apiKey"


$body = @{
    name = "downloadedepisodesscan"
    seriesId = $seriesId
    seasonNumber = $seasonNumber
    episodeNumber = $episodeNumber
    paths = @($file)
} | ConvertTo-Json

Invoke-RestMethod -Uri $addUrl -Method Post -Body $body -ContentType "application/json"


#bing