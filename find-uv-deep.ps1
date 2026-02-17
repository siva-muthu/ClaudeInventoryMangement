$searchPaths = @(
    "$env:USERPROFILE",
    "$env:LOCALAPPDATA",
    "$env:APPDATA",
    "C:\Program Files",
    "C:\Program Files (x86)"
)

foreach ($searchPath in $searchPaths) {
    if (Test-Path $searchPath) {
        $found = Get-ChildItem -Path $searchPath -Filter "uv.exe" -Recurse -ErrorAction SilentlyContinue -Depth 5
        foreach ($f in $found) {
            Write-Host "Found: $($f.FullName)"
        }
    }
}
