Get-ChildItem .\ -Recurse -Include "*.jpg", "*.png", "*.bmp", "*.gif", "*.jpeg" | ForEach-Object {
    $directory = $_.DirectoryName
    $filename = $_.Name
    $jsonPath = Join-Path $directory ($filename + ".json")
    $tags = Get-Content $jsonPath -Raw | ConvertFrom-Json
    $exifToolArgs = @(
        '-GPSAltitude<GeoDataAltitude',
        '-GPSLatitude<GeoDataLatitude',
        '-GPSLatitudeRef<GeoDataLatitude',
        '-GPSLongitude<GeoDataLongitude',
        '-GPSLongitudeRef<GeoDataLongitude',
        '-Keywords<Tags',
        '-Subject<Tags',
        '-Caption-Abstract<Description',
        '-ImageDescription<Description',
        '-DateTimeOriginal<PhotoTakenTimeTimestamp'
    )
    & exiftool.exe -tagsfromfile $jsonPath $exifToolArgs -overwrite_original "$directory\$filename"
}