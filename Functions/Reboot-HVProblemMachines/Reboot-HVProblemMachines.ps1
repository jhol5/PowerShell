function Reboot-HVProblemMachines {
    [CmdletBinding()]
	Param(
        [Parameter(Mandatory=$true)]
        [String]$HorizonCredStore,
        [Parameter(Mandatory=$true)]
        [String]$vCenterCredStore
	)

<#
	.SYNOPSIS
	Reboots problem VM's in the VMware Environment.

	.DESCRIPTION
	This function restarts all problem VM's in the VMware Environment by connecting to a Horizon Connection server querying the problem VM's, then connects to vCenter to gracefully restart the VM(s).
	The original script is at the end of this page, above the summary: https://blogs.vmware.com/euc/2017/01/vmware-horizon-7-powercli-6-5.html. I have removed the reboot and need to connect to vCenter and changed how the script authenticates to the View Admin server.

	.EXAMPLE
		Reboot-HVProblemMachines -HorizonCredStore 'C:\Scripts\credfileview.xml' -vCenterCredStore C:\Scripts\credfilevcenter.xml -HorizonServer 'hva.mydomain.com' -vCenterServer 'vcenter.mydomain.com'

	.NOTES
		Original Author             : Praveen Mathamsetty.
		Original Author email       : pmathamsetty@vmware.com
		Modified/Updated By			: Joshua Holcomb
		Modified/Updated email		: joshua.holcomb@tjc.edu
		Version                     : 1.0.1
		Dependencies                : Make sure to have loaded VMware.HvHelper module loaded on your machine, see: https://blogs.vmware.com/euc/2017/01/vmware-horizon-7-powercli-6-5.html. Also it's state later in the script but you need to run "New-VICredentialStoreItem -host <vcenter server IP address> -user <username> -password <password> -file C:\Scripts\credfilevcenter.xml" to generate a secure encryped credental file first.

		===Tested Against Environment====
		Horizon View Server Version : 7.4.0
        vCenter                     : 6.5.0
		PowerCLI Version            : PowerCLI 6.5, PowerCLI 6.5.1
		PowerShell Version          : 5.0

#>
	# --- Import the PowerCLI Modules required ---
    Import-Module VMware.VimAutomation.HorizonView
    Import-Module VMware.VimAutomation.Core
    Import-Module VMware.Hv.Helper

###################################################################
#                    Variables                                    #
###################################################################

    #Import Credentail Files New-VICredentialStoreItem -host <vcenter server IP address> -user <username> -password <password> -file C:\Scripts\credfilevcenter.xml
    $hvUser = Get-VICredentialStoreItem -File $HorizonCredStore
    $viUser = Get-VICredentialStoreItem -File $vCenterCredStore

    $baseStates = @(
        'PROVISIONING_ERROR',
        'ERROR',
        'AGENT_UNREACHABLE',
        'AGENT_ERR_STARTUP_IN_PROGRESS',
        'AGENT_ERR_DISABLED',
        'AGENT_ERR_INVALID_IP',
        'AGENT_ERR_NEED_REBOOT',
        'AGENT_ERR_PROTOCOL_FAILURE',
        'AGENT_ERR_DOMAIN_FAILURE',
        'AGENT_CONFIG_ERROR',
        'UNKNOWN'
    )

###################################################################
#                    Initialize                                   #
###################################################################
    # --- Connect to Horizon Connection Server API Service ---
    $hvServer1 = Connect-HVServer -Server $hvUser.Host -User $hvUser.User -Password $hvUser.Password
    Connect-VIServer -Server $viUser.Host -User $viUser.User -Password $viUser.Password

    # --- Get Services for interacting with the View API Service ---
    $Services1 = $hvServer1.ExtensionData

###################################################################
#                    Main                                         #
###################################################################
    if ($Services1) {
        foreach ($baseState in $baseStates) {
            # --- Get a list of VMs in this state ---
            $ProblemVMs = Get-HVMachineSummary -State $baseState -SuppressInfo $true
            
            foreach ($ProblemVM in $ProblemVMs) {
                $vm = Get-VM -Name $ProblemVM.Base.Name
                if($vm.PowerState -eq 'PoweredOn') { 
                    Restart-VMGuest -VM $vm | Out-Null
                    Write-Host ($ProblemVM.Base.Name + ' has started the reboot process.')
                }
                else { Write-Warning ($ProblemVM.Base.Name + ' is not powered on.') }
            }
        }
        
        # --- Disconnect from View Admin ---
        Disconnect-HVServer -Server $HorizonServer -Confirm:$false | Out-Null
        Disconnect-VIServer -Server $vCenterServer -Confirm:$false | Out-Null
    } else {
        Write-Output "", "Failed to login in to server."
    }
#endregion main
}

# SIG # Begin signature block
# MIIIeQYJKoZIhvcNAQcCoIIIajCCCGYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUztsiIqig6RsY8SmUC8gxYYjw
# z+GgggXOMIIFyjCCBLKgAwIBAgITFQAAByMkUpCwipe3DwAAAAAHIzANBgkqhkiG
# 9w0BAQsFADBdMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxEzARBgoJkiaJk/IsZAEZ
# FgN0amMxEjAQBgoJkiaJk/IsZAEZFgJhZDEbMBkGA1UEAxMSYWQtVzE2TUFJTkRD
# UDAxLUNBMB4XDTE4MTAwODIxMDYwN1oXDTE5MTAwODIxMDYwN1owdDEVMBMGCgmS
# JomT8ixkARkWBWxvY2FsMRMwEQYKCZImiZPyLGQBGRYDdGpjMRIwEAYKCZImiZPy
# LGQBGRYCYWQxDjAMBgNVBAsTBXN0YWZmMQ4wDAYDVQQLEwVVU0VSUzESMBAGA1UE
# AxMJQTAwMzAzMTQ5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAt1qK
# nm4sQhK8hymiP8M3P3G3uDkaFExk7RVADl4hQZiQSMmog2kkiKrqECzqp6ulhBJP
# BVOWXLp3aBZCsslGcvLwR8eKZWhk2+7L5KdXKfb3Eo7jfZDQV/4SUi1cEuNZ6uu+
# 5d8kpb+DZKxjwN7+u/7rK8q8Urnl44jiAh0gFx8r53/CHmkeYfYozIziI2yHsmiM
# vH+WlvXBA7JH8pCoaK98CBm4Slyl9iCO6RXudtD5einnbOxePaUPM/xLcI7wCP3L
# ppiKsJPyozGIK8MXOh4VsUDG/bq6r185vk8tV79OkHhUgaGvbOGi5xw5mJGleWkN
# /c/FpN99iZhLbEBccwIDAQABo4ICajCCAmYwJQYJKwYBBAGCNxQCBBgeFgBDAG8A
# ZABlAFMAaQBnAG4AaQBuAGcwEwYDVR0lBAwwCgYIKwYBBQUHAwMwDgYDVR0PAQH/
# BAQDAgeAMB0GA1UdDgQWBBQq4YMEvaBKNG4Lj5YNmOg2vaOA9DAfBgNVHSMEGDAW
# gBRunUTjaRhGdTlUbZ403p4E4033qjCB2QYDVR0fBIHRMIHOMIHLoIHIoIHFhoHC
# bGRhcDovLy9DTj1hZC1XMTZNQUlORENQMDEtQ0EsQ049VzE2TUFJTkRDUDAxLENO
# PUNEUCxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1D
# b25maWd1cmF0aW9uLERDPWFkLERDPXRqYyxEQz1sb2NhbD9jZXJ0aWZpY2F0ZVJl
# dm9jYXRpb25MaXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9p
# bnQwgcgGCCsGAQUFBwEBBIG7MIG4MIG1BggrBgEFBQcwAoaBqGxkYXA6Ly8vQ049
# YWQtVzE2TUFJTkRDUDAxLUNBLENOPUFJQSxDTj1QdWJsaWMlMjBLZXklMjBTZXJ2
# aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWFkLERDPXRqYyxE
# Qz1sb2NhbD9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2VydGlmaWNh
# dGlvbkF1dGhvcml0eTAxBgNVHREEKjAooCYGCisGAQQBgjcUAgOgGAwWQTAwMzAz
# MTQ5QGFkLnRqYy5sb2NhbDANBgkqhkiG9w0BAQsFAAOCAQEAWsbGFusPT221Js4n
# KfxPXkKWnIE439KRq59N+z3U38s7/Soi3GsnGmRSo2y2DgX2+2hJ6tlQk6ezaVfO
# ssbRiry3hTs+ONDCX6oqNS2Amyj/on4KceMve22UZYqy5j+7kBeO1Ac4rxA/BWyU
# gXScTSxfk08ZPjG75CSyKNsgOt8dUJyNWjxP4TaWCJ7q+EcxpO4oiHzceuPWEDr4
# 7DGqAx0+oQwUhRAHeejaPuIWJGCaYEr1PpA372dFFbnOmrhUQVoJS56nbUFUxpb5
# dcUAVrPx1hHIHiYXYyh4JJXYs6AeJ8rbdw1MQGSZUj0a8M72zeWwGM4DUh8gY5A9
# AbgcATGCAhUwggIRAgEBMHQwXTEVMBMGCgmSJomT8ixkARkWBWxvY2FsMRMwEQYK
# CZImiZPyLGQBGRYDdGpjMRIwEAYKCZImiZPyLGQBGRYCYWQxGzAZBgNVBAMTEmFk
# LVcxNk1BSU5EQ1AwMS1DQQITFQAAByMkUpCwipe3DwAAAAAHIzAJBgUrDgMCGgUA
# oHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYB
# BAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0B
# CQQxFgQU8y5tkiOokAutJzWodLdT7dQ74JkwDQYJKoZIhvcNAQEBBQAEggEAZWnP
# hxWGpYjYXiqFS0PvNxleDG6nu/tVBeijCBi3W6RPkrwn+53lk+sRekA5JocjvadJ
# IEDrGy08GXD3YNUQVEOx6Ru/JL/q82rKI7JqF6qlt4rZ2tU4OT5TQiS0doBH/yEn
# 49bMEA0kA2cKCOLNVjIc3E/5VyFTEp1o7W5U8nc/7oj/N4buNpM/NfBU1YMvAH5M
# Gk6JWApLN7x+TzeVDhtwVikAYs1P1HD2G6Fm4PHSRMwqeO30tQlTs89e/48jhMjZ
# EnUgntMFfrf4puXVT01ghxzzaVOPoinnnAlRE1w+bgYOJ2swQB0SAz0GVmDwAsKi
# qaPEyFbm1VHGsWNLRw==
# SIG # End signature block
