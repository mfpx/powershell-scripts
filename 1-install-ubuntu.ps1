# Check if the script is running with administrative privileges
$adminRights = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $adminRights) {
    Write-Host "You can only execute this script in an administrative shell."
    Exit
}

$isWin11 = (Get-ComputerInfo | Select-Object -expand OsName) -match 11
if ($isWin11) {
    # Install WSL components
    wsl --install --no-distribution

    # Set the default version
    wsl --set-default-version 2

    # Update WSL
    wsl --update

    # Install Ubuntu
    wsl --install -d Ubuntu

} elseif (!($isWin11)) {
    # Notify of potential issues
    Write-Host "Forewarning that WSL on Windows 10 might experience issues" -ForegroundColor red
    pause

    # Install WSL components
    wsl --install --no-distribution --web-download

    # Set the default version
    wsl --set-default-version 2

    # Update WSL
    wsl --update --web-download

    # Install Ubuntu
    wsl --install -d Ubuntu --web-download
}

# Installing components from scratch will require a restart
$confirmation = Read-Host "A restart is required, are you happy to restart now? (y/n)"
if ($confirmation -eq 'y') {
    # Force restart
    Restart-Computer -Force
} elseif ($confirmation -eq 'n') {
    Write-Host "Please restart your machine before continuing to step 2"
    return
}
