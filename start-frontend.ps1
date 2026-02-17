Set-Location "C:\Users\smuthu\Documents\claude-training\inventory-management-main\client"
Start-Process -FilePath "powershell" -ArgumentList "-Command", "npm run dev" -RedirectStandardOutput "C:\Users\smuthu\Documents\claude-training\inventory-management-main\frontend.log" -RedirectStandardError "C:\Users\smuthu\Documents\claude-training\inventory-management-main\frontend-err.log" -NoNewWindow
Write-Host "Frontend server started"
