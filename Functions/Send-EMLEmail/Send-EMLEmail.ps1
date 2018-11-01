function Send-EMLEmail {
	<#
		.SYNOPSIS
		This function is designed to send an EML file via SMTP relay.

		.DESCRIPTION
		This function is designed to send an EML file via SMTP relay. I took the original and modified it to be an actual PowerShell function to accept parameters.

		.EXAMPLE
			Send-EMLEmail -Server 'myserver.mydomain.com' -Port 25 -From 'myemail@mydomain.com' -To 'theiremail@theirdomain.com' -File 'C:\Path\To\EML\File\email.eml'

		.NOTES
			Original Author             : ser1zw
			Original Author email       : N/A
			Original URL				: https://gist.github.com/ser1zw/4366363
			Modified/Updated By			: Joshua Holcomb
			Modified/Updated email		: joshua.holcomb@tjc.edu
			Version                     : 1.1
			Dependencies                : 

			===Tested Against Environment====
			PowerShell Version          : 2.0, 5.1, 6.1

	#>

	[CmdletBinding()]
	Param
	(
		# The IP or hostname of the SMTP Server
		[Parameter(Mandatory=$true)]
		[string]$Server,
		# The port the SMTP Server uses
		[Parameter(Mandatory=$false)]
		[string]$Port = '25',
		# The email address the email is from.
		[Parameter(Mandatory=$true)]
		[string]$From,
		# The email address the email is to.
		[Parameter(Mandatory=$true)]
		[string]$To,
		# The file path to the EML file
		[Parameter(Mandatory=$true)]
		[string]$File
	)

	$encoding = New-Object System.Text.AsciiEncoding

	Function SendCommand($stream, $writer, $command) {
	# Send command
		foreach ($line in $command) {
			$writer.WriteLine($line)
		}
		$writer.Flush()
		Start-Sleep -m 100

		# Get response
		$buff = New-Object System.Byte[] 4096
		$output = ""
		while ($True) {
			$size = $stream.Read($buff, 0, $buff.Length)
			if ($size -gt 0) {
				$output += $encoding.GetString($buff, 0, $size)
			}
			if (($size -lt $buff.Length) -or ($size -le 0)) {
				break
			}
		}

		if ([int]::Parse($output[0]) -gt 3) {
			throw $output
		}
		$output
	}

	Function SendMessage($Server, $Port, $From, $To, $File) {
		try {
			$socket = New-Object System.Net.Sockets.TcpClient($Server, $Port)
			$stream = $socket.GetStream()
			$stream.ReadTimeout = 1000
			$writer = New-Object System.IO.StreamWriter $stream

			$endOfMessage = "`r`n."

			SendCommand $stream $writer ("EHLO " + $Server)
			SendCommand $stream $writer ("MAIL FROM: <" + $From + ">")
			SendCommand $stream $writer ("RCPT TO: <" + $To + ">")
			SendCommand $stream $writer "DATA"
			$content = (Get-Content $File) -join "`r`n"
			SendCommand $stream $writer ($content + $endOfMessage)
			SendCommand $stream $writer "QUIT"
		}
		catch [Exception] {
			Write-Host $Error[0]
		}
		finally {
			if ($writer -ne $Null) {
				$writer.Close()
			}
			if ($socket -ne $Null) {
				$socket.Close()
			}
		}
	}

	Function Main($Server, $Port, $From, $To, $File) {
		SendMessage $Server $Port $From $To $File
	}
	
	Main | Out-Null
}

# SIG # Begin signature block
# MIIIeQYJKoZIhvcNAQcCoIIIajCCCGYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUI44Em2B1n0yw39jePuJsTk6+
# sjygggXOMIIFyjCCBLKgAwIBAgITFQAAByMkUpCwipe3DwAAAAAHIzANBgkqhkiG
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
# CQQxFgQUx9hPuVuopDcMw9z+Zo64G0kiqsAwDQYJKoZIhvcNAQEBBQAEggEATtif
# 6lxf9TjWwC3AEAE6qOv5EVgFImcLml/LhqX2Poig4iDLur77BOgBi/F0IiN52ESL
# S6y2r5PrzeVrLnwHrym3KDa4Nqe/AogaWnc7uMdLyws6/RAtwkB8W2adzk12u8+H
# o9P0HIcVzBKEyqAolHif+PjdNh1YUEh/+OW5vLyBbYEGxdOFcyonUT8aW+qHN3zQ
# 6Npb6iKIvjMNO8txXwbrYDAaK6wnBwPk/17pi+o5a8EFeNz637ygkq2eKAMwfx2m
# wYwRD2ETqzVillhvH8ZXQXkPcG94aloFpqdWFCNfIBTPZEvxgdqLszWLgaSWoWSA
# qN2lrr/8oxVi/Tb6Yg==
# SIG # End signature block
