$path = 'd:\Github\BanDoDuongThuyNoiDia\DTND-SongYen2.geojson'
$rangeStart = 17112
$rangeEnd = 28619

$lines = Get-Content -Path $path
$matches = Select-String -Path $path -Pattern 'InPointMap' | Where-Object { $_.LineNumber -ge $rangeStart -and $_.LineNumber -le $rangeEnd }

$ranges = New-Object System.Collections.Generic.List[object]
$seen = @{}

foreach ($match in $matches) {
    $lineIndex = $match.LineNumber - 1

    $featureTypeLine = $lineIndex
    while ($featureTypeLine -ge 0 -and ($lines[$featureTypeLine] -notmatch '^\s*"type"\s*:\s*"Feature"\s*,?\s*$')) {
        $featureTypeLine--
    }
    if ($featureTypeLine -lt 0) { continue }

    $objStart = $featureTypeLine
    while ($objStart -ge 0 -and $lines[$objStart].Trim() -ne '{') {
        $objStart--
    }
    if ($objStart -lt 0) { continue }

    $depth = 0
    $objEnd = $objStart
    for ($j = $objStart; $j -lt $lines.Count; $j++) {
        $openCount = ([regex]::Matches($lines[$j], '\{')).Count
        $closeCount = ([regex]::Matches($lines[$j], '\}')).Count
        $depth += ($openCount - $closeCount)
        if ($depth -eq 0) {
            $objEnd = $j
            break
        }
    }

    $key = "$objStart|$objEnd"
    if (-not $seen.ContainsKey($key)) {
        $seen[$key] = $true
        $ranges.Add([pscustomobject]@{ Start = $objStart; End = $objEnd })
    }
}

$removed = $ranges.Count

foreach ($r in ($ranges | Sort-Object Start -Descending)) {
    $before = if ($r.Start -gt 0) { $lines[0..($r.Start - 1)] } else { @() }
    $after = if ($r.End + 1 -lt $lines.Count) { $lines[($r.End + 1)..($lines.Count - 1)] } else { @() }
    $lines = @($before + $after)
}

Set-Content -Path $path -Value $lines -Encoding UTF8
Write-Output "Removed feature blocks: $removed"
Write-Output "New line count: $($lines.Count)"