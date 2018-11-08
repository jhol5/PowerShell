Send-MailMessage -SmtpServer 'smtp.tjc.edu' -to 'joshua.holcomb@tjc.edu' -from 'vdivcenter@tjc.edu' -Subject 'VDI Unmap' -body 'Started'

Date
Write-Host `n
Write-Host -NoNewline ----------------------- Starting -----------------------
Write-Host `n

Import-Module VMware.VimAutomation.Core
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Scope Session -Confirm:$false
Set-PowerCLIConfiguration -WebOperationTimeoutSeconds -1 -Scope Session -Confirm:$false
$vmhost = 'vdiesx01.ad.tjc.local'
Connect-VIServer -Server $vmhost 

$datastores = Get-Datastore |? {$_.Name -Like "*VDI*"}


$esxcli = Get-EsxCli -Server $global:DefaultVIServer -WarningAction Ignore

ForEach ($datastore in $datastores) {
    Write-Host $datastore.Name unmap started.
    $esxcli.storage.vmfs.unmap.Invoke(200,$datastore.Name,$null) | Out-Null
    Write-Host $datastore.Name has been unmapped.
}

Disconnect-VIServer -Confirm:$false

Write-Host `n
Write-Host -NoNewline -------------------------- End -------------------------
Write-Host `n

Send-MailMessage -SmtpServer 'smtp.tjc.edu' -to 'joshua.holcomb@tjc.edu' -from 'vdivcenter@tjc.edu' -Subject 'VDI Unmap' -body 'Finished'

# SIG # Begin signature block
# MIIIeQYJKoZIhvcNAQcCoIIIajCCCGYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUzXsSUXiuBujfjNbBWMRmal/e
# MMegggXOMIIFyjCCBLKgAwIBAgITFQAAByMkUpCwipe3DwAAAAAHIzANBgkqhkiG
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
# CQQxFgQUyzEN4UM9XEky9NPZmDcLNuKlvpUwDQYJKoZIhvcNAQEBBQAEggEABD6L
# UlXkDEgbNvFrEJGyHpBSE6k7B8YN7WAiolr2c9ewHAswRa2IbTiJEuffQbprdTyY
# Fbt5MvOsXBKBAN23AUaIPPUrVR4LS3/Xlznm1btop80vb1kkhy2PXEwsWFisNbhZ
# aB/iGyiw/l6pWw71ndM/VyGPbxxrEpYovNs9e/A/MXHyJgxw8qcMH+b7lUJ29JWL
# Pquuk68mCnvwloGKgL4JTI7YAcFPf6lqaeJfyP7ExIYJVISTEna4+s6wjGdLeYxk
# aGeBQL0xCR63TWYaWIo/Sc7x8n6y4r4w+dIndhGV6/jCXumfAFbR6Cald3lMpYIz
# Y4uqpqdgTtvIXtaFwQ==
# SIG # End signature block
