[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)][string]$CredentialPath
)

function main {
    Write-Log -Output "++++++++++++++++++++++++++++++++++++++++++++++++"
    Write-Log -Output "+ Starting Script ++++++++++++++++++++++++++++++"
    Write-Log -Output "++++++++++++++++++++++++++++++++++++++++++++++++"

    $ErrorActionPreference = 'Stop'

    try {
        ##################################################################
        # Global Variables ###############################################
        ##################################################################
        $pathBase = "\\ntnx-fs\uem\archives"
        $directories = Get-ChildItem $pathBase | Select-Object FullName

        ##################################################################
        # RESTFul Variables ##############################################
        ##################################################################
        $uri = "https://tjcprod.service-now.com/api/now/table/u_cmdb_ci_uem_archive_directory"

        # Eg. User name="admin", Password="admin" for this code sample.
        $creds = Import-Clixml -Path $CredentialPath
        $user = $creds.UserName
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($creds.Password)
        $pass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

        # Build auth header
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user, $pass)))

        # Set proper headers
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
        $headers.Add('Accept','application/json')
        $headers.Add('Content-Type','application/json')

        foreach ($directory in $directories) {
            try {
                $obj = Get-Content -Raw -Path ($directory.FullName + "\accessed.json") | ConvertFrom-Json

                #SNow -> name
                $user = $obj.user
                #SNow -> u_time_accessed
                $time = $obj.time
                #SNow -> u_full_file_path
                $path = $obj.path
                #SNow -> size_bytes
                $size = $obj.dirSize
                #SNow -> storage_type
                $storageType = "UEM Folder Archive"
                #SNow -> discovery_source
                $discoverySource = "Other Automated"

                if($user) {
                    $sysID = Get-Record -Param $user
        
                    if($sysID) {
                        Update-Record -sysID $sysID -Params @{
                            "u_time_accessed"=$time
                            "size_bytes"=$size
                            "discovery_source"=$discoverySource
                        } | Out-File activity.log -Append

                    } else {
                        Create-Record -Params @{
                            "name"=$user
                            "u_time_accessed"=$time
                            "u_full_file_path"=$path
                            "storage_type"=$storageType
                            "size_bytes"=$size
                            "discovery_source"=$discoverySource
                        } | Out-File .\activity.log -Append
                    }
                }
            } catch {
                Write-Log -Output ("[WARN] accessed.json file not found in " + $directory.FullName)
            }
        }
    } Catch {
        Write-Log -Output ("[ERROR] " + $($_.Exception.Message))
    }

    Write-Log -Output "++++++++++++++++++++++++++++++++++++++++++++++++"
    Write-Log -Output "+ Ending Script ++++++++++++++++++++++++++++++++"
    Write-Log -Output "++++++++++++++++++++++++++++++++++++++++++++++++"
}

function Get-Record {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)][String]$Param
	)
    
    # Specify endpoint uri
    $query = "?sysparm_query=name%3D" + $param
            

    # Specify HTTP method
    $method = "get"

    # Send HTTP request
    $response = Invoke-WebRequest -Headers $headers -Method $method -Uri ($uri + $query)

    # Return response
    ($response.Content | ConvertFrom-Json).result.sys_id
}

function Update-Record {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)][String]$sysID,
        [Parameter(Mandatory=$true)][PSCustomObject]$Params
    )

    # Specify HTTP method
    $method = "patch"

    # Specify request body
    $body = $Params | ConvertTo-Json

    # Send HTTP request
    $response = Invoke-WebRequest -Headers $headers -Method $method -Uri ($uri + "/" + $sysID) -Body $body

    # Print response
    Write-Log ("[INFO] " + ($response.Content | ConvertFrom-Json).result.sys_id + " record updated.")
}

function Create-Record {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)][PSCustomObject]$Params
    )

    # Specify HTTP method
    $method = "post"

    # Specify request body
    $body = $Params | ConvertTo-Json

    # Send HTTP request
    $response = Invoke-WebRequest -Headers $headers -Method $method -Uri $uri -Body $body

    # Print response
    Write-Log ("[INFO] " + ($response.Content | ConvertFrom-Json).result.sys_id + " record created.")
}

function Write-Log {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)][String]$Output
	)

    $time = (Get-Date).ToString()
    ("[" + $time + "] " + " " + $Output) | Out-File $PSScriptRoot\activity.log -Append
}

main

# SIG # Begin signature block
# MIIIeQYJKoZIhvcNAQcCoIIIajCCCGYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3559ZgnsXstOM0ZbrwJftiSj
# 6+agggXOMIIFyjCCBLKgAwIBAgITFQAAByMkUpCwipe3DwAAAAAHIzANBgkqhkiG
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
# CQQxFgQU8RY9GwVgYLasXRoiDhQo6BfKQJMwDQYJKoZIhvcNAQEBBQAEggEAD2lb
# rNc5IOZUnGVzfpHkbi3AF5oHW0ChRELYryL8/E6lTNMFMx5EtzCRLg5KPpyS0bHa
# DSeQf/DbVOe+nOfmhAlw6vveRhe8TizOX4s+5y6K3lzqwcCiBSZf+G6bY4Fr0ncb
# p6TDMj3lOln0SHzZ1foBti6Cvye1xf6syFIt4WF0K2y5H7a6fhm7hCsaOgl1Pimw
# vmeksM/SBB8NcTE3XPdyIWeXuU56Ej4HuSk0jkCFI14x5q5bohIqno08fI0aA+t+
# AgmDZp0yDwCiA8yd3SNcJfXUTYWwogNYdO0x2rAU7GpVMRtPfCO9GINYcw1qbHJc
# ckKRdPWucZxBN2/qwQ==
# SIG # End signature block
