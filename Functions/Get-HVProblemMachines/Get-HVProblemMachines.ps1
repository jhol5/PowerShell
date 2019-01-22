function Get-HVProblemMachines {
    [CmdletBinding()]
	Param(
        [Parameter(Mandatory=$true)]
        [String]$HorizonCredStore
	)

<#
	.SYNOPSIS
	Returns the problem VM's in the View Environment.

	.DESCRIPTION
	This function is to get the problem VM's in the View Environment and returns them in an array.
	The original script is at the end of this page, above the summary: https://blogs.vmware.com/euc/2017/01/vmware-horizon-7-powercli-6-5.html. I have removed the reboot and need to connect to vCenter and changed how the script authenticates to the View Admin server.

	.EXAMPLE
		Get-HVProblemMachines -HorizonCredStore C:\Scripts\credfileview.xml

	.NOTES
		Original Author             : Praveen Mathamsetty.
		Original Author email       : pmathamsetty@vmware.com
		Modified/Updated By			: Joshua Holcomb
		Modified/Updated email		: Joshua Holcomb
		Version                     : 1
		Dependencies                : Make sure to have loaded VMware.HvHelper module loaded on your machine, see: https://blogs.vmware.com/euc/2017/01/vmware-horizon-7-powercli-6-5.html. Also it's state later in the script but you need to run "New-VICredentialStoreItem -host <vcenter server IP address> -user <username> -password <password> -file C:\Scripts\credfilevcenter.xml" to generate a secure encryped credental file first.

		===Tested Against Environment====
		Horizon View Server Version : 7.4.0
		PowerCLI Version            : PowerCLI 6.5, PowerCLI 6.5.1
		PowerShell Version          : 5.0, 5.1

#>
	# --- Import the PowerCLI Modules required ---
    Import-Module VMware.VimAutomation.HorizonView
    Import-Module VMware.VimAutomation.Core
    Import-Module VMware.Hv.Helper


###################################################################
#                    Variables                                    #
###################################################################

    #Import Credentail Files New-VICredentialStoreItem -host <vcenter server IP address> -user <username> -password <password> -file C:\Scripts\credfilevcenter.xml
    $hvUser = Get-VICredentialStoreItem -File $CredFile

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
                $ProblemVM
            }
        }
        
        # --- Disconnect from View Admin ---
        Disconnect-HVServer -Server $HorizonServer -Confirm:$false | Out-Null
    } else {
        Write-Output "", "Failed to login in to Connection Server."
    }
#endregion main
}

# SIG # Begin signature block
# MIIIeQYJKoZIhvcNAQcCoIIIajCCCGYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU+m7M+nh3KgAvOG62Yi63vrwI
# 3HSgggXOMIIFyjCCBLKgAwIBAgITFQAAByMkUpCwipe3DwAAAAAHIzANBgkqhkiG
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
# CQQxFgQU6m8XjFs0Ts7DP83RRRVW5/De95wwDQYJKoZIhvcNAQEBBQAEggEAIi+k
# amMCN/iG5yY8oVaopqVqMCFS0eVfaeCQHKMR0pgODIZ80skd8WJCIpsSKa4DD88w
# g1zeO40WLGElQJHV+svgU0AbOjlvMGulOFZIfHT4gga2WCzkK8w0ssDOzHKFS7qV
# ZUpDR9nJIjgFTONNDL2dPkeY580lYiNK0jB1RbCJKptYfnQiOIR2zNFpqjxpyZmn
# izQC4Uh3woVkNxficetHBa07vGB7K2MnLdo/QF3nDiCjpxO4dW2tuN/0KDol+IIN
# TJ/317qYDnhqEh8rqtoQUUv+wwAop2Tbok9N5B1Et/tu7t6GerrHn7KXXb3pmpaq
# 2uFVEcnBKfWkvMSxlg==
# SIG # End signature block
