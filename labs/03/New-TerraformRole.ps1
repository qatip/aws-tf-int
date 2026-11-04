#requires -Version 7.4
[CmdletBinding()]
param([Parameter(Mandatory)][string]$Profile)
. (Join-Path $PSScriptRoot 'Lab03.Common.ps1')
$record = Read-LabRecord
$identity = Assert-LabAccount -Record $record -Profile $Profile
if ($record.RoleCreated) { throw 'The lab record already contains a role. Inspect it rather than creating another.' }
$existing = Invoke-LabAws -Arguments @('iam','get-role','--role-name',$record.RoleName) -Profile $Profile -AllowMissing
if ($null -ne $existing) { throw 'TerraformRole already exists and will not be overwritten.' }
$principalArn = $identity.Arn
if ($principalArn -match ':assumed-role/([^/]+)/') {
    $sourceRoleName = $Matches[1]
    $sourceRole = Invoke-LabAws -Arguments @('iam','get-role','--role-name',$sourceRoleName) -Profile $Profile
    $principalArn = $sourceRole.Role.Arn
} elseif ($principalArn -notmatch '^arn:[^:]+:iam::[0-9]{12}:user/') {
    throw 'Expected a lab IAM user or assumed IAM role. Ask the trainer to confirm the trust principal.'
}
$trust = @{
    Version = '2012-10-17'
    Statement = @(@{Effect='Allow'; Principal=@{AWS=$principalArn}; Action='sts:AssumeRole'})
}
$trustPath = Join-Path $PSScriptRoot 'trust-policy.vscode.json'
$trust | ConvertTo-Json -Depth 6 | Set-Content $trustPath -Encoding utf8NoBOM
$created = Invoke-LabAws -Arguments @('iam','create-role','--role-name',$record.RoleName,'--assume-role-policy-document',"file://$trustPath") -Profile $Profile
$record.RoleCreated = $true; $record.RoleArn = $created.Role.Arn; Write-LabRecord $record
Invoke-LabAws -Arguments @('iam','attach-role-policy','--role-name',$record.RoleName,'--policy-arn',$record.PolicyArn) -Profile $Profile | Out-Null
$record.RolePolicyAttached = $true; Write-LabRecord $record
Write-Host "Created role: $($record.RoleArn)"
Write-Host "Trust principal: $principalArn"
Write-Host 'The source identity must also have any required sts:AssumeRole permission. Existing source identities are not modified by this script.'
