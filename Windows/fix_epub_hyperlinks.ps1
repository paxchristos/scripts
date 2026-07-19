param(
    [Parameter(Mandatory)]
    [string]$EpubPath
)

# ── 1. Backup ─────────────────────────────────────────────────────────────────
$epubFull   = Resolve-Path $EpubPath
$backupPath = "$epubFull.bak"
Copy-Item $epubFull $backupPath
Write-Host "✔ Backup created: $backupPath"

# ── 2. Extract ────────────────────────────────────────────────────────────────
$zipPath    = [IO.Path]::ChangeExtension($epubFull, ".zip")
$extractDir = [IO.Path]::ChangeExtension($epubFull, "_extracted")

Copy-Item $epubFull $zipPath
Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force
Remove-Item $zipPath
Write-Host "✔ Extracted to: $extractDir"

# ── 3. Build anchor → footnote-number map from the notes file ─────────────────
#
# Strategy: the notes file has <div id="pageXXXX"> anchors. The paragraph
# immediately following each anchor starts with the footnote number — but OCR
# has mangled many of them (I→1, S→5, s→5, B→8, etc.) and some notes
# genuinely use a quote/apostrophe symbol as their marker.
#
# For notes that resolve to a clean digit: use that digit.
# For notes whose marker is a quote/symbol: mark them as "needs sequential fix".
# The sequential fix pass (step 4b) will renumber those using their position
# in the content file.

function Resolve-OcrChar([string]$ch) {
    switch -CaseSensitive ($ch) {
        'I'  { return '1' }
        'l'  { return '1' }
        'S'  { return '5' }
        's'  { return '5' }
        'B'  { return '8' }
        '$'  { return '5' }
        default { return $null }
    }
}

$notesFile = Get-ChildItem -Path $extractDir -Recurse -Filter "*_notes.html" |
             Select-Object -First 1

# anchorMap values are either a digit string (e.g. "17") or $null meaning
# "assign sequentially based on position in the content file"
$anchorMap = @{}

# Characters used as non-numeric footnote markers (quote/symbol stand-ins)
$symbolMarkerChars = [System.Collections.Generic.HashSet[char]]@(
    [char]0x22,   # " straight double quote
    [char]0x27,   # ' straight apostrophe
    [char]0x60,   # ` backtick
    [char]0x2018, # ' left single curly
    [char]0x2019, # ' right single curly
    [char]0x201C, # " left double curly
    [char]0x201D, # " right double curly
    [char]0x00B0  # ° degree sign
)

if ($notesFile) {
    Write-Host "✔ Found notes file: $($notesFile.Name)"
    $notesContent = Get-Content $notesFile.FullName -Raw -Encoding UTF8

    $notePattern = [regex]'(?s)<div[^>]+id="(page\d+)"[^>]*>.*?<p[^>]*>(.*?)</p>'
    $noteMatches = $notePattern.Matches($notesContent)

    foreach ($nm in $noteMatches) {
        $anchorId = $nm.Groups[1].Value
        $paraText = $nm.Groups[2].Value
        $plain    = [regex]::Replace($paraText, '<[^>]+>', '').Trim()
        if (-not $plain) { continue }

        $firstChar = $plain[0]

        # Starts with a quote/symbol → needs sequential assignment
        if ($symbolMarkerChars.Contains($firstChar)) {
            $anchorMap[$anchorId] = $null
            continue
        }

        # Walk chars to extract OCR-corrected leading number
        $token = ''
        foreach ($ch in $plain.ToCharArray()) {
            if ([char]::IsDigit($ch)) {
                $token += $ch
            } else {
                $sub = Resolve-OcrChar ([string]$ch)
                if ($null -ne $sub -and ($token.Length -eq 0 -or $token[-1] -match '\d')) {
                    $token += $sub
                } else {
                    break
                }
            }
        }

        if ($token -match '^\d+$') {
            $anchorMap[$anchorId] = $token   # resolved number
        } else {
            $anchorMap[$anchorId] = $null    # fallback: sequential
        }
    }

    Write-Host "✔ Built footnote map: $($anchorMap.Count) anchors"
    $resolved  = ($anchorMap.Values | Where-Object { $_ -ne $null }).Count
    $needsSeq  = ($anchorMap.Values | Where-Object { $_ -eq $null }).Count
    Write-Host "    Resolved to digit: $resolved"
    Write-Host "    Needs sequential:  $needsSeq"
} else {
    Write-Host "⚠ No notes file found — all footnotes will be numbered sequentially"
}

# ── 4. Fix hyperlinks in all content HTML files ───────────────────────────────
#
# For each file:
#   a) Find all footnote <a href="...#pageXXXX"> links in document order
#   b) For anchors with a known number → use it
#      For anchors with $null → assign the next sequential number for this file
#   c) Strip any old marker text from inside the <a>, replace with the number
#   d) Move the link to wrap only the number (unhyperlink the body text)

$linkPattern  = [regex]'(?s)(<a\b[^>]*href="[^"]*#(page\d+)"[^>]*>)([\s\S]*?)(</a>)'

$contentFiles = Get-ChildItem -Path $extractDir -Recurse -Include "*.xhtml","*.html","*.htm" |
                Where-Object { $notesFile -eq $null -or $_.FullName -ne $notesFile.FullName }

foreach ($file in $contentFiles) {
    $original = Get-Content $file.FullName -Raw -Encoding UTF8

    # ── Pass A: find all anchors in this file and assign numbers ──────────────
    # We need the sequential counter to assign numbers in document order.
    # To do this safely, we do two passes: first collect, then replace.

    $allAnchors = $linkPattern.Matches($original)

    # Build a map of anchorId → assigned number for THIS file
    # (sequential counter increments each time we see a $null-mapped anchor)
    $fileAnchorNumbers = @{}
    $seqCounter = 0

    # First, determine the starting sequence number by finding the last
    # known numeric footnote before the first unknown one, so numbering
    # flows correctly across the file.
    # Simpler approach: just count all links in order. Known numbers anchor
    # the sequence; unknowns fill in the gaps sequentially.
    #
    # Actually the cleanest approach: use the known numbers to set the counter,
    # and assign unknowns as "last known + n" where n is offset from that point.
    # But given the data, the simplest correct approach is:
    # Walk links in order. When we see a known number, record it.
    # When we see an unknown, assign lastKnown + gapCount.

    $lastKnownNum  = 0
    $unknownBuffer = [System.Collections.Generic.List[string]]::new()

    $orderedAnchors = @()
    foreach ($m in $allAnchors) {
        $orderedAnchors += $m.Groups[2].Value
    }

    # Two-pass: first scan to resolve all numbers in order
    $assignments = @{}
    $pending     = [System.Collections.Generic.List[string]]::new()

    foreach ($anchorId in $orderedAnchors) {
        if ($assignments.ContainsKey($anchorId)) { continue }  # already seen

        $mapped = if ($anchorMap.ContainsKey($anchorId)) { $anchorMap[$anchorId] } else { $null }

        if ($null -ne $mapped) {
            # Flush any pending unknowns using interpolation
            if ($pending.Count -gt 0) {
                $nextKnown = [int]$mapped
                $step = ($nextKnown - $lastKnownNum) / ($pending.Count + 1)
                $idx = 1
                foreach ($pid in $pending) {
                    $assignments[$pid] = [string][int][Math]::Round($lastKnownNum + $step * $idx)
                    $idx++
                }
                $pending.Clear()
            }
            $assignments[$anchorId] = $mapped
            $lastKnownNum = [int]$mapped
        } else {
            $pending.Add($anchorId)
        }
    }

    # Flush remaining pending (after the last known number)
    $offset = 1
    foreach ($pid in $pending) {
        $assignments[$pid] = [string]($lastKnownNum + $offset)
        $offset++
    }

    # ── Pass B: replace links in the HTML ─────────────────────────────────────
    $updated = $linkPattern.Replace($original, {
        param($m)

        $openTag  = $m.Groups[1].Value
        $anchorId = $m.Groups[2].Value
        $inner    = $m.Groups[3].Value
        $closeTag = $m.Groups[4].Value

        # Get the assigned number for this anchor
        $number = if ($assignments.ContainsKey($anchorId)) { $assignments[$anchorId] } else { $null }

        # If we have no number at all, leave untouched
        if (-not $number) { return $m.Value }

        # Strip any existing marker from the END of inner text
        # (digits, quote chars, degree sign)
        $cleanInner = [regex]::Replace($inner.TrimEnd(),
            '[\d\u2018\u2019\u201c\u201d''"`\u00B0]+$', '').TrimEnd()

        # If inner was ONLY a marker (nothing left), link is already scoped — just fix the marker
        if ([string]::IsNullOrWhiteSpace($cleanInner)) {
            return "$openTag$number$closeTag"
        }

        # Unhyperlink body text; wrap only the number
        return "$cleanInner$openTag$number$closeTag"
    })

    if ($updated -ne $original) {
        Set-Content $file.FullName $updated -Encoding UTF8 -NoNewline
        Write-Host "  ✎ Fixed: $($file.Name)"
    }
}

# ── 5. Repack as .epub ────────────────────────────────────────────────────────
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$outputEpub = $epubFull
if (Test-Path $outputEpub) { Remove-Item $outputEpub }

$zip = [IO.Compression.ZipFile]::Open($outputEpub, 'Create')

try {
    $mimetypeSrc = Join-Path $extractDir "mimetype"
    if (Test-Path $mimetypeSrc) {
        $entry  = $zip.CreateEntry("mimetype", [IO.Compression.CompressionLevel]::NoCompression)
        $writer = [IO.StreamWriter]::new($entry.Open())
        $writer.Write([IO.File]::ReadAllText($mimetypeSrc))
        $writer.Dispose()
    }

    Get-ChildItem -Path $extractDir -Recurse -File |
        Where-Object { $_.Name -ne "mimetype" } |
        ForEach-Object {
            $rel = $_.FullName.Substring($extractDir.Length + 1).Replace("\", "/")
            [IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                $zip, $_.FullName, $rel,
                [IO.Compression.CompressionLevel]::Optimal
            ) | Out-Null
        }
} finally {
    $zip.Dispose()
}

Write-Host "✔ Repacked: $outputEpub"

# ── 6. Cleanup ────────────────────────────────────────────────────────────────
Remove-Item $extractDir -Recurse -Force
Write-Host "✔ Done! Backup saved to: $backupPath"