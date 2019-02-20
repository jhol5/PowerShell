<#
    .SYNOPSIS
    This function is designed to uninstall any version of Palo Alto Traps.

    .DESCRIPTION
    This function is designed to uninstall any version of Palo Alto Traps.

    .EXAMPLE
        Uninstall-Traps -Password my_password

    .NOTES
        URL				: https://github.com/jhol5/PowerShell/blob/master/Functions/Uninstall-Traps/Uninstall-Traps.ps1
        Author			: Joshua Holcomb
        Email		    : joshua.holcomb@tjc.edu
        Version         : 1.0
        Dependencies    : 

        ===Tested Against Environment====
        PowerShell Version          : 5.1, Traps 

#>

[CmdletBinding()]
	Param(
        [Parameter(Mandatory=$true)]
        [String]$Password
    )
    
$TrapsApp = (Get-Package | Where-Object {$_.Name -Like "*Traps*"}).FastPackageReference

if ($TrapsApp) {
    msiexec /x $TrapsApp UNINSTALL_PASSWORD=$Password
}