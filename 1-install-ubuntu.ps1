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
    # Install WSL components
    wsl --install --no-distribution --web-download

    # Set the default version
    wsl --set-default-version 2

    # Update WSL
    wsl --update --web-download

    # Install Ubuntu
    wsl --install -d Ubuntu --web-download
}