# Installing Ubuntu on WSL2 for Terraform and Ansible development
These scripts are aimed at automating parts of WSL2 and Ubuntu installation.  
They _ARE NOT_ meant to serve as a replacement.  

1. First, you will need to run `Set-ExecutionPolicy Unrestricted -Scope CurrentUser`.
2. Then, using **administrative** PowerShell, execute `1-install-ubuntu.ps1`.
3. You will be prompted to set a username and password, these can be anything you want.
4. Once the installation is complete, you will be dropped into `bash`. Type `exit` to logout.
5. Now you will need to run `2-post-install.ps1`.
6. If it determines that Ubuntu has no internet access, you will be prompted to allow changes to `.wslconfig`.  
You are encouraged to agree to this, otherwise you will be unable to access the internet from the VM until the fix is applied.

## Environment setup
Running `2-post-install.ps1` will do some maintenance on the VM, it will also install some _Terraform_ and _Ansible_ tools.  
Once this is complete, you will have a fully working development environment.  

### Full list of installed tools:
- terraform (apt)
- ansible (pypi)
- tftui (pypi)
- tf-lint (GitHub)
- ansible-lint (pypi)
- ShellCheck (apt)
- unzip (apt)
- Python pip (apt)
- python3-venv (apt)

## Known issues/quirks
1. **Sometimes, Ubuntu will be unable to connect to the internet.**  
The solution to this is to add an experimental DNS tunneling option to user's `.wslconfig`.  
This is because WSL2 changed how networking works under the hood from WSL1.  
2. **If an additional user has been created in Ubuntu since installation, the dev environment will be created there.**  
The PowerShell script relies on `/etc/passwd` file to query the last user added to the system.  
Make sure you don't add other users before completing the installation steps.  
3. **Running WSL commands as a user other than the logged in one, you may encounter errors.**  
If you attempt to run a WSL command in a shell running under a separate administrative account, you may  
encounter errors, such as `Catastrophic Failure` or `A specified logon session does not exist. It may already have been terminated.`  
Firstly, a good idea is to get an up-to-date PowerShell which you can get on [GitHub](https://github.com/PowerShell/PowerShell/releases).  
If you are on _Windows 10_, I personally recommend getting the Windows Terminal, which is superior to the Command Prompt in a multitude of ways. You can get it on [GitHub](https://github.com/microsoft/terminal/releases) as well!  
If you are on _Windows 11_, you will already have _Terminal_ installed - you should still get an up-to-date PowerShell installation.  
Now, there are **2** ways to try solving this;  
    - Authenticate as your logged in user. It must have administrative privileges to be able to execute WSL commands.  
    - Try running commands as a standard user, at which point you may be prompted for authentication and can use the other account.  
3. **Regular download of WSL components will fail on Windows 10 when the Microsoft Store is blocked by policy**  
When attempting to run a WSL command on a Windows 10 device where the Microsoft Store is blocked by policy or is
otherwise non-operational, you will probably receive `Error: 0x8024500c`.  
The solution is to force a web download, whereby running an install command WSL will download the required files directly
from the server. This can be done by passing a `--web-download` argument to a command that requires downloads.  
This has already been added to the scripts, but be aware in case issues arise in the future.