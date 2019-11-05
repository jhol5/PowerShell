
$global:NutanixGuestTargetVersion = '1.6.3.0'
$global:NutanixGuestInstallerSettings = '/quiet ACCEPTEULA=yes /norestart'

$ErrorActionPreference = 'SilentlyContinue'

function Test-ForNutanixTools {
    if (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq "Nutanix Guest Tools"})
    {
        return $true
    } 
    
    return $false
}

function Get-NutanixToolsVersion {
    if (Test-ForNutanixTools) {
        return (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq "Nutanix Guest Tools"}).DisplayVersion
    } else {
        Write-Error -Message ('Guest tools was not detected')
    }
}

function Get-CDDriveLetters {
    return (Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 5}).DeviceID
}

function Test-ForNutanixInstaller {
    $DriveLetters = Get-CDDriveLetters

    Foreach ($DriveLetter in $DriveLetters) {
        if ((Get-Item $DriveLetter\setup.exe).VersionInfo.FileDescription -eq 'Nutanix Guest Tools') {
            return $true
        }
    }

    return $false
}

function Get-NutainxInstallerInfo {
    $DriveLetters = Get-CDDriveLetters

    Foreach ($DriveLetter in $DriveLetters) {
        if ((Get-Item $DriveLetter\setup.exe).VersionInfo.FileDescription -eq 'Nutanix Guest Tools') {
            return (Get-Item $DriveLetter\setup.exe).VersionInfo | Select-Object FileVersion,FileName 
        }
    }

    return Write-Error -Message ('Guest tools installer was not detected')
}

function Install-NutanixGuestTools {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [System.Object]
        $NutanixGuestObject
    )

    if ($NutanixGuestObject.FileVersion -eq $NutanixGuestTargetVersion) {
        & (Get-NutainxInstallerInfo).FileName ($NutanixGuestInstallerSettings.Split(' '))
    }
}

function Remove-OlderNutanixGuestTools {
    $All = Get-NutanixToolsVersion

    if ($All -is [System.Array]) {
        Foreach ($version in $All) {
            if ($version -ne $NutanixGuestTargetVersion) {
                $UninstallString = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {($_.DisplayName -eq "Nutanix Guest Tools") -and ($_.DisplayVersion -eq $version)}).QuietUninstallString

                $UninstallArray = $UninstallString.split('/')

                & ($UninstallArray[0]).Replace('"', '') @('/uninstall', '/quiet', '/norestart')
            }
        }
    }
}

function Set-NutanixGuestTargetVersion {
    param (
        [Parameter(Mandatory=$true)]
        [System.String]$TargetVersion
    )
    
    $global:NutanixGuestTargetVersion = $TargetVersion
}

function Set-NutanixGuestInstallerSettings {
    param (
        [Parameter(Mandatory=$true)]
        [System.String]$SettingsString
    )
    
    $global:NutanixGuestInstallerSettings = $SettingsString
}

if (Test-ForNutanixTools) {
    if ((Get-NutanixToolsVersion) -ne $NutanixGuestTargetVersion) {
        if (Test-ForNutanixInstaller) {
            $InstallerInfo = Get-NutainxInstallerInfo

            Install-NutanixGuestTools -NutanixGuestObject $InstallerInfo

            Remove-OlderNutanixGuestTools
        } else {
            Write-Host -ForegroundColor Red ('Nutanix Guest Tools installer could not be found ')
        }
    } else {
        Write-Host -ForegroundColor Green ('Nutanix Guest Tools is already ' + (Get-NutanixToolsVersion))
    }
} else {
    Write-Warning ('Nutanix Guest Tools is not installed on this VM. These functions are only to be used if Nutanix Guest Tools have already been installed.')
}
