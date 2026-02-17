$uvCmd = Get-Command uv -ErrorAction SilentlyContinue
if ($uvCmd) {
    Write-Host $uvCmd.Source
} else {
    # Check common locations
    $paths = @(
        "$env:USERPROFILE\.cargo\bin\uv.exe",
        "$env:USERPROFILE\.local\bin\uv.exe",
        "C:\Users\smuthu\.cargo\bin\uv.exe",
        "C:\Users\smuthu\AppData\Local\Programs\uv\uv.exe",
        "C:\Users\smuthu\AppData\Roaming\uv\uv.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) {
            Write-Host "Found at: $p"
        }
    }
    Write-Host "uv not found in standard PATH"
}
