$path = 'd:\Github\BanDoDuongThuyNoiDia\DTND-SongYen2.geojson'

Write-Host "Reading file..."
$content = Get-Content -Path $path -Raw -Encoding UTF8

Write-Host "Rounding coordinate values to 6 decimal places..."
# Pattern to match numbers with more than 6 decimal places
$pattern = '(\d+\.\d{6})\d+'
$newContent = $content -replace $pattern, '$1'

Write-Host "Writing file..."
Set-Content -Path $path -Value $newContent -Encoding UTF8 -NoNewline

Write-Host "Done! All coordinates rounded to 6 decimal places."
