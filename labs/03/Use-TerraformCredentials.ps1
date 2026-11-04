#requires -Version 7.4
[CmdletBinding()]
param([Parameter(Mandatory)][string]$Profile,[string]$Region = 'us-east-1')
. (Join-Path $PSScriptRoot 'Lab03.Common.ps1')
$record = Read-LabRecord
Assert-LabAccount -Record $record -Profile $Profile | Out-Null
if ($Region -ne $record.Region) { throw 'Use the same Secrets Manager region as the setup step.' }
if (-not $record.SecretArn) { throw 'Secret setup is incomplete.' }
$secret = Invoke-LabAws -Arguments @('secretsmanager','get-secret-value','--region',$Region,'--secret-id',$record.SecretArn) -Profile $Profile
$credentials = $secret.SecretString | ConvertFrom-Json
if (-not $credentials.AWS_ACCESS_KEY_ID -or -not $credentials.AWS_SECRET_ACCESS_KEY) {
    throw 'The secret is missing the expected credential fields.'
}
$env:AWS_ACCESS_KEY_ID = $credentials.AWS_ACCESS_KEY_ID
$env:AWS_SECRET_ACCESS_KEY = $credentials.AWS_SECRET_ACCESS_KEY
Remove-Item Env:AWS_SESSION_TOKEN -ErrorAction SilentlyContinue
Remove-Item Env:AWS_SECURITY_TOKEN -ErrorAction SilentlyContinue
Remove-Item Env:AWS_PROFILE -ErrorAction SilentlyContinue
Remove-Item Env:AWS_DEFAULT_PROFILE -ErrorAction SilentlyContinue
$env:AWS_REGION = $Region; $env:AWS_DEFAULT_REGION = $Region
Remove-Variable secret,credentials -ErrorAction SilentlyContinue
Write-Host 'IAM user credentials loaded into this PowerShell process. Run aws sts get-caller-identity without --profile to verify.'
