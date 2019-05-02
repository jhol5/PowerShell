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

Send-MailMessage -SmtpServer 'smtp.tjc.edu' -to 'joshua.holcomb@tjc.edu' -from 'vdivcenter@tjc.edu' -Subject 'VDI Unmap'