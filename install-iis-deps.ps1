# IIS Prerequisites Automator for Alert Dashboard
# Run this as Administrator

$ErrorActionPreference = "Stop"
$WorkDir = "C:\Temp\AlertDashboardSetup"
$PhpDir = "C:\php"

# Create temp directory
New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null

Write-Host "Starting IIS Prerequisites Setup..." -ForegroundColor Cyan

# 1. Install Chocolatey (The package manager for Windows)
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    # Refresh env vars manually to ensure choco is found
    $env:ChocolateyInstall = Convert-Path "$env:ProgramData\chocolatey"
    $env:Path = "$env:Path;$env:ChocolateyInstall\bin"
}
else {
    Write-Host "Chocolatey is already installed." -ForegroundColor Green
}

# 2. Install Tools via Chocolatey
Write-Host "Installing Dependencies (PHP, Composer, URL Rewrite, VC++)..." -ForegroundColor Yellow
choco install php --version=8.2.11 --package-parameters='"/ThreadSafe:false /InstallDir:C:\php"' -y
choco install vcredist140 -y
choco install urlrewrite -y
choco install composer -y
choco install mysql -y

# 3. Configure PHP.ini
Write-Host "Configuring PHP.ini..." -ForegroundColor Yellow
$PhpIni = "$PhpDir\php.ini"

if (Test-Path "$PhpDir\php.ini-production") {
    Copy-Item "$PhpDir\php.ini-production" $PhpIni -Force
}

# Functions to enable extensions
function Enable-PhpExtension ($name) {
    (Get-Content $PhpIni) -replace ";extension=$name", "extension=$name" | Set-Content $PhpIni
}

Enable-PhpExtension "curl"
Enable-PhpExtension "fileinfo"
Enable-PhpExtension "gd"
Enable-PhpExtension "mbstring"
Enable-PhpExtension "mysqli"
Enable-PhpExtension "openssl"
Enable-PhpExtension "pdo_mysql"
Enable-PhpExtension "zip"

# Set extension dir
(Get-Content $PhpIni) -replace ";extension_dir = `"ext`"", "extension_dir = `"ext`"" | Set-Content $PhpIni

# 4. Configure IIS to use PHP
Write-Host "Linking PHP to IIS..." -ForegroundColor Yellow
$IISPath = "$env:windir\system32\inetsrv\appcmd.exe"

if (Test-Path $IISPath) {
    # Check if handler exists to avoid error - piping to null to hide errors if it already exists
    & $IISPath set config /section:system.webServer/fastCgi /+"[fullPath='C:\php\php-cgi.exe']" /commit:apphost 2>$null
    & $IISPath set config /section:system.webServer/handlers /+"[name='PHP_via_FastCGI',path='*.php',verb='*',modules='FastCgiModule',scriptProcessor='C:\php\php-cgi.exe',resourceType='Either']" /commit:apphost 2>$null
}

Write-Host "------------------------------------------------" -ForegroundColor Cyan
Write-Host "Prerequisites Installed!" -ForegroundColor Green
Write-Host "   - PHP 8.2 (C:\php)" -ForegroundColor Gray
Write-Host "   - Composer" -ForegroundColor Gray
Write-Host "   - URL Rewrite Module" -ForegroundColor Gray
Write-Host "   - MySQL Server" -ForegroundColor Gray
Write-Host "------------------------------------------------"
Write-Host "Next Step: Create your database in MySQL and follow IIS_SETUP.md to deploy the code." -ForegroundColor White
Pause
