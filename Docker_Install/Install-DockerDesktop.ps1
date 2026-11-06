#requires -Version 5.1
#requires -RunAsAdministrator
<#
.SYNOPSIS
Downloads and installs Docker Desktop for Windows using the WSL 2 backend.
.DESCRIPTION
Run from 64-bit PowerShell as Administrator on Windows 10/11.
This script never calls Restart-Computer, shutdown, or enables Windows features.
WSL 2 must already be available. If preparation needs a restart, installation stops.
Installs for all users; leaves existing installations alone. Does not start Docker.
No Ubuntu distribution is required for Docker Desktop.
.PARAMETER AcceptLicense
Accept Docker's Subscription Service Agreement during installation. Without this
switch, the user must accept the agreement when first opening Docker Desktop.
.EXAMPLE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install-DockerDesktop.ps1
.NOTES
Exit codes: 0 = installed/already present, 1 = failure, 3010 = restart required.
An existing installation is not a guarantee that its engine is running.
Documentation: https://docs.docker.com/desktop/setup/install/windows-install/
#>
[CmdletBinding()]
param([switch]$AcceptLicense)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
# Avoid PowerShell 7 treating diagnostic output from native commands as exceptions.
$PSNativeCommandUseErrorActionPreference = $false
$downloadFolder = $null

try {
    if (-not [Environment]::Is64BitProcess) {
        throw 'Run this script in 64-bit Windows PowerShell or PowerShell 7.'
    }

    $os = Get-CimInstance Win32_OperatingSystem
    if ($os.ProductType -ne 1 -or [int]$os.BuildNumber -lt 19045) {
        throw 'Docker Desktop requires a supported Windows 10/11 client. Windows Server is not supported.'
    }
    if ([int]$os.BuildNumber -ge 22000 -and [int]$os.BuildNumber -lt 22631) {
        throw 'This script requires Windows 11 build 22631 or later.'
    }

    $desktopPaths = @(
        (Join-Path $env:ProgramFiles 'Docker\Docker\Docker Desktop.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\DockerDesktop\Docker Desktop.exe')
    )
    $existingDesktop = $desktopPaths | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if ($existingDesktop) {
        Write-Host "Docker Desktop is already installed: $existingDesktop" -ForegroundColor Green
        Write-Host 'No changes made. Open Docker Desktop from the Start menu in your normal Windows session.'
        exit 0
    }

    Write-Host 'Checking prerequisites without changing Windows features...'
    $rebootKeys = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
    )
    foreach ($key in $rebootKeys) {
        if (Test-Path -LiteralPath $key) {
            throw 'Windows already reports a pending restart. Installation stopped because a reboot is not available.'
        }
    }

    foreach ($name in @('Microsoft-Windows-Subsystem-Linux', 'VirtualMachinePlatform')) {
        $feature = Get-WindowsOptionalFeature -Online -FeatureName $name
        if ($feature.State -ne 'Enabled') {
            throw "Windows feature '$name' is $($feature.State). Enabling it can require a reboot; no features were changed."
        }
    }

    $computer = Get-CimInstance Win32_ComputerSystem
    if ($computer.TotalPhysicalMemory -lt 7.5GB) {
        throw 'Docker Desktop requires at least 8 GB RAM.'
    }
    if (-not $computer.HypervisorPresent) {
        throw 'No running Windows hypervisor was detected. WSL 2 needs hardware virtualization (nested virtualization in a VM). Installation stopped.'
    }

    $wsl = Join-Path $env:SystemRoot 'System32\wsl.exe'
    if (-not (Test-Path -LiteralPath $wsl)) {
        throw 'WSL is not installed. Installation stopped; no reboot will be requested by this script.'
    }
    $versionOutput = & $wsl --version 2>&1
    $wslExit = $LASTEXITCODE
    $versionText = ($versionOutput | Out-String) -replace "`0", ''
    if ($wslExit -ne 0 -or $versionText -notmatch '(\d+\.\d+\.\d+(?:\.\d+)?)') {
        throw 'A modern WSL installation was not detected. WSL 2.1.5 or later is required; WSL was not changed.'
    }
    $wslVersion = [version]$Matches[1]
    if ($wslVersion -lt [version]'2.1.5') {
        throw "WSL $wslVersion is too old. WSL 2.1.5 or later is required; WSL was not changed."
    }
    Write-Host "WSL $wslVersion detected."

    $architecture = $env:PROCESSOR_ARCHITECTURE
    if ($env:PROCESSOR_ARCHITEW6432) { $architecture = $env:PROCESSOR_ARCHITEW6432 }
    switch ($architecture) {
        'AMD64' { $platform = 'amd64' }
        'ARM64' { $platform = 'arm64' }
        default { throw "Unsupported processor architecture: $architecture" }
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    $downloadFolder = Join-Path ([IO.Path]::GetTempPath()) ('DockerDesktop-' + [guid]::NewGuid().ToString('N'))
    New-Item -Path $downloadFolder -ItemType Directory | Out-Null
    $installer = Join-Path $downloadFolder 'DockerDesktopInstaller.exe'
    $downloadUrl = "https://desktop.docker.com/win/main/$platform/Docker%20Desktop%20Installer.exe"

    Write-Host 'Downloading the latest Docker Desktop installer. This can take several minutes...'
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installer -UseBasicParsing

    Write-Host 'Checking the installer digital signature...'
    $signature = Get-AuthenticodeSignature -FilePath $installer
    if ($signature.Status -ne 'Valid' -or $null -eq $signature.SignerCertificate -or $signature.SignerCertificate.Subject -notmatch '(?i)\bDocker\s+Inc\.?\b') {
        throw "Installer signature verification failed (status: $($signature.Status)). The installer was not run."
    }

    $installerArguments = @('install', '--quiet', '--backend=wsl-2')
    if ($AcceptLicense) { $installerArguments += '--accept-license' }
    Write-Host 'Installing Docker Desktop. Please wait...'
    $process = Start-Process -FilePath $installer -ArgumentList $installerArguments -Wait -PassThru
    if ($process.ExitCode -eq 3010) {
        Write-Warning 'The installer reports that a restart is required. The script has not requested a reboot. Docker may not run until you can restart Windows.'
        exit 3010
    }
    if ($process.ExitCode -ne 0) {
        throw "Docker Desktop installer failed with exit code $($process.ExitCode). Check %LOCALAPPDATA%\Docker\install-log*.txt and %PROGRAMDATA%\DockerDesktop\install-log*.txt."
    }
    $installedDesktop = Join-Path $env:ProgramFiles 'Docker\Docker\Docker Desktop.exe'
    if (-not (Test-Path -LiteralPath $installedDesktop)) {
        throw 'The installer returned success, but Docker Desktop was not found in the expected installation folder.'
    }

    Write-Host 'Docker Desktop installation completed.' -ForegroundColor Green
    Write-Host 'Open Docker Desktop from the Start menu in your normal Windows session.'
    if (-not $AcceptLicense) { Write-Host 'Accept the Docker agreement when prompted.' }
    Write-Host 'Once Docker shows its engine is running, open a NEW terminal and run: docker run --rm hello-world'
    Write-Host 'No reboot was requested by this script. Engine startup still depends on Windows and WSL readiness.'
    exit 0
}
catch {
    Write-Error -Message $_.Exception.Message -ErrorAction Continue
    exit 1
}
finally {
    if ($downloadFolder -and (Test-Path -LiteralPath $downloadFolder)) {
        Remove-Item -LiteralPath $downloadFolder -Recurse -Force -ErrorAction SilentlyContinue
    }
}
