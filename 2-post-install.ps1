<#
It appears that other PS and .NET methods like .Contains, findstr etc don't properly capture WSL output
So we'll have to do with checking the exit code.
#>
(wsl -l) *> $null
if ($LASTEXITCODE -eq -1) { 
    Write-host "WSL reported no installed distributions, please re-run the first script."
    return
}

# Check if we can access internet
Write-Host "Checking WSL internet connectivity, please wait..."
(wsl nc -vz gov.uk 443 -w 5) *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "No internet connectivity, will attempt a fix..."
    # Check if there is an existing wslconfig
    if (Test-Path "$($env:USERPROFILE)\.wslconfig" -PathType Leaf) {
        $confirmation = Read-Host "Are you happy to have your .wslconfig modified? (y/n)"
        if ($confirmation -eq 'y') {
            # Back up the original
            Copy-Item "$($env:USERPROFILE)\.wslconfig" -Destination "$($env:USERPROFILE)\.wslconfig.bak"
            # Append experimental networking options
            Add-Content -Path "$($env:USERPROFILE)\.wslconfig" -Value "`n[experimental]`ndnsTunneling=true`nnetworkingMode=mirrored"
            # Shutdown WSL, important for changes to take effect
            wsl --shutdown
        } elseif ($confirmation -eq 'n') {
            # User said no, so just exit
            Write-Host "No action was taken, exiting..."
            return
        }
    } else {
        # WSL configuration file doesn't exist, so create one
        "[experimental]`ndnsTunneling=true`nnetworkingMode=mirrored" | Out-File -Path "$($env:USERPROFILE)\.wslconfig"
        # Shutdown WSL, important for changes to take effect
        wsl --shutdown
    }
} else {
    Write-Host "WSL has internet connectivity, continuing..."
}

$confirmation = Read-Host "Would you like to setup the Ansible and Terraform development environment? (y/n)"
if ($confirmation -eq 'y') {
    # System maintenance stuff
    wsl -d Ubuntu -u root -e /bin/bash -c "apt update && apt upgrade -y" *> $null
    # Bash on a single line looks cursed
    wsl -d Ubuntu -u root -e /bin/bash -c 'textToCheck="systemd=true" && textToAppend="[boot]\\nsystemd=true\\n" && file="/etc/wsl.conf" && grep -qF "$textToCheck" "$file" || { printf "$textToAppend" | sed "s/\\\\n/\\n/g" >> "$file"; }'

    # Scripts path
    $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $windowsPath = Join-Path $scriptDirectory "scripts"

    # Use -match to capture the drive letter
    if ($windowsPath -match '^(.):') {
        $driveLetter = $matches[1]

        # Convert the Windows path to a lowercase WSL path
        $wslPath = $windowsPath -replace '\\', '/' -replace "^(.):", "/mnt/$($driveLetter.ToLower())"

    } else {
        Write-Host "Path substitution failed, cannot get the host drive letter..."
    }

    # Specify the path to the passwd file
    $passwdPath = "\\wsl$\Ubuntu\etc\passwd"

    # Check if the file exists
    if (Test-Path $passwdPath) {
        # Read the contents of the passwd file
        $passwdContent = Get-Content $passwdPath

        # Get the last line of the file
        $lastLine = $passwdContent | Select-Object -Last 1

        # Extract the username from the last line
        $username = ($lastLine -split ':')[0]
    }
    else {
        Write-Host "Passwd file not found, cannot get the username..."
        return
    }

    # Make a development directory
    wsl mkdir /home/$username/devenv

    # Copy bash scripts to Ubuntu
    wsl cp -r $wslPath /home/$username/devenv/

    # Make scripts executable
    wsl chmod +x /home/$username/devenv/scripts/*

    # Run the dependencies setup
    wsl -d Ubuntu -u root -e /bin/bash -c "export SUDO_USER=$username; /home/$username/devenv/scripts/deps"
} elseif ($confirmation -eq 'n') {
    Write-Host "No action has been taken, exiting..."
    return
}