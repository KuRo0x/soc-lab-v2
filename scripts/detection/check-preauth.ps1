# check-preauth.ps1
# Audits Active Directory for accounts with Kerberos pre-authentication disabled.
# These accounts are vulnerable to AS-REP Roasting (T1558.004).
# Run on DC as Domain Admin.

param(
    [string]$Domain = "soc.lab",
    [switch]$ExportCsv
)

Write-Host "`n[*] Checking for accounts with DoesNotRequirePreAuth = True...`n" -ForegroundColor Cyan

$vulnerable = Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} `
    -Properties DoesNotRequirePreAuth, Enabled, PasswordLastSet, Description |
    Select-Object Name, SamAccountName, Enabled, PasswordLastSet, Description

if ($vulnerable.Count -eq 0) {
    Write-Host "[+] No vulnerable accounts found. PreAuth is enforced on all accounts." -ForegroundColor Green
} else {
    Write-Host "[!] VULNERABLE ACCOUNTS FOUND: $($vulnerable.Count)" -ForegroundColor Red
    $vulnerable | Format-Table -AutoSize

    if ($ExportCsv) {
        $path = ".\preauth-audit-$(Get-Date -Format 'yyyyMMdd-HHmm').csv"
        $vulnerable | Export-Csv -Path $path -NoTypeInformation
        Write-Host "[*] Exported to $path" -ForegroundColor Yellow
    }
}

Write-Host ""
