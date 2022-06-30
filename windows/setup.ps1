function Install-PowerShellModule {
    param(
        [string]
        [Parameter(Mandatory = $true)]
        $ModuleName,

        [ScriptBlock]
        [Parameter(Mandatory = $true)]
        $PostInstall = {}
    )

    if (!(Get-Command -Name $ModuleName -ErrorAction SilentlyContinue)) {
        Write-Host "Installing $ModuleName"
        Install-Module -Name $ModuleName -Scope CurrentUser
        Import-Module $ModuleName

        Invoke-Command -ScriptBlock $PostInstall
    }
    else {
        Write-Host "$ModuleName was already installed, skipping"
    }
}

Write-Host "Before we start, here's a few question"

$desktop = Read-Host "Setup desktop? (y/n)"
$dsTool = Read-Host "Setup data science tool? (y/n)"

Write-Host Installing winget packages

$packages = @(
    # Dev Tools
    'Git.Git',
    # 'GitHub.cli',
    # 'Microsoft.WindowsTerminal.Preview',
    'Docker.DockerDesktop',
    'JanDeDobbeleer.OhMyPosh',

    # Editors
    'Microsoft.VisualStudioCode',

    # Inspectors
    # 'Postman.Postman',

    # Browsers
    'Mozilla.Firefox',
    # 'Google.Chrome',
    'BraveSoftware.BraveBrowser',

    # Chat
    

    # Misc
    'Microsoft.Powershell.Preview',
    'Microsoft.Office'
)

if ($desktop -eq "y") {
    $packages += 'Discord.Discord'
    $packages += 'Valve.Steam'
}

if ($desktop -eq "y") {
    $packages += 'Anaconda.Miniconda3'
    $packages += 'dbeaver.dbeaver'
    $packages += 'RStudio.RStudio.OpenSource'
    $packages += 'RProject.R'
}


$packages | ForEach-Object { winget install --id $_ --source winget }

Write-Host Installing PowerShell Modules

Set-ExecutionPolicy -ExecutionPolicy Unrestricted

Install-PowerShellModule 'Posh-Git' { }
Install-PowerShellModule 'PSReadLine' { }
Install-PowerShellModule 'Terminal-Icons' { }
Install-PowerShellModule 'Python.Python.3' { }
Install-PowerShellModule 'nvm' {
    Install-NodeVersion latest
    Set-NodeVersion -Persist User latest
}

Write-Host Setting up dotfiles

$repoBaseUrl = 'https://raw.githubusercontent.com/melihuzun/system-automate/main'

Invoke-WebRequest -Uri "$repoBaseUrl/common/.gitconfig" -OutFile (Join-Path $env:USERPROFILE '.gitconfig')
Invoke-WebRequest -Uri "$repoBaseUrl/windows/Microsoft.PowerShell_profile.ps1" -OutFile $PROFILE
Invoke-WebRequest -Uri "$repoBaseUrl/windows/Microsoft.PowerShell_profile.ps1" -OutFile $PROFILE.Replace("WindowsPowerShell", "PowerShell")

Write-Host Installing additional software

wsl --install
# wsl --exec "curl $repoBaseUrl/linux/setup.sh | bash"

Write-Host Manuall install the following
Write-Host "- caskaydiacove nf: https://www.nerdfonts.com/font-downloads"
Write-Host "Nvidia Driver: https://www.nvidia.com.tr/drivers"


# if ($desktop -ne "y") {
#     Write-Host Remember to Update path for oh-my-posh
# }

# Import the registry keys
Write-Host "$('[{0:HH:mm}]' -f (Get-Date)) Importing registry keys..."
regedit /s MakeWindows10GreatAgain.reg