# deploy-winlogbeat.ps1
# Installs and configures Winlogbeat on a Windows host.
# Assumes Winlogbeat zip is already downloaded to C:\Temp\.
# Run as Administrator on the target Windows host.

param(
    [string]$ELKHost = "172.16.0.4",
    [string]$InstallPath = "C:\winlogbeat"
)

Write-Host "`n[*] Deploying Winlogbeat to $InstallPath...`n" -ForegroundColor Cyan

# Expand archive if not already done
if (-not (Test-Path "$InstallPath\winlogbeat.exe")) {
    Expand-Archive -Path "C:\Temp\winlogbeat-*.zip" -DestinationPath "C:\Temp\winlogbeat-extracted" -Force
    $extracted = Get-ChildItem "C:\Temp\winlogbeat-extracted" | Select-Object -First 1
    Move-Item $extracted.FullName $InstallPath -Force
    Write-Host "[+] Extracted to $InstallPath"
}

# Install as Windows service
cd $InstallPath
.\install-service-winlogbeat.ps1

# Set to auto-start
Set-Service winlogbeat -StartupType Automatic

# Start service
Start-Service winlogbeat
Start-Sleep -Seconds 3

$status = (Get-Service winlogbeat).Status
if ($status -eq "Running") {
    Write-Host "[+] Winlogbeat is running." -ForegroundColor Green
} else {
    Write-Host "[!] Winlogbeat failed to start. Check: $InstallPath\logs\winlogbeat" -ForegroundColor Red
}

Write-Host "`n[*] Config path: $InstallPath\winlogbeat.yml"
Write-Host "[*] Logs path:   $InstallPath\logs\"
Write-Host ""
