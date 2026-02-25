$path = 'd:\Github\BanDoDuongThuyNoiDia\DTND-SongYen2.geojson'
$maxLine = 28619

$lines = Get-Content -Path $path
$ranges = New-Object System.Collections.Generic.List[object]

$i = 0
while ($i -lt $lines.Count - 1) {
    if ($lines[$i].Trim() -eq '{') {
        $isFeature = $false
        for ($k = $i + 1; $k -le [Math]::Min($i + 4, $lines.Count - 1); $k++) {
            if ($lines[$k] -match '"type"\s*:\s*"Feature"') {
                $isFeature = $true
                break
            }
        }

        if ($isFeature) {
            $depth = 0
            $objEnd = $i
            for ($j = $i; $j -lt $lines.Count; $j++) {
                $openCount = ([regex]::Matches($lines[$j], '\{')).Count
                $closeCount = ([regex]::Matches($lines[$j], '\}')).Count
                $depth += ($openCount - $closeCount)
                if ($depth -eq 0) {
                    $objEnd = $j
                    break
                }
            }

            $blockLines = $lines[$i..$objEnd]
            $hasInPoint = $false
            $inPointLine = 0
            for ($m = 0; $m -lt $blockLines.Count; $m++) {
                if ($blockLines[$m] -match 'InPointMap') {
                    $hasInPoint = $true
                    $inPointLine = $i + $m + 1
                    break
                }
            }

            if ($hasInPoint -and $inPointLine -le $maxLine) {
                $ranges.Add([pscustomobject]@{ Start = $i; End = $objEnd })
            }

            $i = $objEnd + 1
            continue
        }
    }

    $i++
}

$removed = $ranges.Count

for ($r = $ranges.Count - 1; $r -ge 0; $r--) {
    $start = $ranges[$r].Start
    $end = $ranges[$r].End

    $before = if ($start -gt 0) { $lines[0..($start - 1)] } else { @() }
    $after = if ($end + 1 -lt $lines.Count) { $lines[($end + 1)..($lines.Count - 1)] } else { @() }

    $lines = @($before + $after)
}

Set-Content -Path $path -Value $lines -Encoding UTF8
Write-Output "Removed feature blocks: $removed"
Write-Output "New line count: $($lines.Count)"