#requires -Version 7.4
[CmdletBinding()]
param([Parameter(Mandatory)][string]$Profile)
. (Join-Path $PSScriptRoot 'Lab03.Common.ps1')
$record = Read-LabRecord
Assert-LabAccount -Record $record -Profile $Profile | Out-Null
# Run terraform destroy successfully before running this script.
# Only resources recorded as created by these helpers are removed.
if ($record.RoleCreated) {
    if ($record.RolePolicyAttached) {
        Invoke-LabAws -Arguments @('iam','detach-role-policy','--role-name',$record.RoleName,'--policy-arn',$record.PolicyArn) -Profile $Profile | Out-Null
        $record.RolePolicyAttached = $false; Write-LabRecord $record
    }
    Invoke-LabAws -Arguments @('iam','delete-role','--role-name',$record.RoleName) -Profile $Profile | Out-Null
    $record.RoleCreated = $false; Write-LabRecord $record
}
if ($record.SecretArn) {
    Invoke-LabAws -Arguments @('secretsmanager','delete-secret','--region',$record.Region,'--secret-id',$record.SecretArn,'--force-delete-without-recovery') -Profile $Profile | Out-Null
    $record.SecretArn = $null; Write-LabRecord $record
}
if ($record.AccessKeyId) {
    Invoke-LabAws -Arguments @('iam','delete-access-key','--user-name',$record.UserName,'--access-key-id',$record.AccessKeyId) -Profile $Profile | Out-Null
    $record.AccessKeyId = $null; Write-LabRecord $record
}
if ($record.UserCreated) {
    if ($record.UserPolicyAttached) {
        Invoke-LabAws -Arguments @('iam','detach-user-policy','--user-name',$record.UserName,'--policy-arn',$record.PolicyArn) -Profile $Profile | Out-Null
        $record.UserPolicyAttached = $false; Write-LabRecord $record
    }
    Invoke-LabAws -Arguments @('iam','delete-user','--user-name',$record.UserName) -Profile $Profile | Out-Null
    $record.UserCreated = $false; Write-LabRecord $record
}
Remove-Item (Join-Path $PSScriptRoot 'lab03-vscode-resources.json')
Remove-Item (Join-Path $PSScriptRoot 'trust-policy.vscode.json') -ErrorAction SilentlyContinue
Write-Host 'Lab identities, recorded access key and secret removed. The pre-existing permissions policy was retained.'
