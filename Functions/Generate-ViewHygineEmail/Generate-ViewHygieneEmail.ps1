function Generate-ViewHygieneEmail {

    [CmdletBinding()]
	Param(
        [Parameter(Mandatory=$true)]
            [String]$HorizonCredStore,
        [Parameter(Mandatory=$true)]
            [String]$SMTPServer,
        [Parameter(Mandatory=$true)]
            [String]$FromEmail,
        [Parameter(Mandatory=$true)]
            [Array]$To,
        [Parameter(Mandatory=$true)]
            [Array]$CC,
        [Parameter(Mandatory=$true)]
            [Array]$BCC,
        [Parameter(Mandatory=$true)]
            [String]$Subject
	)

<#
	.SYNOPSIS
	Generates a Email report of the problem VM's in the View Environment.

	.DESCRIPTION
	The Add-HVDesktop adds virtual machines to already exiting pools by using view API service object(hvServer) of Connect-HVServer cmdlet. VMs can be added to any of unmanaged manual, managed manual or Specified name. This advanced function do basic checks for pool and view API service connection existance, hvServer object is bound to specific connection server.

	.EXAMPLE
		Generate-ViewHygieneEmail -HorizonCredStore -SMTPServer -FromEmail -To -CC -BCC -Subject
		Sends an email to the recipients specified in the script.

	.NOTES
		Author                      : Joshua Holcomb.
		Author email                : joshua.holcomb@tjc.edu
		Version                     : 1
		Dependencies                : Make sure you update the location of the Get-HVProblemMachines script, and update the other variables to fit your environment.

		===Tested Against Environment====
		Horizon View Server Version : 7.4.0
		PowerCLI Version            : PowerCLI 6.5
		PowerShell Version          : 5.0
#>

##################################################################
#            Variables                                           #
##################################################################
    $ProblemVMs = Get-HVProblemMachines -HorizonCredStore $HorizonCredStore
# End Variables

##################################################################
#            Main                                                #
##################################################################
    $Body = '<p>Number of problem VMs: ' + ($ProblemVMs.Count - 1).ToString() + '</p>'
    $Body = $Body + '<table border="1" style="border-collapse: collapse;"><tr><th style="padding-left:20px; padding-right:20px;">VM Name</th><th style="padding-left:20px; padding-right:20px;">VM State</th></tr>'
    
    foreach ($ProblemVM in $ProblemVMs) {
        if ($ProblemVM.Base.Name -ne $null ) {
            $Body = $Body + '<tr>'
            $Body = $Body + '<td style="padding-left:20px; padding-right:20px;">' + $ProblemVM.Base.Name + '</td>'
            $Body = $Body + '<td style="padding-left:20px; padding-right:20px;">' + $ProblemVM.Base.BasicState + '</td>'
            $Body = $Body + '</tr>'
        }
    }

    $Body = $Body + '</table>'

    Send-MailMessage -SmtpServer $SMTPServer -From $FromEmail -To $To -Subject $Subject -BodyAsHtml $Body

# End Main
}

# SIG # Begin signature block
# MIIIeQYJKoZIhvcNAQcCoIIIajCCCGYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUG2rtdFX+602sJJ3U9Ed28NHR
# N/OgggXOMIIFyjCCBLKgAwIBAgITFQAAByMkUpCwipe3DwAAAAAHIzANBgkqhkiG
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
# CQQxFgQU7lAMhBZ4duZ+Ufk8p6rbXpog4IIwDQYJKoZIhvcNAQEBBQAEggEAApjY
# 87kHeDgbvcnmwHIeIeT1oDL+mfQX2imZfKLW67zKHsFdopbXpMKq6JkvEkWKQQ0J
# 9/uBdZpTchaRlSqfNEeRRz5kCdstjtB/56Xq1U09Ov6orE7kI9N7brFIWPUmpNe+
# KPupGYn6GVnDp9Q2GgIqa3W/sk+B+3i4uFR+MaMrZTAnQyW07Bf0IhSO8MWqHUqB
# Xdjc2lc+15AtzIVVPBL9/JYDD4mouAN6mz6csS6gkXZ/qIm+nZJ0Lo53TN0apcE4
# AfT8b/ofcIM0PgPmmqhAzoPc2L5rrrQyihl+jgejEWmKqv8yimyqfZ+RiECiXDvQ
# 2HALCoVR641ne2pA2Q==
# SIG # End signature block
