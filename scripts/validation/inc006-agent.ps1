<#
.SYNOPSIS
    INC-006 fixed-count benign HTTP beacon agent.
.DESCRIPTION
    Sends telemetry to the lab-only simulator and handles only the fixed
    internal "status" task. It never invokes a shell or executes server input.
.EXAMPLE
    .\inc006-agent.ps1 -ServerUrl http://172.16.0.11:8080 -BeaconCount 6
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ServerUrl,
    [int]$BeaconCount = 6,
    [int]$IntervalSeconds = 10
)

$ErrorActionPreference = 'Stop'
$token = 'inc006-lab-only'
$agentId = [guid]::NewGuid().ToString()
$headers = @{ 'X-INC006-Token' = $token }

for ($count = 1; $count -le $BeaconCount; $count++) {
    $beacon = @{
        agent_id = $agentId
        hostname = $env:COMPUTERNAME
        username = $env:USERNAME
        sequence = $count
        timestamp_utc = [DateTime]::UtcNow.ToString('o')
    } | ConvertTo-Json

    Invoke-RestMethod -Uri "$ServerUrl/beacon" -Method Post -Headers $headers -Body $beacon -ContentType 'application/json' | Out-Null
    $task = Invoke-RestMethod -Uri "$ServerUrl/task" -Method Get -Headers $headers

    if ($task.task -ne 'status') {
        throw "Unexpected task received; stopping without execution."
    }

    $result = @{
        agent_id = $agentId
        task = $task.task
        task_id = $task.task_id
        result = 'agent-alive'
        sequence = $count
    } | ConvertTo-Json

    Invoke-RestMethod -Uri "$ServerUrl/result" -Method Post -Headers $headers -Body $result -ContentType 'application/json' | Out-Null
    Write-Host "INC-006 beacon $count/$BeaconCount completed; fixed status task acknowledged."

    if ($count -lt $BeaconCount) {
        Start-Sleep -Seconds $IntervalSeconds
    }
}

Write-Host 'INC-006 benign agent finished.'
