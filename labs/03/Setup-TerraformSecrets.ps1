#requires -Version 7.4
[CmdletBinding()]
param([Parameter(Mandatory)][string]$Profile,[string]$Region = 'us-east-1')
. (Join-Path $PSScriptRoot 'Lab03.Common.ps1')
Get-Command aws -ErrorAction Stop | Out-Null
$recordPath = Join-Path $PSScriptRoot 'lab03-vscode-resources.json'
if (Test-Path $recordPath) { throw 'A lab record already exists. Review or complete its cleanup before creating more resources.' }
$identity = Invoke-LabAws -Arguments @('sts','get-caller-identity') -Profile $Profile
$partition = $identity.Arn.Split(':')[1]
$policyArn = "arn:${partition}:iam::$($identity.Account):policy/terraform-user-policy"
# The original lab specifies this as a platform-provided permissions policy.
Invoke-LabAws -Arguments @('iam','get-policy','--policy-arn',$policyArn) -Profile $Profile | Out-Null
$user = Invoke-LabAws -Arguments @('iam','get-user','--user-name','terraform-user') -Profile $Profile -AllowMissing
$secret = Invoke-LabAws -Arguments @('secretsmanager','describe-secret','--region',$Region,'--secret-id','terraform-aws-credentials') -Profile $Profile -AllowMissing
if ($null -ne $user -or $null -ne $secret) {
    throw 'The user or secret already exists. No existing resource or credential will be overwritten. Ask the trainer to resolve the collision.'
}
$record = [pscustomobject]@{
    AccountId = $identity.Account; Region = $Region; PolicyArn = $policyArn
    UserName = 'terraform-user'; UserCreated = $false; UserPolicyAttached = $false
    AccessKeyId = $null; SecretName = 'terraform-aws-credentials'; SecretArn = $null
    RoleName = 'TerraformRole'; RoleCreated = $false; RolePolicyAttached = $false; RoleArn = $null
    BootstrapArn = $identity.Arn
}
Write-LabRecord $record
try {
    Invoke-LabAws -Arguments @('iam','create-user','--user-name',$record.UserName) -Profile $Profile | Out-Null
    $record.UserCreated = $true; Write-LabRecord $record
    Invoke-LabAws -Arguments @('iam','attach-user-policy','--user-name',$record.UserName,'--policy-arn',$policyArn) -Profile $Profile | Out-Null
    $record.UserPolicyAttached = $true; Write-LabRecord $record
    $key = Invoke-LabAws -Arguments @('iam','create-access-key','--user-name',$record.UserName) -Profile $Profile
    $record.AccessKeyId = $key.AccessKey.AccessKeyId; Write-LabRecord $record
    $secretJson = @{
        AWS_ACCESS_KEY_ID = $key.AccessKey.AccessKeyId
        AWS_SECRET_ACCESS_KEY = $key.AccessKey.SecretAccessKey
    } | ConvertTo-Json -Compress
    $newSecret = Invoke-LabAws -Arguments @('secretsmanager','create-secret','--region',$Region,'--name',$record.SecretName,'--description','QATIPINT Lab 03 authentication demonstration','--secret-string',$secretJson) -Profile $Profile
    $record.SecretArn = $newSecret.ARN; Write-LabRecord $record
    Write-Host "Created $($record.UserName) and $($record.SecretName) in $Region. Credential values were not printed or written to a local credential file."
} catch {
    Write-Warning 'Setup did not finish. The lab record lists completed resources; keep it for cleanup.'
    throw
} finally {
    Remove-Variable key,secretJson -ErrorAction SilentlyContinue
}
