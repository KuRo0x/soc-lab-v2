# check-spns.ps1
# Audits Active Directory for user accounts with Service Principal Names (SPNs).
# User accounts with SPNs are vulnerable to Kerberoasting (T1558.003).
# Computer accounts with SPNs are normal and excluded by default.
# Run on DC as Domain Admin.

param(
    [switch]$IncludeDisabled,
    [switch]$ExportCsv
)

Write-Host "`n[*] Checking for user accounts with SPNs (Kerberoastable)...`n" -ForegroundColor Cyan

$filter = if ($IncludeDisabled) {
    {ServicePrincipalName -ne "$null"}
} else {
    {ServicePrincipalName -ne "$null" -and Enabled -eq $true}
}

$kerberoastable = Get-ADUser -Filter $filter `
    -Properties ServicePrincipalName, PasswordLastSet, AdminCount, Description |
    Select-Object Name, SamAccountName, ServicePrincipalName, PasswordLastSet, AdminCount, Description

if ($kerberoastable.Count -eq 0) {
    Write-Host "[+] No Kerberoastable user accounts found." -ForegroundColor Green
} else {
    Write-Host "[!] KERBEROASTABLE ACCOUNTS: $($kerberoastable.Count)" -ForegroundColor Red
    $kerberoastable | Format-Table -AutoSize

    if ($ExportCsv) {
        $path = ".\spn-audit-$(Get-Date -Format 'yyyyMMdd-HHmm').csv"
        $kerberoastable | Export-Csv -Path $path -NoTypeInformation
        Write-Host "[*] Exported to $path" -ForegroundColor Yellow
    }
}

Write-Host ""
