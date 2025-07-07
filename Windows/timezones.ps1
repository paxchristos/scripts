# Launch Excel
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $true
$wb = $excel.Workbooks.Add()
$ws = $wb.Sheets.Item(1)

$utcTime = Get-Date
$timeZones = @(
"UTC-2",
"Dateline Standard Time",
"UTC-11",
"Hawaiian Standard Time",
"Marquesas Standard Time",
"Alaskan Standard Time",
"Pacific Standard Time",
"US Mountain Standard Time",
"Central Standard Time",
"Eastern Standard Time",
"Atlantic Standard Time",
"Newfoundland Standard Time",
"Argentina Standard Time",
"Azores Standard Time",
"Greenwich Standard Time",
"Central Europe Standard Time",
"Israel Standard Time",
"Turkey Standard Time",
"Iran Standard Time",
"Arabian Standard Time",
"Afghanistan Standard Time",
"Pakistan Standard Time",
"India Standard Time",
"Nepal Standard Time",
"Central Asia Standard Time",
"Myanmar Standard Time",
"SE Asia Standard Time",
"China Standard Time",
"Aus Central W. Standard Time",
"Tokyo Standard Time",
"AUS Central Standard Time",
"AUS Eastern Standard Time",
"Lord Howe Standard Time",
"Central Pacific Standard Time",
"New Zealand Standard Time",
"Chatham Islands Standard Time",
"Samoa Standard Time",
"Line Islands Standard Time"
)

# === Header Row 1: Time Zone Names ===
$ws.Cells.Item(1, 1).Value2 = "UTC Hour"
for ($i = 0; $i -lt $timeZones.Count; $i++) {
    $ws.Cells.Item(1, $i + 2).Value2 = $timeZones[$i]
}

# === Header Row 2: Time Zone Offsets ===
$ws.Cells.Item(2, 1).Value2 = "Offset"
for ($i = 0; $i -lt $timeZones.Count; $i++) {
    $tz = [System.TimeZoneInfo]::FindSystemTimeZoneById($timeZones[$i])
    $offset = $tz.BaseUtcOffset

    # If in daylight saving time, adjust
    if ($tz.IsDaylightSavingTime([DateTime]::UtcNow)) {
        $offset = $offset.Add([TimeSpan]::FromHours(1))
    }

    $offsetHours = "{0:+00;-00}:{1:00}" -f $offset.Hours, [Math]::Abs($offset.Minutes)
    $ws.Cells.Item(2, $i + 2).Value2 = $offsetHours
}

# === Data Rows: Each UTC Hour ===
for ($h = 0; $h -lt 24; $h++) {
    $utcTime = (Get-Date -Date "00:00").Date.AddHours($h)
    $row = $h + 3  # Because we used rows 1 and 2 for headers

    $ws.Cells.Item($row, 1).Value2 = $utcTime.ToString("HH:mm")

    for ($i = 0; $i -lt $timeZones.Count; $i++) {
        $tz = [System.TimeZoneInfo]::FindSystemTimeZoneById($timeZones[$i])
        $converted = [System.TimeZoneInfo]::ConvertTimeFromUtc($utcTime, $tz)
        $ws.Cells.Item($row, $i + 2).Value2 = $converted.ToString("HH:mm")
    }
}

# Autofit columns
$ws.Columns.AutoFit()