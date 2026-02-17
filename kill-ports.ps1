$ports = @(3000, 8001)
foreach ($port in $ports) {
    $connections = netstat -ano | Select-String ":$port "
    foreach ($conn in $connections) {
        $parts = $conn.ToString().Trim() -split '\s+'
        $procId = $parts[-1]
        if ($procId -match '^\d+$' -and $procId -ne '0') {
            Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
            Write-Host "Killed PID $procId on port $port"
        }
    }
}
Write-Host "Cleanup done"
