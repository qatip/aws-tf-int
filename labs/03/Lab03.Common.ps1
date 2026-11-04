#requires -Version 7.4
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
$PSNativeCommandArgumentPassing = 'Standard'

function Invoke-LabAws {
    param([Parameter(Mandatory)][string[]]$Arguments,
          [Parameter(Mandatory)][string]$Profile,
          [switch]$AllowMissing)
    $result = & aws @Arguments --profile $Profile --no-cli-pager --output json 2>&1
    $awsExitCode = $LASTEXITCODE
    $resultText = ($result | Out-String).Trim()
    if ($awsExitCode -ne 0) {
        if ($AllowMissing -and $resultText -match 'NoSuchEntity|ResourceNotFoundException') { return $null }
        throw "AWS operation failed: $resultText"
    }
    if ($resultText) { return ($resultText | ConvertFrom-Json) }
}

function Read-LabRecord {
    $path = Join-Path $PSScriptRoot 'lab03-vscode-resources.json'
    if (-not (Test-Path $path)) { throw 'Lab record missing. Run Setup-TerraformSecrets.ps1 first.' }
    return (Get-Content $path -Raw | ConvertFrom-Json)
}

function Write-LabRecord {
    param([Parameter(Mandatory)]$Record)
    $path = Join-Path $PSScriptRoot 'lab03-vscode-resources.json'
    $Record | ConvertTo-Json -Depth 8 | Set-Content $path -Encoding utf8NoBOM
}

function Assert-LabAccount {
    param($Record,[string]$Profile)
    $identity = Invoke-LabAws -Arguments @('sts','get-caller-identity') -Profile $Profile
    if ($identity.Account -ne $Record.AccountId) { throw 'Selected profile is for a different AWS account.' }
    return $identity
}
