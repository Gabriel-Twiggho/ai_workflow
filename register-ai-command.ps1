$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\ai.exe"
$batFile = "C:\Users\gbspi\AIWorkflow\ai.bat"

New-Item -Path $regPath -Force | Out-Null
Set-ItemProperty -Path $regPath -Name "(Default)" -Value $batFile -Force

Write-Host "Registered ai command. Verifying..."
$val = (Get-ItemProperty $regPath).'(Default)'
Write-Host "  (Default) = $val"

if ($val -eq $batFile) {
    Write-Host "SUCCESS: Win+R -> ai should now work."
}
else {
    Write-Host "WARNING: Value does not match expected path."
}
