$uvPath = "C:\Users\smuthu\AppData\Roaming\Python\Python313\Scripts\uv.exe"
Set-Location "C:\Users\smuthu\Documents\claude-training\inventory-management-main\server"
Start-Process -FilePath $uvPath -ArgumentList "run", "python", "main.py" -RedirectStandardOutput "C:\Users\smuthu\Documents\claude-training\inventory-management-main\backend.log" -RedirectStandardError "C:\Users\smuthu\Documents\claude-training\inventory-management-main\backend-err.log" -NoNewWindow -WorkingDirectory "C:\Users\smuthu\Documents\claude-training\inventory-management-main\server"
Write-Host "Backend server started"
