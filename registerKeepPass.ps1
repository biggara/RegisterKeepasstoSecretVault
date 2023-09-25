Install-Module Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore
Install-Module -Name SecretManagement.KeePass 

Import-Module Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore
Import-module SecretManagement.KeePass
Add-Type -AssemblyName System.Windows.Forms

# Set path to KeePass file and test it exists
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog 
$FileBrowser.InitialDirectory = [Environment]::GetFolderPath('Desktop') 
$FileBrowser.Filter = 'KeepassDB (*.kdbx) | *.kdbx'
$FileBrowser.Title = 'Select where you have your keeppass db.'
[void]$FileBrowser.ShowDialog()
$KeePassDB = $FileBrowser.Filename

# set up the value for the VaultParameters parameter
$VParams = @{ Path    = $KeePassDB 
    UseMasterPassword = $true
    MasterPassword    =  Read-Host "Enter the keepass Password" -AsSecureString
}

# Set a vault name and if it exists then unregister that vault in this session
$VaultName = $FileBrowser.SafeFileName -replace ".kdbx$",""
if (Get-SecretVault -Name $VaultName) { Unregister-SecretVault $VaultName }

# register our chosen vault
Register-SecretVault -Name $VaultName -ModuleName SecretManagement.keepass  -VaultParameters $VParams -Verbose

#test vault (this will prompt for password)
Test-SecretVault -Name $VaultName
